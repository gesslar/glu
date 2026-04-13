# Glu

![Y2K Compliant](https://img.shields.io/badge/Y2K-Compliant-success?style=flat&logo=data:...)

A modular utility library for Mudlet that just works. No fuss, no muss.

## Installation

Glu ships in two forms, depending on how you use it.

### For package authors (recommended)

Bundle `Glu-single.lua` in your package and `require` it. Each package gets
its own isolated copy — no globals, no version collisions between packages.

```lua
local glu = require("__PKGNAME__/Glu-single")("__PKGNAME__")
```

### For personal use

Install the `Glu.mpackage` directly in Mudlet. Glu is available globally
from the script editor for ad-hoc scripting without needing to manage files.

```lua
local glu = Glu("MyPackage")
```

## Quick Start

```lua
-- Iterate over a string? Easy.
for i, part in glu.string.walk("hello world") do
  if math.random() > 0.5 then
    part = string.title(part)
  end

  print(i, part)
end

-- prints (probably):
-- 1  "H"
-- 2  "e"
-- 3  "l"
-- 4  "l"
-- 5  "o"
-- 6  " "
-- 7  "W"
-- 8  "o"
-- 9  "r"
-- 10 "l"
-- 11 "D"

-- Dates giving you trouble? Not anymore.
local pretty_time = glu.date.shms(3665, true)      -- "1h 1m 5s"

-- Need some table magic?
local data = {a=1, b=2, c=3}
local just_values = glu.table.values(data)         -- {1, 2, 3}
```

## Extend It

Want to add your own stuff? Register your own glasses on a Glu instance:

### Simple utility glass

```lua
glu.register({
  name = "awesome",
  class_name = "AwesomeClass",
  setup = function(___, self)
    function self.double_it(num)
      ___.v.type(num, "number", 1, false)
      return num * 2
    end
  end
})

-- Now use it!
local doubled = glu.awesome.double_it(21) -- 42
```

### A Geyser component

*Warning: Advanced Usage! May cause hysteria!*

```lua
BuffItem = BuffItem or {
  name = "buff_item",
  class_name = "BuffItemClass",
  call = "new",
  setup = function(___, self)
    local function fade(widget, cb)
      local timer_name = ___.id()

      local curr_fg, curr_bg

      curr_fg = { Geyser.Color.parse(widget.fgColor) }
      curr_bg = { Geyser.Color.parse(widget.color) }

      widget:echo(nil, "nocolor", nil)

      curr_fg[4] = 255
      curr_bg[4] = 255

      local steps = 50
      local duration = 1
      local delay_per_step = duration / steps
      local fade_per_step = ___.number.round(255 / steps, 0)

      registerNamedTimer(
        timer_name,
        timer_name,
        delay_per_step,
        function()
          curr_fg[4] = curr_fg[4] - fade_per_step
          curr_bg[4] = curr_bg[4] - fade_per_step

          local ss =
              "color: rgba(" .. table.concat(curr_fg, ",") .. ");"
              ..
              "background-color: rgba(" .. table.concat(curr_bg, ",") .. ");"

          widget:setStyleSheet(ss)

          steps = steps - 1

          if steps < 0 then
            deleteNamedTimer(timer_name, timer_name)
            cb()
          end
        end,
        true
      )
    end

    function self.new(opts, parent)
      local instance = {}
      opts = opts or {}

      instance.label = Geyser.Label:new(opts, parent)

      function instance:delete()
        fade(self.label, function() instance.label:delete() end)
      end

      return instance
    end
  end
}

-- Make it real!
local item = ThreshBuff.glu.buff_item({
   message = "hi there",
   color = "black",
   fgColor = "white",
}, someContainer)

item:delete()
```

## Documentation

Check out our [Wiki](https://github.com/gesslar/glu/wiki) for detailed
documentation, guides, and examples.

## License

`glu` is released under the [0BSD](LICENSE.txt).
