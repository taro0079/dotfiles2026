-- Autocmds are automatically loaded on the VeryLazy event
-- Default autocmds that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/autocmds.lua
--
-- Add any additional autocmds here
-- with `vim.api.nvim_create_autocmd`
--
-- Or remove existing autocmds by their group name (which is prefixed with `lazyvim_` for the defaults)
-- e.g. vim.api.nvim_del_augroup_by_name("lazyvim_wrap_spell")

-- =============================================================================
-- カスタムコマンドの登録
-- =============================================================================
-- require("utils.phpunit").setup()
require("utils.transport").setup()
require("utils.cmd_to_quickfix").setup()

-- =============================================================================
-- rpst-v2 ファイル保存時に自動転送
-- =============================================================================
local transport = require("utils.transport")
vim.api.nvim_create_autocmd("BufWritePost", {
  pattern = "*/rpst-v2/*",
  callback = function()
    transport.rpst_v2()
  end,
  desc = "rpst-v2 ファイル保存時に自動転送",
})
vim.api.nvim_create_autocmd("BufWritePost", {
  pattern = "*/rpst-api/*",
  callback = function()
    transport.rpst_api()
  end,
  desc = "rpst-api ファイル保存時に自動転送",
})

-- =============================================================================
-- PHP用のインデント設定
-- =============================================================================
vim.api.nvim_create_autocmd("FileType", {
  pattern = "php",
  callback = function()
    vim.opt_local.expandtab = true -- タブをスペースに変換
    vim.opt_local.shiftwidth = 4 -- インデント幅
    vim.opt_local.tabstop = 4 -- タブ幅
    vim.opt_local.softtabstop = 4 -- ソフトタブ幅
  end,
})

-- =============================================================================
-- YAML用のインデント設定
-- =============================================================================
vim.api.nvim_create_autocmd("FileType", {
  pattern = { "yaml", "yml" },
  callback = function()
    vim.opt_local.expandtab = true
    vim.opt_local.shiftwidth = 4
    vim.opt_local.tabstop = 4
    vim.opt_local.softtabstop = 4
  end,
})
