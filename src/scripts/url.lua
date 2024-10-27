---@diagnostic disable-next-line: undefined-global
local mod = mod or {}
local script_name = "url"
function mod.new(parent)
  local instance = { parent = parent }

  --- Decodes a string that has been URL-encoded. Useful for decoding query
  --- parameters into a more readable format.
  ---
  --- @param str string - The URL-encoded string to decode.
  --- @return string - The decoded string.
  --- @example
  --- ```lua
  --- url:decode("This%20string%20is%20now%20readable%21%21%21")
  --- -- "This string is now readable!!!"
  --- ```
  function instance:decode(str)
    self.parent.valid:type(str, "string", 1, false)

    str = string.gsub(str, '+', ' ')
    str = string.gsub(str, '%%(%x%x)', function(h)
      return string.char(tonumber(h, 16))
    end)
    return str
  end

  --- Encodes a string into a URL-encoded string. Useful for encoding query
  --- parameters into a URL before sending it to a server.
  ---
  --- @param str string - The string to encode.
  --- @return string - The URL-encoded string.
  --- @example
  --- ```lua
  --- url:encode("This string is now usable in a URL.")
  --- -- "This%20string%20is%20now%20usable%20in%20a%20URL%2E"
  --- ```
  function instance:encode(str)
    self.parent.valid:type(str, "string", 1, false)

    str = string.gsub(str, "([^%w])", function(c)
      return string.format("%%%02X", string.byte(c))
    end)
    return str
  end

  --- Parses a query string into a table of key-value pairs.
  ---
  --- @param query_string string - The query string to parse.
  --- @return table - A table containing the parsed key-value pairs.
  --- @example
  --- ```lua
  --- url:decode_params("name=John&age=30")
  --- -- { name = "John", age = "30" }
  --- ```
  function instance:decode_params(query_string)
    local params = {}
    for key_value in rex.gmatch(query_string, "([^&]+)") do
      local key, value = rex.match(key_value, "([^=]+)=([^=]+)")
      if key and value then
        params[self:decode(key)] = self:decode(value)
      end
    end
    return params
  end

  --- Encodes a table of key-value pairs into a query string.
  ---
  --- @param params table - The table of key-value pairs to encode.
  --- @return string - The encoded query string.
  --- @example
  --- ```lua
  --- url:encode_params({ name = "John", age = "30" })
  --- -- "name=John&age=30"
  --- ```
  function instance:encode_params(params)
    local encoded = {}
    for key, value in pairs(params) do
      table.insert(encoded, self:encode(key) .. "=" .. self:encode(value))
    end
    return table.concat(encoded, "&")
  end

  --- Parses a URL into its components.
  ---
  --- @param url string - The URL to parse.
  --- @return table - A table containing the parsed URL components.
  --- @example
  --- ```lua
  --- url:parse("https://example.com/path/dosomething?name=John&age=30")
  --- -- {
  --- --   protocol = "https",
  --- --   host = "example.com",
  --- --   port = 443,
  --- --   path = "path/dosomething",
  --- --   file = "dosomething",
  --- --   params = {
  --- --     age = "30",
  --- --     name = "John"
  --- --   }
  --- -- }
  --- ```
  function instance:parse(url)
    self.parent.valid:type(url, "string", 1, false)

    local protocol, host, port, path, query_string = rex.match(url, "^(https?)://([^/:]+)(?::(\\d+))?/([^?]*)\\??(.*)")
    local file = rex.match(path, "([^/]+)$")
    local params = self:decode_params(query_string)

    protocol = protocol and protocol or "http"
    port = port and tonumber(port) or
      protocol and (protocol == "http" and 80 or 443)

    local parsed = {
      protocol = protocol,
      host = host,
      port = port,
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
