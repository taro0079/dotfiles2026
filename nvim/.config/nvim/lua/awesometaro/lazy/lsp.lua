return {
  "neovim/nvim-lspconfig",
  dependencies = {
    "stevearc/conform.nvim",
    "williamboman/mason.nvim",
    "williamboman/mason-lspconfig.nvim",
    "hrsh7th/cmp-nvim-lsp",
    "hrsh7th/cmp-buffer",
    "hrsh7th/cmp-path",
    "hrsh7th/cmp-cmdline",
    "hrsh7th/nvim-cmp",
    "L3MON4D3/LuaSnip",
    "saadparwaiz1/cmp_luasnip",
    "j-hui/fidget.nvim",
  },

  config = function()
    -- vim.keymap.set("n", "gd", function() vim.lsp.buf.definition() end, opts)
    -- vim.keymap.set("n", "K", function() vim.lsp.buf.hover() end, opts)
    -- vim.keymap.set("n", "<leader>vws", function() vim.lsp.buf.workspace_symbol() end, opts)
    -- vim.keymap.set("n", "<leader>vd", function() vim.diagnostic.open_float() end, opts)
    -- vim.keymap.set("n", "<leader>vca", function() vim.lsp.buf.code_action() end, opts)
    -- vim.keymap.set("n", "<leader>vrr", function() vim.lsp.buf.references() end, opts)
    -- vim.keymap.set("n", "<leader>vrn", function() vim.lsp.buf.rename() end, opts)
    -- vim.keymap.set("i", "<C-h>", function() vim.lsp.buf.signature_help() end, opts)
    -- vim.keymap.set("n", "[d", function() vim.diagnostic.goto_next() end, opts)
    -- vim.keymap.set("n", "]d", function() vim.diagnostic.goto_prev() end, opts)
    require("conform").setup({
      formatters_by_ft = {},
    })
    local cmp = require("cmp")
    local cmp_lsp = require("cmp_nvim_lsp")
    local capabilities =
      vim.tbl_deep_extend("force", {}, vim.lsp.protocol.make_client_capabilities(), cmp_lsp.default_capabilities())

    require("fidget").setup({})
    require("mason").setup()
    require("mason-lspconfig").setup({
      ensure_installed = {
        "lua_ls",
        "rust_analyzer",
        "gopls",
        "vtsls",
        "tailwindcss",
        "html",
        "emmet_ls",
        "sqls",
      },
      handlers = {
        function(server_name) -- default handler (optional)
          vim.lsp.config(server_name, { capabilities = capabilities })
        end,

        zls = function()
          local lspconfig = require("lspconfig")
          lspconfig.zls.setup({
            root_dir = lspconfig.util.root_pattern(".git", "build.zig", "zls.json"),
            settings = {
              zls = {
                enable_inlay_hints = true,
                enable_snippets = true,
                warn_style = true,
              },
            },
          })
          vim.g.zig_fmt_parse_errors = 0
          vim.g.zig_fmt_autosave = 0
        end,
        ["lua_ls"] = function()
          local lspconfig = require("lspconfig")
          vim.lsp.config("lua_ls", {
            capabilities = capabilities,
            settings = {
              Lua = {
                runtime = {
                  version = "LuaJIT",
                },
                diagnostics = {
                  globals = { "vim" },
                },
                workspace = {
                  checkThirdParty = false,
                },
                format = {
                  enable = true,
                  -- Put format options here
                  -- NOTE: the value should be STRING!!
                  defaultConfig = {
                    indent_style = "space",
                    indent_size = "2",
                  },
                },
              },
            },
          })
        end,
        ["sqls"] = function()
          local lspconfig = require("lspconfig")
          lspconfig.sqls.setup({
            capabilities = capabilities,
            filetypes = { "sql", "mysql" },
            -- Connections are loaded from ~/.config/sqls/config.yml
          })

          local function parse_lines(result)
            if type(result) ~= "string" then
              return {}
            end
            local lines = {}
            for line in result:gmatch("[^\r\n]+") do
              table.insert(lines, line)
            end
            return lines
          end

          vim.api.nvim_create_user_command("SqlsSwitchDatabase", function()
            vim.lsp.buf_request(
              0,
              "workspace/executeCommand",
              { command = "showDatabases", arguments = {} },
              function(err, result)
                if err then
                  return vim.notify(vim.inspect(err), vim.log.levels.ERROR)
                end
                vim.ui.select(parse_lines(result), { prompt = "Database> " }, function(choice)
                  if not choice then
                    return
                  end
                  vim.lsp.buf.execute_command({ command = "switchDatabase", arguments = { choice } })
                end)
              end
            )
          end, {})

          vim.api.nvim_create_user_command("SqlsSwitchConnection", function()
            vim.lsp.buf_request(
              0,
              "workspace/executeCommand",
              { command = "showConnections", arguments = {} },
              function(err, result)
                if err then
                  return vim.notify(vim.inspect(err), vim.log.levels.ERROR)
                end
                vim.ui.select(parse_lines(result), { prompt = "Connection> " }, function(choice)
                  if not choice then
                    return
                  end
                  local idx = choice:match("^(%d+)")
                  if idx then
                    vim.lsp.buf.execute_command({
                      command = "switchConnections",
                      arguments = { tonumber(idx) },
                    })
                  end
                end)
              end
            )
          end, {})
        end,
        ["tailwindcss"] = function()
          vim.lsp.config("tailwindcss", {
            capabilities = capabilities,
            filetypes = {
              "html",
              "css",
              "scss",
              "javascript",
              "javascriptreact",
              "typescript",
              "typescriptreact",
              "vue",
              "svelte",
              "heex",
            },
          })
        end,
      },
    })

    vim.filetype.add({
      extension = {
        tpl = "smarty",
      },
    })

    vim.lsp.config("smarty_ls", {
      capabilities = capabilities,
    })

    vim.lsp.config("html", {
      capabilities = capabilities,
      filetypes = { "html", "smarty" },
      init_options = {
        configurationSection = { "html", "css", "javascript" },
        embeddedLanguages = {
          css = true,
          javascript = true,
        },
        provideFormatter = true,
      },
    })

    vim.lsp.config("emmet_ls", {
      capabilities = capabilities,
      filetypes = {
        "html",
        "css",
        "scss",
        "javascriptreact",
        "typescriptreact",
        "vue",
        "svelte",
        "smarty",
      },
    })

    vim.lsp.enable("html")
    vim.lsp.enable("emmet_ls")

    vim.lsp.config("test-generator", {
      cmd = { "php-test-generator" },
      filetypes = { "php" },
      capabilities = capabilities,
    })
    vim.lsp.config("efm", {
      cmd = { "efm-langserver" },
      filetypes = { "php" },
      capabilities = capabilities,
      init_options = { documentFormatting = true },
      root_markers = { "composer.json", ".git" },
    })
    vim.lsp.enable("smarty_ls")
    vim.lsp.enable("test-generator")
    vim.lsp.enable("efm")

    local cmp_select = { behavior = cmp.SelectBehavior.Select }

    cmp.setup({
      snippet = {
        expand = function(args)
          require("luasnip").lsp_expand(args.body) -- For `luasnip` users.
        end,
      },
      mapping = cmp.mapping.preset.insert({
        ["<C-p>"] = cmp.mapping.select_prev_item(cmp_select),
        ["<C-n>"] = cmp.mapping.select_next_item(cmp_select),
        ["<C-y>"] = cmp.mapping.confirm({ select = true }),
        ["<C-Space>"] = cmp.mapping.complete(),
      }),
      sources = cmp.config.sources({
        { name = "copilot", group_index = 2 },
        { name = "lazydev", group_index = 0 },
        { name = "nvim_lsp" },
        { name = "luasnip" }, -- For luasnip users.
      }, {
        { name = "buffer" },
      }),
    })

    vim.diagnostic.config({
      -- update_in_insert = true,
      float = {
        focusable = false,
        style = "minimal",
        border = "rounded",
        source = "always",
        header = "",
        prefix = "",
      },
    })
  end,
}
