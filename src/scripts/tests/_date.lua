---@diagnostic disable-next-line: lowercase-global
function run_date_tests()
  -- This is a test for the date module.
  local tester_name = "__PKGNAME__"
  local g = Glu(tester_name, nil)
  local testing = g.date
  local test = g.test

  local function shms(cond)
    return cond.is_deeply(
      { testing.shms(350) },
      { "00", "05", "50" },
      "shms(350) should return '00', '05', '50'"
    )
  end

  local function shms_as_string(cond)
    return cond.is_eq(
      testing.shms(350, true),
      "5m 50s",
      "shms(350, true) should return '5m 50s'"
    )
  end

  local function shms_zero(cond)
    return cond.is_deeply(
      { testing.shms(0) },
      { "00", "00", "00" },
      "shms(0) should return '00', '00', '00'"
    )
  end

  local function shms_negative(cond)
    return cond.is_deeply(
      { testing.shms(-350) },
      { "23", "54", "10" },
      "shms(-350) should return '23', '54', '10'"
    )
  end

  local runner = test:runner({
    name = testing.class_name,
    tests = {
      { name = "date.shms", func = shms },
      { name = "date.shms_as_string", func = shms_as_string },
      { name = "date.shms_zero", func = shms_zero },
      { name = "date.shms_negative", func = shms_negative }
    }
  })
  .execute(true)
  .wipe()
end
