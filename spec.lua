require("randomize/master")

-- TODO: character-values midgame (later version)
-- TODO: mining-drill-productivity (later version)

-- TODO: Redo tag system
-- TODO: drain
-- TODO: check lower_is_better on NEW properties

-- In the form {func = [function to do randomization], name = [user-friendly name of function], setting = [setting this is tied to], tags = [list of tags], default = [whether on by default], grouped = [whether it does all prototypes at once]}
local spec = {
    {
        func = rand.heat_buffer_max_transfer,
        name = "heat-transfer-rate",
        setting = "none",
        tags = {"heat", "power"},
        default = false
    },
    {
        func = rand.heat_buffer_specific_heat,
        name = "specific-heat",
        setting = "none",
        tags = {"heat", "power"},
        default = false
    },
    {
        func = rand.heat_buffer_temperatures,
        name = "heat-temperature",
        setting = "none",
        tags = {"temperature", "heat", "power"},
        default = false
    },
    { -- Technically could be applied to other entities, like roboports, but just applies to accumulators now
        func = rand.energy_source_electric_buffer_capacity,
        name = "electric-capacity",
        setting = "propertyrandomizer-production",
        default = true,
        tags = {"electric", "power"}
    },
    {
        func = rand.energy_source_electric_input_flow_limit,
        name = "electric-input-limit",
        setting = "propertyrandomizer-production",
        tags = {"electric", "power"},
        default = true
    },
    {
        func = rand.energy_source_electric_output_flow_limit,
        name = "electric-output-limit",
        setting = "propertyrandomizer-production",
        tags = {"electric", "power"},
        default = true
    },
    {
        func = rand.energy_source_burner_effectivity,
        name = "burner-effectivity",
        setting = "none",
        tags = {"burner", "power"},
        default = false
    },
    { -- Not tested
        func = rand.energy_source_fluid_effectivity,
        name = "fluid-power-effectivity",
        setting = "propertyrandomizer-production",
        tags = {"fluid-power", "power"},
        default = true
    },
    { -- Not tested
        func = rand.energy_source_fluid_maximum_temperature,
        name = "fluid-power-max-temperature",
        setting = "none",
        tags = {"temperature", "fluid-power", "power"},
        default = false
    },
    {
        func = rand.boiler_energy_consumption,
        name = "boiler-power",
        setting = "propertyrandomizer-production",
        tags = {"power"},
        default = true
    },
    {
        func = rand.boiler_target_temperature,
        name = "boiler-temperature",
        setting = "none",
        tags = {"temperature", "power"},
        default = false,
    },
    {
        func = rand.burner_generator_max_power_output,
        name = "burner-generator-production",
        setting = "propertyrandomizer-production",
        tags = {"power-production", "burner-power", "electric-power", "power"},
        default = true
    },
    { -- Not tested
        func = rand.electric_energy_interface_energy_production,
        name = "energy-interface-production",
        setting = "none",
        tags = {"power-production", "electric", "power"},
        default = false
    },
    { -- Not tested
        func = rand.electric_energy_interface_energy_usage,
        name = "energy-interface-consumption",
        setting = "none",
        tags = {"power-consumption", "electric", "power"},
        default = false
    },
    {
        func = rand.generator_effectivity,
        name = "fluid-generator-effectivity",
        setting = "none",
        tags = {"power-production", "electric", "power"},
        default = false
    },
    {
        func = rand.generator_fluid_usage,
        name = "fluid-generator-production",
        setting = "propertyrandomizer-production",
        tags = {"power-production", "electric", "power"},
        default = true
    },
    {
        func = rand.generator_maximum_temperature,
        name = "fluid-generator-max-temperature",
        setting = "none",
        tags = {"power-production", "temperature", "power"},
        default = false
    }, -- Excluded: generator_max_production
    {
        func = rand.reactor_consumption,
        name = "reactor-consumption",
        setting = "propertyrandomizer-production",
        tags = {"power-production", "power"},
        default = true
    },
    {
        func = rand.solar_panel_production,
        name = "solar-panel-production",
        setting = "propertyrandomizer-production",
        tags = {"power-production", "electric", "power"},
        default = true
    },
    {
        func = rand.machine_energy_usage,
        name = "machine-energy-usage",
        setting = "propertyrandomizer-production",
        tags = {"power-consumption", "power"},
        default = true
    },
    {
        func = rand.equipment_energy_usage,
        name = "equipment-energy-usage",
        setting = "propertyrandomizer-military-advanced",
        tags = {"equipment"},
        default = true
    },
    { -- Not tested
        func = rand.fluid_fuel_value,
        name = "fluid-fuel-value",
        setting = "propertyrandomizer-production",
        tags = {"power"},
        default = true
    },
    { -- NEW
        func = rand.fluid_heat_capacity,
        name = "fluid-heat-capacity",
        setting = "none",
        tags = {},
        default = false
    },
    {
        func = rand.item_fuel_value,
        name = "item-fuel-value",
        setting = "propertyrandomizer-production",
        tags = {"power"},
        default = true
    },
    { -- This is technically two things: over time and movement, but we should do a group randomization of them
        func = rand.bot_energy,
        name = "bot-power",
        setting = "propertyrandomizer-production",
        default = true,
        tags = {"power-consumption", "bots", "power"} -- TODO: Does bot energy have to be electric? Also in general how do we sense electric stuff versus not?
    },
    { -- This is technically two things: per rotation and per movement, but they should be group randomized
        func = rand.inserter_energy,
        name = "inserter-power",
        setting = "propertyrandomizer-production",
        tags = {"power-consumption", "power"},
        default = true
    },
    { -- NEW
        func = rand.turret_energy_usage,
        name = "turret-energy-usage",
        setting = "propertyrandomizer-production",
        tags = {},
        default = true
    },
    {
        func = rand.beacon_supply_area_distance,
        name = "beacon-supply-area",
        setting = "propertyrandomizer-production",
        tags = {"modules", "production"},
        default = true
    },
    {
        func = rand.beacon_distribution_effectivity,
        name = "beacon-effectivity",
        setting = "propertyrandomizer-production",
        tags = {"modules", "production"},
        default = true
    },
    {
        func = rand.belt_speed,
        name = "belt-speed",
        setting = "propertyrandomizer-logistic",
        tags = {"logistic"},
        default = true,
        grouped = true
    },
    {
        func = rand.bot_speed,
        name = "bot-speed",
        setting = "propertyrandomizer-logistic",
        tags = {"bots", "logistic"},
        default = true
    },
    {
        func = rand.car_rotation_speed,
        name = "car-turn-radius",
        setting = "propertyrandomizer-logistic",
        tags = {"vehicle"},
        default = true
    },
    {
        func = rand.character_corpse_time_to_live,
        name = "corpse-time",
        setting = "propertyrandomizer-misc-properties",
        tags = {"misc"},
        default = false
    },
    {
        func = rand.respawn_time,
        name = "respawn-time",
        setting = "propertyrandomizer-misc-properties",
        tags = {"misc"},
        default = false
    },
    {
        func = rand.crafting_machine_speed,
        name = "crafting-machine-speed",
        setting = "propertyrandomizer-production",
        tags = {"production"},
        default = true
    },
    { -- TODO: Break up into wire distance and supply area
        -- TODO: Possibly make sure that medium poles or big poles at least have decent supply area so that life isn't too awful?
        func = rand.electric_poles,
        name = "electric-poles",
        setting = "propertyrandomizer-logistic",
        tags = {"logistic"},
        default = true,
        grouped = true
    },
    {
        func = rand.non_resource_mining_speeds,
        name = "non-resource-mining-speeds",
        setting = "propertyrandomizer-misc-properties",
        tags = {"misc"},
        default = false
    },
    { -- Not tested
        func = rand.repair_speed_modifiers,
        name = "repair-speed-modifiers",
        setting = "propertyrandomizer-misc-properties",
        tags = {"misc"},
        default = false
    },
    {
        func = rand.cliff_sizes,
        name = "cliff-sizes",
        setting = "propertyrandomizer-cliff-sizes",
        default = true,
        tags = {"sizes"}
    },
    {
        func = rand.fuel_inventory_slots,
        name = "fuel-slots",
        setting = "propertyrandomizer-misc-properties",
        tags = {"inventory-slots", "storage"},
        default = false
    },
    {
        func = rand.gate_opening_speed,
        name = "gate-speed",
        setting = "propertyrandomizer-misc-properties",
        tags = {"misc"},
        default = false
    },
    {
        func = rand.non_sensitive_max_health,
        name = "non-sensitive-max-health",
        setting = "propertyrandomizer-misc-properties",
        tags = {"misc"},
        default = false
    },
    {
        func = rand.sensitive_max_health,
        name = "sensitive-max-health",
        setting = "propertyrandomizer-military-advanced",
        tags = {"military"},
        default = true
    },
    {
        func = rand.inserter_offsets,
        name = "inserter-offsets",
        setting = "propertyrandomizer-inserter-position",
        tags = {"logistic"},
        default = true
    },
    {
        func = rand.inserter_speed,
        name = "inserter-speed",
        setting = "propertyrandomizer-logistic",
        tags = {"logistic-speed", "logistic"},
        default = true
    },
    {
        func = rand.inventory_sizes,
        name = "inventory-sizes", -- TODO: Randomize small/big inventories separately
        setting = "propertyrandomizer-storage",
        tags = {"inventory-slots", "storage"},
        default = true
    },
    {
        func = rand.lab_research_speed,
        name = "research-speed",
        setting = "propertyrandomizer-production",
        tags = {"production"},
        default = true
    },
    { -- NEW
        func = rand.landmine_damage,
        name = "landmine-damage",
        setting = "propertyrandomizer-military",
        tags = {},
        default = true
    },
    { -- NEW
        func = rand.landmine_effect_radius,
        name = "landmine-effect-radius",
        setting = "propertyrandomizer-military",
        tags = {},
        default = true
    },
    { -- NEW
        func = rand.landmine_trigger_radius,
        name = "landmine-trigger-radius",
        setting = "propertyrandomizer-military",
        tags = {},
        default = true
    },
    { -- NEW
        func = rand.landmine_timeout,
        name = "landmine-timeout",
        setting = "propertyrandomizer-military",
        tags = {},
        default = true
    },
    {
        func = rand.machine_pollution,
        name = "machine-pollution",
        setting = "propertyrandomizer-military",
        tags = {"production", "military"},
        default = true
    },
    {
        func = rand.mining_drill_dropoff_location,
        name = "drill-offsets",
        setting = "propertyrandomizer-mining-offsets",
        tags = {"logistic"},
        default = true
    },
    { -- NEW
        func = rand.mining_results_tree_rock,
        name = "tree-rock-mining-results",
        setting = "none",
        tags = {},
        default = false
    },
    {
        func = rand.mining_speeds,
        name = "mining-speed",
        setting = "propertyrandomizer-production",
        tags = {"production"},
        default = true
    },
    {
        func = rand.module_slots,
        name = "module-slots",
        setting = "propertyrandomizer-production",
        tags = {"modules", "production"},
        default = true
    },
    {
        func = rand.offshore_pump_speed,
        name = "offshore-pump-speed",
        setting = "propertyrandomizer-production",
        tags = {"production"},
        default = true
    },
    {
        func = rand.pump_pumping_speed,
        name = "pump-speed",
        setting = "propertyrandomizer-logistic",
        tags = {"fluid", "logistic"}, -- TODO: Add fluid as a tag to other places?
        default = true
    },
    {
        func = rand.radar_search_area,
        name = "radar-search-area",
        setting = "none",
        tags = {"misc"},
        default = false
    },
    {
        func = rand.radar_reveal_area,
        name = "radar-reveal-area",
        setting = "none",
        tags = {"misc"},
        default = false
    },
    {
        func = rand.reactor_neighbour_bonus,
        name = "reactor-bonus",
        setting = "propertyrandomizer-production",
        tags = {"power-production", "power"},
        default = true
    },
    {
        func = rand.roboport_inventory,
        name = "roboport-inventory",
        setting = "none",
        tags = {},
        default = false
    },
    {
        func = rand.roboport_charging_energy,
        name = "roboport-charging-speed",
        setting = "propertyrandomizer-logistic",
        tags = {"bots", "power"},
        default = true
    },
    {
        func = rand.roboport_charging_station_count,
        name = "roboport-charging-count",
        setting = "propertyrandomizer-logistic",
        tags = {"bots", "power"},
        default = true
    },
    {
        func = rand.roboport_logistic_radius,
        name = "roboport-logistic-radius",
        setting = "propertyrandomizer-logistic",
        tags = {"bots", "logistic"},
        default = true
    },
    {
        func = rand.roboport_construction_radius,
        name = "roboport-construction-radius",
        setting = "propertyrandomizer-logistic",
        tags = {"bots"},
        default = true
    },
    { -- NEW
        func = rand.rocket_parts_required,
        name = "rocket-parts-required",
        setting = "propertyrandomizer-production",
        tags = {},
        default = true
    },
    { -- NEW
        func = rand.rocket_silo_launch_time,
        name = "rocket-time-to-launch",
        setting = "propertyrandomizer-misc-properties",
        tags = {},
        default = false
    },
    {
        func = rand.storage_tank_capacity,
        name = "tank-capacity",
        setting = "propertyrandomizer-storage",
        tags = {"fluid", "storage"},
        default = true
    }, -- TODO: Turret
    { -- NEW
        func = rand.turret_damage_modifier,
        name = "turret-damage-modifier",
        setting = "propertyrandomizer-military",
        tags = {},
        default = true
    },
    { -- NEW
        func = rand.turret_min_attack_distance,
        name = "turret-min-attack-distance",
        setting = "propertyrandomizer-military",
        tags = {},
        default = true
    },
    { -- NEW
        -- TODO: Separate this out more into worm and player turret range
        func = rand.turret_range,
        name = "turret-range",
        setting = "propertyrandomizer-military",
        tags = {},
        default = true
    },
    { -- NEW
    -- TODO: This affects car "turrets" as well, but I think that should be its own thing
        func = rand.turret_rotation_speed,
        name = "turret-rotation-speed",
        setting = "propertyrandomizer-military",
        tags = {},
        default = true
    },
    { -- NEW
        func = rand.turret_shooting_speed,
        name = "turret-shooting-speed",
        setting = "propertyrandomizer-military",
        tags = {},
        default = true
    },
    {
        func = rand.underground_belt_distance,
        name = "underground-belt-distance",
        setting = "propertyrandomizer-logistic",
        tags = {"logistic"},
        default = true
    },
    { -- NEW
        func = rand.pipe_to_ground_distance,
        name = "pipe-to-ground-distance",
        setting = "propertyrandomizer-logistic",
        tags = {},
        default = true
    },
    -- TODO: Unit
    -- other unit specific, movement speed
    {
        func = rand.unit_attack_speed,
        name = "unit-attack-speed",
        setting = "propertyrandomizer-military",
        tags = {},
        default = false
    },
    { -- NEW
        func = rand.unit_melee_damage,
        name = "unit-melee-damage",
        setting = "propertyrandomizer-military",
        tags = {},
        default = false
    },
    { -- NEW
        func = rand.unit_movement_speed,
        name = "unit-movement-speed",
        setting = "propertyrandomizer-military-advanced",
        tags = {},
        default = false
    },
    { -- NEW
        func = rand.unit_pollution_to_join_attack,
        name = "unit-pollution-to-join-attack",
        setting = "propertyrandomizer-military-advanced",
        tags = {},
        default = false
    },
    { -- NEW
        func = rand.unit_range,
        name = "unit-range",
        setting = "propertyrandomizer-military-advanced",
        tags = {},
        default = false
    }, -- TODO: Unit pursue distance, pursue time, figure out what spawning time modifier does
    {
        func = rand.unit_vision_distance,
        name = "unit-vision-distance",
        setting = "propertyrandomizer-military-advanced",
        tags = {},
        default = false
    },
    -- Excluded: Unit turn radius (it's just visual)
    {
        func = rand.vehicle_crash_damage,
        name = "crash-damage",
        setting = "propertyrandomizer-logistic",
        tags = {"vehicle"},
        default = true
    },
    {
        func = rand.vehicle_power,
        name = "vehicle-speed",
        setting = "propertyrandomizer-logistic",
        tags = {"vehicle", "player-transport"},
        default = true
    },
    {
        func = rand.icons,
        name = "icons",
        setting = "propertyrandomizer-icons",
        tags = {"visual"}, -- TODO: Separate this out more
        default = false,
        grouped = true
    },
    { -- TODO: The following randomization isn't implemented yet
        func = rand.capsule_throw_range,
        name = "capsule-throw-range",
        setting = "none",
        tags = {"misc"},
        default = false
    },
    {
        func = rand.ammo_magazine_size,
        name = "magazine-size",
        setting = "propertyrandomizer-military",
        tags = {"military"},
        default = true
    }, -- TODO: ammo damage?
    { -- TODO: Check to see if anything else from attack_parameters makes sense to add to gun
        func = rand.gun_damage_modifier,
        name = "gun-damage-modifier",
        setting = "propertyrandomizer-military",
        tags = {"military"},
        default = true
    },
    {
        func = rand.gun_range,
        name = "gun-range",
        setting = "propertyrandomizer-military",
        tags = {"military-range", "military"},
        default = true
    },
    {
        func = rand.gun_speed,
        name = "gun-speed",
        setting = "propertyrandomizer-military",
        tags = {"military-speed", "military"},
        default = true
    },
    {
        func = rand.item_stack_sizes,
        name = "stack-sizes",
        setting = "propertyrandomizer-storage",
        tags = {"inventory", "storage", "logistic"},
        default = true
    },
    {
        func = rand.module_effects,
        name = "module-effects",
        setting = "propertyrandomizer-production",
        tags = {"modules", "production"},
        default = true
    },
    {
        func = rand.repair_tool_speeds,
        name = "repair-speeds",
        setting = "propertyrandomizer-misc-properties",
        tags = {"military", "misc"},
        default = false
    },
    {
        func = rand.achievements,
        name = "achievements",
        setting = "propertyrandomizer-misc-properties",
        tags = {},
        default = false,
        grouped = true
    },
    {
        func = rand.equipment_grids,
        name = "equipment-grids",
        setting = "propertyrandomizer-military",
        tags = {"equipment", "military"},
        default = true
    }, -- TODO: equipment shapes and properties
    { -- TODO: Equipment properties
        func = rand.fluid_emissions_multiplier,
        name = "fluid-emissions-multiplier",
        setting = "propertyrandomizer-military",
        tags = {"fluid"},
        default = true
    }, -- TODO: icon shifts
    {
        func = rand.map_colors,
        name = "map-colors",
        setting = "propertyrandomizer-misc-properties",
        tags = {"visual"},
        default = false
    },
    { -- TODO: Yep it's broken, doesn't do anything
        func = rand.projectile_damage, -- Might be buggy?
        name = "projectile-damage",
        setting = "propertyrandomizer-military",
        tags = {"military"},
        default = true
    }, -- TODO: Utility constants properties
    {
        func = rand.sounds,
        name = "sounds",
        setting = "propertyrandomizer-sounds",
        tags = {},
        default = false,
        grouped = true
    },
    { -- TODO: Stickers
        func = rand.tile_walking_speed_modifier,
        name = "tile-speeds",
        setting = "propertyrandomizer-misc-properties",
        tags = {"player-transport", "misc"},
        default = false,
        grouped = true
    },
    {
        func = rand.crafting_times,
        name = "recipe-times",
        setting = "propertyrandomizer-crafting-times",
        tags = {"production"},
        default = true
    },
    {
        func = rand.tech_costs,
        name = "tech-costs",
        setting = "propertyrandomizer-tech-costs",
        tags = {"production"},
        default = true
    },
    {
        func = rand.tech_times,
        name = "tech-times",
        setting = "propertyrandomizer-tech-costs",
        tags = {"tech", "production-speed", "production"},
        default = true
    }
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
        error("tags undefined for randomization named " .. randomization.name)
    end
    if randomization.default == nil then
        error("default undefined for randomization named " .. randomization.name)
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