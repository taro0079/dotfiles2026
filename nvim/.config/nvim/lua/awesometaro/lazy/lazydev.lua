return {
  "folke/lazydev.nvim",
  ft = "lua",
  dependencies = {
    { "Bilal2453/luvit-meta", lazy = true },
    { "LuaCATS/luassert", lazy = true, name = "luassert-types" },
    { "LuaCATS/busted", lazy = true, name = "busted-types" },
  },
  opts = {
    library = {
      -- "lazy.nvim",
      { path = "luvit-meta/library", words = { "vim%.uv" } },
      { path = "luassert-types/library", words = { "assert" } },
      { path = "busted-types/library", words = { "describe" } },
      { path = "snacks.nvim", words = { "Snacks" } },
    },
  },
}
