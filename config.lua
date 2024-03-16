seed_setting = settings.startup["propertyrandomizer-seed"].value

rounding_mode = -1
if settings.startup["propertyrandomizer-rounding-mode"].value == "murder the rightmost digits mercilessly" then
  rounding_mode = 3
elseif settings.startup["propertyrandomizer-rounding-mode"].value == "round-ish" then
  rounding_mode = 2
elseif settings.startup["propertyrandomizer-rounding-mode"].value == "leave 'em raw and unrounded" then
  rounding_mode = 1
end

sync_belt_tiers = settings.startup["propertyrandomizer-belt-sync"].value

-- Basic randomizations

rand_ammo = settings.startup["propertyrandomizer-military"].value
rand_beacons = settings.startup["propertyrandomizer-production"].value
rand_belt_speeds = settings.startup["propertyrandomizer-logistic"].value
rand_bots = settings.startup["propertyrandomizer-logistic"].value
rand_capsules = settings.startup["propertyrandomizer-military"].value
rand_crafting_machine_speed = settings.startup["propertyrandomizer-production"].value
rand_crafting_times = settings.startup["propertyrandomizer-crafting-times"].value
rand_electric_poles = settings.startup["propertyrandomizer-logistic"].value
rand_energy_values = settings.startup["propertyrandomizer-production"].value
rand_gun_damage_modifier = settings.startup["propertyrandomizer-military"].value
rand_gun_range = settings.startup["propertyrandomizer-military"].value
rand_gun_speed = settings.startup["propertyrandomizer-military"].value
rand_health_properties = settings.startup["propertyrandomizer-military"].value
rand_inserter_speed = settings.startup["propertyrandomizer-logistic"].value
rand_inserter_position = settings.startup["propertyrandomizer-inserter-position"].value
rand_inventory_properties = settings.startup["propertyrandomizer-storage"].value
rand_lab_speed = settings.startup["propertyrandomizer-production"].value
rand_machine_pollution = settings.startup["propertyrandomizer-production"].value
rand_mining_drill_dropoff = settings.startup["propertyrandomizer-mining-offsets"].value
rand_mining_speed = settings.startup["propertyrandomizer-production"].value
rand_module_effects = settings.startup["propertyrandomizer-production"].value
rand_module_slots = settings.startup["propertyrandomizer-production"].value
rand_offshore_pump_speed = settings.startup["propertyrandomizer-production"].value
rand_pump_pumping_speed = settings.startup["propertyrandomizer-logistic"].value
rand_radar = settings.startup["propertyrandomizer-logistic"].value
rand_storage_tank_capacity = settings.startup["propertyrandomizer-storage"].value
rand_tech_costs = settings.startup["propertyrandomizer-tech-costs"].value
rand_turret_attack_parameters = settings.startup["propertyrandomizer-military"].value
rand_underground_distance = settings.startup["propertyrandomizer-logistic"].value
rand_vehicles = settings.startup["propertyrandomizer-logistic"].value

-- Advanced randomizations

rand_armor_resistances = settings.startup["propertyrandomizer-military-advanced"].value
rand_character_corpse_time_to_live = settings.startup["propertyrandomizer-misc-properties"].value
rand_character_properties_midgame = settings.startup["propertyrandomizer-character-values-midgame"].value
rand_character_respawn_time = settings.startup["propertyrandomizer-misc-properties"].value
--rand_crafting_machine_productivity = settings.startup["propertyrandomizer-crafting-machine-productivity"].value
rand_entity_interaction_speed = settings.startup["propertyrandomizer-misc-properties"].value
rand_entity_sizes = settings.startup["propertyrandomizer-entity-sizes"].value
rand_equipment_grids = settings.startup["propertyrandomizer-military-advanced"].value
rand_equipment_properties = settings.startup["propertyrandomizer-military-advanced"].value
rand_equipment_shapes = settings.startup["propertyrandomizer-military-advanced"].value
rand_fuel_inventory_slots = settings.startup["propertyrandomizer-misc-properties"].value
rand_gate_opening_speed = settings.startup["propertyrandomizer-misc-properties"].value
rand_map_colors = settings.startup["propertyrandomizer-misc-properties"].value
rand_mining_drill_productivity = settings.startup["propertyrandomizer-mining-drill-productivity"].value
--rand_switch_projectiles = settings.startup["propertyrandomizer-switch-projectiles"].value
rand_tile_walking_speed_modifier = settings.startup["propertyrandomizer-misc-properties"].value
rand_tools = settings.startup["propertyrandomizer-misc-properties"].value -- TODO: make tools not impact research packs lol

-- Silly randomizations

-- Overrides

-- TODO: Bias override and other numerical ones

--blop.blop = nil

for override in string.gmatch(settings.startup["propertyrandomizer-custom-overrides"].value, "([^;]+)") do
  if string.find(override, ":") ~= nil then
    local equals_position = string.find(override, ":")
    if string.sub(override, 1, equals_position) == "randomize" then
    end
    if string.sub(override, 1, equals_position) == "no-randomize" then
    end
  end
end



-- General overrides first

--blop.blop = nil TODO: Overrides