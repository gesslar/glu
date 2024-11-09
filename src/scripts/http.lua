local HttpResponseClass = Glu.glass.register({
  name = "http_response",
  class_name = "HttpResponseClass",
  dependencies = { "table", "valid" },
  setup = function(___, self, response)
    self.id = response.id
    self.result = response
  end
})

local HttpRequestClass = Glu.glass.register({
  name = "http_request",
  class_name = "HttpRequestClass",
  dependencies = { "table", "valid" },
  setup = function(___, self, options)
    self.options = options

    function self.execute()
      local owner = self.container

      self.id = ___.id()

      -- Headers
      if not self.options.headers then self.options.headers = {} end
      if type(self.options.headers) ~= "table" then
        error("headers must be a table")
      end

      self.headers = self.options.headers

      local function write_file(filepath, data)
        local dir, file = ___.fd.dir_file(filepath, true)
        if dir and file then
          return ___.fd.write_file(filepath, data, true)
        else
          return nil, "Invalid file path."
        end
      end

      local function done(response_data)
        local ob_id = response_data.id
        local ob = owner.find_request(ob_id)

        if self.options.saveTo and not response_data.error then
          local result = { write_file(self.options.saveTo, response_data.data) }
        end

        local cb = self.options.callback
        local response = HttpResponseClass(response_data, owner)

        cb(response)
        deleteAllNamedEventHandlers(ob_id)
        owner.delete_request(ob_id)
        ob = nil
      end

      -- Events to listen for
      local events = {}
      local lc = table.index_of(owner.http_types, self.options.method) and
      string.lower(self.options.method) or "custom"
      local uc = string.title(___.string.capitalize(lc))

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
          self.id,
          event_name,
          event_name,
          function(e, ...)
            local response = {
              event = e,
              id = self.id,
            }
            local result
            arg = only_indexed(arg)
            if rex.match(e, "sys(?:\\w+)HttpError$") then
              result = ___.table.allocate({ "error", "url", "server" }, arg)
            elseif rex.match(e, "sys(?:\\w+)HttpDone$") then
              result = ___.table.allocate({ "url", "data", "server" }, arg)
            else
              error("Unknown event: " .. e)
            end

            ___.table.add(response, result)

            done(response)
          end
        )
      end

      self.method_lc = lc
      self.method_uc = uc
      self.custom = self.options.method == "CUSTOM"

      local func_name = string.format("%sHTTP", lc)
      local func = _G[func_name]

      assert(func, "HTTP method " .. func_name .. " not found")
      assert(type(func) == "function", "HTTP method " .. func_name .. " is not a function")

      local ok, err, result = pcall(
        self.custom and
          function() return func(self.options.method, self.options.url, self.options.headers) end or
          function() return func(self.options.url, self.options.headers) end
      )

      if not ok then
        error("Error calling HTTP method " .. tostring(self.custom) .. " " .. tostring(func) .. ": " .. tostring(err))
      end

      return self
    end
  end
})

