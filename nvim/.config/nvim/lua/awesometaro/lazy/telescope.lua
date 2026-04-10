return {
  "nvim-telescope/telescope.nvim",

  tag = "0.1.5",

  dependencies = {
    "nvim-lua/plenary.nvim",
    "nvim-telescope/telescope-ui-select.nvim",
  },

  config = function()
    require("telescope").setup({
      extensions = {
        ["ui-select"] = {
          require("telescope.themes").get_dropdown(),
        },
      },
    })
    require("telescope").load_extension("ui-select")
    local builtin = require("telescope.builtin")
    vim.keymap.set("n", "<leader>pf", function()
      builtin.find_files({ hidden = true, no_ignore = true })
    end, { desc = "Find File Via Telescope" })
    vim.keymap.set("n", "<leader>pp", builtin.git_files, { desc = "Find Git File Via Telescope" })
    vim.keymap.set("n", "<leader>pb", builtin.buffers, { desc = "Pick Buffer Via Telescope" })
    vim.keymap.set("n", "<leader>pm", builtin.marks, { desc = "Pick marks via telescope " })
    vim.keymap.set("n", "<leader>pq", builtin.live_grep, { desc = "Pick live grep  via telescope " })
    vim.keymap.set("n", "<leader>pws", function()
      local word = vim.fn.expand("<cword>")
      builtin.grep_string({ search = word })
    end, { desc = "Search Current word in project" })
    vim.keymap.set("n", "<leader>pWs", function()
      local word = vim.fn.expand("<cWORD>")
      builtin.grep_string({ search = word })
    end, { desc = "Search current WORD in project" })
    vim.keymap.set("n", "<leader>ps", function()
      builtin.grep_string({ search = vim.fn.input("Grep > ") })
    end, { desc = "Grep and Find File" })
    vim.keymap.set("n", "<leader>vh", builtin.help_tags, {})
  end,
}
