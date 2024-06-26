local prototype_tables = require("randomizer-parameter-data/prototype-tables")
local inertia_function = require("randomizer-parameter-data/inertia-function-tables")
local property_info = require("randomizer-parameter-data/property-info-tables")
local walk_params = require("randomizer-parameter-data/walk-params-tables")
local equipment_variations = require("randomizer-parameter-data/equipment-variation-tables")

require("randomizer-functions/util-randomizer")

require("random-utils/randomization-algorithms")

---------------------------------------------------------------------------------------------------
-- randomize_achievements
---------------------------------------------------------------------------------------------------

-- TODO: Add walk_params: lower_is_better
function randomize_achievements()
  -- TODO: Build incompatibility for mods that change/remove vanilla achievements altogether

  local is_vanilla_achievement = {
    ["computer-age-1"] = true,
    ["computer-age-2"] = true,
    ["computer-age-3"] = true,
    ["circuit-veteran-1"] = true,
    ["circuit-veteran-2"] = true,
    ["circuit-veteran-3"] = true,
    ["steam-all-the-way"] = true,
    ["automated-cleanup"] = true,
    ["automated-construction"] = true,
    ["you-are-doing-it-right"] = true,
    ["lazy-bastard"] = true,
    ["eco-unfriendly"] = true,
    ["tech-maniac"] = true,
    ["mass-production-1"] = true,
    ["mass-production-2"] = true,
    ["mass-production-3"] = true,
    ["getting-on-track"] = true,
    ["getting-on-track-like-a-pro"] = true,
    ["it-stinks-and-they-dont-like-it"] = true,
    ["raining-bullets"] = true,
    ["iron-throne-1"] = true,
    ["iron-throne-2"] = true,
    ["iron-throne-3"] = true,
    ["logistic-network-embargo"] = true,
    ["smoke-me-a-kipper-i-will-be-back-for-breakfast"] = true,
    ["no-time-for-chitchat"] = true,
    ["there-is-no-spoon"] = true,
    ["steamrolled"] = true,
    ["run-forrest-run"] = true,
    ["pyromaniac"] = true,
    ["so-long-and-thanks-for-all-the-fish"] = true,
    ["trans-factorio-express"] = true,
    ["you-have-got-a-package"] = true,
    ["delivery-service"] = true,
    ["golem"] = true,
    ["watch-your-step"] = true,
    ["solaris"] = true,
    ["minions"] = true
  }

  for _, prototype in pairs(data.raw["build-entity-achievement"]) do
    if prototype.amount ~= nil and prototype.amount > 1 then
      randomize_numerical_property({
        prototype = prototype,
        property = "amount",
        property_info = property_info.achievement_amount
      })

      if is_vanilla_achievement[prototype.name] then
        prototype.localised_description = {"achievement-description-propertyrandomizer." .. prototype.name, prototype.amount}
      end
    end

    if prototype.until_second ~= nil and prototype.until_second > 0 then
      randomize_numerical_property({
        prototype = prototype,
        property = "until_second",
        property_info = property_info.achievement_timed
      })

      if is_vanilla_achievement[prototype.name] then
        prototype.localised_description = {"achievement-description-propertyrandomizer." .. prototype.name, math.floor(10 * prototype.until_second / 60) / 10}
      end
    end
  end

  for _, prototype in pairs(data.raw["combat-robot-count"]) do
    if prototype.count ~= nil and prototype.count > 1 then
      randomize_numerical_property({
        prototype = prototype,
        property = "count",
        property_info = property_info.achievement_sensitive
      })

      if is_vanilla_achievement[prototype.name] then
        prototype.localised_description = {"achievement-description-propertyrandomizer." .. prototype.name, prototype.count}
      end
    end
  end

  for _, prototype in pairs(data.raw["construct-with-robots-achievement"]) do
    if prototype.amount ~= nil and prototype.amount > 1 then
      randomize_numerical_property({
        prototype = prototype,
        property = "amount",
        property_info = property_info.achievement_amount
      })

      if is_vanilla_achievement[prototype.name] then
        prototype.localised_description = {"achievement-description-propertyrandomizer." .. prototype.name, prototype.amount}
      end
    end
  end

  for _, prototype in pairs(data.raw["deconstruct-with-robots-achievement"]) do
    if prototype.amount ~= nil and prototype.amount > 1 then
      randomize_numerical_property({
        prototype = prototype,
        property = "amount",
        property_info = property_info.achievement_amount
      })

      if is_vanilla_achievement[prototype.name] then
        prototype.localised_description = {"achievement-description-propertyrandomizer." .. prototype.name, prototype.amount}
      end
    end
  end

  for _, prototype in pairs(data.raw["deliver-by-robots-achievement"]) do
    if prototype.amount > 1 then
      randomize_numerical_property({
        prototype = prototype,
        property = "amount",
        property_info = property_info.achievement_amount
      })

      if is_vanilla_achievement[prototype.name] then
        prototype.localised_description = {"achievement-description-propertyrandomizer." .. prototype.name, prototype.amount}
      end
    end
  end

  for _, prototype in pairs(data.raw["dont-build-entity-achievement"]) do
    if prototype.amount ~= nil and prototype.amount > 1 then
      randomize_numerical_property({
        prototype = prototype,
        property = "amount",
        property_info = property_info.achievement_sensitive
      })

      if is_vanilla_achievement[prototype.name] then
        prototype.localised_description = {"achievement-description-propertyrandomizer." .. prototype.name, prototype.amount}
      end
    end
  end

  for _, prototype in pairs(data.raw["dont-craft-manually-achievement"]) do
    if prototype.amount > 1 then
      randomize_numerical_property({
        prototype = prototype,
        property = "amount",
        property_info = property_info.achievement_lazy_bastard
      })

      if is_vanilla_achievement[prototype.name] then
        prototype.localised_description = {"achievement-description-propertyrandomizer." .. prototype.name, prototype.amount}
      end
    end
  end

  for _, prototype in pairs(data.raw["dont-use-entity-in-energy-production-achievement"]) do
    if prototype.minimum_energy_produced and util.parse_energy(prototype.minimum_energy_produced) > 0 then
      local energy_as_number = util.parse_energy(prototype.minimum_energy_produced)
      randomize_numerical_property({
        dummy = energy_as_number,
        prg_key = prg.get_key(prototype),
        property_info = property_info.achievement_amount
      })
      prototype.minimum_energy_produced = energy_as_number .. "J"

      if is_vanilla_achievement[prototype.name] then
        prototype.localised_description = {"achievement-description-propertyrandomizer." .. prototype.name, util.parse_energy(prototype.minimum_energy_produced) / 1000000000}
      end
    end
  end

  for _, prototype in pairs(data.raw["finish-the-game-achievement"]) do
    if prototype.until_second ~= nil and prototype.until_second > 1 then
      randomize_numerical_property({
        prototype = prototype,
        property = "until_second",
        property_info = property_info.achievement_timed
      })

      if is_vanilla_achievement[prototype.name] then
        prototype.localised_description = {"achievement-description-propertyrandomizer." .. prototype.name, math.floor(10 * prototype.until_second / 3600) / 10}
      end
    end
  end

  for _, prototype in pairs(data.raw["group-attack-achievement"]) do
    if prototype.amount ~= nil and prototype.amount > 1 then
      randomize_numerical_property({
        prototype = prototype,
        property = "amount",
        property_info = property_info.achievement_amount
      })

      if is_vanilla_achievement[prototype.name] then
        prototype.localised_description = {"achievement-description-propertyrandomizer." .. prototype.name, prototype.amount}
      end
    end
  end

  for _, prototype in pairs(data.raw["kill-achievement"]) do
    if prototype.amount ~= nil and prototype.amount > 1 then
      randomize_numerical_property({
        prototype = prototype,
        property = "amount",
        property_info = property_info.achievement_amount
      })

      if is_vanilla_achievement[prototype.name] then
        prototype.localised_description = {"achievement-description-propertyrandomizer." .. prototype.name, prototype.amount}
      end
    end
  end

  for _, prototype in pairs(data.raw["player-damaged-achievement"]) do
    randomize_numerical_property({
      prototype = prototype,
      property = "minimum_damage",
      property_info = property_info.achievement_sensitive
    })

    if is_vanilla_achievement[prototype.name] then
      prototype.localised_description = {"achievement-description-propertyrandomizer." .. prototype.name, prototype.minimum_damage}
    end
  end

  for _, prototype in pairs(data.raw["produce-achievement"]) do
    if prototype.amount > 1 then
      randomize_numerical_property({
        prototype = prototype,
        property = "amount",
        property_info = property_info.achievement_amount
      })

      if is_vanilla_achievement[prototype.name] then
        prototype.localised_description = {"achievement-description-propertyrandomizer." .. prototype.name, prototype.amount}
      end
    end
  end

  for _, prototype in pairs(data.raw["produce-per-hour-achievement"]) do
    if prototype.amount > 1 then
      randomize_numerical_property({
        prototype = prototype,
        property = "amount",
        property_info = property_info.achievement_amount
      })

      if is_vanilla_achievement[prototype.name] then
        prototype.localised_description = {"achievement-description-propertyrandomizer." .. prototype.name, prototype.amount}
      end
    end
  end

  -- research-achievement doesn't have numerical properties, so skip it

  for _, prototype in pairs(data.raw["train-path-achievement"]) do
    randomize_numerical_property({
      prototype = prototype,
      property = "minimum_distance",
      property_info = property_info.achievement_amount
    })

    if is_vanilla_achievement[prototype.name] then
      prototype.localised_description = {"achievement-description-propertyrandomizer." .. prototype.name, prototype.minimum_distance}
    end
  end