local HttpClass = Glu.glass.register({
  name = "http",
  class_name = "HttpClass",
  dependencies = { "table", "valid" },
  setup = function(___, self)
    local function validate_options(options)
      ___.valid.type(options, "table", 1, false)
      ___.valid.not_empty(options, 1, false)
      ___.valid.type(options.method, "string", 2, false)
      ___.valid.regex(options.url, ___.regex.http_url, "url", 1, false)
      ___.valid.type(options.callback, "function", 1, false)
    end

    self.http_types = { "GET", "PUT", "POST", "DELETE" }

    local requests = {}

    --- Downloads a file from the given URL and saves it to the specified path.
    --- You may certainly also use the `get` or `request` methods to download a
    --- file, however, this is a bit more convenient as it does some checking
    --- for you.
    ---
    --- @param options table - The options for the request.
    --- @param cb function - The callback function.
    --- @return table - The HTTP request object.
    --- @example
    --- ```lua
    --- http.download({
    ---   url = "http://example.com/file.txt",
    ---   saveTo = "path/to/file.txt"
    --- }, function(response) end)
    --- ```
    function self.download(options, cb)
      options.method = options.method or "GET"
      ___.valid.type(options.saveTo, "string", 1, false)
      return self.request(options, cb)
    end

    --- Makes a GET request to the given URL.
    ---
    --- The options table may consist of the following keys:
    ---
    --- - `url` (`string`) - The URL to request.
    --- - `headers` (`table`) - The headers to send with the request.
    ---
    --- @param options table - The options for the request.
    --- @param cb function - The callback function.
    --- @return table - The HTTP request object.
    --- @example
    --- ```lua
    --- http.get({
    ---   url = "http://example.com/file.txt"
    --- }, function(response) end)
    --- ```
    function self.get(options, cb)
      options.method = "GET"
      return self.request(options, cb)
    end

    --- Makes a POST request to the given URL.
    ---
    --- The options table may consist of the following keys:
    ---
    --- - `url` (`string`) - The URL to request.
    --- - `headers` (`table`) - The headers to send with the request.
    ---
    --- @param options table - The options for the request.
    --- @param cb function - The callback function.
    --- @return table - The HTTP request object.
    --- @example
    --- ```lua
    --- http.post({
    ---   url = "http://example.com/file.txt"
    --- }, function(response) end)
    --- ```
    function self.post(options, cb)
      options.method = "POST"
      return self.request(options, cb)
    end

    --- Makes a PUT request to the given URL.
    ---
    --- The options table may consist of the following keys:
    ---
    --- - `url` (`string`) - The URL to request.
    --- - `headers` (`table`) - The headers to send with the request.
    ---
    --- @param options table - The options for the request.
    --- @param cb function - The callback function.
    --- @return table - The HTTP request object.
    --- @example
    --- ```lua
    --- http.put({
    ---   url = "http://example.com/file.txt"
    --- }, function(response) end)
    --- ```
    function self.put(options, cb)
      options.method = "PUT"
      return self.request(options, cb)
    end

    --- Makes a DELETE request to the given URL.
    ---
    --- The options table may consist of the following keys:
    ---
    --- - `url` (`string`) - The URL to request.
    --- - `headers` (`table`) - The headers to send with the request.
    ---
    --- @param options table - The options for the request.
    --- @param cb function - The callback function.
    --- @return table - The HTTP request object.
    --- @example
    --- ```lua
    --- http.delete({
    ---   url = "http://example.com/file.txt"
    --- }, function(response) end)
    --- ```
    function self.delete(options, cb)
      options.method = "DELETE"
      return self.request(options, cb)
    end

    --- Makes a request to the given URL. Use this option for any HTTP method
    --- that is not: `GET`, `POST`, `PUT`, or `DELETE`.
    ---
    --- The options table may consist of the following keys:
    ---
    --- - `url` (`string`) - The URL to request.
    --- - `method` (`string`) - The HTTP method to use.
    --- - `headers` (`table`) - The headers to send with the request.
    ---
    --- @param options table - The options for the request.
    --- @param cb function|nil - The callback function.
    --- @return table - The HTTP request object.
    --- @example
    --- ```lua
    --- http.request({
    ---   url = "http://example.com/file.txt"
    --- }, function(response) end)
    --- ```
    function self.request(options, cb)
      validate_options(options)

      -- upper case the method
      options.method = string.upper(options.method)

      -- Add the callback if it was manually provided.
      options.callback = options.callback or cb

      -- Get a new http request object
      local request = HttpRequestClass(options, self).execute()
      table.insert(requests, request)
      return request
    end

    function self.delete_request(id)
      for i = 1, #requests do
        if requests[i].id == id then
          table.remove(requests, i)
          break
        end
      end
    end

    function self.find_request(id)
      for _, request in ipairs(requests) do
        if request.id == id then
          return request
        end
      end
      return nil
    end
  end
})
