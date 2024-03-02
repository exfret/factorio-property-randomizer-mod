require("config")
--require("gather-randomizations")

local karma = require("analysis/karma")

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
  table.insert(randomizing_functions_to_call, randomize_energy_properties) -- RocketSilo has extra properties I haven't randomized yet it seems
  table.insert(randomizing_functions_to_call, randomize_power_production_properties) -- TODO
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

if rand_mining_drill_dropoff then
  table.insert(randomizing_functions_to_call, randomize_mining_drill_dropoff_location)
end

if rand_inserter_position then
  table.insert(randomizing_functions_to_call, randomize_inserter_insert_dropoff_positions)
end

if rand_tools then
  table.insert(randomizing_functions_to_call, randomize_tools)
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
for _, randomizing_function in pairs(randomizing_functions_to_call) do
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

--log(serpent.dump(karma.values))

--[[for _, character in pairs(data.raw.character) do
  character.reach
end]]

-- TODO: Locale