---@diagnostic disable-next-line: undefined-global
local mod = mod or {}
local script_name = "preferences"
function mod.new(parent)
  local instance = { parent = parent }

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
  --- preferences:load_prefs("my_package", "settings.json", {
  ---   default_value = 1,
  ---   another_value = "hello"
  --- })
  --- ```
  function instance:load_prefs(pkg, file, defaults)
    self.parent.valid:type(pkg, "string", 1, true)
    self.parent.valid:type(file, "string", 2, false)
    self.parent.valid:type(defaults, "table", 3, false)

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
  --- preferences:save_prefs("my_package", "settings.json", {
  ---   default_value = 1,
  ---   another_value = "hello"
  --- })
  --- ```
  function instance:save_prefs(pkg, file, prefs)
    self.parent.valid:type(pkg, "string", 1, true)
    self.parent.valid:type(file, "string", 2, false)
    self.parent.valid:type(prefs, "table", 3, false)

    local path = getMudletHomeDir() .. "/" .. (pkg and pkg .. "/" or "") .. file

    table.save(path, prefs)
  end

  instance.parent.valid = instance.parent.valid or setmetatable({}, {
    __index = function(_, k) return function(...) end end
  })

  return instance
end

-- Let Glu know we're here
raiseEvent("glu_module_loaded", script_name, mod)

return mod
