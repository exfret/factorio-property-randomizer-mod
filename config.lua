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
rand_belt_speeds = settings.startup["propertyrandomizer-belt-speeds"].value
rand_bots = settings.startup["propertyrandomizer-bots"].value
rand_capsules = settings.startup["propertyrandomizer-capsules"].value
rand_crafting_machine_speed = settings.startup["propertyrandomizer-crafting-machine-speed"].value
rand_electric_poles = settings.startup["propertyrandomizer-electric-pole"].value
rand_energy_values = settings.startup["propertyrandomizer-energy-value"].value
rand_equipment_grids = settings.startup["propertyrandomizer-armor-and-equipment"].value
rand_equipment_properties = settings.startup["propertyrandomizer-armor-and-equipment"].value
rand_equipment_shapes = settings.startup["propertyrandomizer-armor-and-equipment"].value
rand_gun_damage_modifier = settings.startup["propertyrandomizer-gun-damage-modifier"].value
rand_gun_range = settings.startup["propertyrandomizer-gun-range"].value
rand_gun_speed = settings.startup["propertyrandomizer-gun-speed"].value
rand_inserter_rotation_speed = settings.startup["propertyrandomizer-inserter-speed"].value
rand_inventory_properties = settings.startup["propertyrandomizer-inventory-properties"].value
rand_health_properties = settings.startup["propertyrandomizer-health-properties"].value
rand_lab_speed = settings.startup["propertyrandomizer-lab-research-speed"].value
rand_machine_pollution = settings.startup["propertyrandomizer-machine-pollution"].value
rand_mining_speed = settings.startup["propertyrandomizer-mining-speeds"].value
rand_module_effects = settings.startup["propertyrandomizer-module-effects"].value
rand_module_slots = settings.startup["propertyrandomizer-module-slots"].value
rand_offshore_pump_speed = settings.startup["propertyrandomizer-offshore-pump-speed"].value
rand_underground_distance = settings.startup["propertyrandomizer-underground-distance"].value
rand_tech_costs = settings.startup["propertyrandomizer-tech-costs"].value
rand_vehicles = settings.startup["propertyrandomizer-vehicles"].value

-- Advanced randomizations

rand_character_corpse_time_to_live = settings.startup["propertyrandomizer-misc-properties"].value
rand_character_properties_midgame = settings.startup["propertyrandomizer-character-values-midgame"].value
rand_character_respawn_time = settings.startup["propertyrandomizer-misc-properties"].value
rand_crafting_times = settings.startup["propertyrandomizer-crafting-times"].value
rand_enemy_spawning = settings.startup["propertyrandomizer-enemy-spawning"].value
rand_entity_interaction_speed = settings.startup["propertyrandomizer-entity-interaction-speed"].value
rand_gate_opening_speed = settings.startup["propertyrandomizer-misc-properties"].value
rand_inserter_position = settings.startup["propertyrandomizer-inserter-position"].value
rand_mining_drill_productivity = settings.startup["propertyrandomizer-mining-drill-productivity"].value
rand_mining_drill_dropoff = settings.startup["propertyrandomizer-mining-drill-dropoff"].value
--rand_switch_projectiles = settings.startup["propertyrandomizer-switch-projectiles"].value

rand_tools = settings.startup["propertyrandomizer-misc-properties"].value

-- Silly randomizations