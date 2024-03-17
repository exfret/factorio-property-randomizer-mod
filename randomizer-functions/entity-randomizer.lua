require("energy-randomizer")
require("util-randomizer")

require("globals")
require("linking-utils")
local param_table_utils = require("param-table-utils")

local blacklist = require("compatibility/blacklist-tables")

local inertia_function = require("randomizer-parameter-data/inertia-function-tables")
local property_info = require("randomizer-parameter-data/property-info-tables")
local prototype_tables = require("randomizer-parameter-data/prototype-tables")
local walk_params = require("randomizer-parameter-data/walk-params-tables")

require("random-utils/random")
require("random-utils/randomization-algorithms")

---------------------------------------------------------------------------------------------------
-- randomize_beacon_properties
---------------------------------------------------------------------------------------------------

function randomize_beacon_properties ()
  for _, prototype in pairs(data.raw.beacon) do
    randomize_numerical_property{
      prototype = prototype,
      property = "supply_area_distance",
      inertia_function = inertia_function.beacon_supply_area_distance,
      property_info = property_info.supply_area
    }

    randomize_numerical_property{
      prototype = prototype,
      property = "distribution_effectivity",
      inertia_function = inertia_function.beacon_distribution_effectivity,
      property_info = property_info.effectivity
    }
  end
end

---------------------------------------------------------------------------------------------------
-- randomize_belt_speed
---------------------------------------------------------------------------------------------------

function randomize_belt_speed ()
  local min_bias = 0.45
  local max_bias = 0.6
  local prototype_bias_dict = {}
  local belt_tier_groups = {}

  -- Calculate the biases to seperate the belts out
  for _, belt_class in pairs(prototype_tables.transport_belt_classes) do
    for _, prototype1 in pairs(data.raw[belt_class]) do
      local num_worse_speed = 0
      local total_num = 0

      for _, prototype2 in pairs(data.raw[belt_class]) do
        if prototype2.speed < prototype1.speed then
          num_worse_speed = num_worse_speed + 1
        elseif prototype2.speed == prototype1.speed then
          num_worse_speed = num_worse_speed + 0.5
        end

        total_num = total_num + 1
      end

      local speed_score = num_worse_speed / total_num
      prototype_bias_dict[prototype1.name] = min_bias * (1 - speed_score) + max_bias * speed_score
    end
  end

  for transport_belt_prototype_name, transport_belt_prototype in pairs(data.raw["transport-belt"]) do
    local belt_tier_prototypes = {}

    for _, other_belt_class in pairs(prototype_tables.transport_belt_classes) do
      for _, other_belt_prototype in pairs(data.raw[other_belt_class]) do
        if other_belt_prototype.speed == transport_belt_prototype.speed then
          table.insert(belt_tier_prototypes, other_belt_prototype)
        end
      end
    end

    belt_tier_groups[transport_belt_prototype_name] = belt_tier_prototypes
  end

  for _, belt_class in pairs(prototype_tables.transport_belt_classes) do
    for _, prototype in pairs(data.raw[belt_class]) do
      local bias_to_use = prototype_bias_dict[prototype.name]
      -- Make bias higher without syncing belt tiers to account for fact that lowest belt speed slows down everything else
      if not sync_belt_tiers then
        bias_to_use = bias_to_use + 0.03
      end

      randomize_numerical_property{
        prototype = prototype,
        property = "speed",
        inertia_function = inertia_function.belt_speed,
        property_info = property_info.belt_speed,
        walk_params = {
          bias = prototype_bias_dict[prototype.name]
        }
      }
    end
  end

  for belt_tier_group_base_belt, belt_tier_group in pairs(belt_tier_groups) do
    for _, other_belt in pairs(belt_tier_group) do
      other_belt.speed = data.raw["transport-belt"][belt_tier_group_base_belt].speed
    end
  end
end

---------------------------------------------------------------------------------------------------
-- randomize_bot_speed
---------------------------------------------------------------------------------------------------

-- TODO: Make sure to also randomize max_speed if it is non-nil
function randomize_bot_speed ()
  for _, class_name in pairs(prototype_tables.bot_classes) do
    for _, prototype in pairs(data.raw[class_name]) do
      -- Speed is mandatory
      local old_speed = prototype.speed

      randomize_numerical_property{
        prototype = prototype,
        property = "speed",
        inertia_function = inertia_function.bot_speed,
        property_info = property_info.bot_speed
      }

      -- Make sure max_speed is at least speed
      if prototype.max_speed ~= nil then
        prototype.max_speed = prototype.max_speed * prototype.speed / old_speed
      end
    end
  end
end

---------------------------------------------------------------------------------------------------
-- randomize_car_rotation_speed
---------------------------------------------------------------------------------------------------

