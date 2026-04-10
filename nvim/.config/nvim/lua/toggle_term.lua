local term_buf = nil
local term_win = nil

local function toggle_bottom_terminal()
  if term_win and vim.api.nvim_win_is_valid(term_win) then
    vim.api.nvim_win_close(term_win, true)
    term_win = nil
    return
  end

  local height = math.floor(vim.o.lines * 0.3)
  vim.cmd("botright split")
  vim.cmd("resize " .. height)

  if term_buf and vim.api.nvim_buf_is_valid(term_buf) then
    vim.api.nvim_win_set_buf(0, term_buf)
  else
    vim.cmd("terminal")
    term_buf = vim.api.nvim_get_current_buf()
  end

  term_win = vim.api.nvim_get_current_win()
  vim.cmd("startinsert")
end

vim.keymap.set(
  { "n", "t" },
  "<C-t>",
  toggle_bottom_terminal,
  { silent = true, desc = "Terminal: Toggle terminal at bottom" }
)
