---@meta PreferencesClass

------------------------------------------------------------------------------
-- PreferencesClass
------------------------------------------------------------------------------

if false then -- ensure that functions do not get defined

  ---@class PreferencesClass

  --- Loads preferences from a file. If a package name is provided, it will be
  --- used to construct the path. Otherwise, the file will be loaded from the
  --- profile directory.
  ---
  ---@example
  ---```lua
  ---preferences.load("my_package", "settings", { default_value = 1 })
  ---```
  ---
  --- @name load
  --- @param pkg string? - The package name. (Optional. Default is nil.)
  --- @param file string - The file name.
  --- @param defaults table - The default values.
  --- @return table # The loaded preferences.
  function preferences.load() end

  --- Saves preferences to a file. If a package name is provided, it will be
  --- used to construct the path. Otherwise, the file will be saved to the
  --- profile directory.
  ---
  --- @example
  --- ```lua
  --- preferences.save("my_package", "settings", { default_value = 1 })
  --- ```
  ---
  --- @name save
  --- @param pkg string? - The package name. (Optional. Default is nil.)
  --- @param file string - The file name.
  --- @param prefs table # The preferences to save.
  function preferences.save() end

end