function randomize_car_rotation_speed ()
  for _, prototype in pairs(data.raw.car) do
    randomize_numerical_property{
      prototype = prototype,
      property = "rotation_speed",
      inertia_function = inertia_function.car_rotation_speed,
      property_info = property_info.car_rotation_speed
    }
  end
end

---------------------------------------------------------------------------------------------------
-- randomize_character_corpse_time_to_live
---------------------------------------------------------------------------------------------------

function randomize_character_corpse_time_to_live ()
  for _, prototype in pairs(data.raw["character-corpse"]) do
    randomize_numerical_property{
      prototype = prototype,
      property = "time_to_live",
      inertia_function = inertia_function.character_corpse_time_to_live,
      property_info = property_info.character_corpse_time_to_live
    }
  end
end

---------------------------------------------------------------------------------------------------
-- randomize_character_respawn_time
---------------------------------------------------------------------------------------------------

function randomize_character_respawn_time ()
  for _, prototype in pairs(data.raw.character) do
    if prototype.respawn_time == nil then
      prototype.respawn_time = 10
    end

    randomize_numerical_property{
      prototype = prototype,
      property = "respawn_time",
      property_info = property_info.character_respawn_time
    }
  end
end

-- Currently unused
-- TODO: Guarantee this comes after all other recipe randomization
function randomize_crafting_machine_productivity()
  for _, class in pairs(prototype_tables.crafting_machine_classes) do
    for _, prototype in pairs(data.raw[class]) do
      require("randomizer-function-utils/counterproductive")

      if prototype.base_productivity == nil then
        prototype.base_productivity = 1 / COUNTERPRODUCTIVE_SUCCESS_CHANCE - 1
      else
        prototype.base_productivity = prototype.base_productivity / COUNTERPRODUCTIVE_SUCCESS_CHANCE
      end

      randomize_numerical_property{
        prototype = prototype,
        property = "base_productivity"
      }
    end
  end
end

---------------------------------------------------------------------------------------------------
-- randomize_crafting_machine_speeds
---------------------------------------------------------------------------------------------------

function randomize_crafting_machine_speeds ()
  for _, class in pairs(prototype_tables.crafting_machine_classes) do
    for _, prototype in pairs(data.raw[class]) do
      local bias_to_use = 0.5
      if prototype.energy_source.type == "burner" then
        bias_to_use = bias_to_use + BURNER_MACHINE_BIAS_BONUS
      end

      randomize_numerical_property{
        prototype = prototype,
        property = "crafting_speed",
        inertia_function = inertia_function.crafting_speed,
        property_info = property_info.machine_speed,
        walk_params = {
          bias = bias_to_use
        }
      }
    end
  end
end

---------------------------------------------------------------------------------------------------
-- randomize_electric_poles
---------------------------------------------------------------------------------------------------

-- TODO: Also soft link to make electric pole reach usually larger than supply area anyways
function randomize_electric_poles ()
  local points = {}
  for point_label, prototype in pairs(data.raw["electric-pole"]) do
    local point = {}
    point[1] = prototype.supply_area_distance
    point[2] = prototype.maximum_wire_distance
    table.insert(points, point)
  end

  randomize_points_in_space{
    points = points,
    dimension_information = {
      {
        inertia_function = inertia_function.electric_pole_supply_area,
        property_info = property_info.supply_area
      },
      {
        inertia_function = inertia_function.electric_pole_wire_reach,
        property_info = property_info.wire_distance
      }
    },
    prg_key = prg.get_key("electric-pole", "class")
  }

  local index = 1
  for _, prototype in pairs(data.raw["electric-pole"]) do
    prototype.supply_area_distance = points[index][1]
    prototype.maximum_wire_distance = points[index][2]
    index = index + 1
  end

  -- Add back in parity/centering supply squares on poles
  for _, prototype in pairs(data.raw["electric-pole"]) do
    local odd_placement = false
    local even_placement = false
    if prototype.tile_width ~= nil and prototype.tile_width % 2 == 0 then
      even_placement = true
    elseif prototype.tile_width ~= nil and prototype.tile_width % 2 == 1 then
      odd_placement = true
    end
    if prototype.tile_height ~= nil and prototype.tile_height % 2 == 0 then
      even_placement = true
    elseif prototype.tile_height ~= nil and prototype.tile_height % 1 then
      odd_placement = true
    end
  
    if prototype.collision_box ~= nil then
      local collision_box_width_parity = math.floor(prototype.collision_box[2][1] - prototype.collision_box[1][1] + 0.5) % 2
      local collision_box_height_parity = math.floor(prototype.collision_box[2][2] - prototype.collision_box[1][2] + 0.5) % 2
      if prototype.tile_width == nil and collision_box_width_parity == 0 then
        even_placement = true
      elseif prototype.tile_height == nil and collision_box_height_parity == 1 then
        odd_placement = true
      end
    else
      even_placement = true
      odd_placement = true
    end

    if odd_placement == false then
      prototype.supply_area_distance = math.min(64, math.floor(prototype.supply_area_distance + 1) - 0.5)
    elseif even_placement == false then
      prototype.supply_area_distance = math.min(64, math.floor(prototype.supply_area_distance + 0.5))
    end
  end

  for _, prototype in pairs(data.raw["electric-pole"]) do
    if prototype.supply_area_distance > prototype.maximum_wire_distance then
      prototype.maximum_wire_distance = prototype.supply_area_distance
    end
  end
