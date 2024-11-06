-- This is a test for the colour module.
local test_script = "test"
local target_script = "colour"
local tester_name = "__PKGNAME__"
local g = Glu.new(tester_name, nil)
local mod = g[target_script]
local test = g[test_script]

local function interpolate(runner)
  return runner.is_deeply(
    mod.interpolate({255,0,0},{0,0,255},0.5),
    {128,0,128},
    "interpolate() should return the correct interpolated colour"
  )
end

local function is_light(runner)
  return runner.is_eq(
    mod.is_light({255,255,255}),
    true,
    "is_light() should return true for a light colour"
  )
end

local function is_dark(runner)
  return runner.is_eq(
    mod.is_light({0,0,0}),
    false,
    "is_light() should return false for a dark colour"
  )
end

local function adjust_colour_lighten(runner)
  return runner.is_deeply(
    mod.adjust_colour({125,125,125},50,true),
    { 175, 175, 175 },
    "adjust_colour() should return the correct adjusted colour"
  )
end

local function adjust_colour_darken(runner)
  return runner.is_deeply(
    mod.adjust_colour({125,125,125},50,false),
    { 75, 75, 75 },
    "adjust_colour() should return the correct adjusted colour"
  )
end

local function darken(runner)
  return runner.is_deeply(
    mod.darken({125,125,125},50),
    { 75, 75, 75 },
    "darken() should return the correct darkened colour"
  )
end

local function lighten(runner)
  return runner.is_deeply(
    mod.lighten({125,125,125},50),
    { 175, 175, 175 },
    "lighten() should return the correct lightened colour"
  )
end

local function lighten_or_darken_light(runner)
  return runner.is_deeply(
    mod.lighten_or_darken({0,0,0},{0,0,0}, 50),
    { 50, 50, 50 },
    "lighten_or_darken() should return the correct lightened colour"
  )
end

local function lighten_or_darken_dark(runner)
  return runner.is_deeply(
    mod.lighten_or_darken({255,255,255},{255,255,255}, 50),
    { 205, 205, 205 },
    "lighten_or_darken() should return the correct darkened colour"
  )
end

local function complementary(runner)
  return runner.is_deeply(
    mod.complementary({255,0,0}),
    { 0, 255, 255 },
    "complementary() should return the correct complementary colour"
  )
end

local function grayscale(runner)
  return runner.is_deeply(
    mod.grayscale({200,0,200}),
    { 133, 133, 133 },
    "grayscale() should return the correct grayscale colour"
  )
end

local function adjust_saturation(runner)
  return runner.is_deeply(
    mod.adjust_saturation({200,0,200}, 0.5),
    { 166, 66, 166 },
    "adjust_saturation() should return the correct saturated colour"
  )
end

local function random(runner)
  -- Expected color when using seed 1
  local expected_random_color = {0, 144, 49}

  -- Seed the random number generator for predictable results
  math.randomseed(1)

  -- Run the test
  local result = runner.is_deeply(
    mod.random(),
    expected_random_color,
    "random() should return a predictable random color with seed 1"
  )

  -- Reset the seed to avoid affecting other random functions in the program
  math.randomseed(os.time())

  return result
end

local function random_shade(runner)
  -- Expected color when using seed 1
  local expected_random_color = {100,56,130}

  -- Seed the random number generator for predictable results
  math.randomseed(1)

  -- Run the test
  local result = runner.is_deeply(
    mod.random_shade({200,0,200}, 100),
    expected_random_color,
    "random_shade() should return a predictable random color with seed 1"
  )

  -- Reset the seed to avoid affecting other random functions in the program
  math.randomseed(os.time())

  return result
end

local function generate_triad(runner)
  return runner.is_deeply(
    mod.generate_triad({125,0,200}),
    {{40,204,204},{125,204,204}},
    "generate_triad() should return the correct triad"
  )
end
-- Run the tests

---@diagnostic disable-next-line: lowercase-global
function run_colour_tests()
  ---@diagnostic disable-next-line: undefined-global
  local runner = test.runner({name = "colour.runner"})
    .add("colour.interpolate", interpolate)
    .add("colour.is_light", is_light)
    .add("colour.is_dark", is_dark)
    .add("colour.adjust_colour_lighten", adjust_colour_lighten)
    .add("colour.adjust_colour_darken", adjust_colour_darken)
    .add("colour.darken", darken)
    .add("colour.lighten", lighten)
    .add("colour.lighten_or_darken_light", lighten_or_darken_light)
    .add("colour.lighten_or_darken_dark", lighten_or_darken_dark)
    .add("colour.complementary", complementary)
    .add("colour.grayscale", grayscale)
    .add("colour.adjust_saturation", adjust_saturation)
    .add("colour.random", random)
    .add("colour.random_shade", random_shade)
    .add("colour.generate_triad", generate_triad)
    .execute(true)
    .wipe()
end
