local M = {}

function M.run()
  vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<ESC>", true, false, true), "x", true)
  local start_line = vim.fn.getpos("'<")[2]
  local end_line = vim.fn.getpos("'>")[2]
  local relative_path = vim.fn.fnamemodify(vim.api.nvim_buf_get_name(0), ":.")
  local result = string.format("%s:%d-%d", relative_path, start_line, end_line)

  vim.fn.setreg("+", result)
end

function M.setup()
  vim.api.nvim_create_user_command("PathCopy", function()
    M.run()
  end, { desc = "相対パスをクリップボードに保存する", range = true })
end

return M
