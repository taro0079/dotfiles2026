local M = {}

function M.get_php_variable_under_cursor()
  local bufnr = vim.api.nvim_get_current_buf()
  -- カーソル位置のノードを取得
  local node = vim.treesitter.get_node()

  if not node then
    return nil
  end

  -- PHPの変数やプロパティアクセスを含む親ノードを探す
  -- variable: $hoge
  -- member_call_expression: $this->method()
  -- member_access_expression: $this->property
  local target_types = {
    variable = true,
    variable_name = true,
    member_access_expression = true,
    member_call_expression = true,
    array_creation_expression = true,
  }

  while node do
    if target_types[node:type()] then
      break
    end
    node = node:parent()
  end

  if not node then
    return nil
  end

  -- ノードの範囲（行・列）を取得してテキストを抽出
  return vim.treesitter.get_node_text(node, bufnr)
end

function M.insert_dump(mode, debug_command)
  local text = ""

  if mode == "v" then
    local saved_reg = vim.fn.getreg("v")
    vim.cmd('noau normal! "vy')
    text = vim.fn.getreg("v")
    vim.fn.setreg("v", saved_reg)
  else
    text = M.get_php_variable_under_cursor()
    if text == "" then
      vim.notify("カーソル下に変数がありません", vim.log.levels.WARN)
      return
    end
  end

  local debug_str = string.format("%s(%s);", debug_command, text)

  local current_line = vim.api.nvim_get_current_line()
  local indent = string.match(current_line, "^%s*") or ""

  local row = vim.api.nvim_win_get_cursor(0)[1]
  vim.api.nvim_buf_set_lines(0, row, row, false, { indent .. debug_str })
  vim.api.nvim_win_set_cursor(0, { row + 1, #(indent .. debug_str) })
end

vim.keymap.set("n", "<leader>mvd", function()
  M.insert_dump("n", "var_dump")
end, { desc = "Insert var_dump for cursor word" })

vim.keymap.set("v", "<leader>mvd", function()
  M.insert_dump("v", "var_dump")
end, { desc = "Insert var_dump for cursor word" })

vim.keymap.set("n", "<leader>mdd", function()
  M.insert_dump("n", "ddh")
end, { desc = "Insert ddh for cursor word" })

vim.keymap.set("v", "<leader>mdd", function()
  M.insert_dump("v", "ddh")
end, { desc = "Insert ddh for cursor word" })
return M
