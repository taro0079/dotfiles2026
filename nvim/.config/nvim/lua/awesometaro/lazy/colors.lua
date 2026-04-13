function ColorMyPencils(color)
  color = color or "rose-pine-moon"
  -- color = color or "kurodake-green"
  vim.cmd.colorscheme(color)

  -- kurodake-green uses its own background, don't override it
  -- if color ~= "kurodake-green" then
  -- 	vim.api.nvim_set_hl(0, "Normal", { bg = "none" })
  -- 	vim.api.nvim_set_hl(0, "NormalFloat", { bg = "none" })
  -- end
end

return {
  {
    "erikbackman/brightburn.vim",
  },
  {
    "folke/tokyonight.nvim",
    lazy = false,
    priority = 1000,
    opts = {
      transparent = true,
    },
  },
  {
    "olimorris/onedarkpro.nvim",
    priority = 1000,
  },
  {
    "oskarnurm/koda.nvim",
    lazy = false, -- make sure we load this during startup if it is your main colorscheme
    priority = 1000, -- make sure to load this before all the other start plugins
    -- config = function()
    -- require("koda").setup({ transparent = true })
    -- vim.cmd("colorscheme koda")
    -- end,
    config = true,
  },
  {
    "Alexvzyl/nordic.nvim",
    lazy = false,
    priority = 1000,
  },
  {
    "ellisonleao/gruvbox.nvim",
    name = "gruvbox",
    config = function()
      require("gruvbox").setup({
        terminal_color = true,
        undercurl = true,
        underline = false,
        bold = true,
        italic = {
          strings = false,
          emphasis = false,
          comments = false,
          operators = false,
          folds = false,
        },
        strikethrough = true,
        invert_selection = false,
        invert_signs = false,
        invert_tabline = false,
        invert_indentguides = false,
        inverse = true,
        contrast = "",
        pallette_overrides = {},
        overrides = {},
        dim_inactive = false,
        transparent_mode = false,
      })
    end,
  },
  {
    "loctvl842/monokai-pro.nvim",
    lazy = false,
    priority = 1000,
    config = function()
      require("monokai-pro").setup({
        transparent_background = false,
      })
      -- vim.cmd.colorscheme("monokai-pro")
    end,
  },
  {
    "tiesen243/vercel.nvim",
    config = function()
      require("vercel").setup({
        theme = "dark",
      })
    end,
  },
  {
    "catppuccin/nvim",
    name = "catppuccin",
    priority = 1000,
  },
  {
    "rebelot/kanagawa.nvim",
  },
  {
    "rose-pine/neovim",
    name = "rose-pine",
    config = function()
      require("rose-pine").setup({
        disable_background = true,
        styles = {
          italic = false,
        },
      })

      ColorMyPencils("rose-pine")
    end,
  },
}
