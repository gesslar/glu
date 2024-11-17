# Glu

![Y2K Compliant](https://img.shields.io/badge/Y2K-Compliant-success?style=flat&logo=data:...)

A modular utility library for Mudlet that just works. No fuss, no muss.

## Quick Start

```lua
-- Get some Glu in your life
local glu = Glu("MyPackage")

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

Want to add your own stuff? Glu's got you covered:

```lua
Glu.glass.register({
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
local doubled = glu.awesome.double_it(21)  -- 42
```

## Documentation

Check out our [Wiki](https://github.com/gesslar/glu/wiki) for detailed documentation, guides, and examples.

## License

[IDGAF License](LICENSE.md) - Do whatever you want with this code. Seriously.
- Use it ✅
- Modify it ✅
- Copy it ✅
- Translate it to Klingon ✅
- Turn it into a interpretive dance routine ✅

Just have fun and make cool stuff! 🚀

[Liquid glue icons created by Freepik - Flaticon](https://www.flaticon.com/free-icons/liquid-glue)
