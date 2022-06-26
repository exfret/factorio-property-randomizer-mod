require("energy-randomizer")
require("util-randomizer")

require("linking-utils")

local inertia_function = require("randomizer-parameter-data/inertia-function-tables")
local property_info = require("randomizer-parameter-data/property-info-tables")
local prototype_tables = require("randomizer-parameter-data/prototype-tables")
local walk_params = require("randomizer-parameter-data/walk-params-tables")

require("random-utils/random")
require("random-utils/randomization-algorithms")

---------------------------------------------------------------------------------------------------
-- randomize_assembly_machine_groups
---------------------------------------------------------------------------------------------------

function randomize_assembly_machine_groups ()
  local upgrade_groups = find_upgrade_groups("assembling-machine")

  for _, upgrade_group in pairs(upgrade_groups) do
    local group_params = {}
    for _, prototype_in_upgrade_group in pairs(upgrade_group) do
      table.insert(group_params, {
        prototype = prototype_in_upgrade_group,
        property = "crafting_speed",
        inertia_function = add_inertia_function_multiplier(2 / 5, inertia_function.crafting_speed),
        property_info = property_info.machine_speed
      })
    end

    randomize_numerical_property{
      -- TODO: Add custom prg keys for groups depending on the most upgraded version
      group_params = group_params
    }
  end
end

---------------------------------------------------------------------------------------------------
-- randomize_beacon_properties
---------------------------------------------------------------------------------------------------

function randomize_beacon_properties ()
  for _, prototype in pairs(data.raw.beacon) do
    randomize_numerical_property{
      prototype = prototype,
      property = "supply_area_distance",
      inertia_function = add_inertia_function_multiplier(3 / 5, inertia_function.beacon_supply_area_distance),
      property_info = property_info.supply_area
    }

    randomize_numerical_property{
      prototype = prototype,
      property = "distribution_effectivity",
      inertia_function = add_inertia_function_multiplier(3 / 5, inertia_function.beacon_distribution_effectivity),
      property_info = property_info.effectivity
    }
  end
end

---------------------------------------------------------------------------------------------------
-- randomize_beacon_group_properties
---------------------------------------------------------------------------------------------------

function randomize_beacon_group_properties ()
  local group_params = {}

  for _, prototype in pairs(data.raw.beacon) do
    table.insert(group_params, {
      prototype = prototype,
      property = "supply_area_distance",
      inertia_function = add_inertia_function_multiplier(2 / 5, inertia_function.beacon_supply_area_distance),
      property_info = property_info.supply_area
    })

    table.insert(group_params, {
      prototype = prototype,
      property = "distribution_effectivity",
      inertia_function = add_inertia_function_multiplier(2 / 5, inertia_function.beacon_distribution_effectivity),
      property_info = property_info.effectivity
    })
  end

  randomize_numerical_property{
    group_params = group_params
  }
end

---------------------------------------------------------------------------------------------------
-- randomize_belt_speed
---------------------------------------------------------------------------------------------------

-- TODO: Option to sync belt tiers
function randomize_belt_speed ()
  for _, belt_class in pairs(prototype_tables.transport_belt_classes) do
    for _, prototype in pairs(data.raw[belt_class]) do
      randomize_numerical_property{
        prototype = prototype,
        property = "speed",
        inertia_function = add_inertia_function_multiplier(3 / 5, inertia_function.belt_speed),
        property_info = property_info.belt_speed
      }
    end
  end
end

---------------------------------------------------------------------------------------------------
-- randomize_belt_group_speed
---------------------------------------------------------------------------------------------------

function randomize_belt_group_speed ()
  for _, belt_class in pairs(prototype_tables.transport_belt_classes) do
    local group_params = {}
    for _, prototype in pairs(data.raw[belt_class]) do
      table.insert(group_params, {
        prototype = prototype,
        property = "speed",
        inertia_function = add_inertia_function_multiplier(2 / 5, inertia_function.belt_speed),
        property_info = property_info.belt_speed
      })
    end

    randomize_numerical_property{
      prg_key = prg.get_key(belt_class, "class"),
      group_params = group_params
    }
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
      inertia_function = inertia_function.car_rotation_speed
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

---------------------------------------------------------------------------------------------------
-- randomize_container_group_inventory_sizes
---------------------------------------------------------------------------------------------------

function randomize_container_group_inventory_sizes ()
  local group_params = {}

  for class_name, _ in pairs(prototype_tables.container_classes) do
    for _, prototype in pairs(data.raw[class_name]) do
      table.insert(group_params, {
        prototype = prototype,
        property = "inventory_size",
        inertia_function = add_inertia_function_multiplier(2 / 3, inertia_function.inventory_size),
        property_info = property_info.large_inventory
      })
    end
  end

  randomize_numerical_property{
    group_params = group_params
  }
end

---------------------------------------------------------------------------------------------------
-- randomize_electric_pole_groups
---------------------------------------------------------------------------------------------------

