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

    --- Splits a string into a table of strings using PCRE regex. If no
    --- delimiter is provided, it defaults to ".", which will split the string
    --- into individual characters.
    ---
    --- @param str string - The string to split.
    --- @param delimiter string - The regex delimiter to split the string by.
    --- @return table - The split string.
    --- @example
    --- ```lua
    --- string.split("hello world")
    --- -- {"h", "e", "l", "l", "o", " ", "w", "o", "r", "l", "d"}
    ---
    --- string.split("hello world", " ")
    --- -- {"hello", "world"}
    ---
    --- string.split("hello.world", "\\.")
    --- -- {"hello", "world"}
    ---
    --- string.split("hello world", "o")
    --- -- {"hell", " w", "rld"}
    --- ```
    function self.split(str, delimiter)
      ___.v.type(str, "string", 1, false)
      ___.v.type(delimiter, "string", 2, true)

      local t = {}
      delimiter = delimiter or "."

      for part in str:gmatch("[^" .. delimiter .. "]+") do
        table.insert(t, part)
      end

      return t
    end

    --- Walks over a string or table, splitting the string with a PCRE regex
    --- delimiter and returning an iterator.
    ---
    --- @param input string - The string to walk over.
    --- @param delimiter string - The regex delimiter to split the string by.
    --- @return function - The iterator function.
    --- @example
    --- ```lua
    --- for i, part in string.walk("hello world") do
    ---   print(i, part) -- prints 1=h, 2=e, 3=l, 4=l, 5=o, 6= , 7=w, 8=o, 9=r, 10=l, 11=d
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

    --- Checks if a string starts with a given PCRE regex pattern.
    --- If the pattern does not start with "^", it is prepended with "^".
    ---
    --- @param str string - The string to check.
    --- @param start string - The pattern to check for.
    --- @return boolean - Whether the string starts with the pattern.
    --- @example
    --- ```lua
    --- string.starts_with("hello world", "hello")
    --- -- true
    --- ```
    function self.starts_with(str, start)
      ___.v.type(str, "string", 1, false)
      ___.v.type(start, "string", 2, false)

      start = string.sub(start, 1) == "^" and start or "^" .. start

      return rex.match(str, start) ~= nil
    end

    --- Checks if a string ends with a given PCRE regex pattern.
    --- If the pattern does not end with "$", it is appended with "$".
    ---
    --- @param str string - The string to check.
    --- @param ending string - The pattern to check for.
    --- @return boolean - Whether the string ends with the pattern.
    --- @example
    --- ```lua
    --- string.ends_with("hello world", "world")
    --- -- true
    --- ```
    function self.ends_with(str, ending)
      ___.v.type(str, "string", 1, false)
      ___.v.type(ending, "string", 2, false)

      ending = string.sub(ending, 1) == "$" and ending or ending .. "$"

      return rex.match(str, ending) ~= nil
    end

    --- Checks if a string contains a given PCRE regex pattern. The pattern
    --- may not start with "^" or end with "$". For those, use
    --- `string.starts_with` and `string.ends_with`.
    ---
    --- @param str string - The string to check.
    --- @param pattern string - The pattern to check for.
    --- @return boolean - Whether the string contains the pattern.
    --- @example
    --- ```lua
    --- string.contains("hello world", "world")
    --- -- true
    --- ```
    function self.contains(str, pattern)
      ___.v.type(str, "string", 1, false)
      ___.v.type(pattern, "string", 2, false)
      ___.v.test(not self.starts_with(pattern, "^"), "Expected pattern to not start with ^", 2)
      ___.v.test(not self.ends_with(pattern, "$"), "Expected pattern to not end with $", 2)

      return rex.match(str, pattern) ~= nil
    end

    --- Appends a suffix to a string if it does not already end with the suffix.
    ---
    --- @param str string - The string to append to.
    --- @param suffix string - The suffix to append.
    --- @return string - The string with the suffix appended.
    --- @example
    --- ```lua
    --- string.append("hello", " world")
    --- -- "hello world"
    --- ```
    function self.append(str, suffix)
      ___.v.type(str, "string", 1, false)
      ___.v.type(suffix, "string", 2, false)

      return self.ends_with(str, suffix) and str or str .. suffix
    end

    --- Prepends a prefix to a string if it does not already start with the prefix.
    ---
    --- @param str string - The string to prepend to.
    --- @param prefix string - The prefix to prepend.
    --- @return string - The string with the prefix prepended.
    --- @example
    --- ```lua
    --- string.prepend("world", "hello ")
    --- -- "hello world"
    --- ```
    function self.prepend(str, prefix)
      ___.v.type(str, "string", 1, false)
      ___.v.type(prefix, "string", 2, false)

      return self.starts_with(str, prefix) and str or prefix .. str
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

    function is_alpha(char)
      ___.v.type(char, "string", 1, false)
      ___.v.test(#char == 1, "Expected a single character", 1)

      return rex.match(char, "^[a-zA-Z]$") ~= nil
    end

    function is_numeric(char)
      ___.v.type(char, "string", 1, false)
      ___.v.test(#char == 1, "Expected a single character", 1)

      return rex.match(char, "^[0-9]$") ~= nil
    end

    function is_alphanumeric(char)
      ___.v.type(char, "string", 1, false)
      ___.v.test(#char == 1, "Expected a single character", 1)

      return rex.match(char, "^[a-zA-Z0-9]$") ~= nil
    end

    function is_whitespace(char)
      ___.v.type(char, "string", 1, false)
      ___.v.test(#char == 1, "Expected a single character", 1)

      return rex.match(char, "^%s$") ~= nil
    end

    function is_punctuation(char)
      ___.v.type(char, "string", 1, false)
      ___.v.test(#char == 1, "Expected a single character", 1)

      return rex.match(char, "^[^a-zA-Z0-9%s]$") ~= nil
    end

    function is_uppercase(char)
      ___.v.type(char, "string", 1, false)
      ___.v.test(#char == 1, "Expected a single character", 1)

      return rex.match(char, "^[A-Z]$") ~= nil
    end

    -- TODO: handle 1 or more
    function is_lowercase(char)
      ___.v.type(char, "string", 1, false)
      ___.v.test(#char == 1, "Expected a single character", 1)

      return rex.match(char, "^[a-z]$") ~= nil
    end

    function split_natural(str)
      ___.v.type(str, "string", 1, false)

      local resulit, current, is_numeric = {}, {}, false

      local chars = {}
      for c in self.walk(str) do
        local new_is_num = self.is_numeric(c)

        if i > 1 and new_is_num ~= is_num then
          local chunk = table.concat(current)
          if is_num then
            table.push(result, tonumber(chunk))
          else
            table.insert(result, chunk)
          end
          current = {}
        end

        if #current > 0 then
          local chunk = table.concat(current)
          if is_num then
            self.push(result, tonumber(chunk))
          else
            table.insert(result, chunk)
          end
        end
      end
    end

    function natural_compare(a, b)
      local a_parts = self.split_natural(a)
      local b_parts = self.split_natural(b)

      local len = math.min(#a_parts, #b_parts)

      for i = 1, len do
        local a_part, b_part = a_parts[i], b_parts[i]
        local a_type, b_type = type(a_part), type(b_part)

        if a_type == "number" and b_type == "number" then
          if a_part ~= b_part then
            return a_part < b_part
          end
        elseif a_type == "string" and b_type == "string" then
          if a_part ~= b_part then
            return a_part < b_part
          end
        else
          local str_a, str_b = tostring(a_part), tostring(b_part)

          if str_a ~= str_b then
            return str_a < str_b
          end
        end
      end

      return #a_parts < #b_parts
    end

    function self.index_of(str, pattern)
      ___.v.type(str, "string", 1, false)
      ___.v.type(pattern, "string", 2, false)

      return rex.find(str, pattern)
    end
  end
})

-- { "this", " ", "is", " ", "a", " ", "test" }
-- { 1, nil, 1, nil, 1, nil, 1 }

-- this is a thing that is num3rically unsoundh4444, and my favourite number is forty2
