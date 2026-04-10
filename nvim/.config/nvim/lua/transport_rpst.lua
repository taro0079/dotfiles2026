function transport_to_remote(local_path, remote_path)
  local file_path = vim.fn.expand("%:p")
  if file_path:find(vim.fn.expand(local_path), 1, true) == 1 then
    vim.notify("File is inside the project directory")

    local relative_path = file_path:sub(#vim.fn.expand(local_path) + 1)

    local cmd =
      string.format("rsync -aqz --no-motd --mkpath -e 'ssh -q' %s %s%s", file_path, remote_path, relative_path)
    vim.fn.jobstart(cmd, {
      stdout_buffered = true,
      on_stdout = function(_, data)
        local msg = table.concat(data, "\n"):gsub("^%s*(.-)%s*$", "%1")
        if msg ~= "" then
          vim.notify("Message: " .. msg)
        end
      end,
      on_stderr = function(_, data)
        local err = table.concat(data, "\n"):gsub("^%s*(.-)%s*$", "%1")
        if err ~= "" then
          vim.notify("Rsync Error: " .. err, vim.log.levels.ERROR)
        end
      end,
      on_exit = function(_, code)
        if code == 0 then
          vim.notify("File transferred successfully", vim.log.levels.INFO)
        else
          vim.notify("Error: " .. code, vim.log.levels.ERROR)
        end
      end,
    })
  end
end

function transport_v1()
  local local_project_path = "~/ghq/github.com/PRECS-Inc/rpst"
  local remote_project_path =
    "taro_morita@rpst-api:/var/lib/nfs-devel7-volume/dev-tmorita-rpst/var_www/precs/dev_tmorita/"

  transport_to_remote(local_project_path, remote_project_path)
end

vim.api.nvim_create_autocmd("BufWritePost", {
  pattern = "*/rpst/*",
  callback = function()
    transport_v1()
  end,
})

function transport_v2()
  local local_project_path = "~/ghq/github.com/PRECS-Inc/rpst-v2"
  local remote_project_path = "taro_morita@rpst-api:/var/lib/nfs-devel7-volume/dev-tmorita-rpst/var_www/rpst-v2/dev/"
  transport_to_remote(local_project_path, remote_project_path)
end

vim.api.nvim_create_autocmd("BufWritePost", {
  pattern = "*/rpst-v2/*",
  callback = function()
    transport_v2()
  end,
})
