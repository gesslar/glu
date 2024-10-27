---@diagnostic disable-next-line: undefined-global
local mod = mod or {}
local script_name = "url"
function mod.new(parent)
  local instance = { parent = parent }

  --- Decodes a URL-encoded string.
  --- @param str string - The URL-encoded string to decode.
  --- @return string - The decoded string.
  function instance:decode(str)
    self.parent.valid:type(str, "string", 1, false)

    str = string.gsub(str, '+', ' ')
    str = string.gsub(str, '%%(%x%x)', function(h)
      return string.char(tonumber(h, 16))
    end)
    return str
  end

  function instance:encode(str)
    self.parent.valid:type(str, "string", 1, false)

    str = string.gsub(str, "([^%w])", function(c)
      return string.format("%%%02X", string.byte(c))
    end)
    return str
  end

  function instance:parse_params(query_string)
    local params = {}
    for key_value in string.gmatch(query_string, "([^&]+)") do
      local key, value = string.match(key_value, "([^=]+)=([^=]+)")
      if key and value then
        params[self:decode(key)] = self:decode(value)
      end
    end
    return params
  end

  --- Parses a URL into its components.
  --- @param url string - The URL to parse.
  --- @return table - A table containing the parsed URL components.
  function instance:parse(url)
    self.parent.valid:type(url, "string", 1, false)

    local protocol, host, path, query_string = string.match(url, "^(https?)://([^/]+)/([^?]*)%??(.*)")
    local file = string.match(path, "([^/]+)$")
    local params = self:parse_params(query_string)
    local parsed = {
      protocol = protocol,
      host = host,
      path = path,
      file = file,
      params = params
    }

    return parsed
  end

  instance.parent.valid = instance.parent.valid or setmetatable({}, {
    __index = function(_, k) return function(...) end end
  })

  return instance
end

-- Let Glu know we're here
raiseEvent("glu_module_loaded", script_name, mod)

return mod
