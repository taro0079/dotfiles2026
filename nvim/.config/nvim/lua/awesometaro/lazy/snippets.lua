return {
  {
    "L3MON4D3/LuaSnip",
    -- follow latest release.
    version = "v2.*", -- Replace <CurrentMajor> by the latest released major (first number of latest release)
    -- install jsregexp (optional!).
    build = "make install_jsregexp",

    dependencies = { "rafamadriz/friendly-snippets" },

    config = function()
      require("luasnip.loaders.from_vscode").lazy_load({
        path = { vim.fn.stdpath("config") .. "/lua/awesometaro/lazy/snippets" },
      })
      require("luasnip.loaders.from_lua").lazy_load({
        paths = { vim.fn.stdpath("config") .. "/lua/awesometaro/lazy/luasnippets" },
      })
      local ls = require("luasnip")
      -- ls.filetype_extend("javascript", { "jsdoc" })

      --- TODO: What is expand?
      vim.keymap.set({ "i" }, "<C-s>e", function()
        ls.expand()
      end, { silent = true, desc = "LuaSnip: Expand snippets" })

      vim.keymap.set({ "i", "s" }, "<C-s>;", function()
        ls.jump(1)
      end, { silent = true, desc = "LuaSnip: Jump next selection" })
      vim.keymap.set({ "i", "s" }, "<C-s>,", function()
        ls.jump(-1)
      end, { silent = true, desc = "LuaSnip: Jump previous selection" })

      vim.keymap.set({ "i", "s" }, "<C-E>", function()
        if ls.choice_active() then
          ls.change_choice(1)
        end
      end, { silent = true, desc = "LuaSnip: Selection Enum Choice" })
      local ls = require("luasnip")
      local s = ls.snippet
      local t = ls.text_node
      local i = ls.insert_node
      local f = ls.function_node
      local c = ls.choice_node

      local function class_name()
        return vim.fn.expand("%:t:r")
      end

      ls.add_snippets("php", {
        s("class", {
          t({
            "<?php",
            "",
            "declare(strict_types=1);",
            "",
            "class ",
          }),
          f(class_name),
          t({
            "",
            "{",
            "}",
          }),
        }),
        s("f", {
          c(1, {
            t("public"),
            t("private"),
            t("protected"),
          }),
          t(" function "),
          i(2, "methodName"),
          t("("),
          i(3),
          t("): "),
          i(4, "void"),
          t({ "", "{", "    " }),
          i(0),
          t({ "", "}" }),
        }),
      })

      -- require("awesometaro.lazy.luasnippets")
    end,
  },
}
