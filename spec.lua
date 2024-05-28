require("randomize/master")

-- TODO: character-values midgame (later version)
-- TODO: mining-drill-productivity (later version)

-- TODO: Redo tag system
-- TODO: check lower_is_better on NEW properties
-- TODO: movement_slowdown_factor on gun

-- TODO: Balancing

-- Common randomizations...
--   attack_parameters:
--       * range
--       * cooldown (fire rate)
--       * damage_modifier

-- In the form {func = [function to do randomization], name = [user-friendly name of function], setting = [setting this is tied to], tags = [list of tags], default = [whether on by default], grouped = [whether it does all prototypes at once]}
local spec = {
    {
        func = rand.heat_buffer_max_transfer,
        name = "heat-transfer-rate",
        setting = "none"
    },
    {
        func = rand.heat_buffer_specific_heat,
        name = "specific-heat",
        setting = "none"
    },
    {
        func = rand.heat_buffer_temperatures,
        name = "heat-temperature",
        setting = "none"
    },
    { -- Technically could be applied to other entities, like roboports, but just applies to accumulators now
        func = rand.energy_source_electric_buffer_capacity,
        name = "electric-capacity",
        setting = {
            name = "propertyrandomizer-production-dropdown",
            min_val = "less"
        }
    },
    {
        func = rand.energy_source_electric_input_flow_limit,
        name = "electric-input-limit",
        setting = {
            name = "propertyrandomizer-production-dropdown",
            min_val = "default"
        }
    },
    {
        func = rand.energy_source_electric_output_flow_limit,
        name = "electric-output-limit",
        setting = {
            name = "propertyrandomizer-production-dropdown",
            min_val = "default"
        }
    },
    {
        func = rand.energy_source_electric_drain,
        name = "electric-min-consumption",
        setting = {
            name = "propertyrandomizer-production-dropdown",
            min_val = "more"
        }
    },
    {
        func = rand.energy_source_burner_effectivity,
        name = "burner-effectivity",
        setting = {
            name = "propertyrandomizer-production-dropdown",
            min_val = "more"
        }
    },
    { -- Not tested
        func = rand.energy_source_fluid_effectivity,
        name = "fluid-power-effectivity",
        setting = {
            name = "propertyrandomizer-production-dropdown",
            min_val = "more"
        }
    },
    { -- Not tested
        func = rand.energy_source_fluid_maximum_temperature,
        name = "fluid-power-max-temperature",
        setting = "none"
    },
    {
        func = rand.boiler_energy_consumption,
        name = "boiler-power",
        setting = {
            name = "propertyrandomizer-production-dropdown",
            min_val = "default"
        }
    },
    {
        func = rand.boiler_target_temperature,
        name = "boiler-temperature",
        setting = "none"
    },
    {
        func = rand.burner_generator_max_power_output,
        name = "burner-generator-production",
        setting = {
            name = "propertyrandomizer-production-dropdown",
            min_val = "less"
        }
    },
    { -- Not tested
        func = rand.electric_energy_interface_energy_production,
        name = "energy-interface-production",
        setting = "none"
    },
    { -- Not tested
        func = rand.electric_energy_interface_energy_usage,
        name = "energy-interface-consumption",
        setting = "none"
    },
    {
        func = rand.generator_effectivity,
        name = "fluid-generator-effectivity",
        setting = "none"
    },
    {
        func = rand.generator_fluid_usage,
        name = "fluid-generator-production",
        setting = {
            name = "propertyrandomizer-production-dropdown",
            min_val = "less"
        }
    },
    {
        func = rand.generator_maximum_temperature,
        name = "fluid-generator-max-temperature",
        setting = "none"
    }, -- Excluded: generator_max_production
    {
        func = rand.reactor_consumption,
        name = "reactor-consumption",
        setting = {
            name = "propertyrandomizer-production-dropdown",
            min_val = "less"
        }
    },
    {
        func = rand.solar_panel_production,
        name = "solar-panel-production",
        setting = {
            name = "propertyrandomizer-production-dropdown",
            min_val = "less"
        }
    },
    {
        func = rand.machine_energy_usage,
        name = "machine-energy-usage",
        setting = {
            name = "propertyrandomizer-production-dropdown",
            min_val = "less"
        }
    },
    {
        func = rand.equipment_energy_usage,
        name = "equipment-energy-usage",
        setting = {
            name = "propertyrandomizer-production-dropdown",
            min_val = "default"
        }
    },
    { -- Not tested
        func = rand.fluid_fuel_value,
        name = "fluid-fuel-value",
        setting = {
            name = "propertyrandomizer-production-dropdown",
            min_val = "default"
        }
    },
    {
        func = rand.fluid_heat_capacity,
        name = "fluid-heat-capacity",
        setting = "none"
    },
    {
        func = rand.item_fuel_value,
        name = "item-fuel-value",
        setting = {
            name = "propertyrandomizer-production-dropdown",
            min_val = "default"
        }
    },
    { -- This is technically two things: over time and movement, but we should do a group randomization of them
        func = rand.bot_energy,
        name = "bot-power",
        setting = {
            name = "propertyrandomizer-production-dropdown",
            min_val = "default"
        } -- TODO: Does bot energy have to be electric? Also in general how do we sense electric stuff versus not?
    },
    { -- This is technically two things: per rotation and per movement, but they should be group randomized
        func = rand.inserter_energy,
        name = "inserter-power",
        setting = {
            name = "propertyrandomizer-production-dropdown",
            min_val = "less"
        }
    },
    {
        func = rand.turret_energy_usage,
        name = "turret-energy-usage",
        setting = {
            name = "propertyrandomizer-production-dropdown",
            min_val = "default"
        }
    },
    {
        func = rand.beacon_supply_area_distance,
        name = "beacon-supply-area",
        setting = {
            name = "propertyrandomizer-production-dropdown",
            min_val = "default"
        }
    },
    {
        func = rand.beacon_distribution_effectivity,
        name = "beacon-effectivity",
        setting = {
            name = "propertyrandomizer-production-dropdown",
            min_val = "less"
        }
    },
    { -- NEW
        func = rand.beam_damage_interval,
        name = "beam-damage-interval",
        setting = {
            name = "propertyrandomizer-military-dropdown",
            min_val = "more"
        }
    },
    {
        func = rand.belt_speed,
        name = "belt-speed",
        setting = {
            name = "propertyrandomizer-logistic-dropdown",
            min_val = "less"
        },
        grouped = true
    },
    {
        func = rand.bot_speed,
        name = "bot-speed",
        setting = {
            name = "propertyrandomizer-logistic-dropdown",
            min_val = "default"
        }
    },
    {
        func = rand.car_rotation_speed,
        name = "car-turn-radius",
        setting = {
            name = "propertyrandomizer-logistic-dropdown",
            min_val = "default"
        }
    },
    {
        func = rand.character_corpse_time_to_live,
        name = "corpse-time",
        setting = {
            name = "propertyrandomizer-misc-properties-dropdown",
            min_val = "most"
        }
    },
    {
        func = rand.respawn_time,
        name = "respawn-time",
        setting = {
            name = "propertyrandomizer-misc-properties-dropdown",
            min_val = "more"
        }
    },
    {
        func = rand.crafting_machine_speed,
        name = "crafting-machine-speed",
        setting = {
            name = "propertyrandomizer-production-dropdown",
            min_val = "less"
        }
    },
    { -- TODO: Break up into wire distance and supply area
        -- TODO: Possibly make sure that medium poles or big poles at least have decent supply area so that life isn't too awful?
        func = rand.electric_poles,
        name = "electric-poles",
        setting = {
            name = "propertyrandomizer-logistic-dropdown",
            min_val = "less"
        },
        grouped = true
    },
    {
        func = rand.non_resource_mining_speeds,
        name = "non-resource-mining-speeds",
        setting = {
            name = "propertyrandomizer-misc-properties-dropdown",
            min_val = "most"
        }
    },
    { -- Not tested
        func = rand.repair_speed_modifiers,
        name = "repair-speed-modifiers",
        setting = {
            name = "propertyrandomizer-misc-properties-dropdown",
            min_val = "most"
        }
    },
    {
        func = rand.cliff_sizes,
        name = "cliff-sizes",
        setting = {
            name = "propertyrandomizer-misc-properties-dropdown",
            min_val = "more"
        }
    },
    {
        func = rand.fuel_inventory_slots,
        name = "fuel-slots",
        setting = {
            name = "propertyrandomizer-misc-properties-dropdown",
            min_val = "more"
        }
    },
    {
        func = rand.gate_opening_speed,
        name = "gate-speed",
        setting = {
            name = "propertyrandomizer-misc-properties-dropdown",
            min_val = "most"
        }
    },
    {
        func = rand.non_sensitive_max_health,
        name = "non-sensitive-max-health",
        setting = {
            name = "propertyrandomizer-misc-properties-dropdown",
            min_val = "more"
        }
    },
    {
        func = rand.sensitive_max_health,
        name = "sensitive-max-health",
        setting = {
            name = "propertyrandomizer-military-dropdown",
            min_val = "more"
        }
    },
    {
        func = rand.inserter_offsets,
        name = "inserter-offsets",
        setting = "propertyrandomizer-inserter-position"
    },
    {
        func = rand.inserter_speed,
        name = "inserter-speed",
        setting = {
            name = "propertyrandomizer-logistic-dropdown",
            min_val = "less"
        }
    },
    {
        func = rand.inventory_sizes,
        name = "inventory-sizes", -- TODO: Randomize small/big inventories separately
        setting = "propertyrandomizer-storage"
    },
    {
        func = rand.lab_research_speed,
        name = "research-speed",
        setting = {
            name = "propertyrandomizer-production-dropdown",
            min_val = "default"
        }
    },
    {
        func = rand.landmine_damage,
        name = "landmine-damage",
        setting = {
            name = "propertyrandomizer-military-dropdown",
            min_val = "less"
        }
    },
    {
        func = rand.landmine_effect_radius,
        name = "landmine-effect-radius",
        setting = {
            name = "propertyrandomizer-military-dropdown",
            min_val = "more"
        }
    },
    {
        func = rand.landmine_trigger_radius,
        name = "landmine-trigger-radius",
        setting = {
            name = "propertyrandomizer-military-dropdown",
            min_val = "more"
        }
    },
    {
        func = rand.landmine_timeout,
        name = "landmine-timeout",
        setting = {
            name = "propertyrandomizer-military-dropdown",
            min_val = "more"
        }
    },
    {
        func = rand.machine_pollution,
        name = "machine-pollution",
        setting = {
            name = "propertyrandomizer-military-dropdown",
            min_val = "default"
        }
    },
    {
        func = rand.mining_drill_dropoff_location,
        name = "drill-offsets",
        setting = "propertyrandomizer-mining-offsets" -- TODO: Bring back this as its own property
    },
    {
        func = rand.mining_results_tree_rock,
        name = "tree-rock-mining-results",
        setting = {
            name = "propertyrandomizer-misc-properties-dropdown",
            min_val = "more"
        }
    },
    {
        func = rand.mining_speeds,
        name = "mining-speed",
        setting = {
            name = "propertyrandomizer-production-dropdown",
            min_val = "less"
        }
    },
    {
        func = rand.module_slots,
        name = "module-slots",
        setting = {
            name = "propertyrandomizer-production-dropdown",
            min_val = "default"
        }
    },
    {
        func = rand.offshore_pump_speed,
        name = "offshore-pump-speed",
        setting = {
            name = "propertyrandomizer-production-dropdown",
            min_val = "less"
        }
    },
    {
        func = rand.pump_pumping_speed,
        name = "pump-speed",
        setting = {
            name = "propertyrandomizer-logistic-dropdown",
            min_val = "default"
        } -- TODO: Add fluid as a tag to other places?
    },
    {
        func = rand.radar_search_area,
        name = "radar-search-area",
        setting = {
            name = "propertyrandomizer-misc-properties-dropdown",
            min_val = "more"
        }
    },
    {
        func = rand.radar_reveal_area,
        name = "radar-reveal-area",
        setting = {
            name = "propertyrandomizer-misc-properties-dropdown",
            min_val = "more"
        }
    },
    {
        func = rand.reactor_neighbour_bonus,
        name = "reactor-bonus",
        setting = {
            name = "propertyrandomizer-production-dropdown",
            min_val = "default"
        }
    },
    {
        func = rand.roboport_inventory,
        name = "roboport-inventory",
        setting = {
            name = "propertyrandomizer-misc-properties-dropdown",
            min_val = "more"
        }
    },
    {
        func = rand.roboport_charging_energy,
        name = "roboport-charging-speed",
        setting = {
            name = "propertyrandomizer-logistic-dropdown",
            min_val = "default"
        }
    },
    {
        func = rand.roboport_charging_station_count, -- TODO: Make logistic advanced in spreadsheet
        name = "roboport-charging-count",
        setting = {
            name = "propertyrandomizer-logistic-dropdown",
            min_val = "more"
        }
    },
    {
        func = rand.roboport_logistic_radius,
        name = "roboport-logistic-radius",
        setting = {
            name = "propertyrandomizer-logistic-dropdown",
            min_val = "default"
        }
    },
    {
        func = rand.roboport_construction_radius,
        name = "roboport-construction-radius",
        setting = {
            name = "propertyrandomizer-logistic-dropdown",
            min_val = "default"
        }
    },
    {
        -- TODO: Make sure this doesn't randomize for rockets needing one part, since that may end up being really unbalanced in situations
        func = rand.rocket_parts_required,
        name = "rocket-parts-required",
        setting = {
            name = "propertyrandomizer-production-dropdown",
            min_val = "default"
        }
    },
    {
        func = rand.rocket_silo_launch_time,
        name = "rocket-time-to-launch",
        setting = {
            name = "propertyrandomizer-misc-properties-dropdown",
            min_val = "most"
        }
    },
    {
        func = rand.storage_tank_capacity,
        name = "tank-capacity",
        setting = "propertyrandomizer-storage"
    }, -- TODO: Turret
    {
        func = rand.turret_damage_modifier,
        name = "turret-damage-modifier",
        setting = {
            name = "propertyrandomizer-military-dropdown",
            min_val = "default"
        }
    },
    {
        func = rand.turret_min_attack_distance,
        name = "turret-min-attack-distance",
        setting = {
            name = "propertyrandomizer-military-dropdown",
            min_val = "more"
        }
    },
    {
        -- TODO: Separate this out more into worm and player turret range
        func = rand.turret_range,
        name = "turret-range",
        setting = {
            name = "propertyrandomizer-military-dropdown",
            min_val = "more"
        }
    },
    {
    -- TODO: This affects car "turrets" as well, but I think that should be its own thing
        func = rand.turret_rotation_speed,
        name = "turret-rotation-speed",
        setting = {
            name = "propertyrandomizer-military-dropdown",
            min_val = "more"
        }
    },
    {
        func = rand.turret_shooting_speed,
        name = "turret-shooting-speed",
        setting = {
            name = "propertyrandomizer-military-dropdown",
            min_val = "default"
        }
    },
    {
        func = rand.underground_belt_distance,
        name = "underground-belt-distance",
        setting = {
            name = "propertyrandomizer-logistic-dropdown",
            min_val = "less"
        }
    },
    {
        func = rand.pipe_to_ground_distance,
        name = "pipe-to-ground-distance",
        setting = {
            name = "propertyrandomizer-logistic-dropdown",
            min_val = "less"
        }
    },
    {
        func = rand.unit_attack_speed,
        name = "unit-attack-speed",
        setting = {
            name = "propertyrandomizer-military-dropdown",
            min_val = "more"
        }
    },
    { -- Trying this out as default, may have to change back
        func = rand.unit_melee_damage,
        name = "unit-melee-damage",
        setting = {
            name = "propertyrandomizer-military-dropdown",
            min_val = "default"
        }
    },
    {
        func = rand.unit_movement_speed,
        name = "unit-movement-speed",
        setting = {
            name = "propertyrandomizer-military-dropdown",
            min_val = "more"
        }
    },
    {
        func = rand.unit_pollution_to_join_attack,
        name = "unit-pollution-to-attack",
        setting = {
            name = "propertyrandomizer-military-dropdown",
            min_val = "more"
        }
    },
    {
        func = rand.unit_range,
        name = "unit-range",
        setting = {
            name = "propertyrandomizer-military-dropdown",
            min_val = "more"
        }
    },
    {
        func = rand.unit_vision_distance,
        name = "unit-vision-distance",
        setting = {
            name = "propertyrandomizer-military-dropdown",
            min_val = "more"
        }
    },
    -- Excluded: Unit turn radius (it's just visual)
    -- Excluded: Unit following time/distance (I don't think they'll be noticed)
    {
        func = rand.vehicle_crash_damage,
        name = "crash-damage",
        setting = {
            name = "propertyrandomizer-misc-properties-dropdown",
            min_val = "most"
        }
    },
    {
        func = rand.vehicle_power,
        name = "vehicle-speed",
        setting = {
            name = "propertyrandomizer-logistic-dropdown",
            min_val = "less"
        }
    },
    {
        func = rand.icons,
        name = "icons",
        setting = "none", -- TODO: Separate this out more
        grouped = true
    },
    -- TODO: Other icon randomization!
    {
        -- TODO: Remove compilatron images (in general only look for things that can be spawned by an enemy spawner)
        func = rand.biter_images,
        name = "unit-images",
        setting = "none",
        grouped = true
    },
    {
        func = rand.recipe_groups,
        name = "recipe-order",
        setting = "none",
        grouped = true
    },
    -- TODO: Implement
    { -- (not implemented though)
        func = rand.capsule_healing,
        name = "capsule-healing",
        setting = {
            name = "propertyrandomizer-military-dropdown",
            min_val = "default"
        }
    },
    {
        -- TODO: Fix visualization circle
        func = rand.capsule_throw_range,
        name = "capsule-throw-range",
        setting = {
            name = "propertyrandomizer-military-dropdown",
            min_val = "more"
        }
    },
    {
        func = rand.ammo_damage,
        name = "ammo-damage",
        setting = {
            name = "propertyrandomizer-military-dropdown",
            min_val = "less"
        }
    },
    {
        func = rand.ammo_magazine_size,
        name = "magazine-size",
        setting = {
            name = "propertyrandomizer-military-dropdown",
            min_val = "more"
        }
    },
    { -- TODO: Check to see if anything else from attack_parameters makes sense to add to gun
        func = rand.gun_damage_modifier,
        name = "gun-damage-modifier",
        setting = {
            name = "propertyrandomizer-military-dropdown",
            min_val = "default"
        }
    },
    {
        func = rand.gun_movement_slowdown_factor,
        name = "gun-shooting-slowdown",
        setting = "none"
    },
    {
        func = rand.gun_range,
        name = "gun-range",
        setting = {
            name = "propertyrandomizer-military-dropdown",
            min_val = "default"
        }
    },
    {
        func = rand.gun_speed,
        name = "gun-speed",
        setting = {
            name = "propertyrandomizer-military-dropdown",
            min_val = "less"
        }
    },
    {
        func = rand.armor_inventory_bonus,
        name = "armor-inventory-bonus",
        setting = "propertyrandomizer-storage"
    },
    {
        func = rand.item_stack_sizes,
        name = "stack-sizes",
        setting = "propertyrandomizer-storage"
    },
    {
        func = rand.module_effects,
        name = "module-effects",
        setting = {
            name = "propertyrandomizer-production-dropdown",
            min_val = "default"
        }
    },
    {
        func = rand.repair_tool_speeds,
        name = "repair-speeds",
        setting = {
            name = "propertyrandomizer-misc-properties-dropdown",
            min_val = "more"
        }
    },
    {
        func = rand.achievements,
        name = "achievements",
        setting = {
            name = "propertyrandomizer-misc-properties-dropdown",
            min_val = "more"
        },
        grouped = true
    },
    {
        func = rand.equipment_active_defense_cooldown,
        name = "active-defense-equipment-fire-rate",
        setting = {
            name = "propertyrandomizer-military-dropdown",
            min_val = "default"
        }
    },
    {
        func = rand.equipment_active_defense_damage,
        name = "active-defense-equipment-damage",
        setting = {
            name = "propertyrandomizer-military-dropdown",
            min_val = "less"
        }
    },
    -- The electric defense actually creates a projectile rather than being AOE based directly, so this doesn't work as intended
    -- TODO: Fix once I come up with a more general way to deal with attack parameters
    --[[{
        func = rand.equipment_active_defense_radius,
        name = "active-defense-equipment-effect-radius",
        setting = "propertyrandomizer-military"
    },]]
    {
        func = rand.equipment_active_defense_range,
        name = "active-defense-equipment-range",
        setting = {
            name = "propertyrandomizer-military-dropdown",
            min_val = "more"
        }
    },
    {
        func = rand.equipment_battery_buffer,
        name = "personal-battery-buffer",
        setting = {
            name = "propertyrandomizer-production-dropdown",
            min_val = "default"
        } -- TODO: Change other non-military equipment to be more in line with production setting (even if it is technically more military based)
    },
    {
        func = rand.equipment_battery_input_limit,
        name = "personal-battery-input-limit",
        setting = "none"
    },
    {
        func = rand.equipment_battery_output_limit,
        name = "personal-battery-output-limit",
        setting = "none"
    },
    {
        func = rand.equipment_energy_shield_max_shield,
        name = "energy-shield-equipment-max-shield",
        setting = {
            name = "propertyrandomizer-military-dropdown",
            min_val = "less"
        }
    }, -- energy-shield power usage is covered by equipment power usage
    {
        func = rand.equipment_generator_power,
        name = "generator-equipment-power-production",
        setting = {
            name = "propertyrandomizer-production-dropdown",
            min_val = "default"
        }
    },
    {
        func = rand.equipment_movement_bonus,
        name = "movement-equipment-bonus",
        setting = {
            name = "propertyrandomizer-logistic-dropdown",
            min_val = "default"
        } -- Since it just has to do with moving around, I'm making it logistics
    },
    {
        func = rand.equipment_personal_roboport_charging_speed,
        name = "personal-roboport-charging-speed",
        setting = {
            name = "propertyrandomizer-logistic-dropdown",
            min_val = "default"
        }
    },
    {
        func = rand.equipment_personal_roboport_charging_station_count,
        name = "personal-roboport-max-charging-robots",
        setting = {
            name = "propertyrandomizer-logistic-dropdown",
            min_val = "more"
        } -- TODO: Make advanced logistic setting in spreadsheet
    },
    {
        func = rand.equipment_personal_roboport_construction_radius,
        name = "personal-roboport-construction-radius",
        setting = {
            name = "propertyrandomizer-logistic-dropdown",
            min_val = "default"
        }
    },
    {
        func = rand.equipment_personal_roboport_max_robots,
        name = "personal-roboport-max-robots",
        setting = {
            name = "propertyrandomizer-logistic-dropdown",
            min_val = "default"
        }
    },
    {
        func = rand.equipment_solar_panel_production,
        name = "solar-panel-equipment-power-production",
        setting = {
            name = "propertyrandomizer-production-dropdown",
            min_val = "default"
        }
    },
    {
        func = rand.equipment_grid_sizes, -- TODO: Shouldn't this specify sizes in the name?
        name = "equipment-grid-sizes",
        setting = {
            name = "propertyrandomizer-military-dropdown",
            min_val = "default"
        }
    }, -- TODO: equipment shapes
    {
        func = rand.fluid_emissions_multiplier,
        name = "fluid-emissions-multiplier",
        setting = {
            name = "propertyrandomizer-military-dropdown",
            min_val = "default"
        }
    },
    {
        func = rand.icon_shifts,
        name = "icon-shifts",
        setting = {
            name = "propertyrandomizer-misc-properties-dropdown",
            min_val = "most"
        },
        grouped = true
    },
    {
        func = rand.map_colors,
        name = "map-colors",
        setting = {
            name = "propertyrandomizer-misc-properties-dropdown",
            min_val = "more"
        }
    },
    {
        func = rand.projectile_damage,
        name = "projectile-damage",
        setting = {
            name = "propertyrandomizer-military-dropdown",
            min_val = "less"
        }
    }, -- TODO: Utility constants properties
    {
        func = rand.sounds,
        name = "sounds",
        setting = "none",
        grouped = true
    },
    { -- TODO: Stickers
        func = rand.tile_walking_speed_modifier,
        name = "tile-speeds",
        setting = {
            name = "propertyrandomizer-misc-properties-dropdown",
            min_val = "most"
        },
        grouped = true
    },
    {
        func = rand.utility_constants_inventory_widths,
        name = "inventory-widths",
        setting = {
            name = "propertyrandomizer-misc-properties-dropdown",
            min_val = "most"
        },
        grouped = true
    },
    {
        -- Currently just does some train wait times
        func = rand.utility_constants_misc,
        name = "misc-constants",
        setting = {
            name = "propertyrandomizer-misc-properties-dropdown",
            min_val = "most"
        },
        grouped = true
    }, -- TODO: Utility constants map colors
    {
        func = rand.crafting_times,
        name = "recipe-times",
        setting = "propertyrandomizer-crafting-times"
    },
    {
        func = rand.tech_costs,
        name = "tech-costs",
        setting = {
            name = "propertyrandomizer-production-dropdown",
            min_val = "default"
        }
    },
    {
        func = rand.tech_times,
        name = "tech-times",
        setting = {
            name = "propertyrandomizer-production-dropdown",
            min_val = "default"
        }
    },
    {
        func = "control",
        name = "character-values",
        setting = "propertyrandomizer-character-values-midgame"
    },
    {
        func = "control",
        name = "daytime-cycle",
        setting = "none"
    },
    --[[ Doesn't work
        { -- NEW
        func = "control",
        name = "movement",
        setting = "none"
    }]]
}

-- TODO: Hardcode "all" tag which applies to everything
-- Specificity:
--     0  = Very broad categories like "logistic" that include types of gameplay
--     10 = More specific categories like "power" that include whole gameplay mechanics
--     20 = Sub-mechanics categories like "electric-power"
--     30 = "Solutions" or subareas to these sub-mechanics like "nuclear-power"
--     40 = Specific ways of looking at these mechanics or aspects of them like "nuclear-power-heat-transfer" (not that this is even a tag right now)
--[[gather_randomizations.tag_spec = {
    {
        name = "logistic",
        specificity = 0,
        parents = {}
    },
        {
            name = "transport",
            specificity = 10,
            parents = {"logistic"}
        },
            {
                name = "material-transport",
                specificity = 20,
                parents = {"transport"}
            },
            {
                name = "player-transport",
                specificity = 20,
                parents = {"player", "transport"}
            },
                {
                    name = "personal-vehicle",
                    specificity = 30,
                    parents = {"player-transport"}
                },
            {
                name = "transport-speed",
                specificity = 20,
                parents = {"transport"}
            },
        {
            name = "positioning",
            specificity = 10,
            parents = {"logistic"}
        },
                {
                    name = "underground-distance",
                    specificity = 30,
                    parents = {"positioning"}
                },
                {
                    name = "offsets",
                    specificity = 30,
                    parents = {"positioning"}
                },
        {
            name = "storage",
            specificity = 10,
            parents = {"logistics"}
        },
            {
                name = "fluid-storage",
                specificity = 20,
                parents = {"storage"}
            },
            {
                name = "inventory",
                specificity = 20,
                parents = {"storage"}
            },
                {
                    name = "inventory-slots",
                    specificity = 30,
                    parents = {"inventory"}
                },
                    {
                        name = "special_inventory_slots",
                        specificity = 40,
                        parents = {"inventory-slots"}
                    },
        -- Tied to logistic
            {
                name = "belt",
                specificity = 20,
                parents = {"logistic"}
            },
    {
        name = "production",
        specificity = 0,
        parents = {}
    },
        {
            name = "power",
            specificity = 10,
            parents = {"production"}
        },
            {
                name = "burner-power",
                specificity = 20,
                parents = {"power"}
            },
            {
                name = "electric-power",
                specificity = 20,
                parents = {"power"}
            },
            {
                name = "fluid-power",
                specificity = 20,
                parents = {"fluids", "power"}
            },
            {
                name = "heat-power",
                specificity = 20,
                parents = {"power"}
            },
            {
                name = "power-production",
                specificity = 20,
                parents = {"power"}
            },
            {
                name = "power-consumption",
                specificity = 20,
                parents = {"power"}
            },
                    {
                        name = "inserter-power-consumption",
                        specificity = 40,
                        parents = {"power-consumption"}
                    },
        {
            name = "production-speed",
            specificity = 10,
            parents = {"production"}
        },
    {
        name = "military",
        specificity = 0,
        parents = {}
    },
        {
            name = "pollution",
            specificity = 10,
            parents = {"military", "production"}
        },
            {
                name = "pollution-consumption",
                specificity = 20,
                parents = {"pollution"}
            },
            {
                name = "pollution-production",
                specificity = 20,
                parents = {"pollution"}
            },
    -- Not tied to a specific major category
            {
                name = "bots",
                specificity = 20,
                parents = {"logistic", "military"}
            },
                {
                    name = "bot-energy",
                    specificity = 30,
                    parents = {"power", "bots"}
                },
                    {
                        name = "bot-energy-usage",
                        specificity = 40,
                        parents = {"bot-energy"}
                    },
                    {
                        name = "bot-charging",
                        specificity = 40,
                        parents = {"bot-energy"}
                    },
                {
                    name = "bot-speed",
                    specificity = 30,
                    parents = {"bots"}
                },
        {
            name = "player",
            specificity = 10
        },
        {
            name = "fluids",
            specificity = 10
        },
            {
                name = "temperature",
                specificity = 20
            }
}]]

-- List of tables with signature {randomization = [function], blacklist = [table of protoype --> bool of whether blacklisted]}
-- WIP

-- Verify spec
for randomization_num, randomization in pairs(spec) do
    if randomization.name == nil then
        error("name undefined for randomization number " .. randomization_num)
    end
    if randomization.func == nil then
        error("func undefined for randomization named " .. randomization.name)
    end
    if randomization.setting == nil then
        error("setting undefined for randomization named " .. randomization.name)
    end
    if randomization.tags == nil then
        --error("tags undefined for randomization named " .. randomization.name)
    end
    if randomization.default == nil then
        --error("default undefined for randomization named " .. randomization.name)
    end
end

-- Low level groupings that only contain individual randomizations
local spec_groups = { -- TODO
    ["landmines"] = {
        "landmine-damage",
        "landmine-effect-radius",
        "landmine-trigger-radius",
        "landmine-timeout"
    },
    ["tech"] = {
        "tech-costs",
        "tech-times"
    },
    ["visual"] = {
        "icons",
        "map-colors"
    }
}

-- Higher level groupings that can also contain groups
local spec_categories = {
}

return spec, spec_groups, spec_categories