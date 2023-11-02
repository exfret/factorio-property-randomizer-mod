local prototype_tables = require("randomizer-parameter-data/prototype-tables")

local inertia_function = require("randomizer-parameter-data/inertia-function-tables")
local property_info = require("randomizer-parameter-data/property-info-tables")
local walk_params = require("randomizer-parameter-data.walk-params-tables")

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
          prototype[property_key] = sounds[prg.range(prg.get_key(nil, "dummy"), 1, #sounds)]
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
-- randomize_equipment_shapes
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
-- randomize_projectile_damage
---------------------------------------------------------------------------------------------------

function randomize_projectile_damage()
  for _, projectile in pairs(data.raw.projectile) do
    local function randomize_action(action)
      if action ~= nil then
        local action_delivery_table = action.action_delivery

        if action_delivery_table ~= nil then
          local function randomize_action_delivery_damage(action_delivery)
            if action_delivery.target_effects ~= nil then
              local target_effects_table = action_delivery.target_effects

              local function randomize_target_effects_damage(target_effect)
                if target_effect.type == "damage" then
                  randomize_numerical_property{
                    tbl = target_effect.damage,
                    property = "amount",
                    inertia_function = inertia_function.projectile_damage,
                    walk_params = walk_params.projectile_damage
                  }
                end
              end

              if target_effects_table.type ~= nil then
                randomize_target_effects_damage(target_effects_table)
              else
                for _, target_effect in pairs(target_effects_table) do
                  randomize_target_effects_damage(target_effect)
                end
              end
            end
          end

          if action_delivery_table.type ~= nil then
            randomize_action_delivery_damage(action_delivery_table)
          else
            for _, action_delivery in pairs(action_delivery_table) do
              randomize_action_delivery_damage(action_delivery)
            end
          end
        end
      end
    end

    local action_table = projectile.action

    if action_table ~= nil then
      if action_table.type ~= nil then
        randomize_action(action_table)
      else
        for _, action in pairs(action_table) do
          randomize_action(action)
        end
      end
    end
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

---------------------------------------------------------------------------------------------------
-- randomize_tile_walking_speed_modifier
---------------------------------------------------------------------------------------------------

-- Fails if next_direction does not have cyclical relationships with the tiles
function randomize_tile_walking_speed_modifier ()
  local tile_sets = {}

  local tiles_to_evaluate = {}
  for _, prototype in pairs(data.raw.tile) do
    tiles_to_evaluate[prototype.name] = true
  end

  for _, prototype in pairs(data.raw.tile) do
    if tiles_to_evaluate[prototype.name] then
      local curr_tile = prototype
      local curr_tile_set = {}
      table.insert(curr_tile_set, curr_tile)
      tiles_to_evaluate[curr_tile.name] = false

      while (curr_tile.next_direction and curr_tile.next_direction ~= prototype.name) do
        curr_tile = data.raw.tile[curr_tile.next_direction]
        table.insert(curr_tile_set, curr_tile)
        tiles_to_evaluate[prototype.name] = false
      end

      table.insert(tile_sets, curr_tile_set)
    end
  end

  for _, tile_set in pairs(tile_sets) do
    local group_params = {}

    for _, tile in pairs(tile_set) do
      if tile.walking_speed_modifier == nil then
        tile.walking_speed_modifier = 1
      end
      table.insert(group_params, {
        prototype = tile,
        property = "walking_speed_modifier",
        inertia_function = inertia_function.tile_walking_speed_modifier,
        property_info = property_info.tile_walking_speed_modifier
      })
    end

    randomize_numerical_property{
      group_params = group_params,
      walk_params = walk_params.tile_walking_speed_modifier
    }
  end

  --[[for _, prototype in pairs(data.raw.tile) do
    if prototype.walking_speed_modifier == nil then
      prototype.walking_speed_modifier = 1
    end

    randomize_numerical_property{
      prototype = prototype,
      property = "walking_speed_modifier",
      property_info = property_info.tile_walking_speed_modifier
    }
  end]]
end

-- Link together tiles with the same next_direction