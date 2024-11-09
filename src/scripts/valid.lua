local ValidClass = Glu.glass.register({
  name = "valid",
  class_name = "ValidClass",
  dependencies = { "table" },
  setup = function(___, self)
    -- Ignore the current script in tracebacks
    local trace_ignore = debug.getinfo(1).source

    local function get_last_traceback_line()
      local it, trace = 1, ""
      while debug.getinfo(it) do
        if debug.getinfo(it).source ~= trace_ignore then
          local line = debug.getinfo(it).source ..
            ":" ..
            debug.getinfo(it).currentline
          trace = trace .. line .. "\n"
        end
        it = it + 1
      end

      if #trace == 0 then
        return "[No traceback]"
      end

      return trace
    end

    --- Asserts that the value is of the expected type. No return value, but an
    --- error is thrown if the assertion fails. No error is thrown if the value
    --- is nil and nil is allowed, or otherwise if the value is of the expected
    --- type.
    ---
    --- @param value any - The value to validate.
    --- @param expected_type string - The expected type of the value.
    --- @param argument_index number - The index of the argument.
    --- @param nil_allowed boolean - Whether nil is allowed (default false)
    --- @example
    --- ```lua
    --- function my_function(name, age)
    ---   -- name must be a string (mandatory)
    ---   valid.type(name, "string", 1, false)
    ---   -- age must be a number or nil (optional)
    ---   valid.type(age, "number", 2, true)
    --- end
    --- ```
    function self.type(value, expected_type, argument_index, nil_allowed)
      local last = get_last_traceback_line()

      assert((nil_allowed == true and value == nil) or value ~= nil,
        "value must not be nil for argument " .. argument_index .. " in\n" .. last)
      assert(type(expected_type) == "string",
        "expected_type must be a string for argument " .. argument_index .. " in\n" .. last)
      assert(type(argument_index) == "number",
        "argument_index must be a number for argument " .. argument_index .. " in\n" .. last)
      assert(nil == nil_allowed or type(nil_allowed) == "boolean",
        "nil_allowed must be a boolean for argument " .. argument_index .. " in\n" .. last)

      if nil_allowed and value == nil then return end
      if expected_type == "any" then return end

      local expected_types = string.split(expected_type, "|") or { expected_type }
      local invalid = table.n_filter(expected_types, function(t) return not ___.TYPE[t] end)

      if table.size(invalid) > 0 then
        error("Invalid type to argument " .. argument_index .. ". Expected " .. table.concat(invalid, "|") .. ", got " .. type(value) .. " in\n" .. last)
      end

      for _, t in ipairs(expected_types) do
        if type(value) == t then return end
      end

      error("Invalid type to argument " .. argument_index .. ". Expected " .. expected_type .. ", got " .. type(value) .. " in\n" .. last)
    end

    --- Asserts that the value is of the expected type or nil. No return value,
    --- but an error is thrown if the assertion fails. No error is thrown if the
    --- value is nil and nil is allowed.
    ---
    --- @param value any - The value to validate.
    --- @param expected_type string - The expected type of the value.
    --- @param argument_index number - The index of the argument.
    --- @param nil_allowed boolean - Whether nil is allowed (default true)
    --- @example
    --- ```lua
    --- function my_function(name, age)
    ---   valid.type_or_nil(name, "string", 1, false)
    ---   valid.type_or_nil(age, "number", 2, true)
    --- end
    --- ```
    function self.type_or_nil(value, expected_type, argument_index, nil_allowed)
      self.type(value, expected_type, argument_index, nil_allowed)
    end

    --- Asserts that the table is an RGB color table. No return value, but an
    --- error is thrown if the assertion fails. No error is thrown if the value
    --- is nil and nil is allowed.
    ---
    --- @param colour table - The RGB color table to validate.
    --- @param argument_index number - The index of the argument.
    --- @param nil_allowed boolean - Whether nil is allowed (default false)
    --- @example
    --- ```lua
    --- function my_function(colour)
    ---   -- colour must be a table containing three numbers, each between 0 and
    ---   -- 255 (mandatory)
    ---   valid.rgb_table(colour, 1, false)
    --- end
    --- ```
    function self.rgb_table(colour, argument_index, nil_allowed)
      local last = get_last_traceback_line()

      self.type(colour, "table", argument_index, nil_allowed)
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

    --- Asserts that the value is a valid colour name. A valid colour name is a
    --- string that matches the pattern `<colour>` or `colour` and is present
    --- in Mudlet's `color_table` table. No return value, but an error is thrown
    --- if the assertion fails. No error is thrown if the value is nil and nil is
    --- allowed.
    ---
    --- @param colour string - The colour name to validate.
    --- @param argument_index number - The index of the argument.
    --- @param nil_allowed boolean - Whether nil is allowed (default false)
    --- @example
    --- ```lua
    --- function my_function(colour)
    ---   valid.colour_name(colour, 1, false)
    --- end
    ---
    --- my_function("green")
    --- -- OK
    --- my_function("<green>")
    --- -- OK
    --- my_function("<unknown>")
    --- -- Error: Invalid value to argument 1. Expected <unknown>, got unknown in
    --- ```
    function self.colour_name(colour, argument_index, nil_allowed)
      if nil_allowed and colour == nil then return end

      -- Extract the colour name if enclosed in <>
      local name = rex.match(colour, "<?([\\w_]+)>?") or colour

      self.rgb_table(color_table[name], argument_index, nil_allowed)
    end

    --- Asserts that the table is not empty. No return value, but an error is
    --- thrown if the assertion fails. No error is thrown if the value is nil
    --- and nil is allowed.
    ---
    --- @param value table - The value to validate.
    --- @param argument_index number - The index of the argument.
    --- @param nil_allowed boolean - Whether nil is allowed (default false)
    --- @example
    --- ```lua
    --- function my_function(name)
    ---   -- name must not be empty (mandatory)
    ---   valid.not_empty(name, 1, false)
    --- end
    --- ```
    function self.not_empty(value, argument_index, nil_allowed)
      assert(type(value) == "table", "Invalid type to argument " .. argument_index .. ". Expected table, got " .. type(value) .. " in\n" .. get_last_traceback_line())
      if nil_allowed and value == nil then
        return
      end

      local last = get_last_traceback_line()
      assert(not table.is_empty(value), "Invalid value to argument " .. argument_index .. ". Expected non-empty in\n" .. last)
    end

    --- Asserts that all elements in the table are of the same type. No return
    --- value, but an error is thrown if the assertion fails. No error is thrown
    --- if the value is nil and nil is allowed.
    ---
    --- @param value table - The value to validate.
    --- @param expected_type string - The expected type of the value.
    --- @param argument_index number - The index of the argument.
    --- @param nil_allowed boolean - Whether nil is allowed (default false)
    --- @example
    --- ```lua
    --- function my_function(values)
    ---   -- values must be a table containing only numbers
    ---   valid.n_uniform(values, "number", 1, false)
    --- end
    --- ```
    function self.n_uniform(value, expected_type, argument_index, nil_allowed)
      if nil_allowed and value == nil then
        return
      end

      local last = get_last_traceback_line()
      assert(___.table.n_uniform(value, expected_type),
        "Invalid type to argument " .. argument_index .. ". Expected an indexed table of " .. expected_type .. " in\n" .. last)
    end

    --- Asserts that the value matches the pattern using the rex library (PCRE).
    --- No return value, but an error is thrown if the assertion fails. No error
    --- is thrown if the value is nil and nil is allowed.
    ---
    --- @param value any - The value to validate.
    --- @param pattern string - The pattern to match the value against.
    --- @param argument_index number - The index of the argument.
    --- @param nil_allowed boolean - Whether nil is allowed (default false)
    --- @example
    --- ```lua
    --- function my_function(name)
    ---   -- name must match the pattern
    ---   valid.regex(name, "^[A-Za-z]+$", 1, false)
    --- end
    --- ```
    function self.regex(value, pattern, argument_index, nil_allowed)
      if nil_allowed and value == nil then
        return
      end

      local last = get_last_traceback_line()

      assert(rex.match(value, pattern), "Invalid value to argument " .. argument_index .. ". Expected " .. pattern .. ", got " .. value .. " in\n" .. last)
    end

    --- Asserts that the value is an indexed table. No return value, but an error
    --- is thrown if the assertion fails. No error is thrown if the value is nil
    --- and nil is allowed.
    --- @param value table - The value to validate.
    --- @param argument_index number - The index of the argument.
    --- @param nil_allowed boolean - Whether nil is allowed (default false)
    --- @example
    --- ```lua
    --- function my_function(values)
    ---   -- values must be an indexed table
    ---   valid.indexed(values, 1, false)
    --- end
    --- ```
    function self.indexed(value, argument_index, nil_allowed)
      if nil_allowed and value == nil then
        return
      end

      local last = get_last_traceback_line()
      assert(___.table.indexed(value), "Invalid value to argument " .. argument_index .. ". Expected indexed table, got " .. type(value) .. " in\n" .. last)
    end

    --- Asserts that the value is an associative table. No return value, but an
    --- error is thrown if the assertion fails. No error is thrown if the value
    --- is nil and nil is allowed.
    ---
    --- @param value table - The value to validate.
    --- @param argument_index number - The index of the argument.
    --- @param nil_allowed boolean - Whether nil is allowed (default false)
    --- @example
    --- ```lua
    --- function my_function(values)
    ---   -- values must be an associative table
    ---   valid.associative(values, 1, false)
    --- end
    --- ```
    function self.associative(value, argument_index, nil_allowed)
      if nil_allowed and value == nil then
        return
      end

      local last = get_last_traceback_line()
      assert(___.table.associative(value),
        "Invalid value to argument " .. argument_index .. ". Expected associative table, got " .. type(value) .. " in\n" .. last)
    end
    --- Asserts that the statement is true. No return value, but an error is
    --- thrown if the assertion fails. No error is thrown if the value is nil
    --- and nil is allowed.
    ---
    --- @param statement boolean - The statement to validate.
    --- @param value any - The value to validate.
    --- @param argument_index number - The index of the argument.
    --- @param nil_allowed boolean - Whether nil is allowed (default false)
    --- @example
    --- ```lua
    --- function my_function(name)
    ---   -- name must not be empty (mandatory)
    ---   valid.test(not table.is_empty(name), name, 1, false)
    --- end
    --- ```
    function self.test(statement, value, argument_index, nil_allowed)
      if nil_allowed and value == nil then
        return
      end

      local last = get_last_traceback_line()
      assert(statement, "Invalid value to argument " .. argument_index .. ". " .. tostring(value) .. " in\n" .. last)
    end

    --- Asserts that the two values are identical. No return value, but an error
    --- is thrown if the assertion fails. No error is thrown if the value is nil
    --- and nil is allowed.
    ---
    --- @param one any - The first value to validate.
    --- @param two any - The second value to validate.
    --- @example
    --- ```lua
    --- function my_function(name)
    ---   valid.same(name, "John")
    --- end
    --- ```
    function self.same(one, two)
      local last = get_last_traceback_line()
      assert(one == two, "Invalid value to arguments. Expected 1 and 2 to be identical in\n" .. get_last_traceback_line())
    end

    --- Asserts that the two values are of the same type. No return value, but an
    --- error is thrown if the assertion fails. No error is thrown if the value
    --- is nil and nil is allowed.
    ---
    --- @param one any - The first value to validate.
    --- @param two any - The second value to validate.
    --- @example
    --- ```lua
    --- function my_function(name)
    ---   valid.same_type(name, "John")
    --- end
    --- ```
    function self.same_type(one, two)
      local last = get_last_traceback_line()
      assert(type(one) == type(two), "Invalid value to arguments. Expected 1 and 2 to be of the same type in\n" .. last)
    end

    --- Asserts that the value is an object. No return value, but an error is
    --- thrown if the assertion fails. No error is thrown if the value is nil
    --- and nil is allowed.
    ---
    --- @param value any - The value to validate.
    --- @param argument_index number - The index of the argument.
    --- @param nil_allowed boolean - Whether nil is allowed (default false)
    --- @example
    --- ```lua
    --- function my_function(name)
    ---   valid.object(name, 1, false)
    --- end
    --- ```
    function self.object(value, argument_index, nil_allowed)
      if nil_allowed and value == nil then
        return
      end

      local last = get_last_traceback_line()
      assert(___.table.object(value), "Invalid value to argument " .. argument_index .. ". Expected object, got " .. type(value) .. " in\n" .. last)
    end

    --- Asserts that the value is within the range. No return value, but an error
    --- is thrown if the assertion fails. No error is thrown if the value is nil
    --- and nil is allowed.
    ---
    --- @param value any - The value to validate.
    --- @param min number - The minimum value.
    --- @param max number - The maximum value.
    --- @param argument_index number - The index of the argument.
    --- @param nil_allowed boolean - Whether nil is allowed (default false)
    function self.range(value, min, max, argument_index, nil_allowed)
      if nil_allowed and value == nil then
        return
      end

      local last = get_last_traceback_line()
      assert(value >= min and value <= max, "Invalid value to argument " .. argument_index .. ". Expected " .. min .. " to " .. max .. ", got " .. value .. " in\n" .. last)
    end

    function self.file(path, argument_index)
      self.type(path, "string", argument_index, false)
      self.type(argument_index, "number", 2, false)

      local attr = lfs.attributes(path)

      local last = get_last_traceback_line()
      assert(attr ~= nil and attr.mode == "file", "Invalid value. Expected file, got " .. path .. " in\n" .. last)
    end

    function self.dir(path, argument_index)
      self.type(path, "string", argument_index, false)
      self.type(argument_index, "number", 2, false)

      print("valid.dir", path, argument_index)
      local attr = lfs.attributes(path)
      local last = get_last_traceback_line()
      assert(attr ~= nil and attr.mode == "directory", "Invalid value. Expected directory, got " .. path .. " in\n" .. last)
    end
  end
})
