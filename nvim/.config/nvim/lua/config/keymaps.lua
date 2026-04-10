-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here

-- =============================================================================
-- RPST PHPUnit (リモート実行)
-- =============================================================================
local phpunit = require("utils.phpunit")
vim.keymap.set("n", "<leader>tr", phpunit.run_remote, { desc = "RPST PHPUnit (Remote)" })

-- =============================================================================
-- リモートサーバーへのファイル転送
-- =============================================================================
local transport = require("utils.transport")
vim.keymap.set("n", "<leader>rt", transport.rpst_v2, { desc = "Transfer to Remote (rpst-v2)" })
vim.keymap.set("x", "<leader>p", [["_dP]], { desc = "Paste without yanking (greatest keymap)" })
