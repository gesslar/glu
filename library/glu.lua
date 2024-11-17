---@meta Glu

------------------------------------------------------------------------------
-- Glu
------------------------------------------------------------------------------

if false then -- ensure that functions do not get defined

  ---@class Glu

  ---Instantiate a new Glu instance. Can be invoked by its class name or
  ---by the `new` function.
  ---
  ---@example
  ---```lua
  ---local glu = Glu.new("MyPackage", "MyModule")
  ---local glu = Glu("MyPackage", "MyModule")
  ---```
  ---
  ---@name new
  ---@param package_name string - The name of the package to which this module belongs.
  ---@param module_dir_name string? - The directory name inside the package directory where the modules are located.
  ---@return Glu # A new Glu instance.
  function Glu.new(package_name, module_dir_name) end

  ---Generate a unique identifier, producing a version 4 UUID.
  ---
  ---@name id
  ---@return string # A unique identifier.
  ---@example
  ---```lua
  ---local id = Glu.id()
  ---```
  ---@name id
  function Glu.id() end

  ---Get all glasses.
  ---
  ---@name get_glasses
  ---@return Glass[] # A table of glasses.
  ---@example
  ---```lua
  ---local glasses = Glu.get_glasses()
  ---```
  ---
  function Glu.get_glasses() end

  ---Get all glass names.
  ---
  ---@name get_glass_names
  ---@return string[] # A table of glass names.
  ---@example
  ---```lua
  ---local glass_names = Glu.get_glass_names()
  ---```
  ---
  function Glu.get_glass_names() end

  ---Get a glass by name.
  ---
  ---@name get_glass
  ---@param glass_name string - The name of the glass to retrieve.
  ---@return Glass? # The glass, or nil if it does not exist.
  ---@example
  ---```lua
  ---local glass = Glu.get_glass("MyGlass")
  ---```
  ---
  function Glu.get_glass() end

  ---Check if a glass exists.
  ---
  ---@name has_glass
  ---@param glass_name string - The name of the glass to check for.
  ---@return boolean # True if the glass exists, false otherwise.
  ---@example
  ---```lua
  ---local exists = Glu.has_glass("MyGlass")
  ---```
  ---
  function Glu.has_glass(glass_name) end

  ---Get the last traceback line. Used for validation functions, or any
  ---time you need to get the last line of a traceback. Also available
  ---via the `v` table from the anchor.
  ---
  ---@name get_last_traceback_line
  ---@return string # The last traceback line.
  function Glu.get_last_traceback_line() end
end
