-- RPST PHPUnit リモート実行ユーティリティ
local M = {}

-- 設定（必要に応じて変更）
M.config = {
  remote_host = "dev-tmorita",
  user = "taro_morita",
  base_path = "/var/www/rpst-v2/dev",
  phpunit_config = "/var/www/rpst-v2/dev/tests/app/phpunit/v9/phpunit.xml.dist",
}

function M.run_test_runner()
  local cfg = M.config
  local test_runner_cmd = string.format("php %s/app/cli/cmd.php /sandbox/test_runner", cfg.base_path)
  local full_cmd = string.format("ssh %s@%s '%s'", cfg.user, cfg.remote_host, test_runner_cmd)

  -- 非同期でターミナルに表示
  vim.cmd("vsplit")
  vim.cmd("terminal " .. full_cmd)
end

function M.open_test_runner()
  local test_runner_url = "https://tmorita-newrpst-dev74.precs.net/ci/cmd/sandbox/test_runner"
  vim.cmd("!open " .. test_runner_url)
end

function M.run_phpunit_at_remote()
  local cfg = M.config
  local test_target_path = string.format("%s/%s", cfg.base_path, vim.fn.expand("%:."))
  local phpunit_cmd =
    string.format("php %s/vendor/bin/phpunit -c %s %s", cfg.base_path, cfg.phpunit_config, test_target_path)
  local full_cmd = string.format("ssh %s@%s '%s'", cfg.user, cfg.remote_host, phpunit_cmd)

  -- 非同期でターミナルに表示
  vim.cmd("vsplit")
  vim.cmd("terminal " .. full_cmd)
end

function M.get_test_namespace(file_path)
  local dirname = vim.fn.fnamemodify(file_path, ":.:h")
  local base_namespace = "Test\\app\\phpunit\\v9\\xunit\\"
  local converted = string.gsub(dirname, "/", "\\")
  return base_namespace .. converted
end

function M.get_basename(file_path)
  return vim.fn.fnamemodify(file_path, ":t:r")
end

function M.get_test_file_path(file_path)
  local root_dir = "tests/app/phpunit/v9/xunit"
  local dirname = vim.fn.fnamemodify(file_path, ":.:h")
  local basename = M.get_basename(file_path)
  return root_dir .. "/" .. dirname .. "/" .. basename .. "Test.php"
end

function M.create_test_class(file_path)
  local namespace = M.get_test_namespace(file_path)
  local template = [[
  <?php

  declare(strict_type=1);

  namespace %s;

  use Tests\\app\\phpunit\\v9\\abstracts\\test_cases\\TestCaseForXUnit;

  class %sTest extend TestCaseForXUnit
  {}

  ]]

  local content = string.format(template, namespace, M.get_basename(file_path))
  local target_path = M.get_test_file_path(file_path)
  local target_dir = vim.fn.fnamemodify(target_path, ":h")
  if vim.fn.isdirectory(target_dir) == 0 then
    vim.fn.mkdir(target_dir, "p")
  end
  local file, error = io.open(target_path, "w")
  if file then
    file:write(content)
    file:close()
  end
  vim.notify(error)
end

local function find_project_root(filepath)
  local dir = vim.fn.fnamemodify(filepath, ":h")
  while dir ~= "/" do
    if vim.fn.filereadable(dir .. "/composer.json") == 1 then
      return dir
    end
    dir = vim.fn.fnamemodify(dir, ":h")
  end
  return nil
end

