---@meta StringClass

------------------------------------------------------------------------------
-- StringClass
------------------------------------------------------------------------------

if false then -- ensure that functions do not get defined
  ---@class StringClass

  ---Appends a suffix to a string if it does not already end with that suffix. The check
  ---is done using PCRE regex pattern matching to ensure accurate suffix detection.
  ---
  ---@example
  ---```lua
  ---string.append("hello", " world")    -- "hello world"
  ---string.append("hello world", "world") -- "hello world"
  ---```
  ---
  ---@name append
  ---@param str string - The string to append to.
  ---@param suffix string - The suffix to append to the string.
  ---@return string # The resulting string.
  function string.append(str, suffix) end

  ---Checks if a string contains a given pattern using PCRE regex. This is for finding
  ---patterns anywhere within the string. The pattern must not start with "^" or end
  ---with "$" - use starts_with() or ends_with() for those cases instead.
  ---
  ---@example
  ---```lua
  ---string.contains("hello world", "world")     -- true
  ---string.contains("hello world", "goodbye")   -- false
  ---```
  ---
  ---@name contains
  ---@param str string - The string to check.
  ---@param pattern string - The pattern to check for.
  ---@return boolean # Whether the string contains the pattern.
  function string.contains(str, pattern) end

  ---Checks if a string ends with a given pattern using PCRE regex. If the pattern
  ---doesn't already end with "$", it will be automatically appended to ensure matching
  ---at the end of the string.
  ---
  ---@example
  ---```lua
  ---string.ends_with("hello world", "world")     -- true
  ---string.ends_with("hello world", "hello")     -- false
  ---string.ends_with("test.lua", "\\.lua$")      -- true
  ---```
  ---
  ---@name ends_with
  ---@param str string - The string to check.
  ---@param ending string - The pattern to check for.
  ---@return boolean # Whether the string ends with the pattern.
  function string.ends_with(str, ending) end

  ---Formats a number with thousands separators and decimal places. Works with both
  ---numbers and numeric strings. If not specified, uses "," for thousands and "."
  ---for decimal separator. Handles negative numbers and maintains decimal precision.
  ---
  ---@example
  ---```lua
  ---string.format_number(1234567.89)           -- "1,234,567.89"
  ---string.format_number(-1234.56)             -- "-1,234.56"
  ---string.format_number(1234567, ".", ",")    -- "1.234.567"
  ---```
  ---
  ---@name format_number
  ---@param number number|string - The number to format.
  ---@param thousands string? - The thousands separator.
  ---@param decimal string? - The decimal separator.
  ---@return string # The formatted number.
  function string.format_number(number, thousands, decimal) end

  ---Removes whitespace characters from the beginning (left side) of a string.
  ---Whitespace includes spaces, tabs, and newlines.
  ---
  ---@example
  ---```lua
  ---string.ltrim("  hello world  ")    -- "hello world  "
  ---string.ltrim("\t\nhello")          -- "hello"
  ---```
  ---
  ---@name ltrim
  ---@param str string - The string to remove whitespace from.
  ---@return string # The resulting string without whitespace on the left.
  function string.ltrim(str) end

  ---Converts a formatted number string back into a number. Handles thousands and
  ---decimal separators, removing the thousands separators and converting the decimal
  ---separator to a period if necessary.
  ---
  ---@example
  ---```lua
  ---string.parse_formatted_number("1,234,567.89")       -- 1234567.89
  ---string.parse_formatted_number("1.234.567,89", ".", ",")  -- 1234567.89
  ---```
  ---
  ---@name parse_formatted_number
  ---@param str string - The string to parse.
  ---@param thousands string? - The thousands separator.
  ---@param decimal string? - The decimal separator.
  ---@return number # The parsed number.
  function string.parse_formatted_number(str, thousands, decimal) end

  ---Prepends a prefix to a string if it does not already start with that prefix.
  ---Uses PCRE regex pattern matching to ensure accurate prefix detection.
  ---
  ---@example
  ---```lua
  ---string.prepend("world", "hello ")          -- "hello world"
  ---string.prepend("hello world", "hello")     -- "hello world"
  ---```
  ---
  ---@name prepend
  ---@param str string - The string to prepend to.
  ---@param prefix string - The prefix to prepend to the string.
  ---@return string # The resulting string.
  function string.prepend(str, prefix) end

  ---Performs pattern matching using reg_assoc with PCRE regex support. Associates
  ---patterns with tokens and returns both the matched segments and their corresponding
  ---token assignments.
  ---
  ---@example
  ---```lua
  ---local results, tokens = string.reg_assoc(
  ---    "hello world",
  ---    {"hello", "world"},
  ---    {"greeting", "place"}
  ---)
  ---- results: {"hello", " ", "world"}
  ---- tokens: {"greeting", -1, "place"}
  ---```
  ---
  ---@name reg_assoc
  ---@param text string - The text to search through
  ---@param patterns table - The patterns to search for
  ---@param tokens table - The tokens to replace the patterns with
  ---@param default_token string? - The default token for unmatched text
  ---@return table,table # The results table and token list
  function string.reg_assoc(text, patterns, tokens, default_token) end

  ---Replaces all occurrences of a pattern in a string with a replacement string.
  ---Continues replacing until no more matches are found to handle overlapping or
  ---repeated patterns.
  ---
  ---@example
  ---```lua
  ---string.replace("hello world", "o", "a")     -- "hella warld"
  ---string.replace("test", "t", "p")            -- "pesp"
  ---```
  ---
  ---@name replace
  ---@param str string - The string to replace the pattern in.
  ---@param pattern string - The pattern to replace.
  ---@param replacement string - The replacement string.
  ---@return string # The resulting string.
  function string.replace(str, pattern, replacement) end

  ---Removes whitespace characters from the end (right side) of a string.
  ---Whitespace includes spaces, tabs, and newlines.
  ---
  ---@example
  ---```lua
  ---string.rtrim("  hello world  ")    -- "  hello world"
  ---string.rtrim("hello\t\n")          -- "hello"
  ---```
  ---
  ---@name rtrim
  ---@param str string - The string to remove whitespace from.
  ---@return string # The resulting string without whitespace on the right.
  function string.rtrim(str) end

  ---Splits a string into a table of strings using PCRE regex. If no delimiter
  ---is provided, it defaults to ".", which will split the string into individual
  ---characters. The delimiter is treated as a regex pattern.
  ---
  ---@example
  ---```lua
  ---string.split("hello world")           -- {"h", "e", "l", "l", "o", " ", "w", "o", "r", "l", "d"}
  ---string.split("hello world", " ")      -- {"hello", "world"}
  ---string.split("hello.world", "\\.")    -- {"hello", "world"}
  ---string.split("hello world", "o")      -- {"hell", " w", "rld"}
  ---```
  ---
  ---@name split
  ---@param str string - The string to split.
  ---@param delimiter string? - The regex delimiter to split the string by.
  ---@return string[] # The resulting array of strings.
  function string.split(str, delimiter) end

  ---Checks if a string starts with a given pattern using PCRE regex. If the pattern
  ---doesn't already start with "^", it will be automatically prepended to ensure
  ---matching at the start of the string.
  ---
  ---@example
  ---```lua
  ---string.starts_with("hello world", "hello")     -- true
  ---string.starts_with("hello world", "world")     -- false
  ---string.starts_with("test.lua", "^test")        -- true
  ---```
  ---
  ---@name starts_with
  ---@param str string - The string to check.
  ---@param start string - The pattern to check for.
  ---@return boolean # Whether the string starts with the pattern.
  function string.starts_with(str, start) end

  ---Removes all line breaks from a string, including both \r and \n characters.
  ---Useful for converting multi-line text into a single line.
  ---
  ---@example
  ---```lua
  ---string.strip_linebreaks("hello\nworld")     -- "helloworld"
  ---string.strip_linebreaks("hello\r\nworld")   -- "helloworld"
  ---```
  ---
  ---@name strip_linebreaks
  ---@param str string - The string to strip line breaks from.
  ---@return string # The resulting string without line breaks.
  function string.strip_linebreaks(str) end

  ---Removes whitespace from both the beginning and end of a string.
  ---Whitespace includes spaces, tabs, and newlines.
  ---
  ---@example
  ---```lua
  ---string.trim("  hello world  ")    -- "hello world"
  ---string.trim("\t\nhello\n\t")      -- "hello"
  ---```
  ---
  ---@name trim
  ---@param str string - The string to trim.
  ---@return string # The trimmed string.
  function string.trim(str) end

  ---Creates an iterator that walks through a string character by character or by
  ---split segments if a delimiter is provided. Returns index and value pairs.
  ---
  ---@example
  ---```lua
  ---for i, part in string.walk("hello world") do
  ---  print(i, part)  -- prints: 1,"h" 2,"e" 3,"l" 4,"l" 5,"o" 6," " 7,"w" 8,"o" 9,"r" 10,"l" 11,"d"
  ---end
  ---
  ---for i, part in string.walk("a,b,c", ",") do
  ---  print(i, part)  -- prints: 1,"a" 2,"b" 3,"c"
  ---end
  ---```
  ---
  ---@name walk
  ---@param input string - The string to walk through.
  ---@param delimiter string? - The delimiter to split the string by.
  ---@return function # The iterator function.
  function string.walk(input, delimiter) end
end
