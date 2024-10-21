---@diagnostic disable-next-line: undefined-global
local mod = mod or {}
local script_name = "valid"

function mod.new(parent)
  local instance = { parent = parent }
  -- Ignore the current script in tracebacks
  local trace_ignore = debug.getinfo(1).source

  local function get_last_traceback_line()
    local it, trace = 1, ""
    while debug.getinfo(it) do
      if debug.getinfo(it).source ~= trace_ignore then
        local line = debug.getinfo(it).source .. ":" .. debug.getinfo(it).currentline
        trace = trace .. line .. "\n"
      end
      it = it + 1
    end

    if #trace == 0 then
      return "[No traceback]"
    end

    return trace
  end

  --- valid:type(value, expected_type, argument_index, nil_allowed)
  --- Validates the type of a value.
  --- @type function
  --- @param value any - The value to validate.
  --- @param expected_type string - The expected type of the value.
  --- @param argument_index number - The index of the argument.
  --- @param nil_allowed boolean - Whether nil is allowed (default false)
  function instance:type(value, expected_type, argument_index, nil_allowed)
    if nil_allowed and value == nil then return end
    if expected_type == "any" then return end

    local last = get_last_traceback_line()

    assert(type(value) == expected_type,
      "Invalid type to argument " .. argument_index .. ". Expected " .. expected_type .. ", got " .. type(value) .. " in\n" .. last)
  end

  --- valid:rgb_table(colour, argument_index, nil_allowed)
  --- Validates an RGB color table.
  --- Validates that the table has three elements, and that each element is a number between 0 and 255.
  --- @type function
  --- @param colour table - The RGB color table to validate.
  --- @param argument_index number - The index of the argument.
  --- @param nil_allowed boolean - Whether nil is allowed (default false)
  function instance:rgb_table(colour, argument_index, nil_allowed)
    local last = get_last_traceback_line()

    self:type(colour, "table", argument_index, nil_allowed)
    assert(#colour == 3, "Invalid number of elements to argument " .. argument_index .. ". Expected 3, got " .. #colour .. " in\n" .. last)
    assert(type(colour[1]) == "number",
      "Invalid type to argument " .. argument_index .. ". Expected number, got " .. type(colour[1]) .. " in\n" .. last)
    assert(type(colour[2]) == "number",
      "Invalid type to argument " .. argument_index .. ". Expected number, got " .. type(colour[2]) .. " in\n" .. last)
    assert(type(colour[3]) == "number",
      "Invalid type to argument " .. argument_index .. ". Expected number, got " .. type(colour[3]) .. " in\n" .. last)
    assert(colour[1] >= 0 and colour[1] <= 255,
      "Invalid value to argument " .. argument_index .. ". Expected number between 0 and 255, got " .. colour[1] .. " in\n" .. last)
    assert(colour[2] >= 0 and colour[2] <= 255,
      "Invalid value to argument " .. argument_index .. ". Expected number between 0 and 255, got " .. colour[2] .. " in\n" .. last)
    assert(colour[3] >= 0 and colour[3] <= 255,
      "Invalid value to argument " .. argument_index .. ". Expected number between 0 and 255, got " .. colour[3] .. " in\n" .. last)
  end

  --- valid:not_empty(value, argument_index, nil_allowed)
  --- Validates that the value is not empty.
  --- @type function
  --- @param value any - The value to validate.
  --- @param argument_index number - The index of the argument.
  --- @param nil_allowed boolean - Whether nil is allowed (default false)
  function instance:not_empty(value, argument_index, nil_allowed)
    if nil_allowed and value == nil then
      return
    end

    local last = get_last_traceback_line()
    assert(#value > 0, "Invalid value to argument " .. argument_index .. ". Expected non-empty in\n" .. last)
  end

  --- valid:uniform_type(value, expected_type, argument_index, nil_allowed)
  --- Validates that all elements in the table are of the same type.
  --- @type function
  --- @param value any - The value to validate.
  --- @param expected_type string - The expected type of the value.
  --- @param argument_index number - The index of the argument.
  --- @param nil_allowed boolean - Whether nil is allowed (default false)
  function instance:uniform_type(value, expected_type, argument_index, nil_allowed)
    if nil_allowed and value == nil then
      return
    end

    local last = get_last_traceback_line()

    assert(self.parent.table.uniform_type(value, expected_type),
      "Invalid type to argument " .. argument_index .. ". Expected " .. expected_type .. ", got " .. type(value) .. " in\n" .. last)
  end

  --- valid:regex(value, pattern, argument_index, nil_allowed)
  --- Validates that the value matches the pattern using the rex library (PCRE)
  --- @type function
  --- @param value any - The value to validate.
  --- @param pattern string - The pattern to match the value against.
  --- @param argument_index number - The index of the argument.
  --- @param nil_allowed boolean - Whether nil is allowed (default false)
  function instance:regex(value, pattern, argument_index, nil_allowed)
    if nil_allowed and value == nil then
      return
    end

    local last = get_last_traceback_line()

    assert(rex.match(value, pattern), "Invalid value to argument " .. argument_index .. ". Expected " .. pattern .. ", got " .. value .. " in\n" .. last)
  end

  instance.parent.valid = instance.parent.valid or setmetatable({}, {
    __index = function(_, k) return function(...) end end
  })

  return instance
end

-- Let Glu know we're here
raiseEvent("glu_module_loaded", script_name, mod)

return mod
