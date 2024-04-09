blop.blop = nil -- So, reformat things, then have the functions gather the prototypes themselves

blop.blop = nil -- Make these files return things

require("randomize/master")

local gather_randomizations = {}

blop.blop = nil -- Separate randomization functions more so these all make sense

blop.blop = nil -- Add tags for randomizations and names for configs

-- In the form {func = [function to do randomization], name = [user-friendly name of function], tags = [list of tags]}
-- Later will be populated with list of allowed prototypes to randomize
gather_randomizations.randomization_spec = {
    {
        func = rand.heat_buffer_max_transfer,
        name = "heat-transfer-rate",
        tags = {"heat", "power"}
    },
    {
        func = rand.heat_buffer_specific_heat,
        name = "specific-heat",
        tags = {"heat", "power"}
    },
    {
        func = rand.heat_buffer_temperatures,
        name = "heat-temperature",
        tags = {"temperature", "heat", "power"}
    },
    { -- Technically could be applied to other entities, like roboports, but just applies to accumulators now
        func = rand.energy_source_electric_buffer_capacity,
        name = "electric-capacity"
        tags = {"electric", "power"}
    },
    {
        func = rand.energy_source_electric_input_flow_limit,
        name = "electric-input-limit"
        tags = {"electric", "power"}
    },
    {
        func = rand.energy_source_electric_output_flow_limit,
        name = "electric-output-limit",
        tags = {"electric", "power"}
    },
    {
        func = rand.energy_source_burner_effectivity,
        name = "burner-effectivity",
        tags = {"burner", "power"}
    },
    {
        func = rand.energy_source_fluid_effectivity,
        name = "fluid-power-effectivity",
        tags = {"fluid-power", "power"}
    },
    {
        func = rand.energy_source_fluid_maximum_temperature,
        name = "fluid-power-max-temperature",
        tags = {"temperature", "fluid-power", "power"}
    },
    {
        func = energy_randomizer.randomize_boiler_energy_consumption,
        name = "boiler-power",
        tags = {"power"}
    },
    {
        func = energy_randomizer.randomize_boiler_target_temperature,
        name = "boiler-temperature",
        tags = {"temperature", "power"}
    },
    {
        func = energy_randomizer.randomize_burner_generator_max_power_output,
        name = "burner-generator-production",
        tags = {"power-production", "burner-power", "electric-power", "power"}
    },
    {
        func = energy_randomizer.randomize_electric_energy_interface_energy_production,
        name = "energy-interface-production",
        tags = {"power-production", "electric", "power"}
    },
    {
        func = energy_randomizer.randomize_electric_energy_interface_energy_usage,
        name = "energy-interface-consumption",
        tags = {"power-consumption", "electric", "power"}
    },
    {
        func = energy_randomizer.randomize_generator_effectivity,
        name = "generator-effectivity",
        tags = {"power-production", "electric", "power"}
    },
    {
        func = energy_randomizer.randomize_generator_fluid_usage,
        name = "fluid-generator-production",
        tags = {"power-production", "electric", "power"}
    },
    {
        func = energy_randomizer.randomize_generator_maximum_temperature,
        name = "fluid-generator-max-temperature",
        tags = {"power-production", "temperature", "power"}
    }, -- Excluded: generator_max_production
    {
        func = energy_randomizer.randomize_reactor_consumption
        name = "reactor-consumption",
        tags = {"power-production", "power"}
    },
    {
        func = energy_randomizer.randomize_solar_panel_production
        name = "solar-panel-production",
        tags = {"power-production", "electric", "power"}
    },
    {
        func = energy_randomizer.randomize_machine_energy_usage
        name = "machine-energy-usage",
        tags = {"power-consumption", "power"}
    },
    {
        func = energy_randomizer.randomize_equipment_energy_usage
        name = "equipment-energy-usage",
        tags = {"equipment"}
    },
    {
        func = energy_randomizer.randomize_fluid_fuel_value,
        name = "fluid-fuel-value",
        tags = {"power"}
    }, -- Excluded: fluid heat capacity
    {
        func = energy_randomizer.randomize_item_fuel_value,
        name = "item-fuel-value",
        tags = {"power"}
    },
    { -- This is technically two things: over time and movement, but we should do a group randomization of them
        func = energy_randomizer.randomize_bot_energy_per_tick
        name = "bot-power",
        tags = {"power-consumption", "bots", "power"} -- TODO: Does bot energy have to be electric? Also in general how do we sense electric stuff versus not?
    },
    { -- This is technically two things: per rotation and per movement, but they should be group randomized
        func = energy_randomizer.randomize_inserter_energy_per_movement,
        name = "inserter-power",
        tags = {"power-consumption", "power"}
    },
    {
        func = energy_randomizer.randomize_energy_shield_energy_per_shield,
        name = "energy-shield-power",
        tags = {"equipment"}
    },
    {
        func = entity_randomizer.randomize_beacon_supply_area_distance,
        name = "beacon-supply-area",
        tags = {"modules", "production"}
    },
    {
        func = entity_randomizer.randomize_beacon_distribution_effectivity,
        name = "beacon-effectivity",
        tags = {"modules", "production"}
    },
    {
        func = entity_randomizer.randomize_belt_speed,
        name = "belt-speed",
        tags = {"logistic"}
    },
    {
        func = entity_randomizer.randomize_bot_speed,
        name = "bot-speed",
        tags = {"bots", "logistic"}
    },
    {
        func = entity_randomizer.randomize_car_rotation_speed,
        name = "car-turn-radius",
        tags = {"vehicle"}
    },
    {
        func = entity_randomizer.randomize_character_corpse_time_to_live,
        name = "corpse-time",
        tags = {"misc"}
    },
    {
        func = entity_randomizer.randomize_respawn_time,
        name = "respawn-time",
        tags = {"misc"}
    },
    {
        func = entity_randomizer.randomize_crafting_machine_speeds,
        name = "crafting-machine-speeds",
        tags = {"production"}
    },
    {
        func = entity_randomizer.randomize_electric_pole_supply_area
        name = "electric-pole-supply-area",
        tags = {"logistic"}
    },
    {
        func = entity_randomizer.randomize_electric_pole_wire_distance
        name = "electric-pole-wire-distance",
        tags = {"logistic"}
    },
    {
        func = entity_randomizer.randomize_non_resource_mining_speeds,
        name = "non-resource-mining-speeds",
        tags = {"misc"}
    },
    {
        func = entity_randomizer.randomize_repair_speed_modifiers,
        name = "repair-speed-modifiers",
        tags = {"misc"}
    },
    {
        func = entity_randomizer.randomize_cliff_sizes,
        name = "cliff-sizes",
        tags = {"sizes"}
    },
    {
        func = entity_randomizer.randomize_fuel_inventory_slots,
        name = "fuel-slots",
        tags = {"inventory-slots", "storage"}
    },
    {
        func = entity_randomizer.randomize_gate_opening_speed,
        name = "gate-speed",
        tags = {"misc"}
    },
    {
        func = entity_randomizer.randomize_non_sensitive_max_health,
        name = "non-sensitive-max-health",
        tags = {"misc"}
    },
    {
        func = entity_randomizer.randomize_sensitive_max_health,
        name = "sensitive-max-health",
        tags = {"military"}
    },
    {
        func = entity_randomizer.randomize_inserter_offsets,
        name = "inserter-offsets",
        tags = {"logistic"}
    },
    {
        func = entity_randomizer.randomize_inserter_speed,
        name = "inserter-speed",
        tags = {"logistic-speed", "logistic"}
    },
    {
        func = entity_randomizer.randomize_inventory_sizes,
        name = "inventory-sizes", -- TODO: Randomize small/big inventories separately
        tags = {"inventory-slots", "storage"}
    },
    {
        func = entity_randomizer.randomize_lab_research_speed,
        name = "research-speed",
        tags = {"production"}
    },
    {
        func = entity_randomizer.randomize_machine_pollution,
        name = "machine-pollution",
        tags = {"production", "military"}
    },
    {
        func = entity_randomizer.randomize_mining_drill_dropoff_location,
        name = "drill-offsets",
        tags = {"logistic"}
    },
    {
        func = entity_randomizer.randomize_mining_speeds,
        name = "mining-speed",
        tags = {"production"}
    },
    {
        func = entity_randomizer.randomize_module_slots,
        name = "module-slots",
        tags = {"modules", "production"}
    },
    {
        func = entitiy_randomizer.randomize_offshore_pump_speed,
        name = "offshore-pump-speed",
        tags = {"production"}
    },
    {
        func = entity_randomizer.randomize_pump_pumping_speed,
        name = "pump-speed",
        tags = {"fluid", "logistic"} -- TODO: Add fluid as a tag to other places?
    },
    {
        func = entity_randomizer.randomize_radar_search_area,
        name = "radar-search-area",
        tags = {"misc"}
    },
    {
        func = entity_randomizer.randomize_radar_reveal_area,
        name = "radar-reveal-area",
        tags = {"misc"}
    },
    {
        func = entity_randomizer.randomize_reactor_neighbour_bonus,
        name = "reactor_bonus",
        tags = {"power-production", "power"}
    }, -- Excluded: roboport inventory slots for repair packs/bots
    {
        func = entity_randomizer.randomize_roboport_charging_energy,
        name = "roboport-charging-speed",
        tags = {"bots", "power"}
    },
    {
        func = entity_randomizer.randomize_roboport_charging_station_count,
        name = "roboport-charging-count",
        tags = {"bots", "power"}
    },
    {
        func = entity_randomizer.randomize_roboport_logistic_radius,
        name = "roboport-logistic-radius",
        tags = {"bots", "logistic"}
    },
    {
        func = entity_randomizer.randomize_roboport_construction_radius,
        name = "roboport-construction-radius",
        tags = {"bots"}
    },
    {
        func = entity_randomizer.randomize_storage_tank_capacity,
        name = "tank-capacity",
        tags = {"fluid", "storage"}
    },
    {
        func = entity_randomizer.randomize_underground_belt_distance,
        name = "underground-belt-distance",
        tags = {"logistic"}
    },
    {
        func = entity_randomizer.randomize_vehicle_crash_damage,
        name = "crash-damage",
        tags = {"vehicle"}
    },
    {
        func = entity_randomizer.randomize_vehicle_power,
        name = "vehicle-speed",
        tags = {"vehicle", "player-transport"}
    },
    {
        func = icon_randomizer.randomize_icons,
        name = "icons",
        tags = {"visual"} -- TODO: Separate this out more
    },
    {
        func = item_randomizer.randomize_cliff_explosive_throw_range,
        name = "cliff-explosive-throw-range",
        tags = {"misc"}
    },
    {
        func = item_randomizer.randomize_ammo_magazine_size,
        name = "magazine-size",
        tags = {"military"}
    },
    {
        func = item_randomizer.randomize_gun_damage_modifier,
        name = "gun-damage-modifier",
        tags = {"military"}
    },
    {
        func = item_randomizer.randomize_gun_range,
        name = "gun-range",
        tags = {"military-range", "military"}
    },
    {
        func = item_randomizer.randomize_gun_speed,
        name = "gun-speed",
        tags = {"military-speed", "military"}
    },
    {
        func = item_randomizer.randomize_item_stack_sizes,
        name = "stack-sizes",
        tags = {"inventory", "storage", "logistic"}
    },
    {
        func = item_randomizer.randomize_module_effects,
        name = "module-effects",
        tags = {"modules", "production"}
    },
    {
        func = item_randomizer.randomizer_repair_tool_speeds,
        name = "repair-speeds",
        tags = {"military", "misc"}
    },
    {
        func = misc_randomizer.randomize_sounds,
        name = "sounds",
        tags = {}
    },
    {
        func = misc_randomizer.randomize_equipment_grids,
        name = "equipment-grids",
        tags = {"equipment", "military"}
    }, -- TODO: equipment shapes and properties
    {
        func = misc_randomizer.randomize_fluid_emissions_multiplier,
        name = "fluid-emissions-multiplier",
        tags = {"fluid"}
    },
    {
        func = misc_randomizer.randomize_map_colors,
        name = "map-colors",
        tags = {"visual"}
    },
    {
        func = misc_randomizer.randomize_projectile_damage,
        name = "projectile-damage",
        tags = {"military"}
    }, -- TODO: Utility constants properties
    {
        func = misc_randomizer.randomize_tile_walking_speed_modifier,
        name = "tile-speeds",
        tags = {"player-transport", "misc"}
    },
    {
        func = recipe_randomizer.randomize_crafting_times,
        name = "recipe-times",
        tags = {"production"}
    },
    {
        func = technology_randomizer.randomize_tech_costs,
        name = "tech-costs",
        tags = {"production"}
    },
    {
        func = technology_randomizer.randomize_tech_times,
        name = "tech-times",
        tags = {"tech", "production-speed", "production"}
    } -- TODO: util-randomizer (probably needs a rewrite of the file)
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
gather_randomizations.list_to_randomize = {}

return gather_randomizations