-- TODO: Make this work on fast_replaceable_groups rather than next_upgrade
function randomize_electric_pole_groups ()
  local fast_replaceable_group_tbl = find_fast_replaceable_groups("electric-pole")

  for _, fast_replaceable_group in pairs(fast_replaceable_group_tbl) do
    local group_params_supply_area = {}
    local group_params_wire_distance = {}

    for _, prototype in pairs(fast_replaceable_group) do
      table.insert(group_params_supply_area, {
        prototype = prototype,
        property = "supply_area_distance",
        inertia_function = add_inertia_function_multiplier(2 / 5, inertia_function.electric_pole_supply_area),
        property_info = property_info.supply_area,
        walk_params = walk_params.electric_pole_supply_area
      })

      table.insert(group_params_wire_distance, {
        prototype = prototype,
        property = "maximum_wire_distance",
        inertia_function = add_inertia_function_multiplier(2 / 5, inertia_function.electric_pole_wire_reach),
        property_info = property_info.wire_distance
      })
    end

    randomize_numerical_property{
      group_params = group_params_supply_area,
      walk_params = walk_params.electric_pole_supply_area
    }

    randomize_numerical_property{
      group_params = group_params_wire_distance
    }
  end
end

---------------------------------------------------------------------------------------------------
-- randomize_electric_poles
---------------------------------------------------------------------------------------------------

-- TODO: Soft link to make electric pole reach usually larger than supply area
function randomize_electric_poles ()
  for _, prototype in pairs(data.raw["electric-pole"]) do
    randomize_numerical_property{
      prototype = prototype,
      property = "supply_area_distance",
      inertia_function = add_inertia_function_multiplier(3 / 5, inertia_function.electric_pole_supply_area),
      property_info = property_info.supply_area,
      walk_params = walk_params.electric_pole_supply_area
    }

    new_wire_distance_property_info = util.table.deepcopy(property_info.wire_distance)
    new_wire_distance_property_info.min = math.max(new_wire_distance_property_info.min, 2 * prototype.supply_area_distance + 0.5)

    randomize_numerical_property{
      prototype = prototype,
      property = "maximum_wire_distance",
      inertia_function = add_inertia_function_multiplier(3 / 5, inertia_function.electric_pole_wire_reach),
      property_info = new_wire_distance_property_info
    }
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
          inertia_function = inertia_function.entity_interaction_mining_speed
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
        inertia_function = inertia_function.entity_interaction_repair_speed
      }
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
-- randomize_gate_opening_speed
---------------------------------------------------------------------------------------------------

function randomize_gate_opening_speed ()
  for _, prototype in pairs(data.raw.gate) do
    randomize_numerical_property{
      prototype = prototype,
      property = "opening_speed",
      inertia_function = inertia_function.gate_opening_speed
    }
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
        local variance = 1
        if prototype_tables.entities_with_health_sensitive[prototype.type] then
          inertia_function_to_use = inertia_function.max_health_sensitive
          variance = 0.2
        end

        randomize_numerical_property{
          prototype = prototype,
          property = "max_health",
          inertia_function = inertia_function_to_use,
          property_info = property_info.max_health
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
  {1, 1}, -- Diagonal
  {0, -1.2} -- "Back where it came from"
}

local inserter_pickup_positions = {
  {0, -1}, -- Standard
  {0, -2}, -- Long-handed
  {1, 0}, -- To the side
  {-1.2, -0.2}, -- Diagonal, sorta?
  {-3.2, 9.2} -- Huh?
}

