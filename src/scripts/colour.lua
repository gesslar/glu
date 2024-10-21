local mod = mod or {}
local script_name = "colour"
function mod.new(parent)
  local instance = { parent = parent }

  --- Interpolates between two RGB colours based on a step value. Functionally,
  --- it takes two colours and returns a third colour somewhere between the
  --- two colours, based on the step value. Generally used to fade between two
  --- colours. The step value is the current transition percentage as a whole
  --- number between the two colours, with 0 being the first colour and 100 being
  --- the second colour.
  ---
  --- Example:
  --- colour:interpolate({255, 0, 0}, {0, 0, 255}, 50)
  --- Returns: {127, 0, 127}
  --- @type function
  --- @param rgb1 table - The first RGB colour as a table with three elements: red, green, and blue.
  --- @param rgb2 table - The second RGB colour as a table with three elements: red, green, and blue.
  --- @param step number - The step value between 1 and 100.
  --- @return table - The interpolated RGB colour as a table with three elements: red, green, and blue.
  function instance:interpolate(rgb1, rgb2, step)
    instance.parent.valid:rgb_table(rgb1, 1, false)
    instance.parent.valid:rgb_table(rgb2, 2, false)
    instance.parent.valid:type(step, "number", 3, false)
    assert(step >= 0 and step <= 100, "Invalid step value " .. step .. " given. Step value must be between 0 and 100.")

    local r1, g1, b1 = rgb1[1], rgb1[2], rgb1[3]
    local r2, g2, b2 = rgb2[1], rgb2[2], rgb2[3]

    local factor = step / 100

    local r, g, b = math.floor(r1 + (r2 - r1) * factor + 0.5),
                    math.floor(g1 + (g2 - g1) * factor + 0.5),
                    math.floor(b1 + (b2 - b1) * factor + 0.5)

    return { r, g, b }
  end

  --- colour:is_light(colour)
  --- Determines if a colour is a light colour.
  --- @type function
  --- @param rgb table - The RGB colour as a table with three elements: red, green, and blue.
  --- @return boolean - True if the colour is light, false otherwise.
  function instance:is_light(rgb)
    instance.parent.valid:rgb_table(rgb, 1, false)
    local r = rgb[1] / 255
    local g = rgb[2] / 255
    local b = rgb[3] / 255
    local luminance = 0.2126 * r + 0.7152 * g + 0.0722 * b
    return luminance > 0.5
  end

  --- colour:lighten(colour, amount)
  --- Lightens a colour by a given amount.
  --- @type function
  --- @param rgb table - The RGB colour as a table with three elements: red, green, and blue.
  --- @param amount number - The amount to lighten the colour by. (Optional, defaults to 30)
  --- @return table - The lightened RGB colour as a table with three elements: red, green, and blue.
  function instance:lighten(rgb, amount)
    instance.parent.valid:rgb_table(rgb, 1, false)
    instance.parent.valid:type(amount, "number", 2, true)

    amount = amount or 30

    return {
      math.min(rgb[1] + amount, 255),
      math.min(rgb[2] + amount, 255),
      math.min(rgb[3] + amount, 255)
    }
  end

  --- colour:darken(colour, amount)
  --- Darkens a colour by a given amount.
  --- @type function
  --- @param rgb table - The RGB colour as a table with three elements: red, green, and blue.
  --- @param amount number - The amount to darken the colour by.
  --- @return table - The darkened RGB colour as a table with three elements: red, green, and blue.
  function instance:darken(rgb, amount)
    instance.parent.valid:rgb_table(rgb, 1, false)
    instance.parent.valid:type(amount, "number", 2, true)

    amount = amount or 30

    return {
      math.max(rgb[1] - amount, 0),
      math.max(rgb[2] - amount, 0),
      math.max(rgb[3] - amount, 0)
    }
  end

  --- colour:lighten_or_darken(rgb1, rgb2, amount)
  --- Lightens or darkens the first colour by a given amount based on a comparison with the second colour.
  --- @type function
  --- @param rgb_compare table - The first RGB colour as a table with three elements: red, green, and blue.
  --- @param rgb_colour table - The second RGB colour as a table with three elements: red, green, and blue.
  --- @param amount number - The amount to lighten or darken the colour by. (Optional, defaults to 85)
  --- @return table - The adjusted RGB colour as a table with three elements: red, green, and blue. Unless the colours are already constrasted, in which case the original colour is returned.
  function instance:lighten_or_darken(rgb_colour, rgb_compare, amount)
    instance.parent.valid:rgb_table(rgb_colour, 1, false)
    instance.parent.valid:rgb_table(rgb_compare, 2, false)
    instance.parent.valid:type(amount, "number", 3, true)

    amount = amount or 85

    local colour_is_light = instance:is_light(rgb_colour)
    local compare_is_light = instance:is_light(rgb_compare)
    if colour_is_light == compare_is_light then
      if colour_is_light then
        return instance:darken(rgb_colour, amount)
      else
        return instance:lighten(rgb_colour, amount)
      end
    end
    return rgb_colour
  end

  --- colour:complementary(colour)
  --- Returns the complementary colour of a given colour.
  --- @type function
  --- @param rgb table - The RGB colour as a table with three elements: red, green, and blue.
  --- @return table - The complementary RGB colour as a table with three elements: red, green, and blue.
  function instance:complementary(rgb)
    instance.parent.valid:rgb_table(rgb, 1, false)

    return { 255 - rgb[1], 255 - rgb[2], 255 - rgb[3] }
  end

  --- colour:to_grayscale(colour)
  --- Converts a colour to its grayscale equivalent.
  --- @type function
  --- @param rgb table - The RGB colour as a table with three elements: red, green, and blue.
  --- @return table - The grayscale RGB colour as a table with three elements: red, green, and blue.
  function instance:grayscale(rgb)
    instance.parent.valid:rgb_table(rgb, 1, false)

    local gray = math.floor((rgb[1] + rgb[2] + rgb[3]) / 3 + 0.5)
    return { gray, gray, gray }
  end

  --- colour:adjust_saturation(colour, factor)
  --- Adjusts the saturation of a colour by a given factor.
  --- @type function
  --- @param rgb table - The RGB colour as a table with three elements: red, green, and blue.
  --- @param factor number - A factor between 0 (fully desaturated) and 1 (fully saturated).
  --- @return table - The adjusted RGB colour as a table with three elements: red, green, and blue.
  function instance:adjust_saturation(rgb, factor)
    instance.parent.valid:rgb_table(rgb, 1, false)
    instance.parent.valid:type(factor, "number", 2, true)

    local gray = (rgb[1] + rgb[2] + rgb[3]) / 3
    return {
      math.floor(gray + (rgb[1] - gray) * factor),
      math.floor(gray + (rgb[2] - gray) * factor),
      math.floor(gray + (rgb[3] - gray) * factor)
    }
  end

  --- colour:random()
  --- Generates a random RGB colour.
  --- @type function
  --- @return table - A random RGB colour as a table with three elements: red, green, and blue.
  function instance:random()
    return { math.random(0, 255), math.random(0, 255), math.random(0, 255) }
  end

  --- colour:random_shade(colour, range)
  --- Generates a random shade of a given colour within a range.
  --- @type function
  --- @param rgb table - The RGB colour as a table with three elements: red, green, and blue.
  --- @param range number - The range to adjust the colour by (e.g., 50 means +/- 50 for R, G, and B). (Optional, defaults to 50)
  --- @return table - A random RGB colour that is a shade of the given colour.
  function instance:random_shade(rgb, range)
    instance.parent.valid:rgb_table(rgb, 1, false)
    instance.parent.valid:type(range, "number", 2, true)

    range = range or 50

    local r = math.random(math.max(0, rgb[1] - range), math.min(255, rgb[1] + range))
    local g = math.random(math.max(0, rgb[2] - range), math.min(255, rgb[2] + range))
    local b = math.random(math.max(0, rgb[3] - range), math.min(255, rgb[3] + range))
    return { r, g, b }
  end

  --- colour:generate_triad(colour)
  --- Generates the triad colours of a given colour.
  --- @type function
  --- @param rgb table - The RGB colour as a table with three elements: red, green, and blue.
  --- @return table - A table of RGB colours that are the triad of the given colour.
  function instance:generate_triad(rgb)
    instance.parent.valid:rgb_table(rgb, 1, false)

    local angle = 120
    local h = (rgb[1] / 255 + angle / 360) % 1
    local s = 0.8
    local v = 0.8

    local h1 = (h + 1 / 3) % 1
    local h2 = (h - 1 / 3) % 1

    local rgb1 = { h1 * 255, s * 255, v * 255 }
    local rgb2 = { h2 * 255, s * 255, v * 255 }

    return { rgb1, rgb2 }
  end

  return instance
end

-- Let Glu know we're here
raiseEvent("glu_module_loaded", script_name, mod)

return mod
