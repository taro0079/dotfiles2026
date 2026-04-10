return {
  "lewis6991/gitsigns.nvim",
  config = function()
    require("gitsigns").setup({
      current_line_blame = true,
      on_attach = function(bufnr)
        local gitsigns = require("gitsigns")
        local function map(mode, l, r, opts)
          opts = opts or {}
          opts.buffer = bufnr
          vim.keymap.set(mode, l, r, opts)
        end

        map("n", "]c", function()
          if vim.wo.diff then
            vim.cmd.normal({ "]c", bang = true })
          else
            gitsigns.nav_hunk("next")
          end
        end, { desc = "Gitsign: Go to next hunk" })

        map("n", "[c", function()
          if vim.wo.diff then
            vim.cmd.normal({ "[c", bang = true })
          else
            gitsigns.nav_hunk("prev")
          end
        end, { desc = "Gitsign: Go to previous hunk" })

        map("n", "<leader>hs", gitsigns.stage_hunk, { desc = "Gitsign: Stage hunk" })
        map("n", "<leader>hr", gitsigns.reset_hunk, { desc = "Gitsign: Reset hunk" })

        map("v", "<leader>hs", function()
          gitsigns.stage_hunk({ vim.fn.line("."), vim.fn.line("v") })
        end, { desc = "Gitsign: Stage hunk" })

        map("v", "<leader>hr", function()
          gitsigns.reset_hunk({ vim.fn.line("."), vim.fn.line("v") })
        end, { desc = "Gitsign: Reset hunk" })

        map("n", "<leader>hp", gitsigns.preview_hunk, { desc = "Gitsign: Preview hunk" })
        map("n", "<leader>hi", gitsigns.preview_hunk_inline, { desc = "Gitsign: Preview hunk inline" })
      end,
    })
  end,
}
