describe("string module", function()
  local g

  setup(function()
    g = Glu("Glu")
  end)

  describe("capitalize", function()
    it("should capitalize the first character", function()
      assert.are.equal("Hello", g.string.capitalize("hello"))
    end)

    it("should leave already capitalized strings unchanged", function()
      assert.are.equal("Hello", g.string.capitalize("Hello"))
    end)

    it("should handle single character", function()
      assert.are.equal("A", g.string.capitalize("a"))
    end)

    it("should leave non-alpha first character unchanged", function()
      assert.are.equal("123abc", g.string.capitalize("123abc"))
    end)

    it("should error on empty string", function()
      assert.has_error(function()
        g.string.capitalize("")
      end)
    end)

    it("should error on non-string argument", function()
      assert.has_error(function()
        g.string.capitalize(123)
      end)
    end)
  end)

  describe("trim", function()
    it("should trim whitespace from both sides", function()
      assert.are.equal("hello", g.string.trim("  hello  "))
    end)

    it("should handle strings with no whitespace", function()
      assert.are.equal("hello", g.string.trim("hello"))
    end)

    it("should trim tabs", function()
      assert.are.equal("hello", g.string.trim("\thello\t"))
    end)

    it("should trim mixed whitespace", function()
      assert.are.equal("hello", g.string.trim(" \t hello \t "))
    end)

    it("should return empty string for whitespace-only input", function()
      assert.are.equal("", g.string.trim("   "))
    end)

    it("should error on non-string argument", function()
      assert.has_error(function()
        g.string.trim(123)
      end)
    end)
  end)

  describe("ltrim", function()
    it("should trim whitespace from the left", function()
      assert.are.equal("hello  ", g.string.ltrim("  hello  "))
    end)

    it("should trim tabs from the left", function()
      assert.are.equal("hello\t", g.string.ltrim("\thello\t"))
    end)

    it("should not affect right-side whitespace", function()
      assert.are.equal("hello   ", g.string.ltrim("   hello   "))
    end)
  end)

  describe("rtrim", function()
    it("should trim whitespace from the right", function()
      assert.are.equal("  hello", g.string.rtrim("  hello  "))
    end)

    it("should trim tabs from the right", function()
      assert.are.equal("\thello", g.string.rtrim("\thello\t"))
    end)

    it("should not affect left-side whitespace", function()
      assert.are.equal("   hello", g.string.rtrim("   hello   "))
    end)
  end)

  describe("strip_linebreaks", function()
    it("should remove newlines", function()
      assert.are.equal("helloworld", g.string.strip_linebreaks("hello\nworld"))
    end)

    it("should remove carriage returns", function()
      assert.are.equal("helloworld", g.string.strip_linebreaks("hello\r\nworld"))
    end)

    it("should remove multiple linebreaks", function()
      assert.are.equal("abc", g.string.strip_linebreaks("a\nb\r\nc"))
    end)

    it("should return unchanged string with no linebreaks", function()
      assert.are.equal("hello", g.string.strip_linebreaks("hello"))
    end)
  end)

  describe("replace", function()
    it("should replace all occurrences of a pattern", function()
      assert.are.equal("hella warld", g.string.replace("hello world", "o", "a"))
    end)

    it("should return unchanged string when no match", function()
      assert.are.equal("hello", g.string.replace("hello", "x", "y"))
    end)

    it("should handle replacing with empty string", function()
      assert.are.equal("hll wrld", g.string.replace("hello world", "[eo]", ""))
    end)

    it("should error on non-string arguments", function()
      assert.has_error(function()
        g.string.replace(123, "o", "a")
      end)
    end)
  end)

  describe("split", function()
    it("should split by delimiter", function()
      local result = g.string.split("hello world", " ")
      assert.are.same({"hello", "world"}, result)
    end)

    it("should return whole string when no delimiter matches", function()
      local result = g.string.split("abc")
      assert.are.same({"abc"}, result)
    end)

    it("should split on dots with dot delimiter", function()
      local result = g.string.split("hello.world", ".")
      assert.are.same({"hello", "world"}, result)
    end)

    it("should split into multiple parts", function()
      local result = g.string.split("a,b,c,d", ",")
      assert.are.same({"a", "b", "c", "d"}, result)
    end)

    it("should skip empty segments between consecutive delimiters", function()
      local result = g.string.split("a,,b", ",")
      assert.are.same({"a", "b"}, result)
    end)

    it("should handle single character string", function()
      local result = g.string.split("x", ",")
      assert.are.same({"x"}, result)
    end)

    it("should error on non-string first argument", function()
      assert.has_error(function()
        g.string.split(123, ",")
      end)
    end)
  end)

  describe("walk", function()
    it("should iterate over split parts", function()
      local parts = {}
      for i, part in g.string.walk("a,b,c", ",") do
        parts[#parts + 1] = part
      end
      assert.are.same({"a", "b", "c"}, parts)
    end)

    it("should iterate with default delimiter", function()
      local parts = {}
      for i, part in g.string.walk("hi") do
        parts[#parts + 1] = part
      end
      assert.are.same({"hi"}, parts)
    end)

    it("should provide index and value", function()
      local indices = {}
      for i, part in g.string.walk("x,y", ",") do
        indices[#indices + 1] = i
      end
      assert.are.same({1, 2}, indices)
    end)

    it("should error on non-string input", function()
      assert.has_error(function()
        g.string.walk(123)
      end)
    end)
  end)

  describe("starts_with", function()
    it("should return true when string starts with pattern", function()
      assert.is_true(g.string.starts_with("hello world", "hello"))
    end)

    it("should return false when string does not start with pattern", function()
      assert.is_false(g.string.starts_with("hello world", "world"))
    end)

    it("should handle pattern that is the full string", function()
      assert.is_true(g.string.starts_with("hello", "hello"))
    end)

    it("should handle single character", function()
      assert.is_true(g.string.starts_with("hello", "h"))
    end)
  end)

  describe("ends_with", function()
    it("should return true when string ends with pattern", function()
      assert.is_true(g.string.ends_with("hello world", "world"))
    end)

    it("should return false when string does not end with pattern", function()
      assert.is_false(g.string.ends_with("hello world", "hello"))
    end)

    it("should handle pattern that is the full string", function()
      assert.is_true(g.string.ends_with("hello", "hello"))
    end)

    it("should handle single character", function()
      assert.is_true(g.string.ends_with("hello", "o"))
    end)
  end)

  describe("contains", function()
    it("should return true when pattern is found", function()
      assert.is_true(g.string.contains("hello world", "lo wo"))
    end)

    it("should return false when pattern is not found", function()
      assert.is_false(g.string.contains("hello world", "xyz"))
    end)

    it("should match regex patterns", function()
      assert.is_true(g.string.contains("hello world", "\\d*llo"))
    end)

    it("should error when pattern starts with ^", function()
      assert.has_error(function()
        g.string.contains("hello", "^hello")
      end)
    end)

    it("should error when pattern ends with $", function()
      assert.has_error(function()
        g.string.contains("hello", "hello$")
      end)
    end)
  end)

  describe("append", function()
    it("should append suffix when not already present", function()
      assert.are.equal("hello world", g.string.append("hello", " world"))
    end)

    it("should not duplicate suffix when already present", function()
      assert.are.equal("hello world", g.string.append("hello world", " world"))
    end)

    it("should append to empty-like string", function()
      assert.are.equal("a!", g.string.append("a", "!"))
    end)
  end)

  describe("prepend", function()
    it("should prepend prefix when not already present", function()
      assert.are.equal("hello world", g.string.prepend("world", "hello "))
    end)

    it("should not duplicate prefix when already present", function()
      assert.are.equal("hello world", g.string.prepend("hello world", "hello "))
    end)

    it("should prepend single character", function()
      assert.are.equal("!a", g.string.prepend("a", "!"))
    end)
  end)

  describe("format_number", function()
    it("should format with default separators", function()
      assert.are.equal("1,234,567.89", g.string.format_number(1234567.89))
    end)

    it("should handle custom separators", function()
      assert.are.equal("1.234.567,89", g.string.format_number(1234567.89, ".", ","))
    end)

    it("should handle negative numbers", function()
      assert.are.equal("-1,234", g.string.format_number(-1234))
    end)

    it("should handle zero", function()
      assert.are.equal("0", g.string.format_number(0))
    end)

    it("should handle string input", function()
      assert.are.equal("1,234", g.string.format_number("1234"))
    end)

    it("should handle small numbers without thousands separator", function()
      assert.are.equal("999", g.string.format_number(999))
    end)

    it("should handle exactly 1000", function()
      assert.are.equal("1,000", g.string.format_number(1000))
    end)
  end)

  describe("parse_formatted_number", function()
    it("should parse formatted numbers", function()
      assert.are.equal(1234567.89, g.string.parse_formatted_number("1,234,567.89"))
    end)

    it("should handle custom separators", function()
      assert.are.equal(1234567.89, g.string.parse_formatted_number("1.234.567,89", ".", ","))
    end)

    it("should parse number without separators", function()
      assert.are.equal(42, g.string.parse_formatted_number("42"))
    end)

    it("should return 0 for non-numeric string", function()
      assert.are.equal(0, g.string.parse_formatted_number("abc"))
    end)

    it("should round-trip with format_number", function()
      local original = 9876543.21
      local formatted = g.string.format_number(original)
      local parsed = g.string.parse_formatted_number(formatted)
      assert.are.equal(original, parsed)
    end)
  end)

  describe("index_of", function()
    it("should find pattern position", function()
      local start, stop = g.string.index_of("hello world", "world")
      assert.are.equal(7, start)
    end)

    it("should return nil when not found", function()
      assert.is_falsy(g.string.index_of("hello world", "xyz"))
    end)

    it("should find first occurrence", function()
      local start = g.string.index_of("abcabc", "abc")
      assert.are.equal(1, start)
    end)

    it("should support regex patterns", function()
      local start = g.string.index_of("hello 42 world", "\\d+")
      assert.are.equal(7, start)
    end)

    it("should error on non-string arguments", function()
      assert.has_error(function()
        g.string.index_of(123, "abc")
      end)
    end)
  end)

  describe("reg_assoc", function()
    it("should split text by patterns with associated tokens", function()
      local results, tokens = g.string.reg_assoc(
        "hello 123 world",
        {"\\d+"},
        {1}
      )
      assert.are.same({"hello ", "123", " world"}, results)
      assert.are.same({-1, 1, -1}, tokens)
    end)

    it("should handle multiple patterns", function()
      local results, tokens = g.string.reg_assoc(
        "abc 123 def 456",
        {"[a-z]+", "\\d+"},
        {1, 2}
      )
      assert.are.same({"abc", " ", "123", " ", "def", " ", "456"}, results)
      assert.are.same({1, -1, 2, -1, 1, -1, 2}, tokens)
    end)

    it("should use default token for unmatched text", function()
      local results, tokens = g.string.reg_assoc(
        "hello world",
        {"world"},
        {1}
      )
      assert.are.same({"hello ", "world"}, results)
      assert.are.same({-1, 1}, tokens)
    end)

    it("should use custom default token", function()
      local results, tokens = g.string.reg_assoc(
        "hello world",
        {"world"},
        {1},
        0
      )
      assert.are.same({"hello ", "world"}, results)
      assert.are.same({0, 1}, tokens)
    end)

    it("should return entire text with default token when no patterns match", function()
      local results, tokens = g.string.reg_assoc(
        "hello",
        {"\\d+"},
        {1}
      )
      assert.are.same({"hello"}, results)
      assert.are.same({-1}, tokens)
    end)

    it("should handle text that is entirely matched", function()
      local results, tokens = g.string.reg_assoc(
        "hello",
        {"[a-z]+"},
        {1}
      )
      assert.are.same({"hello"}, results)
      assert.are.same({1}, tokens)
    end)

    it("should pick the nearest match when patterns overlap", function()
      local results, tokens = g.string.reg_assoc(
        "abcdef",
        {"cd", "ab"},
        {1, 2}
      )
      -- "ab" starts at position 1, "cd" at position 3 — "ab" wins
      assert.are.same({"ab", "cd", "ef"}, results)
      assert.are.same({2, 1, -1}, tokens)
    end)
  end)

  describe("is_alpha", function()
    it("should return true for lowercase letter", function()
      assert.is_true(g.string.is_alpha("a"))
    end)

    it("should return true for uppercase letter", function()
      assert.is_true(g.string.is_alpha("Z"))
    end)

    it("should return false for digit", function()
      assert.is_false(g.string.is_alpha("5"))
    end)

    it("should return false for punctuation", function()
      assert.is_false(g.string.is_alpha("!"))
    end)

    it("should error on multi-character string", function()
      assert.has_error(function()
        g.string.is_alpha("ab")
      end)
    end)
  end)

  describe("is_numeric", function()
    it("should return true for digit", function()
      assert.is_true(g.string.is_numeric("5"))
    end)

    it("should return false for letter", function()
      assert.is_false(g.string.is_numeric("a"))
    end)

    it("should return false for punctuation", function()
      assert.is_false(g.string.is_numeric("."))
    end)
  end)

  describe("is_alphanumeric", function()
    it("should return true for letter", function()
      assert.is_true(g.string.is_alphanumeric("a"))
    end)

    it("should return true for digit", function()
      assert.is_true(g.string.is_alphanumeric("9"))
    end)

    it("should return false for space", function()
      assert.is_false(g.string.is_alphanumeric(" "))
    end)

    it("should return false for punctuation", function()
      assert.is_false(g.string.is_alphanumeric("!"))
    end)
  end)

  describe("is_whitespace", function()
    it("should return true for space", function()
      assert.is_true(g.string.is_whitespace(" "))
    end)

    it("should return true for tab", function()
      assert.is_true(g.string.is_whitespace("\t"))
    end)

    it("should return false for letter", function()
      assert.is_false(g.string.is_whitespace("a"))
    end)

    it("should return false for digit", function()
      assert.is_false(g.string.is_whitespace("5"))
    end)
  end)

  describe("is_punctuation", function()
    it("should return true for exclamation mark", function()
      assert.is_true(g.string.is_punctuation("!"))
    end)

    it("should return true for period", function()
      assert.is_true(g.string.is_punctuation("."))
    end)

    it("should return false for letter", function()
      assert.is_false(g.string.is_punctuation("a"))
    end)

    it("should return false for digit", function()
      assert.is_false(g.string.is_punctuation("5"))
    end)

    it("should return false for space", function()
      assert.is_false(g.string.is_punctuation(" "))
    end)
  end)

  describe("is_uppercase", function()
    it("should return true for uppercase letter", function()
      assert.is_true(g.string.is_uppercase("A"))
    end)

    it("should return false for lowercase letter", function()
      assert.is_false(g.string.is_uppercase("a"))
    end)

    it("should return false for digit", function()
      assert.is_false(g.string.is_uppercase("5"))
    end)
  end)

  describe("is_lowercase", function()
    it("should return true for lowercase letter", function()
      assert.is_true(g.string.is_lowercase("a"))
    end)

    it("should return false for uppercase letter", function()
      assert.is_false(g.string.is_lowercase("A"))
    end)

    it("should return false for digit", function()
      assert.is_false(g.string.is_lowercase("5"))
    end)
  end)

  describe("split_natural", function()
    it("should split string into text and number parts", function()
      local result = g.string.split_natural("abc123def")
      assert.are.same({"abc", 123, "def"}, result)
    end)

    it("should handle leading numbers", function()
      local result = g.string.split_natural("42abc")
      assert.are.same({42, "abc"}, result)
    end)

    it("should handle all text", function()
      local result = g.string.split_natural("hello")
      assert.are.same({"hello"}, result)
    end)

    it("should handle all numbers", function()
      local result = g.string.split_natural("12345")
      assert.are.same({12345}, result)
    end)

    it("should handle multiple number segments", function()
      local result = g.string.split_natural("a1b2c3")
      assert.are.same({"a", 1, "b", 2, "c", 3}, result)
    end)

    it("should handle single character", function()
      local result = g.string.split_natural("x")
      assert.are.same({"x"}, result)
    end)

    it("should handle single digit", function()
      local result = g.string.split_natural("5")
      assert.are.same({5}, result)
    end)
  end)

  describe("natural_compare", function()
    it("should sort strings with numbers naturally", function()
      assert.is_true(g.string.natural_compare("file2", "file10"))
    end)

    it("should sort identical strings as equal", function()
      assert.is_false(g.string.natural_compare("abc", "abc"))
    end)

    it("should sort alphabetically when no numbers", function()
      assert.is_true(g.string.natural_compare("abc", "def"))
    end)

    it("should sort shorter before longer when prefix matches", function()
      assert.is_true(g.string.natural_compare("file", "file1"))
    end)

    it("should sort numerically within strings", function()
      assert.is_true(g.string.natural_compare("item3", "item20"))
      assert.is_false(g.string.natural_compare("item20", "item3"))
    end)
  end)
end)
