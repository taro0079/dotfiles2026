-- conform.nvim設定
-- php-cs-fixerで除外設定を正しく動作させるための設定
return {
  {
    "stevearc/conform.nvim",
    opts = {
      log_level = vim.log.levels.DEBUG,
      formatters_by_ft = {
        yaml = { "yamlfmt" },
        yml = { "yamlfmt" },
        php = {},
      },
    },
  },
  -- PHPファイルでautoformatを無効化（LazyVim方式）
  {
    "nvim-lspconfig",
    opts = function()
      vim.api.nvim_create_autocmd("FileType", {
        pattern = "php",
        callback = function()
          vim.b.autoformat = false
        end,
      })
    end,
  },
}
