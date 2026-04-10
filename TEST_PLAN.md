# Glu Test Plan

Comprehensive test coverage for all Glu modules. Tests use the **Busted** framework
and run inside a headless Mudlet instance via `test/run-tests.sh`.

Spec files live in `src/resources/test/` and follow the naming convention `<module>_spec.lua`.

---

## Philosophy

This is the first real test suite for Glu. The primary goal is to **surface bugs**, not
to rubber-stamp existing behaviour. When a test fails:

1. **Determine whether the code or the test is wrong.** The test asserts *correct*
   behaviour — if the code doesn't match, that's a bug in the code.
2. **Fix the bug, not the test.** Never write a test that confirms broken behaviour
   just to make it pass. If `format_number(0)` returns `"-0"`, fix `format_number`,
   don't assert `"-0"`.
3. **Document what you fixed.** Each module section has a "Bugs found and fixed" list
   at the bottom. Add to it so there's a record of what testing caught.
4. **Use `pending()` only for genuinely broken/incomplete code** that can't be fixed
   in the current pass (e.g. unfinished implementations with undefined variables).
   Come back and fix those too.

---

## Conventions

- Each spec file initialises Glu with `setup(function() g = Glu("Glu") end)`
- Access modules via `g.<module>.<function>()`
- Use `assert.are.equal`, `assert.is_true`, `assert.has_error`, etc. (Busted assertions)
- Group related tests in nested `describe` blocks per function
- Cover: happy path, edge cases, error/validation cases

---

## Tier 1 — Core Utilities (highest value, most dependencies)

These modules are used by nearly everything else. Test them first.

### table.lua

- [x] Existing: `table_spec.lua`
- [x] `n_cast` — indexed passthrough, single value wrap, multiple values, associative wrap
- [x] `map` — transform values, extra args, empty table
- [x] `values` — associative, indexed, empty
- [x] `n_uniform` — same type, mixed, specified type, mismatch, single element
- [x] `n_distinct` — duplicates, order preserved, already unique, single
- [x] `pop` / `push` / `shift` / `unshift` — ops, return values, empty table
- [x] `allocate` — table spec, scalar spec, function spec, length mismatch error, empty error
- [x] `indexed` / `associative` — sequential, string-keyed, empty, mixed, non-table error
- [x] `reduce` — accumulate, key passed, single element
- [x] `slice` — range, to-end, single element, full table
- [x] `remove` — single, range, first, last
- [x] `chunk` — even, uneven, size=1, size>length
- [x] `concat` — tables, scalars, empty, mixed
- [x] `drop` / `drop_right` — drop n, drop 1
- [x] `fill` — range, full table, from start to end
- [x] `find` / `find_last` — match, no match, first element
- [x] `flatten` / `flatten_deeply` — one level, deep, empty nested, already flat
- [x] `initial` — all but last, single element returns empty
- [x] `pull` — remove values, missing values, no args, all occurrences
- [x] `reverse` — odd, even, single
- [x] `uniq` — duplicates, already unique, single, order preserved
- [x] `unzip` / `zip` — pairs, triples, different-length error
- [x] `includes` — present, absent, type mismatch
- [x] `add` / `n_add` — merge, overwrite, append, insert at index, insert at beginning
- [x] `walk` — values, indices, empty
- [x] `element_of` / `element_of_weighted` — returns valid element, single element, weighted
- [x] `all` / `some` / `none` / `one` — function and scalar predicates, edge cases
- [x] `count` — function match, scalar match, no match
- [x] `natural_sort` / `sort` — natural ordering, original unchanged, custom comparator, fallback
- [x] `new_weak` / `weak` — default mode, key mode, kv mode, detection, non-weak
- [x] `object` — true, absent, false
- [x] `functions` / `methods` / `properties` — function keys, alias, non-function keys
- [ ] Validators: `not_empty`, `n_uniform`, `indexed`, `associative`, `object`, `option` — tested implicitly via usage, not directly
- [x] **Validated** — all tests passing (330 total, 0 failures, 0 pending)

Bugs found and fixed during testing:

- `new_weak()` — validated `opt` with `rex.match` before setting default, so `nil` crashed
- `weak()` — returned `nil` instead of `false` for tables without metatables
- `chunk()` — called `___.slice()` (Glu instance) instead of `self.slice()`
- `drop()` / `drop_right()` — passed `___` (Glu instance) as first arg to `self.slice()`; also wrong arg order in `___.v.test()`
- `fill()` — validator `___.v.test(start and start >= 1, ...)` failed on `nil` start (nil-and is nil)
- `initial()` — same `self.slice(___, tbl, ...)` bug as drop; also crashed on single-element table (stop=0)
- `natural_sort()` — had debug `print("We here")`

