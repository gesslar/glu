---@diagnostic disable-next-line: lowercase-global
function run_http_tests()
  -- This is a test for the http module.
  local tester_name = "__PKGNAME__"
  local g = Glu(tester_name)
  local testing = g.http
  local test = g.test

  local url = "http://example.com"

  local function http_requires_callback(cond)
    return cond.is_error(function()
      testing.get({ url = url })
    end, "http.get should require a callback")
  end

  local function http_invalid_url(cond)
    return cond.is_error(function()
      testing.get({ url = "not a url" }, function() end)
    end, "http.get should reject invalid url")
  end

  local function http_get_event_mapping(cond)
    local original = _G.getHTTP
    local response

    _G.getHTTP = function() return true end
    local ok, err = pcall(function()
      testing.get({ url = url, headers = {} }, function(resp)
        response = resp
      end)
      raiseEvent("sysGetHttpDone", url, "ok", "server")
    end)
    _G.getHTTP = original

    if not ok then error(err) end
    if not response then
      return cond.is_true(false, "http.get callback was not invoked")
    end

    return cond.is_deeply(
      { response.result.url, response.result.data, response.result.server },
      { url, "ok", "server" },
      "http.get should map response fields"
    )
  end

  local function http_custom_method_dispatch(cond)
    local original = _G.customHTTP
    local called = {}
    local response

    _G.customHTTP = function(method, req_url, headers)
      called.method = method
      called.url = req_url
      called.headers = headers
      return true
    end

    local ok, err = pcall(function()
      testing.request({ method = "PATCH", url = url, headers = {} }, function(resp)
        response = resp
      end)
      raiseEvent("sysCustomHttpDone", url, "ok", "server")
    end)
    _G.customHTTP = original

    if not ok then error(err) end
    if not response then
      return cond.is_true(false, "customHTTP callback was not invoked")
    end

    return cond.is_deeply(
      { called.method, called.url, response.result.url },
      { "PATCH", url, url },
      "customHTTP should be used for non-standard methods"
    )
  end

  local runner = test.runner({
        name = testing.name,
        tests = {
          { name = "http.requires_callback",      func = http_requires_callback },
          { name = "http.invalid_url",            func = http_invalid_url },
          { name = "http.get_event_mapping",      func = http_get_event_mapping },
          { name = "http.custom_method_dispatch", func = http_custom_method_dispatch },
        }
      })
      .execute(true)
      .wipe()
end
