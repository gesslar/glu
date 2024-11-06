local script_name = "test"
local class_name = script_name:title() .. "Class"
local deps = { "table", "valid", "util" }

local TestRunnerClass = Glu.registerClass({
  class_name = "TestRunnerClass",
  name = "test_runner",
  dependencies = deps,
})

function TestRunnerClass.setup(___, self, opts, owner)
  opts = opts or {}

  self.id = ___.id()
  self.tests = {}

  ___.table.add(self, {
    colours = {
      good = "<yellow_green>",
      bad = "<orange_red>",
    },
    symbols = {
      good = utf8.escape("%x{2714}"), -- check mark
      bad = utf8.escape("%x{2718}"),  -- cross mark
    },
  })

  local cond = ___.conditions
  local current = {}
  local default = { tests = {} }
  local resets = { success = 0, failure = 0, total = 0 }

  function self.add(name, test)
    table.insert(self.tests, {
      name = name, test = test,
      success = 0, failure = 0,
      total = 0
    })

    return self
  end

  function self.remove(name)
    for i, test in ipairs(self.tests) do
      if test.name == name then
        table.remove(self.tests, i)
        return self
      end
    end

    error(f"Test '{name}' not found")
  end

  function self.print()
    for _, test in ipairs(self.tests) do
      cecho(f"<b>{test.name}<r>\n")
    end

    return self
  end

  function self.reset()
    for k, v in pairs(resets) do
      for _, test in ipairs(self.tests) do
        test[k] = v
      end
    end

    return self
  end

  function self.wipe()
    for _, v in pairs(self.tests) do
      v = nil
    end

    return self
  end

  function self.execute(reset_when_done)
    reset_when_done = reset_when_done or false

    self.reset()

    for _, t in ipairs(self.tests) do
      -- Set the current property because the tests won't otherwise know which
      -- table to update.
      current = t

      local status_message =
        f"<light_goldenrod>Running test '{t.name}' " ..
        "(<r><seashell>%d<r><light_goldenrod>): "

      local success, result, fail_message = pcall(t.test, cond)

      -- If we didn't succeed in our pcall OR we failed tests
      if not success or not result then
        self.fail()

        status_message =
          status_message .. self.colours.bad .. self.symbols.bad .. "\n" ..
          " " .. self.colours.bad .. "Error in test '" .. t.name .. "':\n" ..
          "  " .. tostring(result or fail_message) .. "\n"
      else
        self.succeed()
        status_message = status_message .. self.colours.good .. self.symbols.good .. "\n"
      end

      status_message = string.format(status_message, t.total)
      cecho(status_message)

      current = nil
    end

    owner.summary(self)

    if reset_when_done then self.reset() end

    return self
  end

  function self.succeed()
    current.total = current.total + 1
    current.success = current.success + 1
    return true, nil
  end

  function self.fail()
    current.total = current.total + 1
    current.failure = current.failure + 1
    return false
  end
end

local mod = Glu.registerClass({
  class_name = class_name,
  script_name = script_name,
  dependencies = deps,
})

function mod.setup(___, self)
  local testers = {}

  function self.runner(opts)
    local runner = TestRunnerClass(opts, self)

    testers[runner.id] = runner

    return runner
  end

  local function sum(tests)
    local result = 0

      for _, test in ipairs(tests) do
        result = result + test
      end

    return result
  end

  local function sum_field(tbls, field)
    local totals = {}

    for _, tbl in ipairs(tbls) do
      table.insert(totals, tbl[field])
    end

    return sum(totals)
  end

  function self.summary(runner)
    local good_colour, bad_colour = unpack(___.table.values(runner.colours))
    local total_run = sum_field(runner.tests, "total")
    local total_success = sum_field(runner.tests, "success")
    local total_failure = sum_field(runner.tests, "failure")

    print("")
    cecho("<b> Tests run:</b> <gold>" .. total_run .. "<r>\n")
    cecho("<b> Successes:</b> " .. good_colour .. total_success .. "<r>\n")
    cecho("<b>  Failures:</b> " .. bad_colour .. total_failure .. "<r>\n")
  end

  return self
end
