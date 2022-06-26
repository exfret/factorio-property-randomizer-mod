local inertia_function = {}

inertia_function.beacon_distribution_effectivity = {
  ["type"] = "proportional",
  slope = 4
}

inertia_function.beacon_supply_area_distance = {
  ["type"] = "linear",
  slope = 3.5,
  ["x-intercept"] = 1.5
}

inertia_function.belt_speed = {
  {0, 0},
  {5 / 480, 3 / 480},
  {10 / 480, 21 / 480},
  {255, 1200}
}

inertia_function.bot_speed = {
  ["type"] = "proportional",
  slope = 5 -- Can be higher since bots aren't as necessary
}

inertia_function.car_rotation_speed = {
  ["type"] = "proportional",
  slope = 5
}

inertia_function.character_corpse_time_to_live = {
  ["type"] = "proportional",
  slope = 10
}

inertia_function.charging_station_count = {
  ["type"] = "constant",
  value = 40
}

inertia_function.consumption_effect = {
  {-0.8, 0},
  {-0.4, 1},
  {-0.2, 3},
  {0.0, 0.7},
  {0.3, 3},
  {0.8, 5},
  {100, 5}
}

inertia_function.crafting_speed = {
  ["type"] = "proportional",
  slope = 4
}

inertia_function.electric_pole_supply_area = {
  {-2, 3},
  {1.5, 3},
  {2, 6},
  {4, 45},
  {10, 60},
  {50, 150},
  {64, 0}
}

inertia_function.electric_pole_wire_reach = {
  {1.5, 0},
  {3.5, 3},
  {5, 18},
  {15, 100},
  {50, 300},
  {64, 0}
}

inertia_function.pollution_effect = {
  {-1, 0},
  {-0.2, 2},
  {0.02, 0.6},
  {0.2, 1.4},
  {100, 1.4}
}

inertia_function.productivity_effect = {
  {0, 0},
  {0.03, 0.4},
  {0.1, 0.4},
  {0.3, 0.1},
  {100, 0.1}
}

inertia_function.energy_source_inventory_sizes = {
  ["type"] = "constant",
  value = 40
}

inertia_function.entity_interaction_mining_speed = {
  ["type"] = "proportional",
  slope = 5
}

inertia_function.entity_interaction_repair_speed = {
  ["type"] = "proportional",
  slope = 15
}

inertia_function.gate_opening_speed = {
  ["type"] = "proportional",
  slope = 15
}

inertia_function.speed_effect = {
  {-1, 0},
  {-0.05, 2},
  {0, 0.6},
  {0.1, 1.2},
  {1, 1.2},
  {100, 2}
}

inertia_function.inserter_extension_speed = {
  ["type"] = "proportional",
  slope = 10
}

inertia_function.inserter_rotation_speed = {
  ["type"] = "proportional",
  slope = 6
}

inertia_function.inventory_size = {
  {-4, 50},
  {10, 50},
  {65535, 327675}
}

inertia_function.inventory_slots = {
  ["type"] = "constant",
  value = 40
}

inertia_function.machine_mining_speed = {
  ["type"] = "proportional",
  slope = 2
}

inertia_function.module_specification = {
  ["type"] = "constant",
  value = 10
}

inertia_function.pumping_speed = {
  ["type"] = "proportional",
  slope = 8
}

inertia_function.researching_speed = {
  ["type"] = "proportional",
  slope = 10
}

inertia_function.stack_size = {
  ["type"] = "proportional",
  slope = 7
}

inertia_function.underground_belt_length = {
  {-4, 30},
  {4, 30},
  {8, 60},
  {255, 3000}
}

inertia_function.vehicle_crash_damage = {
  ["type"] = "proportional",
  slope = 20
}

inertia_function.vehicle_speed = {
  ["type"] = "proportional",
  slope = 20
}

return inertia_function