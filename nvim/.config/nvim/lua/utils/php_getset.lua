-- =============================================================================
-- PHP getter/setter 生成ツール
--
-- :PhpGetterSetter を実行すると、カーソル位置のクラス（無ければファイル先頭の
-- クラス）のプロパティ一覧がフローティングウィンドウに表示される。
-- Space/Tab で複数選択し、Enter で選んだプロパティの getter/setter を
-- クラス末尾に生成する。
-- =============================================================================
local M = {}

-- プロパティ宣言に現れる「修飾子」ノード
local MODIFIER_TYPES = {
  visibility_modifier = true,
  static_modifier = true,
  readonly_modifier = true,
  final_modifier = true,
  abstract_modifier = true,
  var_modifier = true,
}

-- getter/setter を生成できる「クラス的」ノード
local CLASS_TYPES = {
  class_declaration = true,
  trait_declaration = true,
  enum_declaration = true,
}

-- snake_case / lowerCamel を UpperCamel（StudlyCase）へ
-- 例: user_id -> UserId, name -> Name
local function studly(name)
  local s = name:gsub("_(%w)", function(c)
    return c:upper()
  end)
  return s:sub(1, 1):upper() .. s:sub(2)
end

-- ツリーを再帰的に辿ってクラス的ノードを集める
local function find_classes(node, acc)
  for child in node:iter_children() do
    if CLASS_TYPES[child:type()] then
      table.insert(acc, child)
    end
    find_classes(child, acc)
  end
end

-- カーソルを含む最も内側のクラスを返す。無ければ最初に見つかったクラス。
local function get_class_node(root, cursor_row)
  local classes = {}
  find_classes(root, classes)
  if #classes == 0 then
    return nil
  end

  local best
  for _, c in ipairs(classes) do
    local sr, _, er = c:range()
    if cursor_row >= sr and cursor_row <= er then
      if not best then
        best = c
      else
        -- より内側（範囲が狭い）のものを優先
        local bsr, _, ber = best:range()
        if (er - sr) < (ber - bsr) then
          best = c
        end
      end
    end
  end
  return best or classes[1]
end

-- クラス本体（declaration_list）を返す
local function get_body(class_node)
  for child in class_node:iter_children() do
    if child:type() == "declaration_list" then
      return child
    end
  end
  return nil
end

-- クラス本体に既に定義されているメソッド名の集合を返す
-- （getFoo が既にあるなら再生成しないため）
local function existing_methods(body, bufnr)
  local set = {}
  for decl in body:iter_children() do
    if decl:type() == "method_declaration" then
      for mc in decl:iter_children() do
        if mc:type() == "name" then
          set[vim.treesitter.get_node_text(mc, bufnr)] = true
        end
      end
    end
  end
  return set
end

-- クラス本体からプロパティ情報を集める
-- 返り値: { { name = "name", type = "string"|nil, modifiers = "private" }, ... }
local function collect_properties(body, bufnr)
  local props = {}
  for decl in body:iter_children() do
    if decl:type() == "property_declaration" then
      local modifiers = {}
      local type_text = nil
      local names = {}

      for c in decl:iter_children() do
        local t = c:type()
        if MODIFIER_TYPES[t] then
          table.insert(modifiers, vim.treesitter.get_node_text(c, bufnr))
        elseif t == "property_element" then
          for pc in c:iter_children() do
            if pc:type() == "variable_name" then
              local nm = vim.treesitter.get_node_text(pc, bufnr):gsub("^%$", "")
              table.insert(names, nm)
            end
          end
        elseif t == "variable_name" then
          -- 文法バージョンによっては property_element を挟まないことがある
          local nm = vim.treesitter.get_node_text(c, bufnr):gsub("^%$", "")
          table.insert(names, nm)
        elseif t ~= ";" and t ~= "," and t ~= "comment" then
          -- 修飾子でもプロパティ本体でもない = 型ノード
          type_text = vim.treesitter.get_node_text(c, bufnr)
        end
      end

      -- private $a, $b; のように 1 宣言で複数プロパティのケースに対応
      for _, nm in ipairs(names) do
        table.insert(props, {
          name = nm,
          type = type_text,
          modifiers = table.concat(modifiers, " "),
        })
      end
    end
  end
  return props
end

-- 1 プロパティ分の getter/setter の行を生成
local function build_methods(p, method_indent, sw, existing)
  local body_indent = method_indent .. string.rep(" ", sw)
  local Name = studly(p.name)
  local lines = {}

  -- getter
  if not existing["get" .. Name] then
    local ret = p.type and (": " .. p.type) or ""
    vim.list_extend(lines, {
      "",
      method_indent .. "public function get" .. Name .. "()" .. ret,
      method_indent .. "{",
      body_indent .. "return $this->" .. p.name .. ";",
      method_indent .. "}",
    })
  end

  -- setter（fluent: $this を返す）
  if not existing["set" .. Name] then
    local param_type = p.type and (p.type .. " ") or ""
    vim.list_extend(lines, {
      "",
      method_indent .. "public function set" .. Name .. "(" .. param_type .. "$" .. p.name .. "): self",
      method_indent .. "{",
      body_indent .. "$this->" .. p.name .. " = $" .. p.name .. ";",
      "",
      body_indent .. "return $this;",
      method_indent .. "}",
    })
  end

  return lines
end

