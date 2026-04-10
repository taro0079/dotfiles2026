local lib = require("neotest.lib")
local parse = require("neotest-rpstrunner.parse")
local results = require("neotest-rpstrunner.results")

local adapter = { name = "neotest-rpstrunner" }

adapter.is_test_file = function(file_path)
  return file_path:match("Test%.php$") ~= nil
end

adapter.root = lib.files.match_root_pattern(".git")

adapter.filter_dir = function(name, _rel_path, _root)
  local exclude = { "vendor", "node_modules", ".git", "storage", "bootstrap" }
  for _, dir in ipairs(exclude) do
    if name == dir then
      return false
    end
  end
  return true
end

adapter.discover_positions = parse.discover_positions
adapter.build_spec = parse.build_spec
adapter.results = results.results

return adapter
