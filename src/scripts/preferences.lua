local script_name = "preferences"
local class_name = script_name:title() .. "Class"
local deps = { "table", "valid" }

local mod = Glu.registerClass({
  class_name = class_name,
  script_name = script_name,
  dependencies = deps,
})

function mod.setup(___, self)
  --- Loads preferences from a file. If a package name is provided, it will be
  --- used to construct the path. Otherwise, the file will be loaded from the
  --- profile directory.
  --- @param pkg string|nil - The package name. (Optional. Default is nil.)
  --- @param file string - The file name.
  --- @param defaults table - A table of default values for those which are missing.
  --- @return table - The loaded preferences.
  --- @example
  --- ```lua
  --- -- Load preferences from the "my_package" package
  --- preferences.load_prefs("my_package", "settings.json", {
  ---   default_value = 1,
  ---   another_value = "hello"
  --- })
  --- ```
  function self.load(pkg, file, defaults)
    ___.valid.type(pkg, "string", 1, true)
    ___.valid.type(file, "string", 2, false)
    ___.valid.type(defaults, "table", 3, false)

    local path = getMudletHomeDir() .. "/" .. (pkg and pkg .. "/" or "") .. file

    if not io.exists(path) then
      return defaults
    end

    local prefs = {}
    table.load(path, prefs)
    prefs = table.update(defaults, prefs)

    return prefs or defaults
  end

  --- Saves preferences to a file. If a package name is provided, it will be
  --- used to construct the path. Otherwise, the file will be saved to the
  --- profile directory.
  --- @param pkg string|nil - The package name. (Optional. Default is nil.)
  --- @param file string - The file name.
  --- @param prefs table - The preferences to save.
  --- @example
  --- ```lua
  --- preferences.save_prefs("my_package", "settings.json", {
  ---   default_value = 1,
  ---   another_value = "hello"
  --- })
  --- ```
  function self.save(pkg, file, prefs)
    ___.valid.type(pkg, "string", 1, true)
    ___.valid.type(file, "string", 2, false)
    ___.valid.type(prefs, "table", 3, false)

    local path = getMudletHomeDir() .. "/" .. (pkg and pkg .. "/" or "") .. file

    table.save(path, prefs)
  end
end
