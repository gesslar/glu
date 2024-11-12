local TestClass = Glu.glass.register({
  name = "test",
  class_name = "TestClass",
  call = "runner",
  dependencies = { "table", "test_runner" },
  setup = function(___, self)
    local testers = {}

    function self.runner(opts)
      local runner = ___.test_runner(opts, self)

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
      local total_pass = sum_field(runner.tests, "passes")
      local total_fail = sum_field(runner.tests, "fails")

      print("")
      cecho("<b> Tests run:</b> <gold>" .. total_run .. "<r>\n")
      cecho("<b> Successes:</b> " .. good_colour .. total_pass .. "<r>\n")
      cecho("<b>  Failures:</b> " .. bad_colour .. total_fail .. "<r>\n")
    end

    return self
  end
})
