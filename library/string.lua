---@meta StringClass

------------------------------------------------------------------------------
-- StringClass
------------------------------------------------------------------------------

if false then -- ensure that functions do not get defined

  ---@class StringClass

  ---Appends one string to another if it is not already present.
  ---
  ---@name append
  ---@param str string - The string to append to.
  ---@param suffix string - The suffix to append to the string.
  ---@return string # The resulting string.
  function string.append(str, suffix) end

  ---Capitalizes the first character of a string.
  ---
  ---@name capitalize
  ---@param str string - The string to capitalize.
  ---@return string # The capitalized string.
  function string.capitalize(str) end

  ---Checks if a string contains a pattern. This function uses PCRE regex. The
  ---pattern must not contain "^" or "$". If you wish to check for a pattern at
  ---the beginning or end of a string, use `string.starts_with` or `string.ends_with`.
  ---
  ---@name contains
  ---@param str string - The string to check.
  ---@param pattern string - The pattern to check for.
  ---@return boolean # Whether the string contains the pattern.
  function string.contains(str, pattern) end

  ---Checks if a string ends with a given pattern. This function uses PCRE regex.
  ---If the pattern does not end with "$", it is appended with "$".
  ---
  ---@name ends_with
  ---@param str string - The string to check.
  ---@param ending string - The pattern to check for.
  ---@return boolean # Whether the string ends with the pattern.
  function string.ends_with(str, ending) end

  ---Formats a number with thousands separators and decimal places. Can be
  ---a number or a string.
  ---
  ---The thousands and decimal separators default to "," and ".", respectively.
  ---If you wish to specify a decimal separator without a thousands separator,
  ---you can pass `nil` as the thousands separator.
  ---
  ---@name format_number
  ---@param number number|string - The number to format.
  ---@param thousands string? - The thousands separator.
  ---@param decimal string? - The decimal separator.
  ---@return string # The formatted number.
  function string.format_number(number, thousands, decimal) end

  ---Removes whitespace from the left side of a string.
  ---
  ---@name ltrim
  ---@param str string - The string to remove whitespace from.
  ---@return string # The resulting string without whitespace on the left.
  function string.ltrim(str) end

  ---Parses a string formatted with thousands and decimal separators into a number.
  ---
  ---@name parse_formatted_number
  ---@param str string - The string to parse.
  ---@param thousands string? - The thousands separator.
  ---@param decimal string? - The decimal separator.
  ---@return number # The parsed number.
  function string.parse_formatted_number(str, thousands, decimal) end

  ---Prepends a string to another string if it is not already present.
  ---
  ---@name prepend
  ---@param str string - The string to prepend to.
  ---@param prefix string - The prefix to prepend to the string.
  ---@return string # The resulting string.
  function string.prepend(str, prefix) end

  function string.reg_assoc(text, patterns, tokens, default_token) end
  ---Replaces a pattern in a string with a replacement string. This function uses
  ---PCRE regex.
  ---
  ---@name replace
  ---@param str string - The string to replace the pattern in.
  ---@param pattern string - The pattern to replace.
  ---@param replacement string - The replacement string.
  ---@return string # The resulting string.
  function string.replace(str, pattern, replacement) end

  ---Removes whitespace from the right side of a string.
  ---
  ---@name rtrim
  ---@param str string - The string to remove whitespace from.
  ---@return string # The resulting string without whitespace on the right.
  function string.rtrim(str) end

  ---Splits a string into an array of strings using a delimiter.
  ---
  ---@name split
  ---@param str string - The string to split.
  ---@param delimiter string - The delimiter to split the string by.
  ---@return string[] # The resulting array of strings.
  function string.split(str, delimiter) end

  ---Checks if a string starts with a given pattern. This function uses PCRE regex.
  ---If the pattern does not start with "^", it is prepended with "^".
  ---
  ---@name starts_with
  ---@param str string - The string to check.
  ---@param start string - The pattern to check for.
  ---@return boolean # Whether the string starts with the pattern.
  function string.starts_with(str, start) end

  ---Strips line breaks from a string.
  ---
  ---@name strip_linebreaks
  ---@param str string - The string to strip line breaks from.
  ---@return string # The resulting string without line breaks.
  function string.strip_linebreaks(str) end

  ---Trims whitespace from the beginning and end of a string.
  ---
  ---@name trim
  ---@param str string - The string to trim.
  ---@return string # The trimmed string.
  function string.trim(str) end

  ---Walks through a string, splitting it into an array of strings using a
  ---delimiter. This function returns an iterator.
  ---
  ---@name walk
  ---@param input string - The string to walk through.
  ---@param delimiter string - The delimiter to split the string by.
  ---@return function # The iterator function.
  function string.walk(input, delimiter) end

end
