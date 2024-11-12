---@diagnostic disable-next-line: lowercase-global
function run_colour_tests()
  -- This is a test for the colour module.
  local tester_name = "__PKGNAME__"
  local g = Glu(tester_name)
  local testing = g.colour
  local test = g.test

  local function interpolate(cond)
    return cond.is_deeply(
      testing.interpolate({255,0,0},{0,0,255},50),
      {255,0,255},
      "interpolate() should return the correct interpolated colour"
    )
  end

  local function is_light(cond)
    return cond.is_eq(
      testing.is_light({255,255,255}),
      true,
      "is_light() should return true for a light colour"
    )
  end

  local function is_dark(cond)
    return cond.is_eq(
      testing.is_light({0,0,0}),
      false,
      "is_light() should return false for a dark colour"
    )
  end

  local function adjust_colour_lighten(cond)
    return cond.is_deeply(
      testing.adjust_colour({125,125,125},50,true),
      { 175, 175, 175 },
      "adjust_colour() should return the correct adjusted colour"
    )
  end

  local function adjust_colour_darken(cond)
    return cond.is_deeply(
      testing.adjust_colour({125,125,125},50,false),
      { 75, 75, 75 },
      "adjust_colour() should return the correct adjusted colour"
    )
  end

  local function darken(cond)
    return cond.is_deeply(
      testing.darken({125,125,125},50),
      { 75, 75, 75 },
      "darken() should return the correct darkened colour"
    )
  end

  local function lighten(cond)
    return cond.is_deeply(
      testing.lighten({125,125,125},50),
      { 175, 175, 175 },
      "lighten() should return the correct lightened colour"
    )
  end

  local function lighten_or_darken_light(cond)
    return cond.is_deeply(
      testing.lighten_or_darken({0,0,0},{0,0,0}, 50),
      { 50, 50, 50 },
      "lighten_or_darken() should return the correct lightened colour"
    )
  end

  local function lighten_or_darken_dark(cond)
    return cond.is_deeply(
      testing.lighten_or_darken({255,255,255},{255,255,255}, 50),
      { 205, 205, 205 },
      "lighten_or_darken() should return the correct darkened colour"
    )
  end

  local function complementary(cond)
    return cond.is_deeply(
      testing.complementary({255,0,0}),
      { 0, 255, 255 },
      "complementary() should return the correct complementary colour"
    )
  end

  local function grayscale(cond)
    return cond.is_deeply(
      testing.grayscale({200,0,200}),
      { 133, 133, 133 },
      "grayscale() should return the correct grayscale colour"
    )
  end

  local function adjust_saturation(cond)
    return cond.is_deeply(
      testing.adjust_saturation({200,0,200}, 0.5),
      { 166, 66, 166 },
      "adjust_saturation() should return the correct saturated colour"
    )
  end

  local function random(cond)
    -- Expected color when using seed 1
    local expected_random_color = {0, 144, 49}

    -- Seed the random number generator for predictable results
    math.randomseed(1)

    -- Run the test
    local result = cond.is_deeply(
      testing.random(),
      expected_random_color,
      "random() should return a predictable random color with seed 1"
    )

    -- Reset the seed to avoid affecting other random functions in the program
    math.randomseed(os.time())

    return result
  end

  local function random_shade(cond)
    -- Expected color when using seed 1
    local expected_random_color = {100,56,130}

    -- Seed the random number generator for predictable results
    math.randomseed(1)

    -- Run the test
    local result = cond.is_deeply(
      testing.random_shade({200,0,200}, 100),
      expected_random_color,
      "random_shade() should return a predictable random color with seed 1"
    )

    -- Reset the seed to avoid affecting other random functions in the program
    math.randomseed(os.time())

    return result
  end

  local function triad(cond)
    return cond.is_deeply(
      testing.triad({125,0,200}),
      {{199,126,0},{0,199,126}},
      "triad() should return the correct triad"
    )
  end

  -- Run the tests
  local runner = test.runner({
    name = testing.name,
    tests = {
      { name = "colour.interpolate", func = interpolate },
      { name = "colour.is_light", func = is_light },
      { name = "colour.is_dark", func = is_dark },
      { name = "colour.adjust_colour_lighten", func = adjust_colour_lighten },
      { name = "colour.adjust_colour_darken", func = adjust_colour_darken },
      { name = "colour.darken", func = darken },
      { name = "colour.lighten", func = lighten },
      { name = "colour.lighten_or_darken_light", func = lighten_or_darken_light },
      { name = "colour.lighten_or_darken_dark", func = lighten_or_darken_dark },
      { name = "colour.complementary", func = complementary },
      { name = "colour.grayscale", func = grayscale },
      { name = "colour.adjust_saturation", func = adjust_saturation },
      { name = "colour.random", func = random },
      { name = "colour.random_shade", func = random_shade },
      { name = "colour.triad", func = triad },
    },
  })
  .execute(true)
  .wipe()
end
