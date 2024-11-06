local script_name = "string"
local class_name = script_name:title() .. "Class"
local deps = { "table", "valid" }

local mod = Glu.registerClass({
  class_name = class_name,
  script_name = script_name,
  dependencies = deps,
})

function mod.setup(___, self, opts)
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
    ___.valid.type(str, "string", 1, false)
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
    ___.valid.type(str, "string", 1, false)
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
    ___.valid.type(str, "string", 1, false)
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
    ___.valid.type(str, "string", 1, false)
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
    ___.valid.type(str, "string", 1, false)
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
    ___.valid.type(str, "string", 1, false)
    ___.valid.type(pattern, "string", 2, false)
    ___.valid.type(replacement, "string", 3, false)

    while string.find(str, pattern) do
      str = string.gsub(str, pattern, replacement)
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
    ___.valid.type(str, "string", 1, false)
    ___.valid.type(delimiter, "string", 2, true)

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
    ___.valid.type(input, "string", 1, false)
    ___.valid.type(delimiter, "string", 2, true)

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
end
