describe("url module", function()
  local g

  setup(function()
    g = Glu("Glu")
  end)

  -- ========================================================================
  -- decode
  -- ========================================================================

  describe("decode", function()
    it("should decode percent-encoded characters", function()
      assert.are.equal("hello world!", g.url.decode("hello%20world%21"))
    end)

    it("should decode plus signs as spaces", function()
      assert.are.equal("hello world", g.url.decode("hello+world"))
    end)

    it("should return plain string unchanged", function()
      assert.are.equal("hello", g.url.decode("hello"))
    end)

    it("should decode special characters", function()
      assert.are.equal("a&b=c", g.url.decode("a%26b%3Dc"))
    end)

    it("should handle empty string", function()
      assert.are.equal("", g.url.decode(""))
    end)

    it("should error on non-string input", function()
      assert.has_error(function()
        g.url.decode(123)
      end)
    end)

    it("should error on nil input", function()
      assert.has_error(function()
        g.url.decode(nil)
      end)
    end)
  end)

  -- ========================================================================
  -- encode
  -- ========================================================================

  describe("encode", function()
    it("should encode spaces", function()
      assert.are.equal("hello%20world", g.url.encode("hello world"))
    end)

    it("should encode special characters", function()
      assert.are.equal("a%26b%3Dc", g.url.encode("a&b=c"))
    end)

    it("should leave alphanumeric characters unchanged", function()
      assert.are.equal("hello123", g.url.encode("hello123"))
    end)

    it("should encode punctuation", function()
      assert.are.equal("hello%21", g.url.encode("hello!"))
    end)

    it("should handle empty string", function()
      assert.are.equal("", g.url.encode(""))
    end)

    it("should error on non-string input", function()
      assert.has_error(function()
        g.url.encode(123)
      end)
    end)

    it("should error on nil input", function()
      assert.has_error(function()
        g.url.encode(nil)
      end)
    end)
  end)

  -- ========================================================================
  -- encode / decode round-trip
  -- ========================================================================

  describe("encode/decode round-trip", function()
    it("should round-trip simple text", function()
      local original = "hello world"
      assert.are.equal(original, g.url.decode(g.url.encode(original)))
    end)

    it("should round-trip special characters", function()
      local original = "a&b=c?d#e"
      assert.are.equal(original, g.url.decode(g.url.encode(original)))
    end)

    it("should round-trip empty string", function()
      assert.are.equal("", g.url.decode(g.url.encode("")))
    end)
  end)

  -- ========================================================================
  -- decode_params
  -- ========================================================================

  describe("decode_params", function()
    it("should parse simple key-value pairs", function()
      local result = g.url.decode_params("name=John&age=30")
      assert.are.equal("John", result.name)
      assert.are.equal("30", result.age)
    end)

    it("should decode encoded keys and values", function()
      local result = g.url.decode_params("first%20name=John%20Doe")
      assert.are.equal("John Doe", result["first name"])
    end)

    it("should handle single parameter", function()
      local result = g.url.decode_params("key=value")
      assert.are.equal("value", result.key)
    end)

    it("should return empty table for empty string", function()
      local result = g.url.decode_params("")
      assert.are.same({}, result)
    end)

    it("should handle empty values", function()
      local result = g.url.decode_params("key=")
      assert.are.equal("", result.key)
    end)

    it("should handle mix of empty and non-empty values", function()
      local result = g.url.decode_params("a=1&b=&c=3")
      assert.are.equal("1", result.a)
      assert.are.equal("", result.b)
      assert.are.equal("3", result.c)
    end)
  end)

  -- ========================================================================
  -- encode_params
  -- ========================================================================

  describe("encode_params", function()
    it("should encode simple key-value pairs", function()
      local result = g.url.encode_params({key = "value"})
      assert.are.equal("key=value", result)
    end)

    it("should encode special characters in keys and values", function()
      local result = g.url.encode_params({["my key"] = "my value"})
      assert.are.equal("my%20key=my%20value", result)
    end)

    it("should handle empty table", function()
      local result = g.url.encode_params({})
      assert.are.equal("", result)
    end)

    it("should join multiple params with ampersand", function()
      local result = g.url.encode_params({a = "1", b = "2"})
      -- Order is not guaranteed from pairs(), so check both parts exist
      assert.is_truthy(string.find(result, "a=1"))
      assert.is_truthy(string.find(result, "b=2"))
      assert.is_truthy(string.find(result, "&"))
    end)
  end)

  -- ========================================================================
  -- encode_params / decode_params round-trip
  -- ========================================================================

  describe("encode_params/decode_params round-trip", function()
    it("should round-trip simple params", function()
      local original = {name = "John", age = "30"}
      local encoded = g.url.encode_params(original)
      local decoded = g.url.decode_params(encoded)
      assert.are.same(original, decoded)
    end)

    it("should round-trip params with special characters", function()
      local original = {["my key"] = "my value"}
      local encoded = g.url.encode_params(original)
      local decoded = g.url.decode_params(encoded)
      assert.are.same(original, decoded)
    end)
  end)

  -- ========================================================================
  -- parse
  -- ========================================================================

  describe("parse", function()
    it("should parse a full URL with query params", function()
      local result = g.url.parse("https://example.com/path/to/page?name=John&age=30")
      assert.are.equal("https", result.protocol)
      assert.are.equal("example.com", result.host)
      assert.are.equal(443, result.port)
      assert.are.equal("path/to/page", result.path)
      assert.are.equal("page", result.file)
      assert.are.equal("John", result.params.name)
      assert.are.equal("30", result.params.age)
    end)

    it("should parse http URL with default port 80", function()
      local result = g.url.parse("http://example.com/page?q=1")
      assert.are.equal("http", result.protocol)
      assert.are.equal(80, result.port)
    end)

    it("should parse URL with explicit port", function()
      local result = g.url.parse("https://example.com:8080/path?q=1")
      assert.are.equal(8080, result.port)
      assert.are.equal("example.com", result.host)
    end)

    it("should parse URL without query string", function()
      local result = g.url.parse("https://example.com/path/file.txt")
      assert.are.equal("https", result.protocol)
      assert.are.equal("example.com", result.host)
      assert.are.equal("path/file.txt", result.path)
      assert.are.equal("file.txt", result.file)
      assert.are.same({}, result.params)
    end)

    it("should extract filename from path", function()
      local result = g.url.parse("https://example.com/a/b/c/file.lua?x=1")
      assert.are.equal("file.lua", result.file)
    end)

    it("should parse URL with single path segment", function()
      local result = g.url.parse("https://example.com/page?x=1")
      assert.are.equal("page", result.path)
      assert.are.equal("page", result.file)
    end)

    it("should parse URL without path", function()
      local result = g.url.parse("https://example.com")
      assert.are.equal("https", result.protocol)
      assert.are.equal("example.com", result.host)
      assert.are.equal(443, result.port)
      assert.is_nil(result.path)
      assert.is_nil(result.file)
      assert.are.same({}, result.params)
    end)

    it("should parse URL with only query string and no path", function()
      local result = g.url.parse("https://example.com?q=search")
      assert.are.equal("example.com", result.host)
      assert.are.equal("search", result.params.q)
      assert.is_nil(result.path)
    end)

    it("should parse URL with trailing slash and no path", function()
      local result = g.url.parse("https://example.com/")
      assert.are.equal("example.com", result.host)
      assert.are.equal("", result.path)
      assert.are.equal("", result.file)
    end)

    it("should error on non-string input", function()
      assert.has_error(function()
        g.url.parse(123)
      end)
    end)

    it("should error on nil input", function()
      assert.has_error(function()
        g.url.parse(nil)
      end)
    end)
  end)
end)
