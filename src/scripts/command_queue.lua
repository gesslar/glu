local CommandQueueClass = Glu.glass.register({
  class_name = "CommandQueueClass",
  name = "command_queue",
  extends = "queue",
  dependencies = {"timer"},
  setup = function(___, self, opts)

    local sequences = {}

    -- Enum for the timer states
    self.states = {
      RUNNING = 1,
      PAUSED  = 2,
      STOPPED = 3,
      ERROR   = -math.huge,
    }

    local SequenceCommands = {}
    local paused = false
    local currentIndex = 1

    function self.queue(name, commands, delay)
      ___.v.type(name, "string", 1, false)
      ___.v.type(commands, "string", 2, true) -- Ensure commands is a string or table
      ___.v.test(delay, "number", 3, false)
      ___.v.test(delay >= 0, "delay must be greater than or equal to 0", 3, false)
      ___.v.test(sequences[name] == nil, "sequence with name " .. name .. " already exists", 1, false)

      if type(commands) == "string" then
        commands = ___.string.split(commands, "\\|")
      end

      local sequence = {}

      SequenceCommands = {}
      paused = false
      currentIndex = 1

      SequenceCommands = ___.table.map(commands, function(_, v)
        local f

        if ___.string.starts_with(v, "lua ") then
          local space = ___.string.index_of(v, "\\s")
          local command = v:sub(space + 1)
          f = function() loadstring(command)() end
        else
          f = function() send(v) end
        end

        return { func = f }
      end)

      local result, err = ___.timer.multi(name, SequenceCommands, delay)
      if not result then
        return false, err
      end

      sequences[name] = sequence
      executeNextCommand()
    end

    function executeNextCommand()
      if paused or not SequenceCommands[currentIndex] then
        return
      end

      send(SequenceCommands[currentIndex].cmd)
      currentIndex = currentIndex + 1

      if SequenceCommands[currentIndex] then
        SequenceCommands[currentIndex].timer = ___.timer.multi("CommandExecution", {
          { delay = 2, func = function() executeNextCommand() end }
        })
      end
    end

    function pauseExecution()
      paused = true
      if SequenceCommands[currentIndex] and SequenceCommands[currentIndex].timer then
        ___.timer.kill_multi("CommandExecution")
        echo("\n [ Pause ] Sequence\n")
      end
    end

    function resumeExecution()
      if paused then
        paused = false
        executeNextCommand()
        echo("\n [ Resume ] Sequence\n")
      end
    end

    function extendDelay(seconds)
      if SequenceCommands[currentIndex] and SequenceCommands[currentIndex].timer then
        ___.timer.kill_multi("CommandExecution")
      end
      SequenceCommands[currentIndex].timer = ___.timer.multi("CommandExecution", {
        { delay = seconds, func = function() executeNextCommand() end }
      })
      echo("\n Extend for " .. seconds .. "\n")
    end

    function fullStop()
      for _, data in pairs(SequenceCommands) do
        if data.timer then
          ___.timer.kill_multi("CommandExecution")
        end
      end
      SequenceCommands = {}
      paused = false
      currentIndex = 1
      echo("stopped.")
    end

    function repeatLastStep()
      if currentIndex > 1 then
        local lastCommand = SequenceCommands[currentIndex - 1]
        if lastCommand then
          send(lastCommand.cmd)
          ___.timer.multi("CommandExecution", {
            { delay = 1, func = function() executeNextCommand() end }
          })
        end
      end
    end

  end
})
