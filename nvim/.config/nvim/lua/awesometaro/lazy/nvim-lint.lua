return {
  "mfussenegger/nvim-lint",
  config = function()
    local lint = require("lint")
    lint.linters.deptrac = {
      name = "deptrac",
      cmd = "docker",
      args = {
        "compose",
        "-f",
        vim.fn.getcwd() .. "/../docker-compose.yml",
        "exec",
        "-T",
        "app",
        "vendor/bin/deptrac",
        "analyse",
        "--formatter=json",
        "--no-progress",
      },
      stdin = false,
      stream = "stdout",
      ignore_exitcode = true,
      append_fname = false,
      parser = function(output, bufnr)
        local match_count = 0
        local diagnostics = {}

        local log = io.open("/tmp/deptrac-debug.log", "w")
        log:write("=== output length: " .. #output .. "\n")
        log:write("=== bufname: " .. vim.api.nvim_buf_get_name(bufnr) .. "\n")

        if output == "" then
          log:write("=== output is empty\n")
          log:close()
          return diagnostics
        end

        local ok, result = pcall(vim.json.decode, output)
        if not ok or not result or not result.files then
          return diagnostics
        end

        local bufname = vim.api.nvim_buf_get_name(bufnr)

        for filepath, filedata in pairs(result.files) do
          local src_path = filepath:match("/src/(.+)$")
          log:write("=== filepath: " .. filepath .. "\n")
          log:write("=== src_path: " .. (src_path or "") .. "\n")
          log:write("=== bufname: " .. bufname .. "\n")
          log:write("=== match: " .. tostring(src_path and bufname:find(src_path, 1, true) ~= nil) .. "\n")
          if src_path and bufname:find(src_path, 1, true) then
            match_count = match_count + 1
            for _, msg in ipairs(filedata.messages or {}) do
              table.insert(diagnostics, {
                lnum = (msg.line or 1) - 1,
                col = 0,
                severity = vim.diagnostic.severity.ERROR,
                message = msg.message,
                source = "deptrac",
              })
            end
          end
        end
        log:write("=== match_count: " .. match_count .. "\n")
        log:write("=== diagnostics count: " .. #diagnostics .. "\n")
        log:close()
        return diagnostics
      end,
    }

    lint.linters_by_ft = {
      -- php = { "phpstan", "deptrac" },
      php = { "deptrac", "phpstan" },
      eruby = { "erb_lint" },
    }

    vim.api.nvim_create_autocmd({ "BufWritePost" }, {
      callback = function()
        local log = io.open("/tmp/deptrac-debug.log", "a")
        log:write("=== BufWritePost fired, ft=" .. vim.bo.filetype .. "\n")
        log:close()
        lint.try_lint()
      end,
    })
  end,
}
