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
        setting = "propertyrandomizer-production"
    },
    {
        func = rand.energy_source_electric_input_flow_limit,
        name = "electric-input-limit",
        setting = "propertyrandomizer-production"
    },
    {
        func = rand.energy_source_electric_output_flow_limit,
        name = "electric-output-limit",
        setting = "propertyrandomizer-production"
    },
    { -- NEW
        func = rand.energy_source_electric_drain,
        name = "electric-min-consumption",
        setting = "propertyrandomizer-production-advanced"
    },
    {
        func = rand.energy_source_burner_effectivity,
        name = "burner-effectivity",
        setting = "propertyrandomizer-production-advanced"
    },
    { -- Not tested
        func = rand.energy_source_fluid_effectivity,
        name = "fluid-power-effectivity",
        setting = "propertyrandomizer-production"
    },
    { -- Not tested
        func = rand.energy_source_fluid_maximum_temperature,
        name = "fluid-power-max-temperature",
        setting = "none"
    },
    {
        func = rand.boiler_energy_consumption,
        name = "boiler-power",
        setting = "propertyrandomizer-production"
    },
    {
        func = rand.boiler_target_temperature,
        name = "boiler-temperature",
        setting = "none"
    },
    {
        func = rand.burner_generator_max_power_output,
        name = "burner-generator-production",
        setting = "propertyrandomizer-production"
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
        setting = "propertyrandomizer-production"
    },
    {
        func = rand.generator_maximum_temperature,
        name = "fluid-generator-max-temperature",
        setting = "none"
    }, -- Excluded: generator_max_production
    {
        func = rand.reactor_consumption,
        name = "reactor-consumption",
        setting = "propertyrandomizer-production"
    },
    {
        func = rand.solar_panel_production,
        name = "solar-panel-production",
        setting = "propertyrandomizer-production"
    },
    {
        func = rand.machine_energy_usage,
        name = "machine-energy-usage",
        setting = "propertyrandomizer-production"
    },
    {
        func = rand.equipment_energy_usage,
        name = "equipment-energy-usage",
        setting = "propertyrandomizer-military-advanced"
    },
    { -- Not tested
        func = rand.fluid_fuel_value,
        name = "fluid-fuel-value",
        setting = "propertyrandomizer-production"
    },
    { -- NEW
        func = rand.fluid_heat_capacity,
        name = "fluid-heat-capacity",
        setting = "none"
    },
    {
        func = rand.item_fuel_value,
        name = "item-fuel-value",
        setting = "propertyrandomizer-production"
    },
    { -- This is technically two things: over time and movement, but we should do a group randomization of them
        func = rand.bot_energy,
        name = "bot-power",
        setting = "propertyrandomizer-production" -- TODO: Does bot energy have to be electric? Also in general how do we sense electric stuff versus not?
    },
    { -- This is technically two things: per rotation and per movement, but they should be group randomized
        func = rand.inserter_energy,
        name = "inserter-power",
        setting = "propertyrandomizer-production"
    },
    { -- NEW
        func = rand.turret_energy_usage,
        name = "turret-energy-usage",
        setting = "propertyrandomizer-production"
    },
    {
        func = rand.beacon_supply_area_distance,
        name = "beacon-supply-area",
        setting = "propertyrandomizer-production"
    },
    {
        func = rand.beacon_distribution_effectivity,
        name = "beacon-effectivity",
        setting = "propertyrandomizer-production"
    },
    {
        func = rand.belt_speed,
        name = "belt-speed",
        setting = "propertyrandomizer-logistic",
        grouped = true
    },
    {
        func = rand.bot_speed,
        name = "bot-speed",
        setting = "propertyrandomizer-logistic"
    },
    {
        func = rand.car_rotation_speed,
        name = "car-turn-radius",
        setting = "propertyrandomizer-logistic"
    },
    {
        func = rand.character_corpse_time_to_live,
        name = "corpse-time",
        setting = "propertyrandomizer-misc-properties"
    },
    {
        func = rand.respawn_time,
        name = "respawn-time",
        setting = "propertyrandomizer-misc-properties"
    },
    {
        func = rand.crafting_machine_speed,
        name = "crafting-machine-speed",
        setting = "propertyrandomizer-production"
    },
    { -- TODO: Break up into wire distance and supply area
        -- TODO: Possibly make sure that medium poles or big poles at least have decent supply area so that life isn't too awful?
        func = rand.electric_poles,
        name = "electric-poles",
        setting = "propertyrandomizer-logistic",
        grouped = true
    },
    {
        func = rand.non_resource_mining_speeds,
        name = "non-resource-mining-speeds",
        setting = "propertyrandomizer-misc-properties"
    },
    { -- Not tested
        func = rand.repair_speed_modifiers,
        name = "repair-speed-modifiers",
        setting = "propertyrandomizer-misc-properties"
    },
    {
        func = rand.cliff_sizes,
        name = "cliff-sizes",
        setting = "propertyrandomizer-misc-properties"
    },
    {
        func = rand.fuel_inventory_slots,
        name = "fuel-slots",
        setting = "propertyrandomizer-misc-properties"
    },
    {
        func = rand.gate_opening_speed,
        name = "gate-speed",
        setting = "propertyrandomizer-misc-properties"
    },
    {
        func = rand.non_sensitive_max_health,
        name = "non-sensitive-max-health",
        setting = "propertyrandomizer-misc-properties"
    },
    {
        func = rand.sensitive_max_health,
        name = "sensitive-max-health",
        setting = "propertyrandomizer-military-advanced"
    },
    {
        func = rand.inserter_offsets,
        name = "inserter-offsets",
        setting = "propertyrandomizer-inserter-position"
    },
    {
        func = rand.inserter_speed,
        name = "inserter-speed",
        setting = "propertyrandomizer-logistic"
    },
    {
        func = rand.inventory_sizes,
        name = "inventory-sizes", -- TODO: Randomize small/big inventories separately
        setting = "propertyrandomizer-storage"
    },
    {
        func = rand.lab_research_speed,
        name = "research-speed",
        setting = "propertyrandomizer-production"
    },
    { -- NEW
        func = rand.landmine_damage,
        name = "landmine-damage",
        setting = "propertyrandomizer-military"
    },
    { -- NEW
        func = rand.landmine_effect_radius,
        name = "landmine-effect-radius",
        setting = "propertyrandomizer-military-advanced"
    },
    { -- NEW
        func = rand.landmine_trigger_radius,
        name = "landmine-trigger-radius",
        setting = "propertyrandomizer-military-advanced"
    },
    { -- NEW
        func = rand.landmine_timeout,
        name = "landmine-timeout",
        setting = "propertyrandomizer-military-advanced"
    },
    {
        func = rand.machine_pollution,
        name = "machine-pollution",
        setting = "propertyrandomizer-military"
    },
    {
        func = rand.mining_drill_dropoff_location,
        name = "drill-offsets",
        setting = "propertyrandomizer-misc-properties"
    },
    { -- NEW
        func = rand.mining_results_tree_rock,
        name = "tree-rock-mining-results",
        setting = "propertyrandomizer-misc-properties"
    },
    {
        func = rand.mining_speeds,
        name = "mining-speed",
        setting = "propertyrandomizer-production"
    },
    {
        func = rand.module_slots,
        name = "module-slots",
        setting = "propertyrandomizer-production"
    },
    {
        func = rand.offshore_pump_speed,
        name = "offshore-pump-speed",
        setting = "propertyrandomizer-production"
    },
    {
        func = rand.pump_pumping_speed,
        name = "pump-speed",
        setting = "propertyrandomizer-logistic" -- TODO: Add fluid as a tag to other places?
    },
    {
        func = rand.radar_search_area,
        name = "radar-search-area",
        setting = "propertyrandomizer-misc-properties"
    },
    {
        func = rand.radar_reveal_area,
        name = "radar-reveal-area",
        setting = "propertyrandomizer-misc-properties"
    },
    {
        func = rand.reactor_neighbour_bonus,
        name = "reactor-bonus",
        setting = "propertyrandomizer-production"
    },
    {
        func = rand.roboport_inventory,
        name = "roboport-inventory",
        setting = "propertyrandomizer-misc-properties"
    },
    {
        func = rand.roboport_charging_energy,
        name = "roboport-charging-speed",
        setting = "propertyrandomizer-logistic"
    },
    {
        func = rand.roboport_charging_station_count,
        name = "roboport-charging-count",
        setting = "propertyrandomizer-logistic"
    },
    {
        func = rand.roboport_logistic_radius,
        name = "roboport-logistic-radius",
        setting = "propertyrandomizer-logistic"
    },
    {
        func = rand.roboport_construction_radius,
        name = "roboport-construction-radius",
        setting = "propertyrandomizer-logistic"
    },
    { -- NEW
        func = rand.rocket_parts_required,
        name = "rocket-parts-required",
        setting = "propertyrandomizer-production"
    },
    { -- NEW
        func = rand.rocket_silo_launch_time,
        name = "rocket-time-to-launch",
        setting = "propertyrandomizer-misc-properties"
    },
    {
        func = rand.storage_tank_capacity,
        name = "tank-capacity",
        setting = "propertyrandomizer-storage"
    }, -- TODO: Turret
    { -- NEW
        func = rand.turret_damage_modifier,
        name = "turret-damage-modifier",
        setting = "propertyrandomizer-military"
    },
    { -- NEW
        func = rand.turret_min_attack_distance,
        name = "turret-min-attack-distance",
        setting = "propertyrandomizer-military-advanced"
    },
    { -- NEW
        -- TODO: Separate this out more into worm and player turret range
        func = rand.turret_range,
        name = "turret-range",
        setting = "propertyrandomizer-military-advanced",
        tags = {},
        default = true
    },
    { -- NEW
    -- TODO: This affects car "turrets" as well, but I think that should be its own thing
        func = rand.turret_rotation_speed,
        name = "turret-rotation-speed",
        setting = "propertyrandomizer-military-advanced"
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
        setting = "propertyrandomizer-logistic"
    },
    { -- NEW
        func = rand.pipe_to_ground_distance,
        name = "pipe-to-ground-distance",
        setting = "propertyrandomizer-logistic"
    },
    { -- NEW
        func = rand.unit_attack_speed,
        name = "unit-attack-speed",
        setting = "propertyrandomizer-military-advanced"
    },
    { -- NEW
        func = rand.unit_melee_damage,
        name = "unit-melee-damage",
        setting = "propertyrandomizer-military-advanced"
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
        setting = "propertyrandomizer-military-advanced"
    },
    { -- NEW
        func = rand.unit_range,
        name = "unit-range",
        setting = "propertyrandomizer-military-advanced"
    },
    { -- NEW
        func = rand.unit_vision_distance,
        name = "unit-vision-distance",
        setting = "propertyrandomizer-military-advanced"
    },
    -- Excluded: Unit turn radius (it's just visual)
    -- Excluded: Unit following properties (I don't think they'll be noticed)
    {
        func = rand.vehicle_crash_damage,
        name = "crash-damage",
        setting = "propertyrandomizer-logistic"
    },
    {
        func = rand.vehicle_power,
        name = "vehicle-speed",
        setting = "propertyrandomizer-logistic"
    },
    {
        func = rand.icons,
        name = "icons",
        setting = "none", -- TODO: Separate this out more
        grouped = true
    },
    -- TODO: Other icon randomization!
    { -- NEW
        func = rand.biter_images,
        name = "biter-images",
        setting = "none",
        grouped = true
    },
    { -- NEW
        func = rand.recipe_groups,
        name = "recipe-order",
        setting = "none",
        grouped = true
    },
    -- TODO: Implement
    { -- NEW (not implemented though)
        func = rand.capsule_healing,
        name = "capsule-healing",
        setting = "propertyrandomizer-military"
    },
    { -- NEW (implemented)
        func = rand.capsule_throw_range,
        name = "capsule-throw-range",
        setting = "propertyrandomizer-military-advanced"
    },
    { -- NEW
        func = rand.ammo_damage,
        name = "ammo-damage",
        setting = "propertyrandomizer-military"
    },
    {
        func = rand.ammo_magazine_size,
        name = "magazine-size",
        setting = "propertyrandomizer-military"
    },
    { -- TODO: Check to see if anything else from attack_parameters makes sense to add to gun
        func = rand.gun_damage_modifier,
        name = "gun-damage-modifier",
        setting = "propertyrandomizer-military"
    },
    { -- NEW
        func = rand.gun_movement_slowdown_factor,
        name = "gun-shooting-slowdown",
        setting = "none"
    },
    {
        func = rand.gun_range,
        name = "gun-range",
        setting = "propertyrandomizer-military"
    },
    {
        func = rand.gun_speed,
        name = "gun-speed",
        setting = "propertyrandomizer-military"
    },
    {
        func = rand.item_stack_sizes,
        name = "stack-sizes",
        setting = "propertyrandomizer-storage"
    },
    {
        func = rand.module_effects,
        name = "module-effects",
        setting = "propertyrandomizer-production"
    },
    {
        func = rand.repair_tool_speeds,
        name = "repair-speeds",
        setting = "propertyrandomizer-misc-properties"
    },
    {
        func = rand.achievements,
        name = "achievements",
        setting = "propertyrandomizer-misc-properties",
        grouped = true
    },
    { -- NEW
        func = rand.equipment_active_defense_cooldown,
        name = "active-defense-equipment-fire-rate",
        setting = "propertyrandomizer-military"
    },
    { -- NEW
        func = rand.equipment_active_defense_damage,
        name = "active-defense-equipment-damage",
        setting = "propertyrandomizer-military"
    },
    -- The electric defense actually creates a projectile rather than being AOE based directly, so this doesn't work as intended
    -- TODO: Fix once I come up with a more general way to deal with attack parameters
    --[[{ -- NEW
        func = rand.equipment_active_defense_radius,
        name = "active-defense-equipment-effect-radius",
        setting = "propertyrandomizer-military"
    },]]
    { -- NEW
        func = rand.equipment_active_defense_range,
        name = "active-defense-equipment-range",
        setting = "propertyrandomizer-military-advanced"
    },
    { -- NEW
        func = rand.equipment_battery_buffer,
        name = "battery-equipment-buffer",
        setting = "propertyrandomizer-production" -- TODO: Change other non-military equipment to be more in line with production setting (even if it is technically more military based)
    },
    { -- NEW
        func = rand.equipment_battery_input_limit,
        name = "battery-equipment-input-limit",
        setting = "propertyrandomizer-production"
    },
    { -- NEW
        func = rand.equipment_battery_output_limit,
        name = "battery-equipment-output-limit",
        setting = "propertyrandomizer-production"
    },
    { -- NEW
        func = rand.equipment_energy_shield_max_shield,
        name = "energy-shield-equipment-max-shield",
        setting = "propertyrandomizer-military"
    }, -- energy-shield power usage is covered by equipment power usage
    { -- NEW
        func = rand.equipment_generator_power,
        name = "generator-equipment-power-production",
        setting = "propertyrandomizer-production"
    },
    { -- NEW
        func = rand.equipment_movement_bonus,
        name = "movement-equipment-bonus",
        setting = "propertyrandomizer-logistic" -- Since it just has to do with moving around, I'm making it logistics
    },
    { -- NEW
        func = rand.equipment_personal_roboport_charging_speed,
        name = "personal-roboport-charging-speed",
        setting = "propertyrandomizer-logistic"
    },
    { -- NEW
        func = rand.equipment_personal_roboport_charging_station_count,
        name = "personal-roboport-max-charging-robots",
        setting = "none" -- Advanced logistic setting
    },
    { -- NEW
        func = rand.equipment_personal_roboport_construction_radius,
        name = "personal-roboport-construction-radius",
        setting = "propertyrandomizer-logistic"
    },
    { -- NEW
        func = rand.equipment_personal_roboport_max_robots,
        name = "personal-roboport-max-robots",
        setting = "propertyrandomizer-logistic"
    },
    { -- NEW
        func = rand.equipment_solar_panel_production,
        name = "solar-panel-equipment-power-production",
        setting = "propertyrandomizer-production"
    },
    { -- NEW: Changed name
        func = rand.equipment_grid_sizes, -- TODO: Shouldn't this specify sizes in the name?
        name = "equipment-grid-sizes",
        setting = "propertyrandomizer-military"
    }, -- TODO: equipment shapes
    {
        func = rand.fluid_emissions_multiplier,
        name = "fluid-emissions-multiplier",
        setting = "propertyrandomizer-military"
    },
    { -- NEW
        func = rand.icon_shifts,
        name = "icon-shifts",
        setting = "propertyrandomizer-misc-properties",
        grouped = true
    },
    {
        func = rand.map_colors,
        name = "map-colors",
        setting = "propertyrandomizer-misc-properties"
    },
    { -- NEW (Okay not new, but FIXED)
        func = rand.projectile_damage,
        name = "projectile-damage",
        setting = "propertyrandomizer-military"
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
        setting = "propertyrandomizer-misc-properties",
        grouped = true
    },
    { -- NEW
        func = rand.utility_constants_inventory_widths,
        name = "inventory-widths",
        setting = "propertyrandomizer-misc-properties",
        grouped = true
    },
    { -- NEW
        -- Currently just does some train wait times
        func = rand.utility_constants_misc,
        name = "misc-constants",
        setting = "propertyrandomizer-misc-properties",
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
        setting = "propertyrandomizer-tech-costs"
    },
    {
        func = rand.tech_times,
        name = "tech-times",
        setting = "propertyrandomizer-tech-costs",
        tags = {"tech", "production-speed", "production"}
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