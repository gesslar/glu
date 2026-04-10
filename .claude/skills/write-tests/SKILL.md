---
name: write-tests
description: Write Busted test specs for Glu modules
---

# Writing Tests for Glu

Tests use the Busted framework and run inside Mudlet, so all Mudlet APIs are available.

## Where tests live

`src/resources/test/*_spec.lua`

## Template

```lua
describe("<module> module", function()
  local g

  setup(function()
    g = Glu("Glu")
  end)

  describe("<function_name>", function()
    it("should <expected behavior>", function()
      local result = g.<module>.<function_name>(<args>)
      assert.are.equal(<expected>, result)
    end)
  end)
end)
```

## Key patterns

- Create a Glu instance with `Glu("Glu")` in `setup()` — this gives access to all modules via `g.<module>.<function>`
- One `describe` block per module, nested `describe` per function
- Use `assert.are.equal(expected, actual)` for scalar comparison
- Use `assert.are.same(expected, actual)` for deep table comparison
- Use `assert.is_true()` / `assert.is_false()` for booleans
- Use `assert.is_truthy()` / `assert.is_falsy()` for nil checks
- Use `assert.is_nil()` for explicit nil
- Use `assert.has_error(function() ... end)` to test that code throws
- Use `pending("description", function() ... end)` for known-broken tests with a comment explaining the bug

## Mudlet-specific notes

- `table.size`, `table.index_of`, `table.keys`, `table.n_filter`, `table.is_empty` are Mudlet extensions — they work in tests
- `table.n_filter(t, fn)` calls `fn(element, index, table)` — element is the first arg
- `table.n_filter` returns `{}` (empty table) when nothing matches, not `nil`
- `rex.match`, `rex.find` are available for PCRE regex
- `string.split` is Mudlet's version
- `lfs` (LuaFileSystem) is available
- All Glu validation functions (`___.v.type`, `___.v.test`, etc.) are active

## Testing async/event-driven code

Mudlet's event loop doesn't yield to busted, so async code must be made synchronous via mocking. This pattern (used by Mudlet's own test suite) works for testing code that relies on `tempTimer`, `installPackage`, `raiseEvent`, and event handlers.

**Mock `tempTimer`** to execute callbacks immediately:

```lua
local real_tempTimer
before_each(function()
  real_tempTimer = _G.tempTimer
  _G.tempTimer = function(time, code)
    if type(code) == "function" then
      code()
    elseif type(code) == "string" then
      loadstring(code)()
    end
  end
end)
after_each(function()
  _G.tempTimer = real_tempTimer
end)
```

**Mock `installPackage`** (or similar async triggers) to do nothing, then use `raiseEvent` to synchronously fire the event the code is waiting for:

```lua
before_each(function()
  _G.installPackage = function() end
end)

it("should handle install", function()
  -- set up the code under test, then manually fire the event
  raiseEvent("sysInstall", "PackageName")
  -- assertions run immediately — the handler fires synchronously
end)
```

**Key insight:** `raiseEvent` calls registered event handlers synchronously, so combining mocked `tempTimer` + mocked async triggers + `raiseEvent` lets the entire async chain execute within a single `it` block.

Always save and restore real globals in `before_each`/`after_each` to avoid polluting other tests.

## Test fixtures

Static test fixtures live in `src/resources/test/fixtures/`. In Mudlet, everything under `resources/` is placed in the package's directory, where `resources/` is the package root. So fixtures are accessible at runtime via:

```lua
local fixtures_dir = getMudletHomeDir() .. "/Glu/test/fixtures"
```

Use fixtures for read-only test data (sample files, etc.). For tests that need to write files, use `g.fd.temp_dir()` to create an isolated temp directory and clean it up in `teardown`.

## Running tests

```bash
npm test                                          # all specs
```

## Process

1. Read the module source in `src/scripts/<module>.lua`
2. Identify public functions defined on `self` inside `setup`
3. Write tests covering: normal inputs, edge cases, error conditions
4. Run `./test/run-tests.sh` to verify
