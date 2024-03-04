blop.blop = nil -- So, reformat things, then have the functions gather the prototypes themselves

blop.blop = nil -- Make these files return things

local energy_randomizer = require("randomizer-functions/energy-randomizer")
local entity_randomizer = require("randomizer-functions/entity-randomizer")
local item_randomizer = require("randomizer-functions/item-randomizer")
local locale_randomizer = require("randomizer-functions/locale-randomizer") -- Currently TODO
local misc_randomizer = require("randomizer-functions/misc-randomizer")
local recipe_randomizer = require("randomizer-functions/recipe-randomizer")
local technology_randomizer = require("randomizer-functions/technology-randomizer")

local gather_randomizations = {}

blop.blop = nil -- Separate randomization functions more so these all make sense

blop.blop = nil -- Add tags for randomizations and names for configs

-- In the form {func = [function to do randomization], name = [user-friendly name of function], tags = [list of tags]}
-- Later will be populated with list of allowed prototypes to randomize
gather_randomizations.randomization_spec = {
    {
        func = energy_randomizer.randomize_heat_buffer_max_transfer,
        name = "heat-buffer-transfer-rate",
        tags = {"heat", "power"}
    },
    {
        func = energy_randomizer.randomize_heat_buffer_specific_heat,
        name = "heat-buffer-specific-heat",
        tags = {"specific-heat", "heat", "power"}
    },
    {
        func = energy_randomizer.randomize_heat_buffer_temperatures, -- TODO: Separate this out more into max temperature etc.
        name = "heat-buffer-temperature",
        tags = {"temperature", "heat", "power"}
    },
    {
        func = energy_randomizer.randomize_energy_source_electric_buffer_capacity,
        name = "electric-buffer-capacity"
        tags = {"electric-buffer", "electric", "power"}
    },
    {
        func = energy_randomizer.randomize_energy_source_electric_input_flow_limit,
        name = "electric-buffer-input-limit"
        tags = {"electric-buffer", "electric", "power"}
    },
    {
        func = energy_randomizer.randomize_energy_source_electric_output_flow_limit,
        name = "electric-buffer-output-limit",
        tags = {"electric-buffer", "electric", "power"}
    },
    {
        func = energy_randomizer.randomize_energy_source_burner_effectivity,
        name = "burner-effectivity",
        tags = {"effectivity", "burner", "power"}
    },
    {
        func = energy_randomizer.randomize_energy_source_fluid_effectivity,
        name = "fluid-power-effectivity",
        tags = {"effectivity", "fluid-power", "power"}
    },
    {
        func = energy_randomizer.randomize_energy_source_fluid_usage,
        name = "fluid-power-usage",
        tags = {"fluid-power", "power"}
    },
    {
        func = energy_randomizer.randomize_energy_source_fluid_maximum_temperature,
        name = "fluid-power-max-temperature",
        tags = {"temperature", "fluid-power", "power"}
    },
    {
        func = energy_randomizer.randomize_boiler_energy_consumption,
        name = "boiler-consumption",
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
        tags = {"power-production", "burner", "electric", "power"}
    },
    {
        func = energy_randomizer.randomize_electric_energy_interface_energy_production,
        name = "energy-interface-production",
        tags = {"power-production", "electric", "power"}
    },
    {
        func = energy_randomizer.randomize_electric_energy_interface_energy_usage,
        name = "energy-interface-consumption",
        tags = {"electric", "power"}
    },
    {
        func = energy_randomizer.randomize_generator_effectivity,
        name = "generator-effectivity",
        tags = {"power-production", "effectivity", "electric", "power"}
    },
    {
        func = energy_randomizer.randomize_generator_fluid_usage,
        name = "generator-fluid-usage",
        tags = {"power"}
    },
    {
        func = energy_randomizer.randomize_generator_maximum_temperature,
        name = "generator-max-temperature",
        tags = {"temperature", "power"}
    },
    {
        func = energy_randomizer.randomize_generator_max_power_output,
        name = "generator-max-production",
        tags = {"power-production", "electric", "power"}
    },
    {
        func = energy_randomizer.randomize_reactor_consumption
        name = "reactor-consumption",
        tags = {"power"}
    },
    {
        func = energy_randomizer.randomize_solar_panel_production
        name = "solar-panel-production",
        tags = {"power-production", "electric", "power"}
    },
    {
        func = energy_randomizer.randomize_machine_energy_usage
        name = "machine-energy-usage",
        tags = {"energy-usage", "power"}
    },
    {
        func = energy_randomizer.randomize_equipment_energy_usage
        name = "equipment-energy-usage",
        tags = {"energy-usage", "power", "equipment"}
    },
    {
        func = energy_randomizer.randomize_fluid_fuel_value,
        name = "fluid-fuel-value",
        tags = {"fuel-value", "power"}
    },
    {
        func = energy_randomizer.randomize_fluid_heat_capacity
        name = "fluid-heat-capacity",
        tags = {"specific-heat", "fuel-value", "power"}
    },
    {
        func = energy_randomizer.randomize_item_fuel_value,
        name = "item-fuel-value",
        tags = {"fuel-value", "power"}
    },
    {
        func = energy_randomizer.randomize_bot_energy_per_tick -- TODO: Se
        name = "bot-energy-over-time",
        tags = {"energy-usage", "bot-energy", "bots", "power"} -- TODO: Does bot energy have to be electric? Also in general how do we sense electric stuff versus not?
    },
    {
        func = energy_randomizer.randomize_bot_energy_per_move,
        name = "bot-energy-movement",
        tags = {"energy-usage", "bot-energy", "bots", "power"}
    },
    {
        func = energy_randomizer.randomize_inserter_energy_per_movement,
        name = "inseter-energy-movement",
        tags = {"energy-usage", "inserter-energy", "power"}
    },
    {
        func = energy_randomizer.randomize_inserter_energy_per_rotation
        name = "inserter-energy-rotation",
        tags = {"energy-usage", "inserter-energy", "power"}
    },
    {
        func = energy_randomizer.randomize_energy_shield_energy_per_shield,
        name = "energy-shield-energy",
        tags = {"energy-usage", "power", "equipment"}
    },
    {
        func = entity_randomizer.randomize_beacon_supply_area_distance,
        name = "beacon-supply-area",
        tags = {"supply-area", "module", "production"}
    },
    {
        func = entity_randomizer.randomize_beacon_distribution_effectivity,
        name = "beacon-effectivity",
        tags = {"module", "production"}
    },
    {
        func = entity_randomizer.randomize_belt_speed,
        name = "belt-speed",
        tags = {"belt", "logistic-speed", "logistic"}
    },
    {
        func = entity_randomizer.randomize_bot_speed,
        name = "bot-speed",
        tags = {"bot", "logistic-speed", "logistic"}
    },
    {
        func = entity_randomizer.randomize_car_rotation_speed,
        name = "car-turn-radius",
        tags = {"vehicle", "player-transport"}
    },
    {
        func = entity_randomizer.randomize_character_corpse_time_to_live,
        name = "corpse-time",
        tags = {}
    },
    {
        func = entity_randomizer.randomize_respawn_time,
        name = "respawn-time",
        tags = {}
    },
    {
        func = entity_randomizer.randomize_crafting_machine_speeds,
        name = "machine-speeds",
        tags = {"production-speed", "production"}
    },
    {
        func = entity_randomizer.randomize_electric_poles, -- TODO: Add way to randomize supply area but not wire distance and vice versa
        name = "electric-poles",
        tags = {"logistic"}
    },
    {
        func = entity_randomizer.randomize_non_resource_mining_speeds,
        name = "non-resource-mining-speeds",
        tags = {}
    },
    {
        func = entity_randomizer.randomize_repair_speed_modifiers,
        name = "repair-speed-modifiers",
        tags = {"military"}
    },
    {
        func = entity_randomizer.randomize_cliff_sizes,
        name = "cliff-sizes",
        tags = {"sizes"}
    },
    {
        func = entity_randomizer.randomize_fuel_inventory_slots,
        name = "fuel-slots",
        tags = {"inventory-slots", "inventory"}
    },
    {
        func = entity_randomizer.randomize_gate_opening_speed,
        name = "gate-speed",
        tags = {}
    },
    {
        func = entity_randomizer.randomize_non_sensitive_max_health,
        name = "non-sensitive-max-health",
        tags = {"health", "military"}
    },
    {
        func = entity_randomizer.randomize_sensitive_max_health,
        name = "sensitive-max-health",
        tags = {"health", "military"}
    },
    {
        func = entity_randomizer.randomize_inserter_offsets,
        name = "inserter-offsets",
        tags = {"offsets", "logistic"}
    },
    {
        func = entity_randomizer.randomize_inserter_speed,
        name = "inserter-speed",
        tags = {"logistic-speed", "logistic"}
    },
    {
        func = entity_randomizer.randomize_inventory_sizes,
        name = "inventory-sizes", -- TODO: Randomize small/big inventories separately
        tags = {"inventory-slots", "inventory"}
    },
    {
        func = entity_randomizer.randomize_lab_research_speed,
        name = "research-speed",
        tags = {"production-speed", "production"}
    },
    {
        func = entity_randomizer.randomize_machine_pollution,
        name = "machine-pollution",
        tags = {"pollution", "production", "military"}
    },
    {
        func = entity_randomizer.randomize_mining_drill_dropoff_location,
        name = "drill-offsets",
        tags = {"offsets", "logistic"}
    },
    {
        func = entity_randomizer.randomize_mining_speeds,
        name = "mining-speed",
        tags = {"production-speed", "production"}
    },
    {
        func = entity_randomizer.randomize_module_slots,
        name = "module-slots",
        tags = {"module", "production"}
    },
    {
        func = entitiy_randomizer.randomize_offshore_pump_speed,
        name = "offshore-pump-speed",
        tags = {"production-speed", "production"}
    },
    {
        func = entity_randomizer.randomize_pump_pumping_speed,
        name = "pump-speed",
        tags = {"fluid", "logistic-speed", "logistic"} -- TODO: Add fluid as a tag to other places?
    },
    {
        func = entity_randomizer.randomize_radar_search_area,
        name = "radar-search-area",
        tags = {}
    },
    {
        func = entity_randomizer.randomize_radar_reveal_area,
        name = "radar-reveal-area",
        tags = {}
    },
    {
        func = entity_randomizer.randomize_reactor_neighbour_bonus,
        name = "reactor_bonus",
        tags = {"power"}
    },
    {
        func = entity_randomizer.randomize_roboport_material_slots_count,
        name = "roboport-repair-pack-slots",
        tags = {"inventory-slots", "inventory", "bots"}
    },
    {
        func = entity_randomizer.randomize_roboport_robot_slots_count,
        name = "roboport-robot-slots",
        tags = {"inventory-slots", "inventory", "bots"}
    },
    {
        func = entity_randomizer.randomize_roboport_charging_energy,
        name = "roboport-charging-power",
        tags = {"bot-energy", "bots", "power"}
    },
    {
        func = entity_randomizer.randomize_roboport_charging_station_count,
        name = "roboport-charging-count",
        tags = {"bot-energy", "bots"}
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
        tags = {"fluid-storage", "storage"}
    },
    {
        func = entity_randomizer.randomize_underground_belt_distance,
        name = "underground-belt-distance",
        tags = {"belt", "logistic"}
    },
    {
        func = entity_randomizer.randomize_vehicle_crash_damage,
        name = "crash-damage",
        tags = {"personal-vehicle", "player-transport", "transport", "logistic"}
    },
    {
        func = entity_randomizer.randomize_vehicle_power,
        name = "vehicle-speed",
        tags = {"personal-vehicle", "player-transport", "transport-speed", "transport", "logistic"}
    },
    {
        func = icon_randomizer.randomize_icons,
        name = "icons",
        tags = {"visual"} -- TODO: Separate this out more
    },
    {
        func = item_randomizer.randomize_cliff_explosive_throw_range,
        name = "cliff-explosive-throw-range",
        tags = {}
    },
    {
        func = item_randomizer.randomize_ammo_magazine_size,
        name = "magazine-size",
        tags = {"military-resource-usage", "military"}
    },
    {
        func = item_randomizer.randomize_gun_damage_modifier,
        name = "gun-damage-modifier",
        tags = {"damage", "military"}
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
        tags = {"module", "production"}
    },
    {
        func = item_randomizer.randomizer_repair_tool_speeds,
        name = "repair-speeds",
        tags = {"military"}
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
        name = "map_colors",
        tags = {"visual"}
    },
    {
        func = misc_randomizer.randomize_projectile_damage,
        name = "projectile-damage",
        tags = {"damage", "military"}
    }, -- TODO: Utility constants properties
    {
        func = misc_randomizer.randomize_tile_walking_speed_modifier,
        name = "tile-speeds",
        tags = {"player-transport", "transport", "logistic"}
    },
    {
        func = recipe_randomizer.randomize_crafting_times,
        name = "crafting_times",
        tags = {"production-speed", "production"}
    },
    {
        func = technology_randomizer.randomize_tech_costs,
        name = "tech-costs",
        tags = {"tech", "production"}
    },
    {
        func = technology_randomizer.randomize_tech_times,
        name = "tech-times",
        tags = {"tech", "production-speed", "production"}
    } -- TODO: util-randomizer (probably needs a rewrite of the file)
}