### string.lua

- [x] Existing: `string_spec.lua`
- [x] `capitalize` — lowercase, uppercase, single char, non-alpha first, empty string error, validation
- [x] `trim` / `ltrim` / `rtrim` — spaces, tabs, mixed whitespace, empty result, validation
- [x] `strip_linebreaks` — \r\n, \n only, mixed, no linebreaks
- [x] `replace` — simple, pattern chars, no match, empty replacement, validation
- [x] `split` — single delimiter, multi-part, empty segments, single char, validation
- [x] `walk` — iterate parts, default delimiter, index+value, validation
- [x] `format_number` / `parse_formatted_number` — round-trip, custom separators, negatives, zero, string input, non-numeric
- [x] `starts_with` / `ends_with` — match, no match, full string, single char
- [x] `contains` — match, no match, regex, ^ and $ rejection (bug fixed: was using starts_with/ends_with for validation)
- [x] `append` / `prepend` — basic concatenation, already present
- [x] `is_alpha` / `is_numeric` / `is_alphanumeric` — letters, digits, mixed, negatives, multi-char error
- [x] `is_whitespace` — space, tab, non-whitespace (bug fixed: was using Lua %s in PCRE)
- [x] `is_punctuation` — punctuation, non-punctuation, space (bug fixed: was using Lua %s in PCRE)
- [x] `is_uppercase` / `is_lowercase` — letters, non-letters
- [x] `index_of` — found, not found, first occurrence, regex, validation
- [x] `reg_assoc` — split by patterns, multiple patterns, custom default token, no match, overlap priority
- [x] `split_natural` — text+number parts, leading numbers, all text, all numbers, multiple segments
- [x] `natural_compare` — natural ordering, identical, alphabetical, prefix, numeric segments
- [x] **Validated** — all tests passing (225 total, 0 failures, 0 pending)

Bugs found and fixed during testing:

- `format_number(0)` returned `"-0"` — was using `number.positive()` instead of `< 0`
- `contains()` always errored — was using `starts_with()`/`ends_with()` to check for `^`/`$` anchors, but those methods prepend/append anchors themselves
- `is_whitespace()` never matched — used Lua `%s` in PCRE regex instead of `\\s`
- `is_punctuation()` matched spaces — same `%s` vs `\\s` issue in negated class
- Character classifiers were private (bare `function`) — changed to `self.xxx`
- `reg_assoc` had debug `print`, wrong variable name (`pre_match` vs `prematch`), infinite loop on no-match
- `split_natural` had typo (`resulit`), undefined vars (`i`, `is_num`), wrong APIs (`table.push`), missing `return`, was private
- `natural_compare` was private

### number.lua

- [x] Existing: `number_spec.lua`
- [x] `round` — integer, decimal places, round up, negative, zero, validation
- [x] `clamp` — within range, below, above, boundary
- [x] `lerp` — t=0, t=1, t=0.5, negative range, t out-of-range error
- [x] `lerp_smooth` — t=0, t=1, t=0.5, between start/end, t out-of-range error
- [x] `lerp_smoother` — t=0, t=1, t=0.5, between start/end
- [x] `lerp_ease_in` — t=0, t=1, quadratic at 0.5 (=25), less than linear
- [x] `lerp_ease_out` — t=0, t=1, quadratic at 0.5 (=75), greater than linear
- [x] `map` — range mapping, inverted, negative, boundaries
- [x] `positive` — positive, negative, zero
- [x] `is_between` — in range, boundaries, out of range
- [x] `sign` — positive (1), negative (-1), zero (0)
- [x] `is_approximate` — within/outside tolerance, default 5%, zero base
- [x] `min` / `max` — varargs, table, single value, negatives
- [x] `sum` — varargs, table, single, negatives, floats
- [x] `random_clamp` — within range, negative range, min=max
- [x] `average` / `mean` — varargs, table, single-element, decimal, same result
- [x] `percent_of` — basic, rounded, >100%
- [x] `percent` — basic, small, rounded, 100%, 0%
- [x] `normalize` — mid, min, max, non-zero-based
- [x] `constrain` — precisions 0.01, 0.1, 1, 5, 10, exact multiple
- [x] Validator: `range` — tested indirectly via table.n_add
- [x] **Validated** — all tests passing (394 total, 0 failures, 0 pending)

Bugs found and fixed during testing:

- `sum()` — called `___.table.n_reduce()` which doesn't exist; fixed to `___.table.reduce()`
- `average()` / `mean()` — overly complex varargs handling broke single-element tables; simplified to match `min`/`max`/`sum` pattern using `n_cast` directly

