---@diagnostic disable-next-line: undefined-global
local mod = mod or {}
local script_name = "util"

function mod.new(parent)
  local instance = { parent = parent }

  --- util:generate_uuid()
  --- Generates a UUID.
  --- @return string - A UUID.
  function instance:generate_uuid()
    -- This is a "version 4" UUID. It's based on random numbers.
    -- Supposed to use lower case, but can accept upper case for comparisons.
    local function random_hex(length)
      return string.format("%0" .. length .. "x", math.random(0, 16 ^ length - 1))
    end

    local result = string.format("%s%s-%s-4%s-%x%s-%s%s%s",
      random_hex(4),
      random_hex(4),
      random_hex(4),
      random_hex(3),
      8 + math.random(0, 3),
      random_hex(3),
      random_hex(4),
      random_hex(4),
      random_hex(4))

    ---@diagnostic disable-next-line: return-type-mismatch
    return result
  end

  instance.parent.valid = instance.parent.valid or setmetatable({}, {
    __index = function(_, k) return function(...) end end
  })

  return instance
end

-- Let Glu know we're here
raiseEvent("glu_module_loaded", script_name, mod)

return mod