end

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
      property = "height",
      property_info = property_info.equipment_grid
    }
    randomize_numerical_property{
      prototype = prototype,
      property = "width",
      property_info = property_info.equipment_grid
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
      if prototype.type == "active-defense-equipment" then
        randomize_attack_parameters(prototype, prototype.attack_parameters)
      end

      if prototype.type == "battery-equipment" then
        -- No special properties
      end

      if prototype.type == "belt-immunity-equipment" then
        -- energy_consumption already covered by energy randomizer
      end

      if prototype.type == "energy-shield-equipment" then
        randomize_numerical_property({
          prototype = prototype,
          property = max_shield_value,
          property_info = property_info.limited_range
        })

        local energy_as_number = util.parse_energy(prototype.energy_per_shield)
        energy_as_number = randomize_numerical_property({
          dummy = energy_as_number,
          prg_key = prg.get_key(prototype),
          property_info = property_info.energy
        })
        prototype.energy_per_shield = energy_as_number .. "J"
      end

      -- TODO: Move to energy randomizer (also in general separate equipment energy from entity energy more too)
      if prototype.type == "generator-equipment" then
        local power_as_number = 60 * util.parse_energy(prototype.power)
        power_as_number = randomize_numerical_property({
          dummy = power_as_number,
          prg_key = prg.get_key(prototype),
          property_info = property_info.power_generation
        })
        prototype.power = power_as_number .. "W"
      end

      if prototype.type == "movement-bonus-equipment" then
        randomize_numerical_property({
          prototype = prototype,
          property = "movement_bonus",
          property_info = property_info.limited_range
        })

        if prototype.type == "night-vision-equipment" then
          -- Not much more to randomize here
        end

        if prototype.type == "roboport-equipment" then
          -- TODO
        end

        if prototype.type == "solar-panel-equipment" then
          -- TODO: Unify with energy randomizer
        end
      end
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
  for class_name, _ in pairs(defines.prototypes.equipment) do
    for _, prototype in pairs(data.raw[class_name]) do
      local num_points_mult = 1
      num_points_mult = randomize_numerical_property({
        dummy = num_points_mult,
        walk_params = walk_params.equipment_size,
        prg_key = prg.get_key(prototype),
        property_info = property_info.equipment_size
      })
      local num_points = math.ceil(num_points_mult * prototype.shape.width * prototype.shape.height)

      -- Choose from some set shapes
      -- We'll do a lot of hand-feeding for early numbers
      local shape = prototype.shape
      shape.type = "manual"
      if num_points == 1 then
        shape.width = 1
        shape.height = 1
        shape.points = {
          {0,0}
        }
      elseif num_points == 2 then
        local variations = {
          {
            width = 1,
            height = 2,
            points = {
              {0,0},
              {0,1}
            }
          }
        }

        local variation = prg.range(prg.get_key(prototype), 1, #variations)
      end


      local shape = prg.range(prg.get_key(prototype), 1, 1)

      -- Circle
      if shape == 1 then
        if num_points == 1 then
          prototype.shape.width = 1
          prototype.shape.height = 1

          prototype.shape.points = {
            {0, 0}
          }
        elseif num_points <= 3 then
          prototype.shape.width = 2
          prototype.shape.height = 1

          prototype.shape.points = {
            {0, 0},
            {1, 0}
          }
        elseif num_points == 4 then
          prototype.shape.width = 2
          prototype.shape.height = 2

          prototype.shape.points = {
            {0, 0},
            {0, 1},
            {1, 0},
            {1, 1}
          }
        elseif num_points == 5 then
          prototype.shape.width = 3
          prototype.shape.height = 3

          prototype.shape.points = {
            {0, 0},
            {0, 1},
            {1, 0},
            {1, 2},
            {2, 1}
          }
        elseif num_points == 6 then
          prototype.shape.width = 3
          prototype.shape.height = 3

          prototype.shape.points = {
            {0, 0},
            {0, 1},
            {1, 0},
            {1, 2},
            {2, 1},
            {2, 2}
          }
        elseif num_points == 7 then
          prototype.shape.width = 3
          prototype.shape.height = 3

          prototype.shape.points = {
            {0, 0},
            {0, 1},
            {0, 2},
            {1, 0},
            {1, 2},
            {2, 1},
            {2, 2}
          }
        elseif num_points >= 8 then
          prototype.shape.width = 3
          prototype.shape.height = 3

          prototype.shape.points = {
            {0, 0},
            {0, 1},
            {0, 2},
            {1, 0},
            {1, 2},
            {2, 0},
            {2, 1},
            {2, 2}
          }
        end
      end
    end
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
-- randomize_icon_shifts
---------------------------------------------------------------------------------------------------

-- TODO: Make this compatible with mods that have icons defined on an item
function randomize_icon_shifts()
  for item_class, _ in pairs(defines.prototypes.item) do
    for _, item in pairs(data.raw[item_class]) do
      if item.icon ~= nil then
        item.icons = {
          {
            icon = item.icon,
            icon_size = item.icon_size,
            shift = {
              (math.random() - 0.4) * 0.2 * item.icon_size,
              (math.random() - 0.4) * 0.2 * item.icon_size
            }
          }
        }
        item.icon = nil
      end
    end
  end
end

---------------------------------------------------------------------------------------------------
-- randomize_map_colors
---------------------------------------------------------------------------------------------------

function randomize_map_colors()
  for entity_class, _ in pairs(defines.prototypes.entity) do
    for _, entity in pairs(data.raw[entity_class]) do
      if entity.map_color ~= nil then
        entity.map_color = {r = prg.float_range(prg.get_key(entity), 0, 1), g = prg.float_range(prg.get_key(entity), 0, 1), b = prg.float_range(prg.get_key(entity), 0, 1)}
      end
      if entity.friendly_map_color ~= nil then
        entity.friendly_map_color = {r = prg.float_range(prg.get_key(entity), 0, 1), g = prg.float_range(prg.get_key(entity), 0, 1), b = prg.float_range(prg.get_key(entity), 0, 1)}
      end
      if entity.enemy_map_color ~= nil then
        entity.enemy_map_color = {r = prg.float_range(prg.get_key(entity), 0, 1), g = prg.float_range(prg.get_key(entity), 0, 1), b = prg.float_range(prg.get_key(entity), 0, 1)}
      end
    end
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
                    walk_params = walk_params.projectile_damage,
                    property_info = property_info.projectile_damage
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
-- randomize_stickers
---------------------------------------------------------------------------------------------------

function randomize_stickers()
  for _, prototype in pairs(data.raw.sticker) do
    randomize_numerical_property({
      prototype = prototype,
      property = "duration_in_ticks",
      inertia_function = inertia_function.sensitive,
      property_info = property_info.limited_range_strict
    })

    -- There's a rule for defaults here but that's when it's every tick and pretty sensitive anyways
    randomize_numerical_property({
      prototype = prototype,
      property = "damage_interval",
      inertia_function = inertia_function.sensitive,
      property_info = property_info.limited_range_strict
    })

    randomize_numerical_property({
      prototype = prototype,
      tbl = prototype.damage_per_tick,
      property = "amount",
      inertia_function = inertia_function.sensitive,
      property_info = property_info.limited_range_strict
    })

    -- Don't set default movement modifier so it doesn't randomize if it's 1
    randomize_numerical_property({
      group_params = {
        {
          prototype = prototype,
          property = "target_movement_modifier",
          inertia_function = inertia_function.sensitive,
          property_info = property_info.limited_range_strict
        },
        {
          prototype = prototype,
          property = "target_movement_modifier_from",
          inertia_function = inertia_function.sensitive,
          property_info = property_info.limited_range_strict
        },
        {
          prototype = prototype,
          property = "target_movement_modifier_to",
          inertia_function = inertia_function.sensitive,
          property_info = property_info.limited_range_strict
        },
        {
          prototype = prototype,
          property = "vehicle_speed_modifier",
          inertia_function = inertia_function.sensitive,
          property_info = property_info.limited_range_strict
        },
        {
          prototype = prototype,
          property = "vehicle_speed_modifier_from",
          inertia_function = inertia_function.sensitive,
          property_info = property_info.limited_range_strict
        },
        {
          prototype = prototype,
          property = "vehicle_speed_modifier_to",
          inertia_function = inertia_function.sensitive,
          property_info = property_info.limited_range_strict
        }
      }
    })
  end
end

---------------------------------------------------------------------------------------------------
-- randomize_utility_constants_properties
---------------------------------------------------------------------------------------------------

-- Just a silly randomization that makes you have 11 columns per row of inventory
function randomize_utility_constants_properties()
  for _, prototype in pairs(data.raw["utility-constants"]) do
    prototype.inventory_width = 9
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

      local inertia_function_to_use = inertia_function.tile_walking_speed_modifier
      if tile.walking_speed_modifier == 1 then
        inertia_function_to_use = inertia_function.tile_walking_speed_modifier_nonstandard
      end

      table.insert(group_params, {
        prototype = tile,
        property = "walking_speed_modifier",
        inertia_function = inertia_function_to_use,
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