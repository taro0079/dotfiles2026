return {
  "folke/which-key.nvim",
  event = "VeryLazy",

  --@class wk.Opts
  opts = {
    preset = "helix",
    spec = {
      { "<leader>p", group = "Picker" },
      { "<leader>v", group = "Lsp" },
      { "<leader>t", group = "Test" },
      { "<leader>g", group = "Git" },
      { "-", group = "Php" },
    },
  },
  keys = {
    {
      "<leader>?",
      function()
        require("which-key").show({ global = false })
      end,
      desc = "Buffer Local Keymaps (which-key)",
    },
  },
}