---

## Tier 2 — Data & Logic Modules

### colour.lua ✅

- [x] `rgb_to_hsl` / `hsl_to_rgb` — round-trip conversions, pure colors, grayscale
- [x] `to_hex` — with/without background colour
- [x] `is_light` — light colors, dark colors, high/low luminance
- [x] `interpolate` — all methods (linear, smooth, smoother, ease_in, ease_out), factor=0/50/100, invalid method
- [x] `adjust_colour` / `lighten` / `darken` — positive/negative amounts, boundary clipping, default amount
- [x] `lighten_or_darken` — auto-detect based on comparison color, default/custom amount
- [x] `complementary` — 180-degree hue rotation, gray invariance
- [x] `grayscale` — average desaturation, identity for white/black/gray
- [x] `adjust_saturation` — factor 0 (desaturate), factor 1 (identity), factor 0.5
- [x] `random` — returns valid RGB, structure and range checks
- [x] `random_shade` — within range of base color, clamping, default range
- [x] `triad` — 2-color harmony at 120/240 degrees
- [x] `tetrad` — 4-color harmony at 90-degree intervals, includes original
- [x] `analogous` — 3 adjacent colors including original, default/custom angle
- [x] `split_complement` — split complementary, custom angle
- [x] `monochrome` — step count, valid RGB, same hue preserved
- [x] `contrast_ratio` — WCAG calculation, black/white=21, symmetry
- [x] `contrast` — invert lightness, preserve hue/saturation
- [x] Validators: `rgb_table`, `hsl_table` (nil guard, boundary, type checks)

#### Bugs found and fixed

- `to_hex()` — second parameter was a `boolean` flag but referenced undefined `bg` variable; changed to accept an optional background RGB table
- `rgb_table` validator — missing early return when `nil_allowed=true` and value is `nil`; crashed on `#colour`
- `hsl_table` validator — same missing nil guard as `rgb_table`

### conditions.lua ✅

- [x] `is` / `is_true` / `is_false` — boolean conditions, default/custom messages, non-boolean rejection
- [x] `is_nil` / `is_not_nil` — nil and non-nil, false vs nil distinction
- [x] `is_error` — function that errors, function that doesn't, custom check function, check failure
- [x] `is_eq` / `is_ne` — equal/not equal across types, same reference, nil == nil
- [x] `is_lt` / `is_le` / `is_gt` / `is_ge` — comparison operators, boundary equality, strings
- [x] `is_type` — all Lua types (string, number, table, boolean, function, nil)
- [x] `is_deeply` — nested tables, missing/extra keys, empty tables, scalars, mixed key types

#### Bugs found and fixed

- `is()` — `condition and nil or message` Lua ternary fails when true branch is `nil`; always returned message even on success. Fixed with explicit `if/else`.

### same.lua ✅

- [x] `value_zero` — NaN (same), +0/-0 (same), type mismatches, booleans, table/function refs
- [x] `value` — NaN (same), +0/-0 (same), various types

#### Changes made

- `value()` — removed dead +0/-0 reciprocal check; LuaJIT optimizes away -0, making the distinction unreachable. Both functions now treat zeros identically.

### version.lua ✅

- [x] `compare` — greater, lesser, equal, 1/2/3-segment versions, number inputs, numeric segments >= 10, string segments, different segment counts error, mixed type error, invalid type errors

#### Bugs found and fixed

- `compare()` — called undefined validator `___.v.same_type()`; added `same_type` as a core validator in `glu.lua`
- `compare()` — segments compared as strings after `split()`, so `"9" > "10"` lexicographically; fixed `_compare` to try `tonumber()` first, falling back to string comparison for non-numeric segments

### url.lua ✅

- [x] `encode` / `decode` — round-trip, special characters, spaces, empty string, error cases
- [x] `encode_params` / `decode_params` — round-trip, special characters in keys/values, empty table, multiple params
- [x] `parse` — full URLs with query params, http/https default ports, explicit port, no query string, filename extraction, single path segment, error cases

#### Bugs found and fixed

- `decode_params()` — regex `([^=]+)=([^=]+)` required non-empty value; `key=` (empty value) was silently dropped. Changed to `([^=]+)=(.*)`
- `parse()` — regex required `/` after host; bare domain URLs like `https://example.com` failed to match. Made path and query groups optional, added `?` to host character exclusion, and normalized `false` returns from `rex.match` unmatched optional captures to `nil`

### try.lua ✅

