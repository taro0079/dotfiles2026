return {
  "vim-skk/eskk.vim",
  config = function()
    vim.cmd([[let g:eskk#directory        = "~/.config/eskk"]])
    vim.cmd([[let g:eskk#dictionary       = { 'path': "~/.config/eskk/my_jisyo", 'sorted': 1, 'encoding': 'utf-8',}]])
    vim.cmd([[let g:eskk#large_dictionary = {'path': "~/.config/eskk/SKK-JISYO.L", 'sorted': 1, 'encoding': 'euc-jp',}]])
  end,
}