end

---------------------------------------------------------------------------------------------------
-- randomize_enemy_spawning
---------------------------------------------------------------------------------------------------

-- TODO: Balance this better and fix it up
function randomize_enemy_spawning ()
  for _, prototype in pairs(data.raw["unit-spawner"]) do
    local key = prg.get_key(prototype)

    for _, unit in pairs(prototype.result_units) do
      local evolution_shift = (prg.int(key, 100) - 60) / 400

      for _, spawn_point in pairs(unit[2]) do
        local spawn_point_evolution_factor
        if spawn_point[1] then
          spawn_point_evolution_factor = spawn_point[1]
        else
          spawn_point_evolution_factor = spawn_point.evolution_factor
        end

        local spawn_point_spawn_weight
        if spawn_point[2] then
          spawn_point_spawn_weight = spawn_point[2]
        else
          spawn_point_spawn_weight = spawn_point.spawn_weight
        end

        spawn_point[1] = nil
        spawn_point[2] = nil

        spawn_point.evolution_factor = spawn_point_evolution_factor + evolution_shift
        spawn_point.spawn_weight = spawn_point_spawn_weight * randomize_numerical_property()
      end
    end
  end
end

---------------------------------------------------------------------------------------------------
-- randomize_entity_interaction_speed
---------------------------------------------------------------------------------------------------

-- Right now randomizes repair speed and mining speed
-- TODO: randomize EntityGhost and tile-ghost mining speed to be above zero sometimes randomly
function randomize_entity_interaction_speed ()
  for _, class_name in pairs(prototype_tables.entities_to_modify_mining_speed) do
    for _, prototype in pairs(data.raw[class_name]) do
      if prototype.minable then
        randomize_numerical_property{
          prototype = prototype,
          tbl = prototype.minable,
          property = "mining_time",
          inertia_function = inertia_function.entity_interaction_mining_speed,
          property_info = property_info.entity_interaction_mining_speed
        }
      end
    end
  end

  for _, class_name in pairs(prototype_tables.entities_with_health) do
    for _, prototype in pairs(data.raw[class_name]) do
      if prototype.repair_speed_modifier == nil then
        prototype.repair_speed_modifier = 1
      end

      randomize_numerical_property{
        prototype = prototype,
        property = "repair_speed_modifier",
        inertia_function = inertia_function.entity_interaction_repair_speed,
        property_info = property_info.entity_interaction_repair_speed
      }
    end
  end
end

---------------------------------------------------------------------------------------------------
-- randomize_entity_sizes
---------------------------------------------------------------------------------------------------

--[[
local curr_prototype = data.raw.container["wooden-chest"]
for _, layer in pairs(curr_prototype.picture.layers) do
  layer.scale = 2
end ]]

-- Accumulator
-- Artillery turret?
-- Beacon
-- ...
-- Container stuffs
-- Electric pole?
-- Lab
-- Turret

function randomize_entity_sizes ()
  local function change_image_size(picture, factor)
    if picture.layers ~= nil then
      for _, layer in pairs(picture.layers) do
        change_image_size(layer, factor)
      end
    else
      if picture.hr_version ~= nil then
        change_image_size(picture.hr_version, factor)
      end
  
      if picture.scale == nil then
        picture.scale = 1
      end
  
      picture.scale = picture.scale * factor
    end
  end

  -- Cliffs
  for _, cliff in pairs(data.raw.cliff) do
    for _, orientation in pairs(cliff.orientations) do
      local factor = randomize_numerical_property{
        inertia_function = inertia_function.cliff_size,
        prg_key = prg.get_key(cliff),
        property_info = property_info.cliff_size
      }

      for _, vector in pairs(orientation.collision_bounding_box) do
        -- Just ignore the orientation number, wiki says it seems to be unused
        if type(vector) ~= "number" then
          vector[1] = vector[1] * factor
          vector[2] = vector[2] * factor
        end
      end

      if pictures.filename ~= nil or pictures.layers ~= nil then
        change_image_size(orientation.pictures, factor)
      else
        for _, picture in pairs(orientation.pictures) do
          change_image_size(picture, factor)
        end
      end
    end
  end
end

