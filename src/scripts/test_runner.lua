local TestRunnerClass = Glu.glass.register({
  name = "test_runner",
  class_name = "TestRunnerClass",
  call = "new_runner",
  dependencies = { "table" },
  setup = function(___, self)
    function self.new_runner(opts, owner)
      self.id = ___.id()
      self.tests = {}
      self.colours = {
        pass = (opts.colour and opts.colour.pass) or "<yellow_green>",
        fail = (opts.colour and opts.colour.fail) or "<orange_red>",
      }
      self.symbols = {
        -- check mark
        pass = (opts.symbol and opts.symbol.pass) or utf8.escape("%x{2714}"),
        -- cross mark
        fail = (opts.symbol and opts.symbol.fail) or utf8.escape("%x{2718}"),
      }
      ___.v.colour_name(self.colours.pass, 2, false)
      ___.v.colour_name(self.colours.fail, 2, false)

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
          cecho(f "<b>{test.name}<r>\n")
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
              f "<light_goldenrod>Running test '{t.name}' " ..
              "(<r><seashell>%d<r><light_goldenrod>): "

          local success, result, fail_message = (function(test, condition)
            registerNamedEventHandler(test.name, test.name, "condition_is",
              function(_, c)
                if c == true then
                  self.pass(test)
                elseif c == false then
                  self.fail(test)
                else
                  error(f "Expected a boolean, got {c}")
                end
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
      return self
    end
  end
})