-- TODO: Add Bob's mods compatibility
function randomize_inserter_insert_dropoff_positions()
  for _, prototype in pairs(data.raw.inserter) do
    -- Test that this inserter is a "good" size
    if prototype.collision_box ~= nil and prototype.collision_box[1][1] == -0.15 and prototype.collision_box[1][2] == -0.15 and prototype.collision_box[2][1] == 0.15 and prototype.collisions_box[2][2] == 0.15 then
      local key = prototype.type .. "aaa" .. prototype.name

      local inserter_position_variable = prg.range(key, 1,8)

      -- 1/4 chance to change to a different type of insert position
      if 1 <= inserter_position_variable and inserter_position_variable <= 3 then
        prototype.insert_position = inserter_insert_positions[prg.range(key, 1, #inserter_insert_positions)]
      end

      -- 1/4 chance to change to a different type of pickup position
      if 2 <= inserter_position_variable and inserter_position_variable <= 4 then
        prototype.pickup_position = inserter_pickup_positions[prg.range(key, 1, #inserter_pickup_positions)]
      end
    end
  end
end

---------------------------------------------------------------------------------------------------
-- randomize_group_inserter_speed
---------------------------------------------------------------------------------------------------

function randomize_inserter_group_speed ()
  local group_params_rotation_speed = {}
  local group_params_extension_speed = {}

  for _, prototype in pairs(data.raw.inserter) do
    table.insert(group_params_rotation_speed, {
      protototype = prototype,
      property = "rotation_speed",
      inertia_function = add_inertia_function_multiplier(1 / 3, inertia_function.inserter_rotation_speed),
      property_info = property_info.inserter_rotation_speed
    })

    table.insert(group_params_extension_speed, {
      prototype = prototype,
      property = "extension_speed",
      inertia_function = add_inertia_function_multiplier(1 / 3, inertia_function.inserter_extension_speed)
    })
  end

  randomize_numerical_property{
    group_params = group_params_rotation_speed
  }

  randomize_numerical_property{
    group_params = group_params_extension_speed
  }
end

---------------------------------------------------------------------------------------------------
-- randomize_inserter_speed
---------------------------------------------------------------------------------------------------

function randomize_inserter_speed ()
  for _, prototype in pairs(data.raw.inserter) do
    randomize_numerical_property{
      prototype = prototype,
      property = "rotation_speed",
      inertia_function = add_inertia_function_multiplier(2 / 3, inertia_function.inserter_rotation_speed),
      property_info = property_info.inserter_rotation_speed
    }

    randomize_numerical_property{
      prototype = prototype,
      property = "extension_speed",
      inertia_function = add_inertia_function_multiplier(2 / 3, inertia_function.inserter_extension_speed)
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
        if prototype[property_name] then
          local property_info_to_use
          if prototype[property_name] == 0 then
            property_info_to_use = property_info.small_inventory
          elseif prototype[property_name] < 10 then
            property_info_to_use = property_info.small_nonempty_inventory
          else
            property_info_to_use = property_info.large_inventory
          end

          local multiplier = 1
          if prototype_tables[class_name] == true then
            multiplier = 1 / 3
          end

          randomize_numerical_property{
            prototype = prototype,
            property = property_name,
            inertia_function = add_inertia_function_multiplier(multiplier, inertia_function.inventory_size),
            property_info = property_info_to_use
          }
        end
      end
    end
  end

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

          randomize_numerical_property{
            prototype = prototype,
            tbl = prototype[property_name],
            property = "burnt_inventory_size",
            inertia_function = inertia_function.energy_source_inventory_sizes,
            property_info = property_info.small_inventory
          }
        end
      end
    end
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
-- randomize_machine_speed
---------------------------------------------------------------------------------------------------

function randomize_machine_speed ()
  for _, class in pairs(prototype_tables.machine_classes) do
    for _, prototype in pairs(data.raw[class]) do
      randomize_numerical_property{
        prototype = prototype,
        property = "crafting_speed",
        inertia_function = add_inertia_function_multiplier(3 / 5, inertia_function.crafting_speed),
        property_info = property_info.machine_speed
      }

      -- TODO: Make burner mining drill swingier?
      randomize_numerical_property{
        prototype = prototype,
        property = "mining_speed",
        inertia_function = inertia_function.machine_mining_speed,
        property_info = property_info.machine_speed
      }

      randomize_numerical_property{
        prototype = prototype,
        property = "pumping_speed",
        inertia_function = inertia_function.pumping_speed,
        property_info = property_info.pumping_speed
      }

      randomize_numerical_property{
        prototype = prototype,
        property = "researching_speed",
        inertia_function = inertia_function.researching_speed,
        property_info = property_info.researching_speed
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
-- randomize_module_slots
---------------------------------------------------------------------------------------------------

function randomize_module_slots ()
  for _, class_name in pairs(prototype_tables.machines_with_module_slots) do
    for _, prototype in pairs(data.raw[class_name]) do
      if prototype["module_specification"] then
        if prototype["module_specification"].module_slots == nil then
          prototype["module_specification"].module_slots = 0
        end

        randomize_numerical_property{
          prototype = prototype,
          tbl = prototype["module_specification"],
          property = "module_slots",
          inertia_function = inertia_function.module_specification,
          property_info = property_info.small_inventory
        }
      end
    end
  end
end

---------------------------------------------------------------------------------------------------
-- randomize_pump_speed
---------------------------------------------------------------------------------------------------

function randomize_pump_speed ()
  for _, prototype in pairs(data.raw.pump) do
    -- TODO
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
      dummy = charging_energy
    }
    prototype.charging_energy = charging_energy .. "W"

    -- TODO: Keep the charging offsets instead of discarding these vectors entirely (or just make them charge in a circle)
    -- Randomize how many robots can charge at the roboport
    if prototype.charging_station_count == nil or prototype.charging_station_count == 0 then
      prototype.charging_station_count = #prototype.charging_offsets
    end
    randomize_numerical_property{
      prototype = prototype,
      property = "charging_station_count",
      inertia_function = inertia_function.charging_statiion_count,
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
-- randomize_vehicle_crash_damage
---------------------------------------------------------------------------------------------------

function randomize_vehicle_crash_damage ()
  for _, class_key in pairs(prototype_tables.vehicle_classes) do
    for _, prototype in pairs(data.raw[class_key]) do
      local old_energy_per_hit_point = prototype.energy_per_hit_point
      randomize_numerical_property{
        prototype = prototype,
        property = "energy_per_hit_point",
        inertia_function = inertia_function.vehicle_crash_damage
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
        walk_params = walk_params.vehicle_speed
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