- [x] `try` — successful execution, returns result, stores success/error/caught, passes arguments, handles nil/false/string/table returns
- [x] `catch` — receives try result info, called on success and error, handles catch handler that errors
- [x] `finally` — executes after try, after try+catch, receives full result, errors if handler errors
- [x] Chaining — try/catch/finally, try/finally (no catch), successful try/catch/finally, execution order
- [x] `clone` — creates independent instances, no shared state

#### Bugs found and fixed

- `try()` — Lua ternary `success and nil or try_result` set `error` field to the return value instead of nil on success. Also `success and try_result or nil` lost `false` return values. Replaced with explicit `if/else`.
- `catch()` — same Lua ternary bugs in `error` and `result` fields. Replaced with explicit `if/else`.

---

## Tier 3 — Data Structures

### queue_stack.lua ✅

- [x] Construction — empty, with initial functions, id assignment, nil funcs default, non-function rejection
- [x] `push` — add functions, return new count, FIFO ordering, error on non-function/nil
- [x] `shift` — remove in FIFO order, return nil when empty
- [x] `execute` — runs and removes, passes self + arguments, returns self/count/results, multiple results, FIFO order across calls, count decrement, nil count when empty

### queue.lua ✅

- [x] `new_queue` — create with function list, nil for empty, adds to queues list, error on non-functions
- [x] `get` — retrieve by ID, nil + error for unknown ID, error on non-string/nil
- [x] `push` / `shift` — add/remove by queue ID, return count/function, nil + error for unknown ID, validation errors

### queuable.lua ✅

- [x] `stack` property — initialised as empty table
- [x] Adopted methods — push/shift available as functions, push adds to end, shift removes from front

---

## Tier 4 — I/O & System Modules (require Mudlet mocking)

### fd.lua (file/directory) ✅

