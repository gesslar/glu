---@diagnostic disable-next-line: undefined-global
local mod = mod or {}
local script_name = "util"

function mod.new(parent)
  local instance = {
    parent = parent,
    ___ = (function(p)
      while p.parent do p = p.parent end
      return p
    end)(parent)
  }

  --- Generates a version 4 UUID based on random numbers.
  ---
  --- @return string - A version 4 UUID.
  --- @example
  --- ```lua
  --- util:generate_uuid()
  --- -- "89edaf15-d8c1-42ab-92fe-5e3ab0dd1722"
  --- ```
  function instance:generate_uuid()
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

  instance.___.valid = instance.___.valid or setmetatable({}, {
    __index = function(_, k) return function(...) end end
  })

  return instance
end

-- Let Glu know we're here
raiseEvent("glu_module_loaded", script_name, mod)

return mod
