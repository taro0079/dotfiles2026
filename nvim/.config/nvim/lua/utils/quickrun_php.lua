local M = {}
function M.getRegion()
  local s_pos = vim.fn.getpos("'<")
  local e_pos = vim.fn.getpos("'>")

  local lines = vim.fn.getregion(s_pos, e_pos)
  return table.concat(lines, "\n")
end

function M.exe()
  local lines = M.getRegion()
  local obj = vim.system({ "php", "-r", lines }, { text = true }):wait()
  local result = obj.stdout ~= "" and obj.stdout or obj.stdout or ""

  local buffer = vim.api.nvim_create_buf(false, true)
  vim.api.nvim_buf_set_lines(buffer, 0, -1, false, vim.split(result, "\n"))

  vim.api.nvim_command("vsplit")
  vim.api.nvim_win_set_buf(0, buffer)

  vim.api.nvim_set_option_value("buftype", "nofile", { buf = buffer })
  vim.api.nvim_set_option_value("bufhidden", "hide", { buf = buffer })
end

function M.setup()
  vim.api.nvim_create_user_command("Taro", function()
    M.exe()
  end, { desc = "test", range = true })
end

return M