-- Specificity:
--     0  = Very broad categories like "logistic" that include types of gameplay
--     10 = More specific categories like "power" that include whole gameplay mechanics
--     20 = Sub-mechanics categories like "electric-power"
--     30 = "Solutions" or subareas to these sub-mechanics like "nuclear-power"
--     40 = Specific ways of looking at these mechanics or aspects of them like "nuclear-power-heat-transfer" (not that this is even a tag right now)
gather_randomizations.tag_spec = {
    {
        name = "logistic",
        specificity = 0
    },
        {
            name = "transport",
            specificity = 10
        },
            {
                name = "material-transport",
                specificity = 20
            },
            {
                name = "player-transport",
                specificity = 20
            },
                {
                    name = "personal-vehicle",
                    specificity = 30
                },
            {
                name = "transport-speed",
                specificity = 20
            },
        {
            name = "positioning",
            specificity = 10
        },
                {
                    name = "underground-distance",
                    specificity = 30
                },
                {
                    name = "offsets",
                    specificity = 30
                },
        {
            name = "storage",
            specificity = 10
        },
            {
                name = "fluid-storage",
                specificity = 20
            },
            {
                name = "inventory",
                specificity = 20
            },
                {
                    name = "inventory_slots",
                    specificity = 30
                },
                    {
                        name = "special_inventory_slots",
                        specificity = 40
                    },
    {
        name = "production",
        specificity = 0
    },
        {
            name = "power",
            specificity = 10
        },
            {
                name = "burner-power",
                specificity = 20
            },
            {
                name = "electric-power",
                specificity = 20
            },
            {
                name = "fluid-power",
                specificity = 20
            },
            {
                name = "heat-power",
                specificity = 20
            },
            {
                name = "power-production",
                specificity = 20
            },
            {
                name = "power-consumption",
                specificity = 20
            },
        {
            name = "production-speed",
            specificity = 10
        },
    {
        name = "military",
        specificity = 0
    },
        {
            name = "pollution",
            specificity = 10
        },
            {
                name = "pollution-consumption",
                specificity = 20
            },
            {
                name = "pollution-production",
                specificity = 20
            },
    -- Not tied to a specific major category
            {
                name = "belt",
                specificity = 20
            },
            {
                name = "bots",
                specificity = 20
            },
                {
                    name = "bot-energy",
                    specificity = 30
                },
                    {
                        name = "bot-energy-usage",
                        specificity = 40
                    },
                    {
                        name = "bot-charging",
                        specificity = 40
                    },
                {
                    name = "bot-speed",
                    specificity = 30
                }
}

-- List of tables with signature {randomization = [function], blacklist = [table of protoype --> bool of whether blacklisted]}
gather_randomizations.list_to_randomize = {}

return gather_randomizations