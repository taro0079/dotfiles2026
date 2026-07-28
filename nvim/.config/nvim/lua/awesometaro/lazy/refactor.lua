return {
  "ThePrimeagen/refactoring.nvim",
  dependencies = {
    "lewis6991/async.nvim",
  },
  lazy = false,
  config = function()
    require("refactoring").setup()

    -- 末尾にスペースがあるものは抽出先の名前入力待ちになる
    vim.keymap.set("x", "<leader>re", ":Refactor extract ", { desc = "Refactor: 関数抽出" })
    vim.keymap.set("x", "<leader>rf", ":Refactor extract_to_file ", { desc = "Refactor: 関数抽出（別ファイルへ）" })
    vim.keymap.set("x", "<leader>rv", ":Refactor extract_var ", { desc = "Refactor: 変数抽出" })
    vim.keymap.set({ "n", "x" }, "<leader>ri", ":Refactor inline_var<CR>", { desc = "Refactor: 変数のインライン化" })
    vim.keymap.set("n", "<leader>rI", ":Refactor inline_func<CR>", { desc = "Refactor: 関数のインライン化" })
    vim.keymap.set("n", "<leader>rb", ":Refactor extract_block<CR>", { desc = "Refactor: ブロック抽出" })
    vim.keymap.set("n", "<leader>rbf", ":Refactor extract_block_to_file<CR>", { desc = "Refactor: ブロック抽出（別ファイルへ）" })
  end,
}
