---@meta FuncClass

------------------------------------------------------------------------------
-- FuncClass
------------------------------------------------------------------------------

---@class FuncClass
func = {}

if false then -- ensure that functions do not get defined

  --- Delays the execution of a function.
  ---
  ---@example
  ---```lua
  ---func.delay(function() print("Hello, world!") end, 1)
  ---```
  ---@name delay
  ---@param func function - The function to delay.
  ---@param delay number - The delay in seconds.
  function func.delay(func, delay, ...) end

  --- Wraps a function in another function.
  ---
  ---@example
  ---```lua
  ---local becho = func.wrap(cecho, function(func, text)
  ---  func("<b>{text}</b>")
  ---end)
  ---
  ---becho("Hello, world!")
  --- -- <b>Hello, world!</b>
  ---```
  ---@name wrap
  ---@param func function - The function to wrap.
  ---@param wrapper function - The wrapper function.
  function func.wrap(func, wrapper) end

  --- Repeats a function a given number of times.
  ---
  ---@example
  ---```lua
  ---func.repeater(function() print("Hello, world!") end, 1, 3)
  ---```
  ---@name repeater
  ---@param func function - The function to repeat.
  ---@param interval number? - The interval between repetitions (Optional. Default is 1).
  ---@param times number? - The number of times to repeat the function (Optional. Default is 1).
  function func.repeater(func, interval, times, ...) end

end
