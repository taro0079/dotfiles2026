local lib = require("neotest.lib")
local M = {}

local QUERY = [[
(class_declaration
    name: (name) @namespace.name
) @namespace.definition

(method_declaration
    name: (name) @test.name
) @test.definition
]]

local function build_position(file_path, source, captured_nodes)
  if captured_nodes["namespace.name"] then
    local name = vim.treesitter.get_node_text(captured_nodes["namespace.name"], source)
    local definition = captured_nodes["namespace.definition"]
    return {
      type = "namespace",
      path = file_path,
      name = name,
      range = { definition:range() },
    }
  end

  if captured_nodes["test.name"] then
    local name_node = captured_nodes["test.name"]
    local def_node = captured_nodes["test.definition"]
    local name = vim.treesitter.get_node_text(name_node, source)

    if name:match("^test") then
      return {
        type = "test",
        path = file_path,
        name = name,
        range = { def_node:range() },
      }
    end

    -- @test アノテーションをソーステキストで検索
    local start_row = def_node:range()
    if start_row > 0 then
      local lines = vim.split(source, "\n")
      for row = start_row - 1, math.max(0, start_row - 50), -1 do
        local line = lines[row + 1] or ""
        if line:match("@test") then
          return {
            type = "test",
            path = file_path,
            name = name,
            range = { def_node:range() },
          }
        end
        -- コメント行・空白行でなければ検索を打ち切る
        if not line:match("^%s*[%*/%#]") and not line:match("^%s*$") then
          break
        end
      end
    end

    return nil
  end
end

M.discover_positions = function(path)
  return lib.treesitter.parse_positions(path, QUERY, {
    nested_tests = false,
    build_position = build_position,
  })
end

M.build_spec = function(args)
  local pos = args.tree:data()
  local root = args.tree:root():data().path

  local binary = root .. "/vendor/bin/phpunit"
  if vim.fn.executable(binary) == 0 then
    binary = "phpunit"
  end

  local config_file
  local config_candidates = {
    "phpunit.xml",
    "phpunit.xml.dist",
    "tests/app/phpunit/v9/phpunit.xml",
    "tests/app/phpunit/v9/phpunit.xml.dist",
  }
  for _, name in ipairs(config_candidates) do
    local candidate = root .. "/" .. name
    if vim.fn.filereadable(candidate) == 1 then
      config_file = candidate
      break
    end
  end

  local report = vim.fn.tempname() .. ".xml"

  local cmd = { binary }
  if config_file then
    vim.list_extend(cmd, { "--configuration", config_file })
  end
  vim.list_extend(cmd, { "--log-junit", report })

  if pos.type == "dir" then
    table.insert(cmd, pos.path)
  elseif pos.type == "file" then
    table.insert(cmd, pos.path)
  elseif pos.type == "namespace" then
    vim.list_extend(cmd, { "--filter", pos.name, pos.path })
  elseif pos.type == "test" then
    vim.list_extend(cmd, { "--filter", string.format("^%s(::.+)?$", pos.name), pos.path })
  end

  return {
    command = cmd,
    context = {
      position_id = pos.id,
      file = pos.path,
      report = report,
    },
  }
end

return M
