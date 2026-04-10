local M = {}
local function parse_xml(xml)
  local cases = {}

  for block in xml:gmatch("<testcase(.-)/>") do
    local name = block:match('name="(.-)"')
    local class = block:match('class="(.-)"')
    local line = block:match('line="(.-)"')

    if name then
      table.insert(cases, {
        name = name,
        class = class,
        line = tonumber(line),
        status = "passed",
      })
    end
  end

  for block in xml:gmatch("<testcase(.-)>(.-)</testcase>") do
    local attrs = block
    local name = attrs:match('name="(.-)"')
    local class = attrs:match('class="(.-)"')
    local line = attrs:match('line="(.-)"')

    local status, message
    local failure = block:match("<failure[^>]*>(.-)</failure>")
    local error_ = block:match("<error[^>]*>(.-)</error>")
    local skipped = block:match("<skipped")

    if failure then
      status = "failed"
      message = failure:match("^%s*(.-)%s*$")
    elseif error_ then
      status = "failed"
      message = error_:match("^%s*(.-)%s*$")
    elseif skipped then
      status = "skipped"
    else
      status = "passed"
    end

    if name then
      table.insert(cases, {
        name = name,
        class = class,
        line = tonumber(line),
        status = status,
        message = message,
      })
    end
  end

  return cases
end

local function make_id(file, class, test_name)
  if class and class ~= "" then
    return file .. "::" .. class .. "::" .. test_name
  end

  return file .. "::" .. test_name
end

M.results = function(spec, result, _tree)
  local res = {}

  local report_path = spec.context.report
  if not report_path or vim.fn.filereadable(report_path) == 0 then
    res[spec.context.position_id] = {
      status = "failed",
      output = result.output,
      errors = {
        { message = "phpunit failed to produce a report. exit code: " .. result.code },
      },
    }
    return res
  end
  local xml = table.concat(vim.fn.readfile(report_path), "\n")
  local cases = parse_xml(xml)

  if vim.tbl_isempty(cases) then
    res[spec.context.position_id] = {
      status = "failed",
      output = result.output,
      errors = { { message = "Could not parse JUnit XML report." } },
    }
    return res
  end

  for _, case in ipairs(cases) do
    local id = make_id(spec.context.file, case.class, case.name)
    res[id] = {
      status = case.status,
      output = result.output,
      short = case.message,
      errors = (case.status == "failed" and case.message) and {
        {
          message = case.message,
          line = case.line and (case.line - 1) or nil,
        },
      } or nil,
    }
  end

  vim.fn.delete(report_path)

  return res
end

return M
