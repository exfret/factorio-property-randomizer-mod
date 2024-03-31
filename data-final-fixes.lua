require("config")
--require("gather-randomizations")
require("linking-utils")
require("randomizer-functions/energy-randomizer")
require("randomizer-functions/entity-randomizer")
require("randomizer-functions/item-randomizer")
require("randomizer-functions/misc-randomizer")
require("randomizer-functions/recipe-randomizer")
require("randomizer-functions/technology-randomizer")

require("random-utils/randomization-algorithms")

require("analysis/karma")

local reformat = require("utilities/reformat")

--local dependency_utils = require("dependency-graph/dependency-utils")

log("Reformatting prototypes...")

--reformat.prototypes()

log("Gathering things to randomize...")

local randomizing_functions_to_call = {}

log("Performing randomizations...")

--[[for _, class in pairs(data.raw) do
  for _, prototype in pairs(class) do

  end
end]]

--blop.blop = nil

---------------------------------------------------------------------------------------------------
-- Basic randomizations
---------------------------------------------------------------------------------------------------

if rand_ammo then
  table.insert(randomizing_functions_to_call, randomize_ammo)
  table.insert(randomizing_functions_to_call, randomize_projectile_damage)
end

if rand_armor_resistances then
  -- Disable armor resistance for now
  --table.insert(randomizing_functions_to_call, randomize_armor_resistances)
  --table.insert(randomizing_functions_to_call, randomize_armor_group_resistances)
end

-- Does not randomize module slots (randomized elsewhere)
if rand_beacons then
  table.insert(randomizing_functions_to_call, randomize_beacon_properties)
end

if rand_belt_speeds then
  table.insert(randomizing_functions_to_call, randomize_belt_speed)
end

if rand_bots then
  table.insert(randomizing_functions_to_call, randomize_bot_speed)
  table.insert(randomizing_functions_to_call, randomize_roboports)
end

if rand_capsules then
  table.insert(randomizing_functions_to_call, randomize_capsules)
end

if rand_crafting_machine_speed then
  table.insert(randomizing_functions_to_call, randomize_crafting_machine_speeds)
end

if rand_crafting_times then
  table.insert(randomizing_functions_to_call, randomize_crafting_times)
end

if rand_electric_poles then
  table.insert(randomizing_functions_to_call, randomize_electric_poles)
end

if rand_energy_values then
  table.insert(randomizing_functions_to_call, randomize_energy_properties) -- Don't randomize rocket silo lamp and active energy usage, most people don't even know about those
  table.insert(randomizing_functions_to_call, randomize_power_production_properties)
  table.insert(randomizing_functions_to_call, randomize_reactor_neighbour_bonus)
end

if rand_equipment_grids then
  table.insert(randomizing_functions_to_call, randomize_equipment_grids)
end

if rand_equipment_properties then
  -- TODO
  table.insert(randomizing_functions_to_call, randomize_equipment_properties)
end

if rand_equipment_shapes then
  -- TODO
  table.insert(randomizing_functions_to_call, randomize_equipment_shapes)
end

if rand_gun_damage_modifier then
  table.insert(randomizing_functions_to_call, randomize_gun_damage_modifier)
end

if rand_gun_range then
  table.insert(randomizing_functions_to_call, randomize_gun_range)
end

if rand_gun_speed then
  table.insert(randomizing_functions_to_call, randomize_gun_speed)
end

if rand_health_properties then
  table.insert(randomizing_functions_to_call, randomize_health_properties)
end

if rand_inserter_speed then
  table.insert(randomizing_functions_to_call, randomize_inserter_speed)
end

-- TODO: Modify fluid "inventory" sizes too
if rand_inventory_properties then
  table.insert(randomizing_functions_to_call, randomize_inventory_sizes)
  table.insert(randomizing_functions_to_call, randomize_item_stack_sizes)
end

if rand_lab_speed then
  table.insert(randomizing_functions_to_call, randomize_lab_research_speed)
end

if rand_landmines then
  table.insert(randomizing_functions_to_call, randomize_landmines)
end

-- TODO: Figure out what extra things support pollution
if rand_machine_pollution then
  table.insert(randomizing_functions_to_call, randomize_machine_pollution)
end

if rand_mining_drill_productivity then
  table.insert(randomizing_functions_to_call, randomize_mining_productivity)
end

if rand_mining_speed then
  table.insert(randomizing_functions_to_call, randomize_mining_speeds)
end

if rand_module_effects then
  table.insert(randomizing_functions_to_call, randomize_module_effects)
end

if rand_module_slots then
  table.insert(randomizing_functions_to_call, randomize_module_slots)
end

if rand_offshore_pump_speed then
  table.insert(randomizing_functions_to_call, randomize_offshore_pump_speed)
end

if rand_pump_pumping_speed then
  table.insert(randomizing_functions_to_call, randomize_pump_speed)
end

if rand_radar then
  table.insert(randomizing_functions_to_call, randomize_radar)
end

if rand_storage_tank_capacity then
  table.insert(randomizing_functions_to_call, randomize_storage_tank_capacity)
end

if rand_tech_costs then
  table.insert(randomizing_functions_to_call, randomize_technology_science_cost)
  table.insert(randomizing_functions_to_call, randomize_technology_time_cost)
end

if rand_tile_walking_speed_modifier then
  table.insert(randomizing_functions_to_call, randomize_tile_walking_speed_modifier)
end

if rand_turret_attack_parameters then
  table.insert(randomizing_functions_to_call, randomize_turret)
  table.insert(randomizing_functions_to_call, randomize_turret_attack_parameters)
