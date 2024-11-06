-- This is a test for the date module.
local test_script = "test"
local target_script = "date"
local tester_name = "__PKGNAME__"
local g = Glu.new(tester_name)
local mod = g[target_script]
local test = g[test_script]

local function shms(t)
  return t.is_deeply(
    { mod.shms(350) },
    { "00", "05", "50" },
    "shms(350) should return '00', '05', '50'"
  )
end

local function shms_as_string(t)
  return t.is_eq(
    mod.shms(350, true),
    "5m 50s",
    "shms(350, true) should return '5m 50s'"
  )
end

local function shms_zero(t)
  return t.is_deeply(
    { mod.shms(0) },
    { "00", "00", "00" },
    "shms(0) should return '00', '00', '00'"
  )
end

local function shms_negative(t)
  return t.is_deeply(
    { mod.shms(-350) },
    { "23", "54", "10" },
    "shms(-350) should return '23', '54', '10'"
  )
end

-- Run the tests

---@diagnostic disable-next-line: lowercase-global
function run_date_tests()
  ---@diagnostic disable-next-line: undefined-global
  local self = self or {}
  local runner = test.runner({ name = "date.runner" })
  .add("date.shms", shms)
    .add("date.shms_as_string", shms_as_string)
    .add("date.shms_zero", shms_zero)
    .add("date.shms_negative", shms_negative)
    .execute(true)
    .wipe()
end
