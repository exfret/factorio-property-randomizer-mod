local prototype_tables = require("randomizer-parameter-data/prototype-tables")

local inertia_function = require("randomizer-parameter-data/inertia-function-tables")
local property_info = require("randomizer-parameter-data/property-info-tables")

require("random-utils/randomization-algorithms")

---------------------------------------------------------------------------------------------------
-- randomize_all_game_sounds
---------------------------------------------------------------------------------------------------

-- Currently, I don't really use this since it's a little too silly

function is_sound_file (file)
  return file and string.len(file) >= 4 and prototype_tables.sound_file_extensions[string.sub(file, -4)]
end

function is_sound_property (property)
  if type(property) ~= "table" then
    return false
  end

  if is_sound_file(property.filename) then
    return true
  end
  if property[1] and type(property[1]) == "table" and is_sound_file(property[1].filename) then
    return true
  end
  if property.variations and is_sound_file(property.variations.filename) then
    return true
  end
  if property.variations and property.variations[1] and is_sound_file(property.variations[1].filename) then
    return true
  end

  return false
end

function randomize_all_game_sounds ()
  local sounds = {}

  -- Gather up all the sounds
  for _, class in pairs(data.raw) do
    for _, prototype in pairs(class) do
      for _, property in pairs(prototype) do
        if is_sound_property(property) then
          table.insert(sounds, property)
        end
      end
    end
  end

  -- Now mix them all together
  for _, class in pairs(data.raw) do
    for _, prototype in pairs(class) do
      for property_key, property in pairs(prototype) do
        if is_sound_property(property) then
          prototype[property_key] = sounds[prg.range(1,#sounds)]
        end
      end
    end
  end
end

---------------------------------------------------------------------------------------------------
-- randomize_equipment_grids
---------------------------------------------------------------------------------------------------

function randomize_equipment_grids ()
  for _, prototype in pairs(data.raw["equipment-grid"]) do
    randomize_numerical_property{
      prototype = prototype,
      property = "width",
      property_info = property_info.equipment_grid
    }
    randomize_numerical_property{
      prototype = prototype,
      property = "height",
      property_info = property_info.discrete
    }
    randomize_numerical_property{
      prototype = prototype,
      property = "width",
      property_info = property_info.discrete
    }
  end
end

---------------------------------------------------------------------------------------------------
-- randomize_equipment_properties
---------------------------------------------------------------------------------------------------

-- triangle (each orientation) for now

-- TODO: Mess with equipment shape more
-- TODO: Just clean this up in general
function randomize_equipment_properties ()
  for class_name, _ in pairs(defines.prototypes["equipment"]) do
    for _, prototype in pairs(data.raw[class_name]) do
    end
  end

  --[[local shape_2d_array
  local num_points
  if prototype.shape.type == "manual" then
    num_points = #prototype.shape.points
  else
    num_points = prototype.height * prototype.width
  end]]

--[[  if prototype.shape.width then
    prototype.shape.width = randomize_small_int(prototype.shape.width, 1, 31)
  end

  if prototype.shape.height then
    prototype.shape.height = randomize_small_int(prototype.shape.height, 1, 31)
  end

  if prototype.max_shield_value then
    randomize_numerical_property{
      prototype
    }
    prototype.max_shield_value = prototype.max_shield_value * random_modifier()
  end

  if prototype.movement_bonus then
    prototype.movement_bonus = prototype.movement_bonus * random_modifier()
  end

  if prototype.construction_radius then
    prototype.construction_radius = prototype.construction_radius * random_modifier()
  end

  if prototype.robot_limit then
    prototype.robot_limit = math.ceil(prototype.robot_limit * random_modifier())
  end]]
end

---------------------------------------------------------------------------------------------------
-- randomize_fluid_properties
---------------------------------------------------------------------------------------------------

-- TODO
function randomize_equipment_shapes ()
  for _, prototype in pairs(data.raw["equipment-grid"]) do
  end
end

---------------------------------------------------------------------------------------------------
-- randomize_fluid_properties
---------------------------------------------------------------------------------------------------

-- Note: fuel value is already randomized
function randomize_fluid_properties ()
  for _, prototype in pairs(data.raw.fluid) do
    if prototype.emissions_multiplier == nil then
      prototype.emissions_multiplier = 1
    end

    randomize_numerical_property{
      prototype = prototype,
      property = "emissions_multiplier",
      property_info = property_info.fluid_emissions_multiplier
    }
  end
end

---------------------------------------------------------------------------------------------------
-- randomize_utility_constants_properties
---------------------------------------------------------------------------------------------------

-- Just a silly randomization that makes you have 11 columns per row of inventory
-- Currently not really used
function randomize_utility_constants_properties ()
  for _, prototype in pairs(data.raw["utility-constants"]) do
    prototype.inventory_width = 11
  end
end