-- 選択されたプロパティの getter/setter をクラス末尾（閉じ } の直前）へ挿入
local function insert_methods(bufnr, class_node, chosen)
  local body = get_body(class_node)
  if not body then
    vim.notify("クラス本体が見つかりません", vim.log.levels.ERROR)
    return
  end
  local existing = existing_methods(body, bufnr)

  -- インデント（クラスの字下げ + shiftwidth）
  local class_sr = class_node:range()
  local class_line = vim.api.nvim_buf_get_lines(bufnr, class_sr, class_sr + 1, false)[1] or ""
  local class_indent = class_line:match("^%s*") or ""
  local sw = vim.bo[bufnr].shiftwidth
  if sw == 0 then
    sw = 4
  end
  local method_indent = class_indent .. string.rep(" ", sw)

  local out = {}
  local generated = 0
  for _, p in ipairs(chosen) do
    local methods = build_methods(p, method_indent, sw, existing)
    if #methods > 0 then
      generated = generated + 1
    end
    vim.list_extend(out, methods)
  end

  if #out == 0 then
    vim.notify("選択したプロパティの getter/setter は既に存在します", vim.log.levels.INFO)
    return
  end

  -- 閉じ } の行の直前に挿入
  local _, _, end_row = body:range()
  vim.api.nvim_buf_set_lines(bufnr, end_row, end_row, false, out)
  vim.notify(string.format("%d 件のプロパティに getter/setter を生成しました", generated), vim.log.levels.INFO)
end

-- 複数選択ピッカー（フローティングウィンドウ）
local function open_picker(bufnr, class_node, props)
  local selected = {}
  local labels = {}
  for i, p in ipairs(props) do
    selected[i] = false
    labels[i] = string.format(
      "%s%s$%s",
      p.modifiers ~= "" and (p.modifiers .. " ") or "",
      p.type and (p.type .. " ") or "",
      p.name
    )
  end

  local lines = {}
  for i, label in ipairs(labels) do
    lines[i] = "[ ] " .. label
  end

  local width = 40
  for _, l in ipairs(lines) do
    width = math.max(width, #l + 2)
  end
  local height = math.min(#lines, 20)

  local pbuf = vim.api.nvim_create_buf(false, true)
  vim.api.nvim_buf_set_lines(pbuf, 0, -1, false, lines)
  vim.bo[pbuf].modifiable = false
  vim.bo[pbuf].filetype = "php_getset_picker"

  local win = vim.api.nvim_open_win(pbuf, true, {
    relative = "editor",
    width = width,
    height = height,
    row = math.floor((vim.o.lines - height) / 2 - 1),
    col = math.floor((vim.o.columns - width) / 2),
    style = "minimal",
    border = "rounded",
    title = " getter/setter 生成  (Space:選択  a:全選択  Enter:確定  q:中止) ",
    title_pos = "center",
  })

  local function render()
    vim.bo[pbuf].modifiable = true
    for i = 1, #props do
      local mark = selected[i] and "[x] " or "[ ] "
      vim.api.nvim_buf_set_lines(pbuf, i - 1, i, false, { mark .. labels[i] })
    end
    vim.bo[pbuf].modifiable = false
  end

  local function toggle()
    local row = vim.api.nvim_win_get_cursor(win)[1]
    selected[row] = not selected[row]
    render()
  end

  local function toggle_all()
    local any_unselected = false
    for i = 1, #props do
      if not selected[i] then
        any_unselected = true
        break
      end
    end
    for i = 1, #props do
      selected[i] = any_unselected
    end
    render()
  end

  local function close()
    if vim.api.nvim_win_is_valid(win) then
      vim.api.nvim_win_close(win, true)
    end
  end

  local function confirm()
    local chosen = {}
    for i, p in ipairs(props) do
      if selected[i] then
        table.insert(chosen, p)
      end
    end
    close()
    if #chosen == 0 then
      vim.notify("何も選択されていません", vim.log.levels.INFO)
      return
    end
    insert_methods(bufnr, class_node, chosen)
  end

  local opts = { buffer = pbuf, nowait = true, silent = true }
  vim.keymap.set("n", "<Space>", toggle, opts)
  vim.keymap.set("n", "<Tab>", toggle, opts)
  vim.keymap.set("n", "a", toggle_all, opts)
  vim.keymap.set("n", "<CR>", confirm, opts)
  vim.keymap.set("n", "q", close, opts)
  vim.keymap.set("n", "<Esc>", close, opts)
end

-- エントリポイント
function M.generate()
  local bufnr = vim.api.nvim_get_current_buf()
  if vim.bo[bufnr].filetype ~= "php" then
    vim.notify("PHP ファイルではありません", vim.log.levels.WARN)
    return
  end

  local ok, parser = pcall(vim.treesitter.get_parser, bufnr, "php")
  if not ok or not parser then
    vim.notify("PHP の treesitter parser が見つかりません", vim.log.levels.ERROR)
    return
  end

  local root = parser:parse()[1]:root()
  local cursor_row = vim.api.nvim_win_get_cursor(0)[1] - 1
  local class_node = get_class_node(root, cursor_row)
  if not class_node then
    vim.notify("クラスが見つかりません", vim.log.levels.WARN)
    return
  end

  local body = get_body(class_node)
  if not body then
    vim.notify("クラス本体が見つかりません", vim.log.levels.WARN)
    return
  end

  local props = collect_properties(body, bufnr)
  if #props == 0 then
    vim.notify("プロパティが見つかりません", vim.log.levels.WARN)
    return
  end

  open_picker(bufnr, class_node, props)
end

function M.setup()
  vim.api.nvim_create_user_command("PhpGetterSetter", function()
    M.generate()
  end, { desc = "PHP: 選択したプロパティの getter/setter を生成" })

  vim.keymap.set("n", "<leader>mgs", function()
    M.generate()
  end, { desc = "PHP: getter/setter を生成" })
end

return M
