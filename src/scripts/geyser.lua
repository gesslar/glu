---@diagnostic disable-next-line: undefined-global
local mod = mod or {}
local script_name = "geyser"

function mod.new(parent)
  local instance = { parent = parent }

  -- Pool of Geyser objects that can be reused.
  local recycleBin = {}
  local geyserDefaults = {} -- Stores default settings for each Geyser type

  --- Capture defaults for each Geyser type on first creation.
  local function captureDefaults(geyserObj, geyserType)
    if not geyserDefaults[geyserType] then
      geyserDefaults[geyserType] = {}
      for key, value in pairs(geyserObj) do
        if type(value) ~= "function" then
          geyserDefaults[geyserType][key] = value
        end
      end
    end
  end

  --- Reset a Geyser object to its default state.
  local function resetToDefaults(geyserObj, geyserType)
    local defaults = geyserDefaults[geyserType]
    if defaults then
      for key, value in pairs(defaults) do
        geyserObj[key] = value
      end
    end
  end

  --- Creates or recycles a Geyser object.
  --- @param geyserType table - The Geyser type to create.
  --- @param opts table - The options to pass to the Geyser constructor.
  --- @return table - The new or recycled Geyser object.
  --- @example
  --- ```lua
  --- --- Create a new label or recycle an existing one
  --- local myLabel = geyser:new(Geyser.Label, {
  ---   message = "Hello, world!"
  --- }, myGuiContainer)
  --- ```
  function instance:new(geyserType, opts)
    local geyser

    -- Check if we have a recycled object of this type
    if recycleBin[geyserType] and #recycleBin[geyserType] > 0 then
      geyser = table.remove(recycleBin[geyserType]) -- Remove from recycleBin
    else
      geyser = geyserType:new(opts)
      captureDefaults(geyser, geyserType) -- Capture defaults on first creation
    end

    return geyser
  end

  --- Deletes (recycles) a Geyser object.
  --- @param geyser table - The Geyser object to delete/recycle.
  --- @example
  --- ```lua
  --- --- Hides and resets the label to its default state, adding it to the
  --- --- recycle bin to be reused later upon need.
  --- geyser:delete(myLabel)
  --- ```
  function instance:delete(geyser)
    geyser:hide()

    -- Determine the Geyser type and reset it to defaults
    for geyserType, _ in pairs(geyserDefaults) do
      if getmetatable(geyser) == getmetatable(geyserType) then
        resetToDefaults(geyser, geyserType) -- Reset properties to defaults
        recycleBin[geyserType] = recycleBin[geyserType] or {}
        table.insert(recycleBin[geyserType], geyser)
        break
      end
    end
  end

  instance.parent.valid = instance.parent.valid or setmetatable({}, {
    __index = function(_, k) return function(...) end end
  })

  return instance
end

-- Let Glu know we're here
raiseEvent("glu_module_loaded", script_name, mod)

return mod
