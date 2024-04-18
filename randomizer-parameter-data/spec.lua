local inertia_function = require("randomizer-parameter-data/inertia-function-tables")
-- property_info will be refactored into a "fix" step afterwards from now on
--local property_info = require("randomizer-parameter-data/property-info-tables")
local walk_params = require("randomizer-parameter-data/walk-params-tables")

local spec = {}

-- TODO: util randomizer

-- Note: This is just for getting potential rolls; karma will be assigned beforehand by upgrade lines
-- Note: Blacklist things during formatting phase so that it's known that they aren't supposed to be randomized rather than just assuming it's fine when they don't have the expected property

-- NUM_RANDS     --> Map of NUM_RAND
-- NUM_RAND      --> Map w/
--                      group = List of GROUP_RAND (see *)
--                      One Of...
--                          *target = TARGET_ID
--                          *targets = List of TARGET_ID
--                          *target_spec = TARGET_SPEC
--                      *property = string of a property name
--  TODO: describe property_group (can include separate inertia functions/special_considerations still, but not separate targets)
--                      *inertia_function = INERTIA_FUNCTION
--                      walk_params = WALK_PARAMS
--                      *special_considerations = List of SPECIAL_CONSIDERATIONS
--                  * means properties that can be overriden in the group spec. If all properties are overriden, they are no longer mandatory in the main table.
spec.basic_numerical = {
    ["ammo-magazine-size"] = {
        target_class = "ammo",
        property = "magazine_size",
        pdf = "magazine_size",
        fixes = "magazine_size"
    },
    ["attack-parameters-gun-cooldown"] = { -- NEW
        target_class = "gun",
        target_type = "AttackParameters",
        property = "cooldown",
        pdf = "gun_cooldown",
        fixes = "none"
    },
    ["attack-parameters-gun-range"] = { -- NEW
        target_class = "gun",
        target = "attack-parameters",
        property = "range"
    },
    ["artillery-turret-rotation-speed"] = { -- NEW
        target_classes = {
            "artillery-turret",
            "artillery-wagon"
        },
        property = "turret_rotation_speed"
    },
    ["beacon-supply-area-distance"] = {
        target_class = "beacon",
        property = "supply_area_distance",
        inertia_function = inertia_function.beacon_supply_area_distance
    },
    ["beacon-distribution-effectivity"] = {
        target_class = "beacon",
        property = "distribution_effectivity",
        inertia_function = inertia_function.beacon_distribution_effectivity
    },
    ["belt-speeds"] = { -- Do belt stitching/linking afterward
        target = "belt-classes",
        property = "speed",
        inertia_function = inertia_function.belt_speed
    },
    ["boiler-consumption"] = {
        target_class = "boiler",
        property = "energy_consumption",
        format = "power"
    },
    ["boiler-temperature"] = {
        target_class = "boiler",
        property = "target_temperature",
        walk_params = walk_params.temperature
    },
    ["bot-energy-movement"] = {
        target = "bot-class",
        property = "energy_per_move",
        format = "energy"
    },
    ["bot-energy-per-tick"] = {
        target = "bot-classes",
        property = "energy_per_tick",
        format = "energy"
    },
    ["bot-speed"] = {
        target = "bot-classes",
        property = "speed",
        inertia_function = inertia_function.bot_speed
    },
    ["burner-generator-power-output"] = {
        target_class = "burner-generator",
        property = "max_power_output",
        format = "power"
    },
    ["capsule-action-destroy-cliffs-radius"] = {
        target = "capsule-action",
        target_type = "destroy-cliffs",
        property = "radius"
    },
    ["car-movement-speed"] = {
        target_class = "car",
        property = "consumption",
        inertia_function = inertia_function.vehicle_speed,
        walk_params = walk_params.vehicle_speed,
        format = "power"
    },
    ["car-rotation-speed"] = {
        target_class = "car",
        property = "rotation_speed",
        inertia_function = inertia_function.car_rotation_speed
    },
    ["car-turret-rotation-speed"] = { -- NEW
        target_class = "car",
        property = "turret_rotation_speed"
    },
    ["character-corpse-time-to-live"] = {
        target_class = "character-corpse",
        property = "time_to_live",
        inertia_function = inertia_function.character_corpse_time_to_live
    },
    ["character-respawn-time"] = {
        target_class = "character",
        property = "respawn_time"
    },
    ["crafting-time-end-products"] = {
        target = "end-product-recipes",
        property = "energy_required",
        inertia_function = inertia_function.energy_required_end_products
    },
    ["crafting-time-intermediates"] = {
        target = "intermediate-recipes",
        property = "energy_required",
        inertia_function = inertia_function.intermediates
    },
    ["electric-energy-interface-production"] = {
        target_class = "electric-energy-interface",
        property = "energy_production",
        format = "power"
    },
    ["electric-energy-interface-consumption"] = {
        target_class = "electric-energy-interface",
        property = "energy_usage",
        format = "power"
    },
    ["electric-pole-supply-area"] = {
        target_class = "electric-pole",
        property = "supply_area_distance",
        inertia_function = inertia_function.electric_pole_supply_area
    },
    ["electric-pole-wire-reach"] = {
        target_class = "electric-pole",
        property = "wire_reach_distance",
        inertia_function = inertia_function.electric_pole_wire_reach
    },
    ["energy-source-burner-effectivity"] = {
        target = "energy-source",
        target_type = "burner",
        property = "effectivity"
    },
    ["energy-source-electric-buffer-capacity"] = {
        target = "energy-source",
        target_type = "electric",
        property = "buffer_capacity",
        format = "energy"
    },
    ["energy-source-electric-drain"] = { -- NEW
        target = "energy-source",
        target_type = "electric",
        property = "drain",
        walk_params = walk_params.electric_energy_drain
    },
    ["energy-source-electric-input-flow-rate"] = {
        target = "energy-source",
        target_type = "electric",
        property = "input_flow_limit",
        format = "power"
    },
    ["energy-source-electric-output-flow-rate"] = {
        target = "energy-source",
        target_type = "electric"
        property = "output_flow_limit",
        format = "power"
    },
    ["energy-source-fluid-effectivity"] = {
        target = "energy-source",
        target_type = "fluid",
        property = "effectivity"
    },
    ["energy-source-fluid-max-temperature"] = {
        target = "energy-source",
        target_type = "fluid",
        property = "maximum_temperature",
        walk_params = walk_params.temperature
    },
    ["energy-source-fluid-usage"] = {
        target = "energy-source",
        target_type = "fluid",
        property = "fluid_usage_per_tick"
    },
    ["energy-source-heat-specific-heat"] = {
        target = "energy-source",
        target_type = "heat",
        property = "specific_heat",
        format = "energy"
    },
    ["energy-source-heat-temperature-max"] = {
        target = "energy-source",
        target_type = "heat",
        property = "max_temperature",
        walk_params = walk_params.temperature
    },
    ["energy-source-heat-temperature-default"] = {
        target = "energy-source",
        target_type = "heat",
        property = "default_temperature",
        walk_params = walk_params.temperature
    },
    ["energy-usage-combinator"] = {
        target = "non-constant-combinator-classes",
        property = "active_energy_usage",
        format = "power"
    },
    ["energy-usage-equipment-belt-immunity"] = {
        target_class = "belt-immunity-equipment",
        property = "energy_consumption",
        format = "power"
    },
    ["energy-usage-equipment-movement-bonus"] = {
        target_class = "movement-bonus-equipment",
        property = "energy_consumption",
        format = "power"
    },
    ["energy-usage-equipment-night-vision"] = {
        target_class = "night-vision-equipment",
        property = "energy_input",
        format = "power"
    },
    ["energy-usage-lamp"] = {
        target_class = "lamp",
        property = "energy_usage_per_tick",
        format = "energy"
    },
    ["energy-usage-machines"] = {
        target_classes = {
            "beacon",
            "assembling-machine",
            "rocket-silo",
            "furnace",
            "lab",
            "mining-drill",
            "radar"
        },
        property = "energy_usage",
        format = "power"
    },
    ["energy-usage-programmable-speaker"] = {
        target_class = "programmable-speaker",
        property = "energy_usage_per_tick",
        format = "energy"
    },
    ["entity-heal-rate"] = { -- NEW
        target = "entity-with-health-classes",
        property = "healing_per_tick"
    },
    ["entity-health-non-sensitive"] = {
        target = "entity-with-health-non-sensitive",
        property = "max_health",
        inertia_function = inertia_function.max_health
    },
    ["entity-health-sensitive"] = {
        target = "entity-with-health-sensitive",
        property = "max_health",
        inertia_function = inertia_function.max_health_sensitive
    },
    ["entity-repair-speed-modifier"] = {
        target = "entity-with-health-classes",
        property = "repair_speed_modifier",
        inertia_function = inertia_function.entity_interaction_repair_speed
    },
    ["equipment-energy-shield-energy"] = {
        target_class = "energy-shield-equipment",
        property = "energy_per_shield",
        format = "energy"
    },
    ["equipment-grid-height"] = {
        target_class = "equipment-grid",
        property = "height"
    },
    ["equipment-grid-width"] = {
        target_class = "equipment-grid",
        property = "width"
    },
    ["fluid-heat-capacity"] = {
        target_class = "fluid",
        property = "heat_capacity",
        format = "energy"
    },
    ["fluid-emissions-multiplier"] = {
        target_class = "fluid",
        property = "emissions_multiplier"
    },
    ["fuel-value-fluids"] = {
        target_class = "fluid",
        property = "fuel-value",
        format = "energy"
    },
    ["fuel-value-items"] = {
        target = "item-prototypes",
        property = "fuel-value",
        format = "energy"
    },
    ["gate-opening-speed"] = {
        target_class = "gate",
        property = "opening_speed",
        inertia_function = inertia_function.gate_opening_speed
    },
    ["generator-effectivity"] = {
        target_class = "generator",
        property = "effectivity"
    },
    ["generator-fluid-usage-per-tick"] = {
        target_class = "generator",
        property = "fluid_usage_per_tick"
    },
    ["generator-max-power"] = {
        target_class = "generator",
        property = "max_power_output",
        format = "power"
    },
    ["generator-maximum-temperature"] = {
        target_class = "generator",
        property = "maximum_temperature",
        walk_params = walk_params.temperature
    },
    ["gun-damage-modifier"] = {
        target_class = "gun",
        target = "attack_parameters",
        property = "damage_modifier",
        walk_params = walk_params.gun_damage_modifier
    },
    ["gun-range"] = {
        target_class = "gun",
        target = "attack_parameters",
        property = "range"
    },
    ["gun-speed"] = {
        target_class = "gun",
        target = "attack_parameters",
        property = "cooldown"
    },
    ["heat-buffer-specific-heat"] = {
        target = "heat-buffer",
        property = "specific_heat",
        format = "energy"
    },
    ["heat-buffer-temperature-max"] = {
        target = "heat-buffer",
        property = "max_temperature",
        walk_params = walk_params.temperature
    },
    ["heat-buffer-temperature-default"] = {
        target = "heat-buffer",
        property = "default_temperature",
        walk_params = walk_params.temperature
    },
    ["heat-buffer-temperature-min"] = {
        targets = {
            "heat-buffer",
            "heat-energy-source"
        },
        property = "min_working_temperature",
        walk_params = walk_params.temperature
    },
    ["heat-buffer-transfer-rate"] = {
        targets = {
            "heat-buffer",
            "heat-energy-source"
        },
        property = "max_transfer",
        format = "power"
    },
    ["inserter-energy-extension"] = {
        target_class = "inserter",
        property = "energy_per_movement",
        format = "energy"
    },
    ["inserter-energy-rotation"] = {
        target_class = "inserter",
        property = "energy_per_rotation",
        format = "energy"
    },
    ["inserter-speed-extension"] = {
        target_class = "inserter",
        property = "extension_speed",
        inertia_function = inertia_function.inserter_extension_speed
    },
    ["inserter-speed-rotation"] = {
        target_class = "inserter"
        property = "rotation_speed",
        inertia_function = inertia_function.inserter_rotation_speed
    },
    ["inventory-slots-containers"] = {
        target = "container-classes",
        property = "inventory_size",
        inertia_function = inertia_function.inventory_size
    },
    ["inventory-slots-fuel"] = {
        target = "burner-energy-source",
        property = "fuel_inventory_size",
        inertia_function = inertia_function.energy_source_inventory_sizes
    },
    ["inventory-slots-turret"] = {
        target_classes = {
            "artillery-turret",
            "artillery-wagon",
            "ammo-turret"
        },
        property = "inventory_size",
        inertia_function = inertia_function.inventory_size
    },
    ["inventory-slots-vehicle"] = {
        target_classes = {
            "spider-vehicle",
            "car",
            "cargo-wagon"
        },
        property = "inventory_size",
        inertia_function = inertia_function.inventory_size
    },
    ["item-stack-sizes"] = {
        target = "item-classes",
        property = "stack_size",
        inertia_function = inertia_function.stack_size,
        walk_params = walk_params.stack_size
    },
    ["lab-research-speed"] = {
        target_class = "lab",
        property = "researching_speed",
        inertia_function = inertia_function.researching_speed,
        walk_params = walk_params.research_speed
    },
    ["locomotive-speed"] = {
        target_class = "locomotive",
        property = "max_power",
        inertia_function = inertia_function.vehicle_speed,
        walk_params = walk_params.vehicle_speed,
        format = "power"
    },
    ["machine-crafting-speeds"] = {
        target = "crafting-machine-classes",
        property = "crafting_speed",
        inertia_function = inertia_function.crafting_speed
    },
    ["machine-emissions"] = {
        target = "emission-producing-energy_source",
        property = "emissions_per_minute"
    },
    ["minable-time-non-resource"] = {
        target = "non-mining-sensitive-entity-classes",
        target_sub_table = "minable",
        property = "mining_time",
        inertia_function = inertia_function.entity_interaction_mining_speed
    },
    ["minable-time-resource"] = { -- NEW
        target = "mining-sensitive-entity-classes",
        target_sub_table = "minable",
        property = "mining_time",
        inertia_function = inertia_function.resource_mining_speed
    }
    ["mining-drill-productivity"] = {
        target_class = "mining-drill",
        property = "base_productivity"
    },
    ["mining-drill-speeds"] = {
        target_class = "mining-drill",
        property = "mining_speed",
        inertia_function = inertia_function.machine_mining_speed
    },
    ["module-effect-efficiency-bonus"] = {
        target = "consumption-module-effect",
        property = "bonus",
        inertia_function = inertia_function.consumption_effect
    },
    ["module-effect-productivity-bonus"] = {
        target = "productivity-module-effect",
        property = "bonus",
        inertia_function = inertia_function.productivity_bonus
    },
    ["module-effect-pollution-bonus"] = {
        target = "pollution-module-effect",
        property = "bonus",
        inertia_function = inertia_function.productivity_bonus
    },
    ["module-effect-speed-bonus"] = {
        target = "speed-module-effect",
        property = "bonus",
        inertia_function = inertia_function.speed_effect
    },
    ["offshore-pump-speed"] = {
        target_class = "offshore-pump",
        property = "pumping_speed",
        inertia_function = inertia_function.offshore_pumping_speed,
        walk_params = walk_params.offshore_pumping_speed
    },
    ["pipe-to-ground-distance"] = {
        target = "pipe-connection-definition",
        target_class = "pipe-to-ground",
        property = "max_underground_distance"
    },
    ["projectile-damage"] = {
        target_class = "projectile",
        target = "trigger-effect-item",
        target_type = "damage",
        target_sub_table = "damage",
        property = "amount",
        inertia_function = inertia_function.projectile_damage,
        walk_params = walk_params.projectile_damage
    },
    ["pump-speed"] = {
        target_class = "pump",
        property = "pumping_speed"
    },
    ["radar-area-revealed"] = {
        target_class = "radar",
        property = "max_distance_of_nearby_sector_revealed",
        inertia_function = inertia_function.radar
    },
    ["radar-area-scanned"] = {
        target_class = "radar",
        property = "max_distance_of_sector_revealed",
        inertia_function = inertia_function.radar
    },
    ["reactor-consumption"] = {
        target_class = "reactor",
        property = "consumption",
        format = "power"
    },
    ["reactor-neighbour-bonus"] = {
        target_class = "reactor",
        property = "neighbour_bonus"
    },
    ["repair-tool-speed"] = {
        target_class = "repair-tool",
        property = "speed"
    },
    ["roboport-charging-count"] = {
        target_class = "roboport",
        property = "charging_station_count",
        inertia_function = inertia_function.charging_station_count
    },
    ["roboport-charging-power"] = {
        target_class = "roboport",
        property = "charging_energy",
        format = "power"
    },
    ["roboport-construction-area"] = {
        target_class = "roboport",
        property = "construction_radius"
    },
    ["roboport-logistic-area"] = {
        target_class = "roboport",
        property = "logistics_radius"
    },
    ["roboport-logistics-connection-distance"] = {
        target_class = "roboport",
        property = "logistics_connection_distance"
    },
    ["roboport-material-slots-count"] = {
        target_class = "roboport",
        property = "material_slots_count",
        inertia_function = inertia_function.inventory_slots
    },
    ["roboport-robot-slots-count"] = {
        target_class = "roboport",
        property = "robot_slots_count",
        inertia_function = inertia_function.inventory_slots
    },
    ["solar-panel-production"] = {
        target_class = "solar-panel",
        property = "production",
        format = "power"
    },
    ["spidertron-speed"] = {
        target_class = "spider-vehicle",
        property = "movement_energy_consumption",
        inertia_function = inertia_function.vehicle_speed,
        walk_params = walk_params.vehicle_speed,
        format = "power"
    },
    ["storage-tank-capacity"] = {
        target_class = "storage-tank",
        target = "fluid-box",
        property = "base-area"
    },
    ["technology-cost"] = {
        target = "technology-unit",
        property = "count",
        inertia_function = inertia_function.tech_count
    },
    ["technology-time"] = {
        target = "technology-unit",
        property = "time",
        inertia_function = inertia_function.tech_time
    },
    ["tile-walking-speed-modifier"] = {
        target_class = "tile",
        property = "walking_speed_modifier",
        inertia_function = inertia_function.tile_walking_speed_modifier,
        walk_params = walk_params.tile_walking_speed_modifier
    },
    ["turret-rotation-speed"] = { -- NEW
        target_classes = {
            "ammo-turret",
            "electric-turret",
            "fluid-turret"
        },
        property = "rotation_speed"
    },
    ["underground-belt-distance"] = {
        target_class = "underground-belt",
        property = "max_distance",
        inertia_function = inertia_function.underground_belt_length,
        walk_params = walk_params.underground_belt_length
    },
    ["utility-constants-inventory-widths"] = { -- NEW
        target_class = "utility-constants",
        property = inventory_width,
        inertia_function = inertia_function.utility_constant_inventory_width
    },
    ["vehicle-crash-damage"] = {
        target = "vehicle-classes",
        property = "energy_per_hit_point",
        inertia_function = inertia_function.vehicle_crash_damage
    }
}

-- Complex randomizations:
--      * Cliff sizes and collision boxes in general
--      * Inserter pickup & dropoffs
--      * Mining drill dropoffs
--      * Infinite tech count formulas
--      * Random fluids for fluid turrets
--      * Resistances (need player to be able to also specify types not to randomize, or maybe test for which types are more sensitive and such)

-- Fixes:
--      * Mining drill productivity (the ore mining changes setup)
--      * Module slot numbers
--      * Switch roboport areas or radar scan areas if they're "out of order"