- [x] `fix_path` — backslash to forward slash, collapse double slashes, preserve trailing slash, unchanged paths
- [x] `determine_path_separator` — forward slash, backslash, preference order, no separator
- [x] `determine_root` — Unix `/`, Windows `C:\`, relative paths
- [x] `dir_file` — split path into dir+file, backslash normalization, validation
- [x] `root_dir_file` — absolute Unix path split, relative path returns nil
- [x] `file_exists` / `dir_exists` — existing and non-existing paths, type discrimination (file vs dir)
- [x] `read_file` / `write_file` — text and binary modes, overwrite vs append, return values, error on non-existing
- [x] `valid_path_string` / `valid_path` — separator detection, existing paths
- [x] `get_dir` / `dir_empty` — list files, dot exclusion/inclusion, empty directory detection
- [x] `assure_dir` — create single and nested directories, idempotent on existing
- [x] `temp_dir` — creates unique directories
- [x] `rmfile` / `rmdir` — delete operations, error on wrong type, error on non-existing
- [x] Validators — `file`, `dir` validators via rmfile/rmdir

#### Bugs found and fixed

- `fix_path()` — `num` variable only tracked count from second `rex.gsub` (double slash collapse), not the first (backslash conversion). Single backslash paths that didn't produce double slashes returned the original unchanged path. Fixed by tracking both counts.
- `fix_path()` — original had dead code for trailing slash stripping (gated behind `num > 0` which only counted the second gsub). Removed dead code; trailing slashes are preserved as `assure_dir` depends on them.

### timer.lua

- [x] Existing: `timer_spec.lua`
- [x] `multi` — creation, return value, stores timer id, uniform delay, per-step delay
- [x] `multi` — sequential execution (3-step chain), cleanup after last step
- [x] `multi` — validation: non-string name, empty def, tempTimer failure
- [x] `kill_multi` — kills existing, removes from state, calls killTimer with correct id
- [x] `kill_multi` — returns nil for non-existent, validation: non-string name
- [x] **Validated** — all tests passing (410 total, 0 failures, 0 pending)

No bugs found — timer module is clean.

### preferences.lua ✅

- [x] `save` — with/without package, validation errors
- [x] `load` — load saved prefs, defaults on missing file, merge saved with defaults, with/without package, validation errors

### http.lua + http_request.lua + http_response.lua ✅

- [x] `get` / `post` / `put` / `delete` — correct method dispatch, method override
- [x] `download` — defaults to GET, error on missing saveTo
- [x] `request` — custom method, uppercase normalization, headers default/preserve, validation errors (missing url, invalid url, missing callback, non-table options)
- [x] `find_request` / `delete_request` — find by id, nil for unknown, remove by id, no error on unknown
- [x] Callback execution — done event fires callback with response
- [x] `http_request` — id assignment, header initialization, custom vs standard method detection
- [x] `http_response` — stores response data (tested through callback)

#### Bugs found and fixed

- `validate_options()` — `___.v.regex` called with extra `"url"` argument that shifted parameter positions; `nil_allowed` received `1` (truthy) instead of `false`, causing nil URLs to pass validation silently. Removed extra argument.

---

## Tier 5 — Framework & Integration

### glu.lua (core framework) ✅

- [x] `Glu.new` — create instance, package name, callable via `Glu()`, TYPE constants, error on invalid args
- [x] `Glu.get_glass` / `has_glass` / `get_glass_names` / `get_glasses` — glass registry, find/not found, name list
- [x] `Glu.id` — UUID v4 format, uniqueness, version digit
- [x] `Glass.register` — returns existing glass, error on missing name/class_name/setup, error on non-table
- [x] Module access — all registered modules accessible on instance
- [x] `has_object` / `get_object` — find existing, nil for non-existing
- [x] `getPackageName` — returns package name
- [x] Dependency injection — dependencies resolved, all modules available
- [x] Validators — `v.type` (correct/wrong type, nil handling, any, union types), `v.test`, `v.not_nil`, `v.same_type`
- [x] Uninstall handler — handler_name set with correct prefix

### glass_loader.lua ✅

- [x] `load_glass` — load from local file path, return compiled function
- [x] `load_glass` — execute loaded code with `execute=true`
- [x] Error handling — missing file, invalid lua syntax, execution errors, missing callback, missing path

### dependency_queue.lua

- [x] Existing: `dependency_queue_spec.lua`
- [x] `new_dependency_queue` — all installed, needs installing, multiple uninstalled, mixed, empty list
- [x] `start` — begin installation, start after clean_up returns nil+error
- [x] `clean_up` — nils queue, nils handler_name
- [x] Install flow — sysInstall completes single, sysInstall completes multi-sequence
- [x] Install flow — ignores sysInstall for non-matching package name
- [x] Error handling — download error single, download error first-of-multi, download error second-of-multi
- [x] Cleanup verification — handlers cleaned after success, handlers cleaned after error
- [x] **Validated** — all tests passing

### command_queue.lua ⚠️ NOT TESTED — implementation has structural issues

- [ ] `queue` — queue commands with delay
- [ ] State management — RUNNING, PAUSED, STOPPED, ERROR transitions

#### Issues found (not fixed — needs design review)

- `executeNextCommand`, `pauseExecution`, `resumeExecution`, `extendDelay`, `fullStop`, `repeatLastStep` are all global leaks (not `local` or `self.`)
- `executeNextCommand` references `.cmd` on sequence items but the map stores `{ func = f }` — no `.cmd` property
- `___.v.test(delay, "number", 3, false)` misuses the validator — first arg should be a boolean statement, not the value
- Module appears to be a work-in-progress prototype

---

## Tier 6 — Date & Specialised

### date.lua

- [x] Existing: `date_spec.lua`
- [x] `shms` — numeric mode: 0, negative, large, fractional, exact minute, exact hour
- [x] `shms` — string mode: 0s, seconds only, minutes only, hours only, combined
- [x] `shms` — validation: non-number arg, non-boolean arg, nil second arg
- [x] **Validated** — all tests passing

---

## Tier 7 — Meta / Test Infrastructure

### test.lua / test_runner.lua ✅

- [x] `runner` — creation, id, default/custom colours, default symbols, empty initial tests
- [x] `add` — add test, chaining, multiple tests, counter initialization, runner reference, validation errors
- [x] `remove` — remove by name, chaining, error on non-existing
- [x] `reset` — reset counters to 0, chaining
- [x] `wipe` — remove all tests, chaining
- [x] `pass` / `fail` — increment counters correctly
- [x] Construction with tests — opts with name/func, array-style entries

---

## Modules NOT requiring test specs

| Module | Reason |
|--------|--------|
| `regex.lua` | Single property + validator; covered implicitly by modules that use it |
| `func.lua` | 3 functions, all depend on Mudlet `tempTimer`; low value without real timer |

---

## Notes

- **Mocking**: Modules in Tiers 4-5 depend heavily on Mudlet APIs. The test harness
  runs inside a real Mudlet instance, so most APIs are available. For unit isolation,
  consider `stub`/`mock` from Busted where needed.
- **Known bugs**: `string.reg_assoc()` has a debug print statement; `string.split_natural()`
  may be incomplete; `command_queue.lua` has unfinished code. Tests should document
  these as `pending()` until fixed.
- **Validator coverage**: Many modules define custom validators in their `valid` table.
  Each validator should have its own `describe` block testing valid input, invalid input,
  and the `nil_allowed` flag.
