seed_setting = settings.startup["propertyrandomizer-seed"].value

rounding_mode = -1
if settings.startup["propertyrandomizer-rounding-mode"].value == "murder the rightmost digits mercilessly" then
  rounding_mode = 3
elseif settings.startup["propertyrandomizer-rounding-mode"].value == "round-ish" then
  rounding_mode = 2
elseif settings.startup["propertyrandomizer-rounding-mode"].value == "leave 'em raw and unrounded" then
  rounding_mode = 1
end

-- Basic randomizations

rand_ammo = settings.startup["propertyrandomizer-ammo"].value
rand_armor_resistances = settings.startup["propertyrandomizer-armor-and-equipment"].value
rand_beacons = settings.startup["propertyrandomizer-beacons"].value
rand_bots = settings.startup["propertyrandomizer-bots"].value
rand_capsules = settings.startup["propertyrandomizer-capsules"].value
rand_crafting_times = settings.startup["propertyrandomizer-crafting-times"].value
rand_electric_poles = settings.startup["propertyrandomizer-electric-pole"].value
rand_energy_values = settings.startup["propertyrandomizer-energy-value"].value
rand_equipment_grids = settings.startup["propertyrandomizer-armor-and-equipment"].value
rand_equipment_properties = settings.startup["propertyrandomizer-armor-and-equipment"].value
rand_equipment_shapes = settings.startup["propertyrandomizer-armor-and-equipment"].value
rand_inventory_properties = settings.startup["propertyrandomizer-inventory-properties"].value
rand_health_properties = settings.startup["propertyrandomizer-health-properties"].value
rand_logistic_speed = settings.startup["propertyrandomizer-logistic-speed"].value
rand_machine_speed = settings.startup["propertyrandomizer-machine-speed"].value
rand_machine_pollution = settings.startup["propertyrandomizer-machine-pollution"].value
rand_module_effects = settings.startup["propertyrandomizer-module-effects"].value
rand_module_slots = settings.startup["propertyrandomizer-module-slots"].value
rand_underground_distance = settings.startup["propertyrandomizer-underground-distance"].value
rand_vehicles = settings.startup["propertyrandomizer-vehicles"].value

-- Advanced randomizations

rand_character_corpse_time_to_live = settings.startup["propertyrandomizer-misc-properties"].value
rand_character_respawn_time = settings.startup["propertyrandomizer-misc-properties"].value
rand_enemy_spawning = settings.startup["propertyrandomizer-enemy-spawning"].value
rand_entity_interaction_speed = settings.startup["propertyrandomizer-entity-interaction-speed"].value
rand_gate_opening_speed = settings.startup["propertyrandomizer-misc-properties"].value
rand_inserter_position = settings.startup["propertyrandomizer-inserter-position"].value
rand_mining_drill_productivity = settings.startup["propertyrandomizer-mining-drill-productivity"].value
--rand_switch_projectiles = settings.startup["propertyrandomizer-switch-projectiles"].value
rand_tools = settings.startup["propertyrandomizer-misc-properties"].value

-- Silly randomizations