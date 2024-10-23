local script_name = "http"

local requests = {}
local http_types = { "GET", "PUT", "POST", "DELETE" }

local function newResponse(parent, err, url)
  return {
    type = "response",
    id = parent.parent.util.generate_uuid(),
    parent = parent,
    err = err,
    url = url,
  }
end

local function newHttp(parent, options)
  local id = parent.parent.util.generate_uuid()
  local instance = {
    id = id,
    parent = parent,
    options = options,
  }

  -- Headers
  if not options.headers then options.headers = {} end
  if type(options.headers) ~= "table" then
    error("headers must be a table")
  end
  instance.headers = options.headers

  local function write_file(self, filepath, data)
    local dir, file = self.parent.parent.fd:dir_file(filepath, true)
    if dir and file then
      return self.parent.parent.fd:write_file(filepath, data, true)
    else
      return nil, "Invalid file path."
    end
  end

  local function done(self, response)
    local ob_id = response.id
    local ob = requests[ob_id]

    display(response)

    if self.options.saveTo and not response.error then
      local result = { write_file(self, self.options.saveTo, response.data) }
      display(result)
    end

    local cb = self.options.cb

    cb(response)
    deleteAllNamedEventHandlers(ob_id)
    requests[ob_id] = nil
    ob = nil
    instance = nil
  end

  -- Events to listen for
  local events = {}
  local lc = table.index_of(http_types, options.method) and
    string.lower(options.method) or
    "custom"
  local uc = string.title(parent.parent.string:capitalize(lc))

  for _, event in ipairs({"Done", "Error"}) do
    local event_mod = string.format("sys%sHttp%s", uc, event)
    table.insert(events, { event, event_mod })
  end

  local function only_indexed(t)
    local tmp = {}
    for i = 1, #t do
      tmp[i] = t[i]
    end
    return tmp
  end

  for _, event in ipairs(events) do
    local event_type, event_name = unpack(event)
    registerNamedEventHandler(
      instance.id,
      event_name,
      event_name,
      function(e, ...)
        local response = {
          event = e,
          id = instance.id,
          parent = instance,
        }
        local result
        arg = only_indexed(arg)
        display(arg)
        if rex.match(e, "sys(?:\\w+)HttpError$") then
          result = parent.parent.table:allocate({ "error", "url", "server" }, arg)
        elseif rex.match(e, "sys(?:\\w+)HttpDone$") then
          result = parent.parent.table:allocate({ "url", "data", "server" }, arg)
        else
          error("Unknown event: " .. e)
        end

        response = table.union(response, result)

        done(instance, response)
      end
    )
  end

  instance.method_lc = lc
  instance.method_uc = uc
  instance.custom = options.method == "CUSTOM"

  local func_name = string.format("%sHTTP", lc)
  local func = _G[func_name]

  assert(func, "HTTP method " .. func_name .. " not found")
  assert(type(func) == "function", "HTTP method " .. func_name .. " is not a function")

  local ok, err, result = pcall(
    instance.custom and
      function() return func(options.method, options.url, options.headers) end or
      function() return func(options.url, options.headers) end
  )

  if not ok then
    error("Error calling HTTP method " .. tostring(instance.custom) .. " " .. tostring(func) .. ": " .. tostring(err))
  end

  setmetatable(instance, { __index = instance })

  return instance
end

---@diagnostic disable-next-line: undefined-global
local mod = mod or {}
function mod.new(parent)
  local instance = { parent = parent, type = "http" }

  local function validate_options(self, options)
    self.parent.valid:type(options, "table", 1, false)
    self.parent.valid:not_empty(options, 1, false)
    self.parent.valid:type(options.method, "string", 2, false)

    -- We must have a URL
    self.parent.valid:regex(options.url, self.parent.regex.http_url, "url", 1,
      false
    )
  end

  function instance:download(options, cb)
    options.method = options.method or "GET"
    self.parent.valid:type(options.saveTo, "string", 1, false)
    return instance:request(options, cb)
  end

  function instance:get(options, cb)
    options.method = "GET"
    return instance:request(options, cb)
  end

  function instance:post(options, cb)
    options.method = "POST"
    return instance:request(options, cb)
  end

  function instance:put(options, cb)
    options.method = "PUT"
    return instance:request(options, cb)
  end

  function instance:delete(options, cb)
    options.method = "DELETE"
    return instance:request(options, cb)
  end

  function instance:request(options, cb)
    validate_options(self, options)

    -- upper case the method
    options.method = string.upper(options.method)

    -- We must have a callback
    self.parent.valid:type(cb, "function", 2, false)
    options.cb = cb

    -- Get a new http object
    local request = newHttp(self, options)
    requests[request.id] = request
    return request
  end

  instance.parent.valid = instance.parent.valid or setmetatable({}, {
    __index = function(_, k) return function(...) end end
  })

  return instance
end

-- Let Glu know we're here
raiseEvent("glu_module_loaded", script_name, mod)

return mod