---------------------------------------------------------------------------------------------------
-- randomize_entity_triggers
---------------------------------------------------------------------------------------------------

-- This should be split up based on why we want to randomize the triggers

-- Entity is the only class with triggers
--[[local entity_trigger_keys_to_modify = {
  ["artillery-projectile"] = {"action", "final_action"},
  beam = {"action"},
  character = {"tool_attack_result"},
  ["combat-robot"] = {"destroy_action"},
  ["construction-robot"] = {"destroy_action"},
  ["logistic-robot"] = {"destroy_action"},
  ["land-mine"] = {"action"},
  reactor = {"meltdown_action"},
  fire = {"on_damage_tick_effect", "on_fuel_added_action"},
  stream = {"action", "initial_action"},
  projectile = {"action", "final_action"},
  ["smoke-with-trigger"] = {"action"}
}
-- All entities have a special created_effect Trigger key
for class_name, _ in pairs(defines.prototypes["entity"]) do
  if entity_trigger_keys_to_modify[class_name] == nil then
    entity_trigger_keys_to_modify[class_name] = {}
  end
  table.insert(entity_trigger_keys_to_modify[class_name], "created_effect")
end

function randomize_entity_triggers ()
  for class_name, property_list in pairs(entity_trigger_keys_to_modify) do
    for _, prototype in pairs(data.raw[class_name]) do
      for _, property in pairs(property_list) do
        if prototype[property] then
          if prototype[property].type then
            randomize_trigger_item(prototype, prototype[property])
          else
            for _, trigger_item in pairs(prototype[property]) do
              randomize_trigger_item(prototype, trigger_item)
            end
          end
        end
      end
    end
  end
end]]

---------------------------------------------------------------------------------------------------
-- randomize_fuel_inventory_slots
---------------------------------------------------------------------------------------------------

function randomize_fuel_inventory_slots ()
  for class_name, energy_source_property_list in pairs(prototype_tables.energy_source_names) do
    for _, prototype in pairs(data.raw[class_name]) do
      for _, property_name in pairs(energy_source_property_list) do
        if prototype[property_name] then
          randomize_numerical_property{
            prototype = prototype,
            tbl = prototype[property_name],
            property = "fuel_inventory_size",
            inertia_function = inertia_function.energy_source_inventory_sizes,
            property_info = property_info.small_nonempty_inventory
          }
        end
      end
    end
  end
end

---------------------------------------------------------------------------------------------------
-- randomize_gate_opening_speed
---------------------------------------------------------------------------------------------------

function randomize_gate_opening_speed ()
  for _, prototype in pairs(data.raw.gate) do
    local old_opening_speed = prototype.opening_speed

    randomize_numerical_property{
      prototype = prototype,
      property = "opening_speed",
      inertia_function = inertia_function.gate_opening_speed,
      property_info = property_info.gate_opening_speed
    }

    -- Modify approach distance so gate has enough time to open
    -- opening speed will always be >0 after randomization due to this being included in property_info
    prototype.activation_distance = prototype.activation_distance / (prototype.opening_speed / old_opening_speed)
  end
end

---------------------------------------------------------------------------------------------------
-- randomize_health_properties
---------------------------------------------------------------------------------------------------

-- TODO: randomize resistances for entities that don't have them
-- TODO: randomize resistances in a smarter way
-- TODO: Round health/resistances to a whole number (or close) for niceness (at least resistances are an eyesore to look at)
function randomize_health_properties ()
  for _, class_name in pairs(prototype_tables.entities_with_health) do
    for _, prototype in pairs(data.raw[class_name]) do
      if not prototype_tables.entities_with_health_blacklist[prototype.type] then
        if prototype.max_health == nil then
          prototype.max_health = 10
        end

        local inertia_function_to_use = inertia_function.max_health
        local property_info_to_use = property_info.max_health
        if prototype_tables.entities_with_health_sensitive[prototype.type] then
          inertia_function_to_use = inertia_function.max_health_sensitive
          property_info_to_use = property_info.max_health_sensitive
        end

        randomize_numerical_property{
          prototype = prototype,
          property = "max_health",
          inertia_function = inertia_function_to_use,
          property_info = property_info_to_use
        }
  
        -- Disable resistance randomization for now
        --[[randomize_resistances{
          prototypes = {prototype},
          variance = variance
        }
        -- TODO: Get rid of showing all resistances
        prototype.hide_resistances = false -- Make it so that players can see that resistances were changed
        ]]
      end
    end
  end
end

---------------------------------------------------------------------------------------------------
-- randomize_inserter_insert_dropoff_positions
---------------------------------------------------------------------------------------------------

local inserter_insert_positions = {
  {0, 1.2}, -- Standard
  {0, 0.8}, -- Near
  {0, 2.2}, -- Far
  {0, 4.2}, -- Very far
  {-1, 0}, -- To the side
  {1, 1}, -- Diagonal
  {0, -1.2} -- "Back where it came from"
}

