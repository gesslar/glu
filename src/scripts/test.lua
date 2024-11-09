local TestRunnerClass = Glu.glass.register({
  name = "test_runner",
  class_name = "TestRunnerClass",
  dependencies = { "table", "valid" },
  setup = function(___, self, opts, owner)
    opts = opts or {}

    ___.table.add(self, {
      id = ___.id(),
      tests = {},
      colours = {
        pass = (opts.colour and opts.colour.pass) or "<yellow_green>",
        fail = (opts.colour and opts.colour.fail) or "<orange_red>",
      },
      symbols = {
        pass = (opts.symbol and opts.symbol.pass) or utf8.escape("%x{2714}"), -- check mark
        fail = (opts.symbol and opts.symbol.fail) or utf8.escape("%x{2718}"),  -- cross mark
      },
    })

    ___.valid.colour_name(self.colours.pass, 2, false)
    ___.valid.colour_name(self.colours.fail, 2, false)

    local cond = ___.conditions
    local default = { tests = {} }
    local resets = { passes = 0, fails = 0, total = 0 }

    function self.add(name, test)
      table.insert(self.tests, {
        name = name,
        test = test,
        passes = 0,
        fails = 0,
        total = 0,
        runner = self,
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

      error(f "Test '{name}' not found")
    end

    if opts.tests then
      repeat
        local name, test = unpack(
          ___.table.values(table.remove(opts.tests, 1))
        )
        self.add(name, test)
      until table.size(opts.tests) == 0
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

    function self.pass(test)
      test.total = test.total + 1
      test.passes = test.passes + 1
    end

    function self.fail(test)
      test.total = test.total + 1
      test.fails = test.fails + 1
    end

    function self.execute(reset_when_done)
      reset_when_done = reset_when_done or false

      self.reset()

      for _, t in ipairs(self.tests) do
        local status_message =
          f"<light_goldenrod>Running test '{t.name}' " ..
          "(<r><seashell>%d<r><light_goldenrod>): "

        local success, result, fail_message = (function(test, condition)
          registerNamedEventHandler(test.name, test.name, "condition_is",
            function(_, c)
              if c == true then self.pass(test)
              elseif c == false then self.fail(test)
              else error(f"Expected a boolean, got {c}") end
            end
          )

          local success, result, fail_message = pcall(test.test, condition, self, test)

          deleteNamedEventHandler(test.name, test.name)

          return success, result, fail_message
        end)(t, cond)

        -- If we didn't succeed in our pcall OR we failed tests
        if not success or not result then
          if not success then self.fail(t) end
          status_message =
            status_message .. self.colours.fail .. self.symbols.fail .. "\n" ..
            " " .. self.colours.fail .. "Error in test '" .. t.name .. "':\n" ..
            "  " .. tostring(result or fail_message) .. "\n"
        else
          self.pass(t)
          status_message = status_message .. self.colours.pass .. self.symbols.pass .. "\n"
        end

        status_message = string.format(status_message, t.total)
        cecho(status_message)
      end

      owner.summary(self)

      if reset_when_done then self.reset() end

      return self
    end
  end
})

local TestClass = Glu.glass.register({
  name = "test",
  class_name = "TestClass",
  dependencies = { "table", "valid" },
  setup = function(___, self)
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
})

local FinallyClass = Glu.glass.register({
  class_name = "FinallyClass",
  name = "finally",
  inherit_from = nil,
  call = "finally",
  setup = function(___, self, opts)
    function self.finally(f, ...)
      -- Pass both success and error information to finally block
      local success, result = pcall(f, {
        success = opts.catch.success,
        error = opts.catch.err,
        original_error = opts.try.err
      })
      -- If finally block itself errors, we should probably handle that
      if not success then
        print("Error in finally block:", result)
      end
      return self
    end

    return self
  end
})

local CatchClass = Glu.glass.register({
  class_name = "CatchClass",
  name = "catch",
  inherit_from = nil,
  call = "catch",
  setup = function(___, self, opts)
    function self.catch(f, ...)
      if opts.try.success then
        -- If try succeeded, skip catch and go to finally
        return FinallyClass({
          catch = { success = true, err = nil },
          try = opts.try
        }, self)
      end
      -- Only execute catch if try failed
      local success, result = pcall(f, opts.try.err)
      return FinallyClass({
        catch = { success = success, err = result },
        try = opts.try
      }, self)
    end

    return self
  end
})

local TryClass = Glu.glass.register({
  class_name = "TryClass",
  name = "try",
  inherit_from = nil,
  dependencies = {},
  call = "try",
  setup = function(___, self, opts)
    function self.try(f, ...)
      local args = { ... }
      local success, result = pcall(function()
        return f(unpack(args))
      end)
      return CatchClass({
        try = {
          success = success,
          err = result,
          result = success and result or nil
        }
      }, self)
    end

    return self
  end
})
