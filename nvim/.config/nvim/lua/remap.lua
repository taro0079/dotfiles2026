vim.g.mapleader = " "
-- local wk = require("which-key")
-- wk.add({
--   { "<leader>pv", vim.cmd.Ex, desc = "file explorer", mode = "n" },
-- })
vim.keymap.set("n", "<leader>pv", vim.cmd.Ex, { desc = "File Exporer" })
vim.keymap.set("v", "J", ":m '>+1<CR>gv=gv")
vim.keymap.set("v", "K", ":m '<-2<CR>gv=gv")
vim.keymap.set("n", "J", "mzJ`z")
vim.keymap.set("n", "<C-d>", "<C-d>zz")
vim.keymap.set("n", "<C-u>", "<C-u>zz")
vim.keymap.set("n", "n", "nzzzv")
vim.keymap.set("n", "N", "Nzzzv")
vim.keymap.set("n", "=ap", "ma=ap`a", { desc = "Format Paragraph Without Moving Cursor" })
vim.keymap.set("n", "<leader>zig", "<cmd>LspRestart<cr>", { desc = "Restart LSP" })
-- greatest remap ever
vim.keymap.set("x", "<leader>p", [["_dP]], { desc = "Paste Without Overriding Register" })
-- next greatest remap ever : asbjornHaland
vim.keymap.set({ "n", "v" }, "<leader>y", [["+y]], { desc = "Yank to System Clipboard" })
vim.keymap.set("n", "<leader>Y", [["+Y]], { desc = "Yank line to system clipboard" })
vim.keymap.set({ "n", "v" }, "<leader>d", '"_d', { desc = "Delete in Blackhole Register" })
-- This is going to get me cancelled
vim.keymap.set("i", "<C-c>", "<Esc>")
vim.keymap.set("n", "<leader><leader>", function()
  vim.cmd("so")
end, { desc = "Source Current File" })
-- vim.keymap.set("i", "(;", "(<CR>);<C-c>O<tab><Esc>zzi")
-- vim.keymap.set("i", "{;", "{<CR>};<C-c>O<tab><Esc>zzi")
-- vim.keymap.set("i", "{,", "{<CR>},<C-c>O<tab><Esc>zzi")
-- vim.keymap.set("i", "[;", "[<CR>];<C-c>O<tab><Esc>zzi")
-- vim.keymap.set("i", "[,", "[<CR>],<C-c>O<tab><Esc>zzi")

vim.keymap.set("t", "<ESC><ESC>", [[<C-\><C-n>]], { noremap = true, silent = true })
