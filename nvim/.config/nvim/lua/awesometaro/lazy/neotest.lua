return {
  "nvim-neotest/neotest",
  dependencies = {
    "nvim-neotest/nvim-nio",
    "nvim-lua/plenary.nvim",
    "antoinemadec/FixCursorHold.nvim",
    "nvim-treesitter/nvim-treesitter",
    "olimorris/neotest-phpunit",
  },
  config = function()
    require("neotest").setup({
      adapters = {
        require("neotest-phpunit"),
      },
    })
    vim.keymap.set("n", "<leader>tn", function()
      require("neotest").run.run()
    end, { desc = "Run the nearest test" })
    vim.keymap.set("n", "<leader>to", function()
      require("neotest").output.open({ enter = true })
    end, { desc = "Open test output" })
    vim.keymap.set("n", "<leader>tp", function()
      require("neotest").output_panel.toggle()
    end, { desc = "Toggle test output panel" })
    vim.keymap.set(
      "n",
      "<leader>tf",
      '<Cmd>lua require("neotest").run.run(vim.fn.expand("%"))<CR>',
      { desc = "Run current file tests" }
    )
    vim.keymap.set(
      "n",
      "<leader>ts",
      '<Cmd>lua require("neotest").summary.toggle()<CR>',
      { desc = "Toggle test summary" }
    )
  end,
}