local function to_test_path(filepath, root)
  local rel = filepath:sub(#root + 2)

  -- if not rel:match("^src/") then
  --   return nil, "src/ 配下のファイルではありません: " .. rel
  -- end
  local test_rel = ("tests/app/phpunit/v9/xunit/" .. rel):gsub("%.php$", "Test.php")

  -- local test_rel = rel:gsub("^src/", "tests/"):gsub("%.php$", "Test.php")

  return root .. "/" .. test_rel, nil
end

local function parse_php(filepath)
  local ns, classname

  for line in io.lines(filepath) do
    if not ns then
      ns = line:match("^namespace%s+([%w%_\\]+)%s*;")
    end

    if not classname then
      classname = line:match("^class%s+(%w+)")
    end
    if ns and classname then
      break
    end
  end

  return ns, classname
end

local function to_test_namespace(ns)
  if not ns then
    return nil
  end
  return "Tests\\app\\phpunit\\v9\\xunit\\" .. ns:sub(1, 1):lower() .. ns:sub(2)

  -- return ns:gsub("^(App)\\", "%1\\Tests\\")
end

local function generate_skeleton(ns, classname, test_ns, test_classname)
  local use_line = ""
  if ns and classname then
    use_line = string.format("use %s\\%s;\n", ns, classname)
  end

  return string.format(
    "<?php\n\ndeclare(strict_type=1);\n\nnamespace %s;\n\n%suse Tests\\app\\phpunit\\v9\\abstracts\\test_cases\\TestCaseForXUnit;\n\nclass %s extends TestCaseForXUnit\n{\n}",
    test_ns or "Tests",
    use_line,
    test_classname
  )
end

function M.create_testclass()
  local filepath = vim.fn.expand("%")

  if not filepath:match("%.php") then
    vim.notify("PHPファイルではありません", vim.log.levels.WARN)
    return
  end

  local root = find_project_root(filepath)
  if not root then
    vim.notify("composer.jsonが見つかりません", vim.log.levels.WARN)
    return
  end

  local test_path, err = to_test_path(filepath, root)
  if not test_path then
    vim.notify(err, vim.log.levels.WARN)
    return
  end

  if vim.fn.filereadable(test_path) == 1 then
    vim.ui.select(
      { "既存ファイルを開く", "上書きする", "キャンセル" },
      { prompt = "テストファイルがすでに存在します" .. test_path },
      function(choise)
        if choise == "既存ファイルを開く" then
          vim.cmd("edit " .. vim.fn.fnameescape(test_path))
        elseif choise == "上書きする" then
          M._write_and_open(filepath, test_path)
        end
      end
    )
  end
  -- M._write_and_open(filepath, test_path)
end

function M._write_and_open(src_path, test_path)
  vim.fn.mkdir(vim.fn.fnamemodify(test_path, ":h"), "p")

  local ns, classname = parse_php(src_path)
  local test_ns = to_test_namespace(ns)
  local test_classname = classname and (classname .. "Test") or "GeneratedTest"

  local skeleton = generate_skeleton(ns, classname, test_ns, test_classname)
  local f = io.open(test_path, "w")
  if not f then
    vim.notify("ファイルの書き込みに失敗" .. test_path, vim.log.levels.ERROR)
    return
  end
  f:write(skeleton)
  f:close()

  vim.notify("テストファイルを作成しました: " .. test_path, vim.log.levels.INFO)
  vim.cmd("edit " .. vim.fn.fnameescape(test_path))
end

-- コマンドを登録
function M.setup(opts)
  opts = opts or {}
  local key = opts.keymap or "<leader>mrc"
  vim.keymap.set("n", key, M.create_testclass, {
    desc = "RPST: テストクラス作成",
    silent = true,
  })
  vim.api.nvim_create_user_command("RpstTestRunner", function()
    M.run_test_runner()
  end, { desc = "RPST TestRunner をリモートで実行" })

  vim.api.nvim_create_user_command("RpstTestGenerator", function()
    local file_path = vim.fn.expand("%:p")
    M.create_test_class(file_path)
  end, { desc = "RPSTのテストクラスを生成します" })

  vim.api.nvim_create_user_command("RpstTestRunnerWeb", function()
    M.run_test_runner()
  end, { desc = "RPST TestRunner をブラウザで実行" })

  vim.api.nvim_create_user_command("RpstPhpunit", function()
    M.run_phpunit_at_remote()
  end, { desc = "RPST PHPUnit をリモートで実行" })

  vim.keymap.set("n", "<leader>mrp", function()
    M.run_phpunit_at_remote()
  end, { desc = "Rpst: Phpunit on Remote server" })

  vim.keymap.set("n", "<leader>mrt", function()
    M.run_test_runner()
  end, { desc = "Rpst: TestRunner on Remote server" })

  vim.keymap.set("n", "<leader>mrw", function()
    M.open_test_runner()
  end, { desc = "Rpst: TestRunner on Web browser" })
end

return M
