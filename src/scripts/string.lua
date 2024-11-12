local StringClass = Glu.glass.register({
  name = "string",
  class_name = "StringClass",
  dependencies = { "table" },
  setup = function(___, self)
    --- Capitalizes the first character of a string.
    ---
    --- @param str string - The string to capitalize.
    --- @return string - The capitalized string.
    --- @example
    --- ```lua
    --- string.capitalize("hello")
    --- -- "Hello"
    --- ```
    function self.capitalize(str)
      ___.v.type(str, "string", 1, false)
      assert(str ~= "", "Expected a non-empty string")

      local result = str:gsub("^%l", string.upper)
      return result or str
    end

    --- Trims whitespace from the beginning and end of a string.
    ---
    --- @param str string - The string to trim.
    --- @return string - The trimmed string.
    --- @example
    --- ```lua
    --- string.trim("  hello  ")
    --- -- "hello"
    --- ```
    function self.trim(str)
      ___.v.type(str, "string", 1, false)
      return str:match("^%s*(.-)%s*$")
    end

    --- Trims whitespace from the left side of a string.
    ---
    --- @param str string - The string to trim.
    --- @return string - The trimmed string.
    --- @example
    --- ```lua
    --- string.ltrim("  hello  ")
    --- -- "hello  "
    --- ```
    function self.ltrim(str)
      ___.v.type(str, "string", 1, false)
      return str:match("^%s*(.-)$")
    end

    --- Trims whitespace from the right side of a string.
    ---
    --- @param str string - The string to trim.
    --- @return string - The trimmed string.
    --- @example
    --- ```lua
    --- string.rtrim("  hello  ")
    --- -- "  hello"
    --- ```
    function self.rtrim(str)
      ___.v.type(str, "string", 1, false)
      return str:match("^.-%s*$")
    end

    --- Strips line breaks from a string.
    ---
    --- @param str string - The string to strip line breaks from.
    --- @return string - The string with line breaks removed.
    --- @example
    --- ```lua
    --- string.strip_linebreaks("hello\nworld")
    --- -- "helloworld"
    --- ```
    function self.strip_linebreaks(str)
      ___.v.type(str, "string", 1, false)
      local result, found, subbed = rex.gsub(str, "[\\r\\n]", "")
      return result or str
    end

    --- Replaces all occurrences of a pattern in a string.
    ---
    --- @param str string - The string to replace occurrences in.
    --- @param pattern string - The pattern to replace.
    --- @param replacement string - The replacement string.
    --- @return string - The string with occurrences replaced.
    --- @example
    --- ```lua
    --- string.replace("hello world", "o", "a")
    --- -- "hella warld"
    --- ```
    function self.replace(str, pattern, replacement)
      ___.v.type(str, "string", 1, false)
      ___.v.type(pattern, "string", 2, false)
      ___.v.type(replacement, "string", 3, false)

      while string.find(str, pattern) do
        str = string.gsub(str, pattern, replacement) or str
      end

      return str
    end

    --- Splits a string into a table of strings.
    ---
    --- @param str string - The string to split.
    --- @param delimiter string - The delimiter to split the string by. (Optional, defaults to ".")
    --- @return table - The split string.
    --- @example
    --- ```lua
    --- string.split("hello world", " ")
    --- -- {"hello", "world"}
    ---
    --- string.split("hello.world")
    --- -- {"hello", "world"}
    --- ```
    function self.split(str, delimiter)
      ___.v.type(str, "string", 1, false)
      ___.v.type(delimiter, "string", 2, true)

      local t = {}
      if not delimiter then
        -- Split by character
        for c in str:gmatch(".") do
          table.insert(t, c)
        end
      else
        -- Split by delimiter
        for part in str:gmatch("[^" .. delimiter .. "]+") do
          table.insert(t, part)
        end
      end

      return t
    end

    --- Walks over a string or table, splitting the string and returning an iterator.
    ---
    --- @param input string - The string to walk over.
    --- @param delimiter string - The delimiter to split the string by. (Optional, defaults to ".")
    --- @return function - The iterator function.
    --- @example
    --- ```lua
    --- for i, part in string.walk("hello.world") do
    ---   print(i, part) -- prints 1=hello, 2=world
    --- end
    --- ```
    function self.walk(input, delimiter)
      ___.v.type(input, "string", 1, false)
      ___.v.type(delimiter, "string", 2, true)

      local data
      if type(input) == "string" then
        data = self.split(input, delimiter)
      else
        data = input
      end

      return ___.table.walk(data)
    end

    function self.explode(input, delimiter)
      if type(input) == "string" then
        return self.split(input, delimiter)
      elseif type(input) == "table" then
        return input
      end

      error("Input must be string or table")
    end

    --- Formats a number with thousands separators and decimal places.
    --- If not specified, defaults to "," for thousands and "." for decimal.
    ---
    --- @example
    --- ```lua
    --- string.format_number(1234567.89)
    --- -- "1,234,567.89"
    --- ```
    --- @param number string|number - The number to format (number or string)
    --- @param thousands string - The thousands separator (optional, defaults to ",")
    --- @param decimal string - The decimal separator (optional, defaults to ".")
    --- @return string - The formatted number
    function self.format_number(number, thousands, decimal)
      ___.v.type(number, { "number|string" }, 1, false)
      ___.v.type(thousands, "string", 2, true)
      ___.v.type(decimal, "string", 3, true)

      -- Set defaults
      thousands = thousands or ","
      decimal = decimal or "."

      number = tonumber(number) or 0
      local is_negative = not ___.number.positive(number)
      number = math.abs(number)

      -- Convert to string if needed
      local numStr = tostring(number)

      -- Split integer and decimal parts
      local intPart, decPart = numStr:match("([^%.]*)%.?(.*)")

      -- Add thousands separators to integer part
      local formatted = ""
      local length = #intPart

      for i = 1, length do
        if i > 1 and (length - i + 1) % 3 == 0 then
          formatted = thousands .. formatted
        end
        formatted = intPart:sub(length - i + 1, length - i + 1) .. formatted
      end

      -- Add decimal part if it exists
      if decPart and decPart ~= "" then
        formatted = formatted .. decimal .. decPart
      end

      -- Restore negative sign if needed
      if is_negative then formatted = "-" .. formatted end

      return formatted
    end

    --- Parses a formatted number string back to a number.
    ---
    --- @param str string - The formatted number string.
    --- @param thousands string - The thousands separator (optional, defaults to ",").
    --- @param decimal string - The decimal separator (optional, defaults to ".").
    --- @return number - The parsed number.
    --- @example
    --- ```lua
    --- string.parse_formatted_number("1,234,567.89")
    --- -- 1234567.89
    --- ```
    function self.parse_formatted_number(str, thousands, decimal)
      ___.v.type(str, "string", 1, false)
      ___.v.type(thousands, "string", 2, true)
      ___.v.type(decimal, "string", 3, true)

      thousands = thousands or ","
      decimal = decimal or "."

      -- Remove thousands separators
      str = str:gsub(thousands, "") or str

      -- Convert decimal separator to period if different
      if decimal ~= "." then
        str = str:gsub(decimal, ".") or str
      end

      -- Convert to number
      return tonumber(str) or 0
    end

    --- Implementation of reg_assoc for Mudlet using rex PCRE support
    --- @param text string - The text to search through
    --- @param patterns table - The patterns to search for
    --- @param tokens table - The tokens to replace the patterns with
    --- @param default_token string - The default token to use if no pattern is found (optional, defaults to "")
    --- @return table,table - A table of results and token list
    --- @example
    --- ```lua
    --- string.reg_assoc("hello world", {"hello", "world"}, {"foo", "bar"})
    --- -- {"foo", "bar"}
    --- ```
    function self.reg_assoc(text, patterns, tokens, default_token)
      default_token = default_token or -1
      local work = text

      local results = {}
      local token_list = {}


      while #work > 0 do
        local nearest_from, nearest_match, nearest_token = nil, nil, nil

        for i, pattern in ipairs(patterns) do
          local from, to = rex.find(work, pattern)
          if from and to then
            if not nearest_from or from < nearest_from then
              nearest_from, nearest_match, nearest_token =
              from, work:sub(from, to), tokens[i] or default_token
            end
          end
        end

        local prematch = ""
        local token = nearest_token or default_token
        local match = nearest_match or work
        nearest_from = nearest_from or #work
        prematch = work:sub(1, nearest_from - 1 or nil)
        print("Prematch = `" .. tostring(prematch) .. "` with token `" .. tostring(token) .. "` and match `" .. tostring(match) .. "`")

        work = work:sub(nearest_from + #match) or ""
--[[
        if nearest_from then
          token = nearest_token or default_token
          match = nearest_match or work
          prematch = ""
        else
          token = default_token
          nearest_from = #work
          match = work
          work = ""
          break
        end

        -- The text between 1 and the nearest match
        local pre_match = work:sub(1, nearest_from - 1 or nil)
--]]
        -- Add it to the results
        table.insert(results, pre_match)
        table.insert(token_list, default_token)

        if #match > 0 then
          table.insert(results, match)
          table.insert(token_list, token)
        end
      end

      return results, token_list
    end
  end
})

-- { "this", " ", "is", " ", "a", " ", "test" }
-- { 1, nil, 1, nil, 1, nil, 1 }

-- this is a thing that is num3rically unsoundh4444, and my favourite number is forty2
