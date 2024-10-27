---@diagnostic disable-next-line: undefined-global
local mod = mod or {}
local script_name = "string"
function mod.new(parent)
  local instance = { parent = parent }

  --- Capitalizes the first character of a string.
  ---
  --- @param str string - The string to capitalize.
  --- @return string - The capitalized string.
  --- @example
  --- ```lua
  --- string:capitalize("hello")
  --- -- "Hello"
  --- ```
  function instance:capitalize(str)
    self.parent.valid:type(str, "string", 1, false)
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
  --- string:trim("  hello  ")
  --- -- "hello"
  --- ```
  function instance:trim(str)
    self.parent.valid:type(str, "string", 1, false)
    return str:match("^%s*(.-)%s*$")
  end

  --- Trims whitespace from the left side of a string.
  ---
  --- @param str string - The string to trim.
  --- @return string - The trimmed string.
  --- @example
  --- ```lua
  --- string:ltrim("  hello  ")
  --- -- "hello  "
  --- ```
  function instance:ltrim(str)
    self.parent.valid:type(str, "string", 1, false)
    return str:match("^%s*(.-)$")
  end

  --- Trims whitespace from the right side of a string.
  ---
  --- @param str string - The string to trim.
  --- @return string - The trimmed string.
  --- @example
  --- ```lua
  --- string:rtrim("  hello  ")
  --- -- "  hello"
  --- ```
  function instance:rtrim(str)
    self.parent.valid:type(str, "string", 1, false)
    return str:match("^.-%s*$")
  end

  --- Strips line breaks from a string.
  ---
  --- @param str string - The string to strip line breaks from.
  --- @return string - The string with line breaks removed.
  --- @example
  --- ```lua
  --- string:strip_linebreaks("hello\nworld")
  --- -- "helloworld"
  --- ```
  function instance:strip_linebreaks(str)
    local result, found, subbed = rex.gsub(str, "[\\r\\n]", "")
    return result or str
  end

  instance.parent.valid = instance.parent.valid or setmetatable({}, {
    __index = function(_, k) return function(...) end end
  })

  return instance
end

-- Let Glu know we're here
raiseEvent("glu_module_loaded", script_name, mod)

return mod
