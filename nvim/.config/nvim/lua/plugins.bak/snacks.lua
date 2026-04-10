return {
  "folke/snacks.nvim",
  opts = {
    scroll = { enabled = false },
  },
  keys = {
    { "<Space><Space>", false },
    {
      "<leader><Space>",
      function()
        Snacks.picker.smart()
      end,
      desc = "Smart Find",
    },
  },
}