end

if rand_underground_distance then
  table.insert(randomizing_functions_to_call, randomize_underground_belt_distance)
  -- randomize_underground_pipe_distance() TODO
end

if rand_vehicles then
  table.insert(randomizing_functions_to_call, randomize_car_rotation_speed)
  table.insert(randomizing_functions_to_call, randomize_vehicle_speed)
  table.insert(randomizing_functions_to_call, randomize_vehicle_crash_damage)
end

---------------------------------------------------------------------------------------------------
-- Advanced randomizations
---------------------------------------------------------------------------------------------------

if rand_character_corpse_time_to_live then
  table.insert(randomizing_functions_to_call, randomize_character_corpse_time_to_live)
end

if rand_character_respawn_time then
  table.insert(randomizing_functions_to_call, randomize_character_respawn_time)
end

if rand_crafting_machine_productivity then
  table.insert(randomizing_functions_to_call, randomize_crafting_machine_productivity)
end

if rand_entity_interaction_speed then
  table.insert(randomizing_functions_to_call, randomize_entity_interaction_speed)
end

if rand_entity_sizes then
  table.insert(randomizing_functions_to_call, randomize_entity_sizes)
end

if rand_fuel_inventory_slots then
  table.insert(randomizing_functions_to_call, randomize_fuel_inventory_slots)
end

if rand_gate_opening_speed then
  table.insert(randomizing_functions_to_call, randomize_gate_opening_speed)
end

if rand_inserter_position then
  table.insert(randomizing_functions_to_call, randomize_inserter_insert_dropoff_positions)
end

if rand_mining_drill_dropoff then
  table.insert(randomizing_functions_to_call, randomize_mining_drill_dropoff_location)
end

if rand_mining_results_tree_rock then
  table.insert(randomizing_functions_to_call, randomize_mining_results_tree_rock)
end

if rand_projectiles then
  table.insert(randomizing_functions_to_call, randomize_projectiles)
end

if rand_stickers then
  table.insert(randomizing_functions_to_call, randomize_stickers)
end

if rand_tools then
  table.insert(randomizing_functions_to_call, randomize_tools)
end

if rand_unit then
  table.insert(randomizing_functions_to_call, randomize_unit)
end

---------------------------------------------------------------------------------------------------
-- Silly randomizations
---------------------------------------------------------------------------------------------------

-- randomize_all_game_sounds()
-- randomize_utility_constants_properties()

---------------------------------------------------------------------------------------------------
-- Perform the randomizations
---------------------------------------------------------------------------------------------------

log("Performing randomizations...")
for i, randomizing_function in pairs(randomizing_functions_to_call) do
  log("Randomization number " .. i)
  randomizing_function()
end

log("Performing test randomizations...")

if settings.startup["propertyrandomizer-icons"].value then
  require("randomizer-functions/icon-randomizer")
end

if settings.startup["propertyrandomizer-sounds"].value then
  randomize_all_game_sounds()
end

if settings.startup["propertyrandomizer-misc-properties"].value then
  randomize_map_colors()
end

if settings.startup["propertyrandomizer-misc-properties"].value then
  randomize_icon_shifts()
  randomize_utility_constants_properties()
  randomize_rocket_silo_rocket_launch_length()
end

-- Final quick fixes
if data.raw["generator"]["steam-engine"] ~= nil and data.raw["boiler"]["boiler"] ~= nil then
  local boiler_temp = data.raw["boiler"]["boiler"].target_temperature
  local steam_engine_temp = data.raw["generator"]["steam-engine"].maximum_temperature

  data.raw["boiler"]["boiler"].target_temperature = math.max(boiler_temp, steam_engine_temp)
  data.raw["generator"]["steam-engine"].maximum_temperature = math.max(boiler_temp, steam_engine_temp)
end

--log(serpent.dump(karma.values))

local new_table = {}
for class_name, class in pairs(data.raw) do
  for prototype_name, prototype in pairs(class) do
    for property_name, property in pairs(prototype) do
      table.insert(new_table, serpent.dump({
        value_type = "property",
        class = class_name,
        prototype = prototype_name,
        property = property_name,
        key = prg.get_key({type = prototype.type, name = prototype.name, property = property_name}, "property"),
        value = karma.values.property_values[prg.get_key({type = class_name, name = prototype_name, property = property_name}, "property")]
      }))
    end
    table.insert(new_table, serpent.dump({
      value_type = "prototype",
      class = class_name,
      prototype = prototype_name,
      key = prg.get_key({type = class_name, name = prototype_name}),
      value = karma.values.prototype_values[prg.get_key(prototype)]
    }))
  end
  table.insert(new_table, serpent.dump({
    value_type = "class",
    class = class_name,
    key = prg.get_key(class_name, "class"),
    value = karma.values.class_values[prg.get_key(class_name, "class")]
  }))
end
table.insert(new_table, serpent.dump({
  value_type = "overall",
  key = prg.get_key(nil, "dummy"),
  value = karma.values.overall[prg.get_key(nil, "dummy")]
}))

data:extend({
  {
    type = "selection-tool",
    name = "prototype-data",
    icon = "__base__/graphics/icons/iron-plate.png",
    icon_size = 64,
    stack_size = 1,
    selection_mode = {"blueprint"},
    alt_selection_mode = {"blueprint"},
    selection_color = {},
    alt_selection_color = {},
    selection_cursor_box_type = "entity",
    alt_selection_cursor_box_type = "entity",
    entity_type_filters = new_table
  }
})

-- TEST
-- require("randomizer-functions/keybind-randomizer-prototypes")

-- TODO: Locale