---@diagnostic disable-next-line: undefined-global
local mod = mod or {}
local script_name = "string"
function mod.new(parent)
  local instance = { parent = parent }

  --- string:split(str, delimiter)
  --- Splits a string into a table of substrings based on a delimiter.
  --- @type function
  --- @param str string - The string to split.
  --- @param delimiter string - The delimiter to split the string by.
  --- @return table - A table of substrings.
  function instance:split(str, delimiter)
    local result = {}
    for match in (str .. delimiter):gmatch("(.-)" .. delimiter) do
      table.insert(result, match)
    end
    return result
  end

  --- string:capitalize(str)
  --- Capitalizes the first character of a string.
  ---@param str string - The string to capitalize.
  ---@return string
  function instance:capitalize(str)
    self.parent.valid:type(str, "string", 1, false)
    assert(str ~= "", "Expected a non-empty string")

    local result = str:gsub("^%l", string.upper)
    return result or str
  end

  --- string:trim(str)
  --- Trims whitespace from the beginning and end of a string.
  --- @type function
  --- @param str string - The string to trim.
  --- @return string
  function instance:trim(str)
    self.parent.valid:type(str, "string", 1, false)
    return str:match("^%s*(.-)%s*$")
  end

  --- string:ltrim(str)
  --- Trims whitespace from the left side of a string.
  --- @type function
  --- @param str string - The string to trim.
  --- @return string
  function instance:ltrim(str)
    self.parent.valid:type(str, "string", 1, false)
    return str:match("^%s*(.-)$")
  end

  --- string:rtrim(str)
  --- Trims whitespace from the right side of a string.
  --- @type function
  --- @param str string - The string to trim.
  --- @return string
  function instance:rtrim(str)
    self.parent.valid:type(str, "string", 1, false)
    return str:match("^.-%s*$")
  end

  --- string:strip_linebreaks(str)
  --- Strips line breaks from a string.
  --- @type function
  --- @param str string - The string to strip line breaks from.
  --- @return string
  function instance.strip_linebreaks(str)
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
