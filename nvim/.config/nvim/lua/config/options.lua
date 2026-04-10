-- Options are automatically loaded before lazy.nvim startup
-- Default options that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua
-- Add any additional options here

-- PHP: phpactorの代わりにintelephenseを使用
vim.g.lazyvim_php_lsp = "intelephense"
-- vim.g.clipboard = {
--   name = "OSC 52",
--   copy = {
--     ["+"] = require("vim.ui.clipboard.osc52").copy("+"),
--     ["*"] = require("vim.ui.clipboard.osc52").copy("*"),
--   },
--   -- paste = {
--   --   ["+"] = require("vim.ui.clipboard.osc52").paste("+"),
--   --   ["*"] = require("vim.ui.clipboard.osc52").paste("*"),
--   -- },
-- }
vim.opt.clipboard = "unnamedplus"
