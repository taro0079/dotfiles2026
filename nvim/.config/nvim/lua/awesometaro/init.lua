local autocmd = vim.api.nvim_create_autocmd
local augroup = vim.api.nvim_create_augroup
autocmd("LspAttach", {
  callback = function(e)
    local opts = { buffer = e.buf }
    vim.keymap.set("n", "gd", function()
      vim.lsp.buf.definition()
    end, vim.tbl_deep_extend("force", opts, { desc = "Lsp: Go to Definition" }))
    vim.keymap.set("n", "gi", function()
      vim.lsp.buf.implementation()
    end, vim.tbl_deep_extend("force", opts, { desc = "Lsp: Go to Implementation" }))
    vim.keymap.set("n", "K", function()
      vim.lsp.buf.hover()
    end, vim.tbl_deep_extend("force", opts, { desc = "Lsp: Hover" }))
    vim.keymap.set("n", "<leader>vws", function()
      vim.lsp.buf.workspace_symbol()
    end, vim.tbl_deep_extend("force", opts, { desc = "Lsp: Workspace Symbol" }))
    vim.keymap.set("n", "<leader>vd", function()
      local float_win = vim.b.diagnostic_float_win
      if float_win and vim.api.nvim_win_is_valid(float_win) then
        vim.api.nvim_set_current_win(float_win)
        vim.b.diagnostic_float_win = nil
      else
        local _, winnr = vim.diagnostic.open_float({ focusable = true })
        if winnr then
          vim.b.diagnostic_float_win = winnr
        end
      end
    end, vim.tbl_deep_extend("force", opts, { desc = "Lsp: Show Diagnostic" }))
    vim.keymap.set("n", "<leader>vca", function()
      vim.lsp.buf.code_action()
    end, vim.tbl_deep_extend("force", opts, { desc = "Lsp: Code Action" }))
    vim.keymap.set("n", "<leader>vrr", function()
      vim.lsp.buf.references()
    end, vim.tbl_deep_extend("force", opts, { desc = "Lsp: Go to Reference" }))
    vim.keymap.set("n", "<leader>vrn", function()
      vim.lsp.buf.rename()
    end, vim.tbl_deep_extend("force", opts, { desc = "Lsp: Rename Symbol" }))
    vim.keymap.set("i", "<C-h>", function()
      vim.lsp.buf.signature_help()
    end, vim.tbl_deep_extend("force", opts, { desc = "Lsp: Signature Help" }))
    vim.keymap.set("n", "[d", function()
      vim.diagnostic.goto_next()
    end, opts)
    vim.keymap.set("n", "]d", function()
      vim.diagnostic.goto_prev()
    end, opts)
  end,
})

autocmd({ "BufWritePre" }, {
  pattern = "*",
  command = [[%s/\s\+$//e]],
})

autocmd({ "TextYankPost" }, {
  pattern = "*",
  callback = function()
    vim.highlight.on_yank({
      higroup = "IncSearch",
      timeout = 40,
    })
  end,
})

vim.g.netrw_browse_split = 0
vim.g.netrw_banner = 0
vim.g.netrw_winsize = 25
