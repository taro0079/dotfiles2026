-- リモートサーバーへのファイル転送ユーティリティ
local M = {}

-- 汎用的なリモート転送関数
function M.to_remote(local_path, remote_path)
  local file_path = vim.fn.expand("%:p")
  if file_path:find(vim.fn.expand(local_path), 1, true) == 1 then
    vim.notify("File is inside the project directory")

    local relative_path = file_path:sub(#vim.fn.expand(local_path) + 1)

    -- rsync コマンドを非同期で実行
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

-- rpst-v2 プロジェクト用の転送
function M.rpst_v2()
  local local_project_path = "~/ghq/rpst-v2/"
  local remote_project_path = "taro_morita@rpst-api:/var/lib/nfs-devel7-volume/dev-tmorita-rpst/var_www/rpst-v2/dev/"
  M.to_remote(local_project_path, remote_project_path)
end

function M.rpst_api()
  local local_project_path = "~/ghq/rpst-api/"
  local remote_project_path = "taro_morita@rpst-api:/var/lib/rpst-api-docker/"
  M.to_remote(local_project_path, remote_project_path)
end

-- コマンドを登録
function M.setup()
  vim.api.nvim_create_user_command("TransportV2", function()
    M.rpst_v2()
  end, { desc = "rpst-v2 のファイルをリモートに転送" })
  vim.api.nvim_create_user_command("TransportRpstApi", function()
    M.rpst_api()
  end, { desc = "rpst-api のファイルをリモートに転送" })
end

return M
