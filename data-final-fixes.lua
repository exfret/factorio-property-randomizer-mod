require("config")

require("randomizer-functions/energy-randomizer")
require("randomizer-functions/entity-randomizer")
require("randomizer-functions/item-randomizer")
require("randomizer-functions/misc-randomizer")
require("randomizer-functions/recipe-randomizer")
require("randomizer-functions/technology-randomizer")

local randomizing_functions_to_call = {}

---------------------------------------------------------------------------------------------------
-- Basic randomizations
---------------------------------------------------------------------------------------------------

if rand_ammo then
  table.insert(randomizing_functions_to_call, randomize_ammo)
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

if rand_bots then
  table.insert(randomizing_functions_to_call, randomize_bot_speed)
  table.insert(randomizing_functions_to_call, randomize_roboports)
end

if rand_capsules then
  table.insert(randomizing_functions_to_call, randomize_capsules)
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

if rand_health_properties then
  table.insert(randomizing_functions_to_call, randomize_health_properties)
end

-- TODO: Modify fluid "inventory" sizes too
if rand_inventory_properties then
  table.insert(randomizing_functions_to_call, randomize_inventory_sizes)
  table.insert(randomizing_functions_to_call, randomize_item_stack_sizes)
end

-- TODO: Randomize pump (normal pump, not offshore pump) speed
if rand_logistic_speed then
  table.insert(randomizing_functions_to_call, randomize_belt_speed)
  table.insert(randomizing_functions_to_call, randomize_inserter_speed)
  table.insert(randomizing_functions_to_call, randomize_pump_speed) -- TODO once I learn about fluidboxes
end

if rand_machine_speed then
  table.insert(randomizing_functions_to_call, randomize_machine_speed)
end

-- TODO: Figure out what extra things support pollution
if rand_machine_pollution then
  table.insert(randomizing_functions_to_call, randomize_machine_pollution)
end

if rand_mining_drill_productivity then
  table.insert(randomizing_functions_to_call, randomize_mining_productivity)
end

if rand_module_effects then
  table.insert(randomizing_functions_to_call, randomize_module_effects)
end

if rand_module_slots then
  table.insert(randomizing_functions_to_call, randomize_module_slots)
end

if rand_tech_costs then
  table.insert(randomizing_functions_to_call, randomize_technology_science_cost)
  table.insert(randomizing_functions_to_call, randomize_technology_time_cost)
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

if rand_enemy_spawning then
  table.insert(randomizing_functions_to_call, randomize_enemy_spawning)
end

if rand_entity_interaction_speed then
  table.insert(randomizing_functions_to_call, randomize_entity_interaction_speed)
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

for _, randomizing_function in pairs(randomizing_functions_to_call) do
  randomizing_function()
end