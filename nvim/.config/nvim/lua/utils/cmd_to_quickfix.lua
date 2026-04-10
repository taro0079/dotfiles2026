local M = {}

function M.register_from_external_command(command)
  local result = vim.fn.system(command)
  local lines = vim.fn.split(result, "\n")
  local items = {}

  for _, line in ipairs(lines) do
    if line ~= "" then
      table.insert(items, { filename = line })
    end
  end

  vim.fn.setqflist({}, "r", { title = "External Command Results", items = items })
  vim.cmd("copen")
end

function M.setup()
  vim.api.nvim_create_user_command("CmdQf", function(opts)
    M.register_from_external_command(opts.args)
  end, { desc = "コマンドで出力されたファイルリストをquick fixに追加する", nargs = "+" })
end

return M