local inserter_pickup_positions = {
  {0, -1}, -- Standard
  {0, -1.2}, -- Other side of the belt
  {0, -2}, -- Long-handed
  {0, -4}, -- Very long-handed
  {1, 0}, -- To the side
  {-1, -1}, -- Diagonal
  {-1.2, -0.2}, -- Diagonal, sorta?
  {-2.2, 7.2} -- Huh?
}

-- TODO: Add Bob's mods compatibility
function randomize_inserter_insert_dropoff_positions()
  for _, prototype in pairs(data.raw.inserter) do
    -- Test that this inserter is a "good" size
    if prototype.collision_box ~= nil and prototype.collision_box[1][1] == -0.15 and prototype.collision_box[1][2] == -0.15 and prototype.collision_box[2][1] == 0.15 and prototype.collision_box[2][2] == 0.15 then
      local key = prg.get_key(prototype)

      local inserter_position_variable = prg.range(key, 1,18)

      -- 1/2 chance to change to a different type of insert position
      if 1 <= inserter_position_variable and inserter_position_variable <= 10 then
        prototype.insert_position = inserter_insert_positions[prg.range(key, 1, #inserter_insert_positions)]
      end

      -- 1/2 chance to change to a different type of pickup position
      if 3 <= inserter_position_variable and inserter_position_variable <= 13 then
        prototype.pickup_position = inserter_pickup_positions[prg.range(key, 1, #inserter_pickup_positions)]
      end
    end
  end

  if data.raw.inserter["inserter"] ~= nil and data.raw.inserter["burner-inserter"] ~= nil then
    local inserter_dropoff = data.raw.inserter["inserter"].insert_position
    local burner_dropoff = data.raw.inserter["burner-inserter"].insert_position

    if inserter_dropoff[1] == 0 and inserter_dropoff[2] == -1.2 and burner_dropoff[1] == 0 and burner_dropoff[2] == -1.2 then
      data.raw.inserter["inserter"].insert_position = {0, 1.2}
    end
  end
end

---------------------------------------------------------------------------------------------------
-- randomize_inserter_speed
---------------------------------------------------------------------------------------------------

function randomize_inserter_speed ()
  for _, prototype in pairs(data.raw.inserter) do
    randomize_numerical_property{
      group_params = {
        {
          prototype = prototype,
          property = "rotation_speed",
          inertia_function = inertia_function.inserter_rotation_speed,
          property_info = property_info.inserter_rotation_speed
        },
        {
          prototype = prototype,
          property = "extension_speed",
          inertia_function = inertia_function.inserter_extension_speed,
          property_info = property_info.inserter_extension_speed
        }
      }
    }
  end
end

---------------------------------------------------------------------------------------------------
-- randomize_inventory_sizes
---------------------------------------------------------------------------------------------------

-- DON'T: Randomize material_slots_count and robot_slots_count of roboport (already randomized elsewhere)
-- Don't modify the character's inventory speed for now
-- Note: item_with_inventory inventory size is not randomized out of fear of packing tape incompatibility
function randomize_inventory_sizes ()
  for class_name, inventory_property_list in pairs(prototype_tables.inventory_names) do
    for _, prototype in pairs(data.raw[class_name]) do
      for _, property_name in pairs(inventory_property_list) do
        if prototype[property_name] ~= nil then
          if not blacklist["randomize_inventory_sizes"][prototype.name] then
            -- I have to turn these to numbers because some modders are writing inventory sizes as strings somehow
            prototype[property_name] = tonumber(prototype[property_name])

            local property_info_to_use
            if prototype[property_name] == 0 then
              property_info_to_use = property_info.small_inventory
            elseif prototype[property_name] < 10 then
              property_info_to_use = property_info.small_nonempty_inventory
            else
              property_info_to_use = property_info.large_inventory
            end

            randomize_numerical_property{
              prototype = prototype,
              property = property_name,
              inertia_function = inertia_function.inventory_size,
              property_info = property_info_to_use
            }
          end
        end
      end
    end
  end
end

---------------------------------------------------------------------------------------------------
-- randomize_lab_research_speed
---------------------------------------------------------------------------------------------------

function randomize_lab_research_speed ()
  for _, prototype in pairs(data.raw.lab) do
    randomize_numerical_property{
      prototype = prototype,
      property = "researching_speed",
      inertia_function = inertia_function.researching_speed,
      property_info = property_info.researching_speed
    }
  end
end

---------------------------------------------------------------------------------------------------
-- randomize_machine_pollution
---------------------------------------------------------------------------------------------------

function randomize_machine_pollution ()
  for class_name, energy_source_list in pairs(prototype_tables.polluting_machine_classes) do
    for _, prototype in pairs(data.raw[class_name]) do
      for _, energy_source_name in pairs(energy_source_list) do
        randomize_numerical_property{
          prototype = prototype,
          tbl = prototype[energy_source_name],
          property = "emissions_per_minute",
          property_info = property_info.machine_pollution
        }
      end
    end
  end
end

---------------------------------------------------------------------------------------------------
-- randomize_mining_drill_dropoff_location
---------------------------------------------------------------------------------------------------

function randomize_mining_drill_dropoff_location ()
  for _, prototype in pairs(data.raw["mining-drill"]) do
    -- TODO: Need to check that this isn't a purely fluid-based thing, which is usually indicated by a (0,0) place vector
    if prototype.vector_to_place_result[1] ~= 0 or prototype.vector_to_place_result[2] ~= 0 then
      randomize_numerical_property{
        prototype = prototype,
        tbl = prototype.vector_to_place_result,
        property = 1,
        inertia_function = inertia_function.mining_drill_dropoff,
        property_info = property_info.mining_drill_dropoff
      }

      randomize_numerical_property{
        prototype = prototype,
        tbl = prototype.vector_to_place_result,
        property = 2,
        inertia_function = inertia_function.mining_drill_dropoff,
        property_info = property_info.mining_drill_dropoff
      }
    end
  end
end

---------------------------------------------------------------------------------------------------
-- randomize_mining_productivity
---------------------------------------------------------------------------------------------------

local resource_success_chance = 0.8

local function reduce_product_chance (minable_properties)
  if minable_properties.result then
    local result_count = 1
    if minable_properties.count ~= nil then
      result_count = minable_properties.count
    end

    minable_properties.results = {{name = minable_properties.result, amount = result_count, probability = resource_success_chance}}
    minable_properties.result = nil
  else
    for _, result in pairs(minable_properties.results) do
      if result[1] then
        result.name = result[1]
        result.amount = 1
        if result[2] then
          result.amount = result[2]
        end

        result[1] = nil
        result[2] = nil
      end

      success_probability = resource_success_chance
      if result.probability then
        success_probability = success_probability * result.probability
      end

      result.probability = success_probability
    end
  end
end

function randomize_mining_productivity ()
  -- First randomize chances of getting resources down
  for _, resource_prototype in pairs(data.raw.resource) do
    reduce_product_chance(resource_prototype.minable)
  end

  -- Now randomize base productivity
  for _, mining_drill_prototype in pairs(data.raw["mining-drill"]) do
    if mining_drill_prototype.base_productivity ~= nil then
      mining_drill_prototype.base_productivity = mining_drill_prototype.base_productivity + 0.25
    else
      mining_drill_prototype.base_productivity = 1 / resource_success_chance - 1
    end

    randomize_numerical_property{
      prototype = mining_drill_prototype,
      property = "base_productivity"
    }
  end
end

---------------------------------------------------------------------------------------------------
-- randomize_mining_speeds
---------------------------------------------------------------------------------------------------

function randomize_mining_speeds ()
  for _, prototype in pairs(data.raw["mining-drill"]) do
    local bias_to_use = 0.5
    if prototype.energy_source.type == "burner" then
      bias_to_use = bias_to_use + BURNER_MACHINE_BIAS_BONUS
    end

    randomize_numerical_property{
      prototype = prototype,
      property = "mining_speed",
      inertia_function = inertia_function.machine_mining_speed,
      property_info = property_info.machine_speed,
      walk_params = {
        bias = bias_to_use
      }
    }
  end
end

---------------------------------------------------------------------------------------------------
-- randomize_module_slots
---------------------------------------------------------------------------------------------------

function randomize_module_slots ()
  for _, class_name in pairs(prototype_tables.machines_with_module_slots) do
    for _, prototype in pairs(data.raw[class_name]) do
      if prototype["module_specification"] then
        local property_info_to_use = property_info.small_inventory
        if prototype["module_specification"].module_slots == nil then
          prototype["module_specification"].module_slots = 0
        elseif prototype["module_specification"].module_slots > 0 then
          property_info_to_use = property_info.small_nonempty_inventory
        end

        randomize_numerical_property{
          prototype = prototype,
          tbl = prototype["module_specification"],
          property = "module_slots",
          inertia_function = inertia_function.module_specification,
          property_info = property_info_to_use
        }

        -- If no effects are allowed, turn the number of modules back to 0
        -- Factorio doesn't like modules slots with no allowed modules
        local no_effects_allowed = false
        if class_name == "lab" or class_name == "mining-drill" then
          if prototype.allowed_effects ~= nil and next(prototype.allowed_effects) == nil then
            no_effects_allowed = true
          end
        else
          if prototype.allowed_effects == nil or next(prototype.allowed_effects) == nil then
            no_effects_allowed = true
          end
        end
        if no_effects_allowed then
          prototype["module_specification"].module_slots = 0
        end
      end
    end
  end
end

---------------------------------------------------------------------------------------------------
-- randomize_offshore_pump_speed
---------------------------------------------------------------------------------------------------

function randomize_offshore_pump_speed ()
  for _, prototype in pairs(data.raw["offshore-pump"]) do
    randomize_numerical_property{
      prototype = prototype,
      property = "pumping_speed",
      inertia_function = inertia_function.offshore_pumping_speed,
      property_info = property_info.offshore_pumping_speed,
      walk_params = walk_params.offshore_pumping_speed
    }
  end
end

---------------------------------------------------------------------------------------------------
-- randomize_pump_speed
---------------------------------------------------------------------------------------------------

function randomize_pump_speed ()
  for _, prototype in pairs(data.raw.pump) do
    if prototype.fluid_box.height == nil then
      prototype.fluid_box.height = 1
    end
    local old_fluid_box_height = prototype.fluid_box.height

    randomize_numerical_property{
      group_params = {
        {
          prototype = prototype,
          property = "pumping_speed",
          property_info = property_info.pump_pumping_speed
        },
        {
          prototype = prototype,
          tbl = prototype.fluid_box,
          property = "height"
        }
      }
    }

    if prototype.fluid_box.base_area == nil then
      prototype.fluid_box.base_area = 1
    end
    prototype.fluid_box.base_area = prototype.fluid_box.base_area * old_fluid_box_height / prototype.fluid_box.height
  end
end

---------------------------------------------------------------------------------------------------
-- randomize_radar
---------------------------------------------------------------------------------------------------

function randomize_radar ()
  for _, prototype in pairs(data.raw["radar"]) do
    randomize_numerical_property({
      prototype = prototype,
      property = "max_distance_of_sector_revealed",
      inertia_function = inertia_function.radar,
      property_info = property_info.radar_reveal_areas
    })

    randomize_numerical_property({
      prototype = prototype,
      property = "max_distance_of_nearby_sector_revealed",
      inertia_function = inertia_function.radar,
      property_info = property_info.radar_reveal_areas
    })
  end
end

---------------------------------------------------------------------------------------------------
-- randomize_reactor_neighbour_bonus
---------------------------------------------------------------------------------------------------

function randomize_reactor_neighbour_bonus ()
  for _, prototype in pairs(data.raw.reactor) do
    if prototype.neighbour_bonus == nil then
      prototype.neighbour_bonus = 1
    end
    
    randomize_numerical_property{
      prototype = prototype,
      property = "neighbour_bonus",
      property_info = property_info.neighbour_bonus
    }
  end
end

---------------------------------------------------------------------------------------------------
-- randomize_roboports
---------------------------------------------------------------------------------------------------

function randomize_roboports ()
  for _, prototype in pairs(data.raw.roboport) do
    randomize_numerical_property{
      prototype = prototype,
      property = "material_slots_count",
      inertia_function = inertia_function.inventory_slots,
      property_info = property_info.inventory_slots
    }
    
    randomize_numerical_property{
      prototype = prototype,
      property = "robot_slots_count",
      inertia_function = inertia_function.inventory_slots,
      property_info = property_info.inventory_slots
    }

    -- Randomize how quickly robots charge
    local charging_energy = 60 * util.parse_energy(prototype.charging_energy)
    charging_energy = randomize_numerical_property{
      dummy = charging_energy,
      property_info = property_info.limited_range
    }
    prototype.charging_energy = charging_energy .. "W"

    -- TODO: Keep the charging offsets instead of discarding these vectors entirely (or just make them charge in a circle)
    -- Randomize how many robots can charge at the roboport
    if prototype.charging_station_count == nil or prototype.charging_station_count == 0 then
      if prototype.charging_offsets ~= nil then
        prototype.charging_station_count = #prototype.charging_offsets
      else
        prototype.charging_station_count = 0
      end
    end
    randomize_numerical_property{
      prototype = prototype,
      property = "charging_station_count",
      inertia_function = inertia_function.charging_station_count,
      property_info = property_info.charging_station_count
    }

    if prototype.logistics_connection_distance == nil then
      prototype.logistics_connection_distance = prototype.logistics_radius
    end
    randomize_numerical_property{
      group_params = {
        {
          prototype = prototype,
          property = "logistics_radius",
          property_info = property_info.roboport_radius
        },
        {
          prototype = prototype,
          property = "logistics_connection_distance",
          property_info = property_info.roboport_radius
        }
      }
    }

    randomize_numerical_property{
      prototype = prototype,
      property = "construction_radius",
      property_info = property_info.roboport_radius
    }
  end
end

---------------------------------------------------------------------------------------------------
-- randomize_storage_tank_capacity
---------------------------------------------------------------------------------------------------

function randomize_storage_tank_capacity ()
  for _, prototype in pairs(data.raw["storage-tank"]) do
    if not blacklist["randomize_storage_tank_capacity"][prototype.name] then
      randomize_numerical_property{
        prototype = prototype,
        tbl = prototype.fluid_box,
        property = "base_area",
        property_info = property_info.limited_range
        -- Let's not set rounding info since it can be messed up by the height anyways
      }
    end
  end
end

---------------------------------------------------------------------------------------------------
-- randomize_turret_attack_parameters
---------------------------------------------------------------------------------------------------

function randomize_turret_attack_parameters()
  for _, turret_class in pairs(prototype_tables.turret_classes) do
    for _, turret in pairs(data.raw[turret_class]) do
      if turret.attack_parameters ~= nil then
        randomize_attack_parameters(turret, turret.attack_parameters)
      end
    end
  end
end

---------------------------------------------------------------------------------------------------
-- randomize_underground_belt_distance
---------------------------------------------------------------------------------------------------

function randomize_underground_belt_distance ()
  -- Underground belt
  for _, prototype in pairs(data.raw["underground-belt"]) do
    randomize_numerical_property{
      prototype = prototype,
      property = "max_distance",
      inertia_function = inertia_function.underground_belt_length,
      property_info = property_info.underground_belt_length,
      walk_params = walk_params.underground_belt_length
    }
  end
end

---------------------------------------------------------------------------------------------------
-- randomize_unit
---------------------------------------------------------------------------------------------------

function randomize_unit()
  for _, prototype in pairs(data.raw.unit) do
    randomize_attack_parameters(prototype, prototype.attack_parameters)

    local old_movement_speed = prototype.movement_speed

    randomize_numerical_property({
      prototype = prototype,
      property = "movement_speed",
      inertia_function = inertia_function.sensitive,
      property_info = property_info.limited_range_very_strict
    })

    if prototype.old_movement_speed ~= 0 then
      prototype.distance_per_frame = prototype.distance_per_frame * prototype.movement_speed / old_movement_speed
    end
  end
end

---------------------------------------------------------------------------------------------------
-- randomize_vehicle_crash_damage
---------------------------------------------------------------------------------------------------

function randomize_vehicle_crash_damage ()
  for _, class_key in pairs(prototype_tables.vehicle_classes) do
    for _, prototype in pairs(data.raw[class_key]) do
      local old_energy_per_hit_point = prototype.energy_per_hit_point
      randomize_numerical_property{
        prototype = prototype,
        property = "energy_per_hit_point",
        inertia_function = inertia_function.vehicle_crash_damage,
        property_info = property_info.limited_range
      }

      -- Increase impact resistance for higher crash damages so that this isn't just a glass cannon
      if prototype.resistances then
        for _, resistance in pairs(prototype.resistances) do
          if resistance.type == "impact" then
            resistance.decrease = resistance.decrease * prototype.energy_per_hit_point / old_energy_per_hit_point
          end
        end
      end
    end
  end
end

---------------------------------------------------------------------------------------------------
-- randomize_vehicle_speed
---------------------------------------------------------------------------------------------------

function randomize_vehicle_speed ()
  for class_key, speed_key in pairs(prototype_tables.vehicle_speed_keys) do
    for _, prototype in pairs(data.raw[class_key]) do
      energy_as_number = 60 * util.parse_energy(prototype[speed_key])
      local new_energy_as_number = randomize_numerical_property{
        dummy = energy_as_number,
        prg_key = prg.get_key(prototype),
        inertia_function = inertia_function.vehicle_speed,
        walk_params = walk_params.vehicle_speed,
        property_info = property_info.limited_range
      }
      prototype[speed_key] = new_energy_as_number .. "W"

      -- Scale braking force with the new consumption for improved user experience
      if prototype.braking_power and energy_as_number ~= 0 then
        braking_power_as_number = 60 * util.parse_energy(prototype.braking_power)
        braking_power_as_number = braking_power_as_number * new_energy_as_number / energy_as_number
        prototype.braking_power = braking_power_as_number .. "W"
      elseif prototype.braking_force then
        prototype.braking_force = prototype.braking_force * new_energy_as_number / energy_as_number
      end

      if energy_as_number ~= 0 then
        -- Scale impact hitpoints taken *inversely* cuz that's a bit more balanced and funny
        prototype.energy_per_hit_point = prototype.energy_per_hit_point * new_energy_as_number / energy_as_number

        -- Also scale flat impact resistance
        if prototype.resistances then
          for _, resistance in pairs(prototype.resistances) do
            if resistance.type == "impact" then
              resistance.decrease = resistance.decrease * new_energy_as_number / energy_as_number
            end
          end
        end
      end
    end
  end
end