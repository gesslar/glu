---@meta ConditionsClass

------------------------------------------------------------------------------
-- ConditionsClass
------------------------------------------------------------------------------

if false then -- ensure that functions do not get defined
  ---@class ConditionsClass

  --- Checks if a condition is true or false.
  ---
  ---@example
  ---```lua
  ---conditions.is(true)
  ----- true, nil
  ---conditions.is(false, "Expected condition to be false")
  ----- false, "Expected condition to be false"
  ---```
  ---
  ---@name is
  ---@param condition boolean - The condition to check
  ---@param message string? - The message to return if the condition is false
  ---@return boolean, string? # The condition and message, or nil if the condition is true
  function conditions.is(condition, message) end

  --- Checks if a condition is true.
  ---
  ---@example
  ---```lua
  ---conditions.is_true(true)
  ----- true, nil
  ---conditions.is_true(false, "Expected condition to be true")
  ----- false, "Expected condition to be true"
  ---```
  ---
  ---@name is_true
  ---@param condition boolean - The condition to check
  ---@param message string? - The message to return if the condition is false
  ---@return boolean, string? # The condition and message, or nil if the condition is true
  function conditions.is_true(condition, message) end

  --- Checks if a condition is false.
  ---
  ---@example
  ---```lua
  ---conditions.is_false(false)
  ----- false, nil
  ---conditions.is_false(true, "Expected condition to be false")
  ----- true, "Expected condition to be false"
  ---```
  ---
  ---@name is_false
  ---@param condition boolean - The condition to check
  ---@param message string? - The message to return if the condition is true
  ---@return boolean, string? # The condition and message, or nil if the condition is true
  function conditions.is_false(condition, message) end

  --- Checks if a value is nil.
  ---
  ---@example
  ---```lua
  ---conditions.is_nil(nil)
  ----- true, nil
  ---conditions.is_nil(false, "Expected value to be nil")
  ----- false, "Expected value to be nil"
  ---```
  ---
  ---@name is_nil
  ---@param value any - The value to check
  ---@param message string? - The message to return if the value is nil
  ---@return boolean, string? # The condition and message, or nil if the condition is true
  function conditions.is_nil(value, message) end

  --- Checks if a value is not nil.
  ---
  ---@example
  ---```lua
  ---conditions.is_not_nil(false)
  ----- false, nil
  ---conditions.is_not_nil(nil, "Expected value to not be nil")
  ----- true, "Expected value to not be nil"
  ---```
  ---
  ---@name is_not_nil
  ---@param value any - The value to check
  ---@param message string? - The message to return if the value is nil
  ---@return boolean, string? # The condition and message, or nil if the condition is true
  function conditions.is_not_nil(value, message) end

  --- Checks if a function throws an error.
  ---
  ---@example
  ---```lua
  ---conditions.is_error(function() error("Expected error") end, "Expected error")
  ----- false, "Expected error"
  ---```
  ---
  ---@name is_error
  ---@param func function - The function to check
  ---@param message string? - The message to return if the function does not throw an error
  ---@param check function? - The function to check the error message against
  ---@return boolean, string? # The condition and message, or nil if the condition is true
  function conditions.is_error(func, message, check) end

  --- Checks if two values are equal.
  ---
  ---@example
  ---```lua
  ---conditions.is_eq(1, 1)
  ----- true, nil
  ---conditions.is_eq(1, 2, "Expected values to be equal")
  ----- false, "Expected values to be equal"
  ---```
  ---
  ---@name is_eq
  ---@param a any - The first value to check
  ---@param b any - The second value to check
  ---@param message string? - The message to return if the values are not equal
  ---@return boolean, string? # The condition and message, or nil if the condition is true
  function conditions.is_eq(a, b, message) end

  --- Checks if two values are not equal.
  ---
  ---@example
  ---```lua
  ---conditions.is_ne(1, 2)
  ----- true, nil
  ---conditions.is_ne(1, 1, "Expected values to not be equal")
  ----- false, "Expected values to not be equal"
  ---```
  ---
  ---@name is_ne
  ---@param a any - The first value to check
  ---@param b any - The second value to check
  ---@param message string? - The message to return if the values are equal
  ---@return boolean, string? # The condition and message, or nil if the condition is true
  function conditions.is_ne(a, b, message) end
  end

  --- Checks if a value is less than another value.
  ---
  ---@example
  ---```lua
  ---conditions.is_lt(1, 2)
  ----- true, nil
  ---conditions.is_lt(2, 1, "Expected values to be less than")
  ----- false, "Expected values to be less than"
  ---```
  ---
  ---@name is_lt
  ---@param a any - The first value to check
  ---@param b any - The second value to check
  ---@param message string? - The message to return if the values are not less than
  ---@return boolean, string? # The condition and message, or nil if the condition is true
  function conditions.is_lt(a, b, message) end

  --- Checks if a value is less than or equal to another value.
  ---
  ---@example
  ---```lua
  ---conditions.is_le(1, 2)
  ----- true, nil
  ---conditions.is_le(2, 1, "Expected values to be less than or equal to")
  ----- false, "Expected values to be less than or equal to"
  ---```
  ---
  ---@name is_le
  ---@param a any - The first value to check
  ---@param b any - The second value to check
  ---@param message string? - The message to return if the values are not less than or equal to
  ---@return boolean, string? # The condition and message, or nil if the condition is true
  function conditions.is_le(a, b, message) end

  --- Checks if a value is greater than another value.
  ---
  ---@example
  ---```lua
  ---conditions.is_gt(2, 1)
  ----- true, nil
  ---conditions.is_gt(1, 2, "Expected values to be greater than")
  ----- false, "Expected values to be greater than"
  ---```
  ---
  ---@name is_gt
  ---@param a any - The first value to check
  ---@param b any - The second value to check
  ---@param message string? - The message to return if the values are not greater than
  ---@return boolean, string? # The condition and message, or nil if the condition is true
  function conditions.is_gt(a, b, message) end

  --- Checks if a value is greater than or equal to another value.
  ---
  ---@example
  ---```lua
  ---conditions.is_ge(2, 1)
  ----- true, nil
  ---conditions.is_ge(1, 2, "Expected values to be greater than or equal to")
  ----- false, "Expected values to be greater than or equal to"
  ---```
  ---
  ---@name is_ge
  ---@param a any - The first value to check
  ---@param b any - The second value to check
  ---@param message string? - The message to return if the values are not greater than or equal to
  ---@return boolean, string? # The condition and message, or nil if the condition is true
  function conditions.is_ge(a, b, message) end

  --- Checks if a value is of a specific type.
  ---
  ---@example
  ---```lua
  ---conditions.is_type(1, "number")
  ----- true, nil
  ---conditions.is_type(1, "string", "Expected value to be a string")
  ----- false, "Expected value to be a string"
  ---```
  ---
  ---@name is_type
  ---@param value any - The value to check
  ---@param type string - The type to check against
  ---@param message string? - The message to return if the values are not of the specified type
  ---@return boolean, string? # The condition and message, or nil if the condition is true
  function conditions.is_type(value, type, message) end

  --- Checks if two values are deeply equal.
  ---
  ---@example
  ---```lua
  ---conditions.is_deeply({a = 1}, {a = 1})
  ----- true, nil
  ---```
  ---
  ---@name is_deeply
  ---@param a any - The first value to check
  ---@param b any - The second value to check
  ---@param message string? - The message to return if the values are not deeply equal
  ---@return boolean, string? # The condition and message, or nil if the condition is true
  function conditions.is_deeply(a, b, message) end

end
