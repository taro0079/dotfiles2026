return {
  { "ellisonleao/gruvbox.nvim", opts = {
    transparent_mode = true,
  } },
  {
    "loctvl842/monokai-pro.nvim",
    config = function()
      require("monokai-pro").setup({

        transparent_background = true,
        background_clear = {
          "float_win",
          "toggleterm",
          "telescope",
          "which-key",
          "neo-tree",
          "notify",
          "bufferline",
        },
      })
    end,
  },
  {
    "rose-pine/neovim",
    config = function()
      require("rose-pine").setup({
        dark_variant = "moon",
        dim_inactive_windows = false,
        styles = {
          transparency = true,
        },
      })
    end,
  },
  {
    "LazyVim/LazyVim",
    opts = {
      colorscheme = "bluloco-dark",
    },
  },
}
