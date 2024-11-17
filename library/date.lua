---@meta DateClass

------------------------------------------------------------------------------
-- DateClass
------------------------------------------------------------------------------

if false then -- ensure that functions do not get defined

  ---@class DateClass

  ---Converts a number of seconds into a human-readable string. By default, the
  ---result is returned as a table of three strings. However, if the `as_string`
  ---parameter is provided, the result is returned as a single string.
  ---
  ---@name shms
  ---@param seconds number - The number of seconds to convert.
  ---@param as_string boolean? - Whether to return the result as a string.
  ---@return string[]|string # The resulting string or table of strings.
  function date.shms(seconds, as_string) end

end
