return {
  "stevearc/conform.nvim",
  opts = {
    log_level = vim.log.levels.TRACE,
  },

  config = function()
    require("conform").setup({
      format_on_save = {
        timeout_ms = 10000,
        lsp_format = "fallback",
      },
      log_level = vim.log.levels.TRACE,
      formatters_by_ft = {
        c = { "clang-format" },
        cpp = { "clang-format" },
        lua = { "stylua" },
        go = { "gofmt" },
        python = { "ruff_fix", "ruff_format" },
        ruby = { "rubocop" },
        javascript = { "prettier" },
        typescript = { "prettier" },
        elixir = { "mix" },
        php = { "php_cs_fixer" },
        html = { "htmlbeautifier" },
        eruby = { "erb_format" },
        yaml = { "yamlfmt" },
        yml = { "yamlfmt" },
        astro = { "prettier" },
      },
      formatters = {
        ["clang-format"] = {
          prepend_args = { "-style=file", "-fallback-style=LLVM" },
        },
      },
    })

    vim.keymap.set("n", "<leader>f", function()
      require("conform").format({ bufnr = 0 })
    end, { desc = "Conform: format code" })
  end,
}
