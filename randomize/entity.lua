require("randomize/energy")
require("randomize/types")

require("globals")
require("linking-utils")

local inertia_function = require("randomizer-parameter-data/inertia-function-tables")
local property_info = require("randomizer-parameter-data/property-info-tables")
local prototype_tables = require("randomizer-parameter-data/prototype-tables")
local walk_params = require("randomizer-parameter-data/walk-params-tables")

rand.beacon_supply_area_distance = function(prototype)
    if prototype.type == "beacon" then
        randomize_numerical_property({
            prototype = prototype,
            property = "supply_area_distance",
            inertia_function = inertia_function.beacon_supply_area_distance,
            property_info = property_info.supply_area_beacon
        })
    end
end

rand.beacon_distribution_effectivity = function(prototype)
    if prototype.type == "beacon" then
        randomize_numerical_property({
            prototype = prototype,
            property = "distribution_effectivity",
            inertia_function = inertia_function.beacon_distribution_effectivity,
            property_info = property_info.effectivity_beacon
        })
    end
end

rand.belt_speed = function()
    local min_bias = 0.45
    local max_bias = 0.6
    local prototype_bias_dict = {}
    local belt_tier_groups = {}

    -- Calculate the biases to seperate the belts out
    for _, belt_class in pairs(prototype_tables.transport_belt_classes) do
        for _, prototype1 in pairs(data.raw[belt_class]) do
            local num_worse_speed = 0
            local total_num = 0

            for _, prototype2 in pairs(data.raw[belt_class]) do
                if prototype2.speed < prototype1.speed then
                    num_worse_speed = num_worse_speed + 1
                elseif prototype2.speed == prototype1.speed then
                    num_worse_speed = num_worse_speed + 0.5
                end

                total_num = total_num + 1
            end

            local speed_score = num_worse_speed / total_num
            prototype_bias_dict[prototype1.name] = min_bias * (1 - speed_score) + max_bias * speed_score
        end
    end

    for transport_belt_prototype_name, transport_belt_prototype in pairs(data.raw["transport-belt"]) do
        local belt_tier_prototypes = {}

        for _, other_belt_class in pairs(prototype_tables.transport_belt_classes) do
            for _, other_belt_prototype in pairs(data.raw[other_belt_class]) do
                if other_belt_prototype.speed == transport_belt_prototype.speed then
                    table.insert(belt_tier_prototypes, other_belt_prototype)
                end
            end
        end

        belt_tier_groups[transport_belt_prototype_name] = belt_tier_prototypes
    end

    for _, belt_class in pairs(prototype_tables.transport_belt_classes) do
        for _, prototype in pairs(data.raw[belt_class]) do
            local bias_to_use = prototype_bias_dict[prototype.name]
            -- Make bias higher without syncing belt tiers to account for fact that lowest belt speed slows down everything else
            if not sync_belt_tiers then
                bias_to_use = bias_to_use + 0.03
            end

            randomize_numerical_property({
                prototype = prototype,
                property = "speed",
                inertia_function = inertia_function.belt_speed,
                walk_params = {
                    bias = prototype_bias_dict[prototype.name]
                },
                property_info = property_info.belt_speed
            })
        end
    end

    if sync_belt_tiers then
        for belt_tier_group_base_belt, belt_tier_group in pairs(belt_tier_groups) do
            for _, other_belt in pairs(belt_tier_group) do
                other_belt.speed = data.raw["transport-belt"][belt_tier_group_base_belt].speed
            end
        end
    end
end

rand.bot_speed = function(prototype)
    -- TODO: Also randomize max_speed
    if prototype_tables.bot_classes_as_keys[prototype.type] then
        local old_speed = prototype.speed

        randomize_numerical_property({
            prototype = prototype,
            property = "speed",
            inertia_function = inertia_function.bot_speed,
            walk_params = walk_params.bot_speed,
            property_info = property_info.bot_speed
        })

        if prototype.max_speed ~= nil and old_speed ~= 0 then
            prototype.max_speed = prototype.max_speed * prototype.speed / old_speed
        end
    end
end

rand.car_rotation_speed = function(prototype)
    if prototype.type == "car" then
        randomize_numerical_property({
            prototype = prototype,
            property = "rotation_speed",
            inertia_function = inertia_function.car_rotation_speed,
            property_info = property_info.car_rotation_speed
        })
    end
end

rand.character_corpse_time_to_live = function(prototype)
    if prototype.type == "character-corpse" then
        randomize_numerical_property({
            prototype = prototype,
            property = "time_to_live",
            inertia_function = inertia_function.character_corpse_time_to_live,
            property_info = property_info.character_corpse_time_to_live
        })
    end
end

rand.respawn_time = function(prototype)
    if prototype.type == "character" then
        if prototype.respawn_time == nil then
            prototype.respawn_time = 10
        end

        randomize_numerical_property({
            prototype = prototype,
            property = "respawn_time",
            property_info = property_info.character_respawn_time
        })
    end
end

rand.crafting_machine_speed = function(prototype)
    if prototype_tables.crafting_machine_classes_as_keys[prototype.type] then
        -- Note: Removed burner bias bonus

        randomize_numerical_property({
            prototype = prototype,
            property = "crafting_speed",
            inertia_function = inertia_function.crafting_speed,
            property_info = property_info.machine_speed
        })
    end
end

rand.electric_poles = function() -- TODO: Add back in prototype-based rando
    local points = {}
    for point_label, prototype in pairs(data.raw["electric-pole"]) do
        -- TODO: Blacklist check
        local point = {}
        point[1] = prototype.supply_area_distance
        point[2] = prototype.maximum_wire_distance
        table.insert(points, point)
    end

    randomize_points_in_space{
        points = points,
        dimension_information = {
            {
                inertia_function = inertia_function.electric_pole_supply_area,
                property_info = property_info.supply_area
            },
            {
                inertia_function = inertia_function.electric_pole_wire_reach,
                property_info = property_info.wire_distance
            }
        },
        prg_key = prg.get_key("electric-pole", "class")
    }

    local index = 1
    for _, prototype in pairs(data.raw["electric-pole"]) do
        prototype.supply_area_distance = points[index][1]
        prototype.maximum_wire_distance = points[index][2]
        index = index + 1
    end

    -- Add back in parity/centering supply squares on poles
    for _, prototype in pairs(data.raw["electric-pole"]) do
        local odd_placement = false
        local even_placement = false
        if prototype.tile_width ~= nil and prototype.tile_width % 2 == 0 then
            even_placement = true
        elseif prototype.tile_width ~= nil and prototype.tile_width % 2 == 1 then
            odd_placement = true
        end
        if prototype.tile_height ~= nil and prototype.tile_height % 2 == 0 then
            even_placement = true
        elseif prototype.tile_height ~= nil and prototype.tile_height % 1 then
            odd_placement = true
        end
    
        if prototype.collision_box ~= nil then
            local collision_box_width_parity = math.floor(prototype.collision_box[2][1] - prototype.collision_box[1][1] + 0.5) % 2
            local collision_box_height_parity = math.floor(prototype.collision_box[2][2] - prototype.collision_box[1][2] + 0.5) % 2
            if prototype.tile_width == nil and collision_box_width_parity == 0 then
                even_placement = true
            elseif prototype.tile_height == nil and collision_box_height_parity == 1 then
                odd_placement = true
            end
        else
            even_placement = true
            odd_placement = true
        end

        if odd_placement == false then
            prototype.supply_area_distance = math.min(64, math.floor(prototype.supply_area_distance + 1) - 0.5)
        elseif even_placement == false then
            prototype.supply_area_distance = math.min(64, math.floor(prototype.supply_area_distance + 0.5))
        end
    end

    for _, prototype in pairs(data.raw["electric-pole"]) do
        if prototype.supply_area_distance > prototype.maximum_wire_distance then
            prototype.maximum_wire_distance = prototype.supply_area_distance
        end
    end
end

rand.non_resource_mining_speeds = function(prototype)
    if prototype_tables.entities_to_modify_mining_speed_as_keys[prototype.type] then
        if prototype.minable ~= nil then
            randomize_numerical_property({
                prototype = prototype,
                tbl = prototype.minable,
                property = "mining_time",
                inertia_function = inertia_function.entity_interaction_mining_speed,
                property_info = property_info.entity_interaction_mining_speed
            })
        end
    end
end

rand.repair_speed_modifiers = function(prototype)
    if prototype_tables.entities_with_health_as_keys[prototype.type] then
        if prototype.repair_speed_modifier == nil then
            prototype.repair_speed_modifier = 1
        end

        randomize_numerical_property({
            prototype = prototype,
            property = "repair_speed_modifier",
            inertia_function = inertia_function.entity_interaction_repair_speed,
            property_info = property_info.entity_interaction_repair_speed
        })
    end
end

rand.cliff_sizes = function(prototype)
    local function change_image_size(picture, factor)
        if picture.layers ~= nil then
            for _, layer in pairs(picture.layers) do
                change_image_size(layer, factor)
            end
        else
            if picture.hr_version ~= nil then
                change_image_size(picture.hr_version, factor)
            end
      
            if picture.scale == nil then
                picture.scale = 1
            end
      
            picture.scale = picture.scale * factor
        end
    end

    if prototype.type == "cliff" then
        for _, orientation in pairs(prototype.orientations) do
            local factor = randomize_numerical_property{
                inertia_function = inertia_function.cliff_size,
                prg_key = prg.get_key(prototype),
                property_info = property_info.cliff_size
            }
    
            for _, vector in pairs(orientation.collision_bounding_box) do
                -- Just ignore the orientation number, api docs say it seems to be unused
                if type(vector) ~= "number" then
                    vector[1] = vector[1] * factor
                    vector[2] = vector[2] * factor
                end
            end
    
            if pictures.filename ~= nil or pictures.layers ~= nil then
                change_image_size(orientation.pictures, factor)
            else
                for _, picture in pairs(orientation.pictures) do
                    change_image_size(picture, factor)
                end
            end
        end
    end
end

rand.fuel_inventory_slots = function(prototype)
    local energy_sources = {}
    if prototype.energy_source and prototype.energy_source.type == "burner" then
        table.insert(energy_sources, prototype.energy_source)
    end
    if prototype.burner ~= nil then
        table.insert(energy_sources, prototype.burner)
    end

    for _, energy_source in pairs(energy_sources) do
        log(energy_source.fuel_inventory_size)

        randomize_numerical_property({
            prototype = prototype,
            tbl = energy_source,
            property = "fuel_inventory_size",
            inertia_function = inertia_function.energy_source_inventory_sizes,
            walk_params = walk_params.fuel_inventory_size,
            property_info = property_info.small_nonempty_inventory
        })

        log(energy_source.fuel_inventory_size)
    end
end

rand.gate_opening_speed = function(prototype)
    if prototype.type == "gate" then
        local old_opening_speed = prototype.opening_speed

        randomize_numerical_property({
            prototype = prototype,
            property = "opening_speed",
            inertia_function = inertia_function.gate_opening_speed,
            property_info = property_info.gate_opening_speed
        })

        if prototype.opening_speed > 0 then
            prototype.activation_distance = prototype.activation_distance * old_opening_speed / prototype.opening_speed
        end
    end
end

rand.non_sensitive_max_health = function(prototype)
    if prototype_tables.entities_with_health_non_sensitive_as_keys[prototype.type] then
        if prototype.max_health == nil then
            prototype.max_health = 10
        end

        randomize_numerical_property({
            prototype = prototype,
            property = "max_health",
            inertia_function = inertia_function.max_health,
            property_info = property_info.max_health
        })
    end
end

rand.sensitive_max_health = function(prototype)
    if prototype_tables.entities_with_health_sensitive[prototype.type] then
        if prototype.max_health == nil then
            prototype.max_health = 10
        end

        randomize_numerical_property({
            prototype = prototype,
            property = "max_health",
            inertia_function = inertia_function.max_health_sensitive,
            property_info = property_info.max_health_sensitive
        })
    end
end

rand.inserter_offsets = function(prototype)
    local inserter_insert_positions = {
        {0, 1.2}, -- Standard
        {0, 0.8}, -- Near
        {0, 2.2}, -- Far
        {0, 4.2}, -- Very far
        {-1, 0}, -- To the side
        {1, 1}, -- Diagonal
        {0, -1.2} -- "Back where it came from"
    }
      
    local inserter_pickup_positions = {
        {0, -1}, -- Standard
        {0, -1.2}, -- Other side of the belt
        {0, -2}, -- Long-handed
        {0, -4}, -- Very long-handed
        {1, 0}, -- To the side
        {-1, -1}, -- Diagonal
        {-1.2, -0.2}, -- Diagonal, sorta?
        {-2.2, 7.2} -- Huh?
    }

    if prototype.type == "inserter" then
        -- Only do "normal-size" inserters for now, bigger collision boxes can break things
        if prototype.collision_box ~= nil and prototype.collision_box[1][1] == -0.15 and prototype.collision_box[1][2] == -0.15 and prototype.collision_box[2][1] == 0.15 and prototype.collision_box[2][2] == 0.15 then
            local key = prg.get_key(prototype)

            local inserter_position_variable = prg.range(key, 1, 18)

            -- 2 / 3 chance to change to a different type of insert position
            if 1 <= inserter_position_variable and inserter_position_variable <= 12 then
                prototype.insert_position = inserter_insert_positions[prg.range(key, 1, #inserter_insert_positions)]
            end

            -- 2 / 3 chance to change to a different type of pickup position
            if 3 <= inserter_position_variable and inserter_position_variable <= 14 then
                prototype.pickup_position = inserter_pickup_positions[prg.range(key, 1, #inserter_pickup_positions)]
            end
        end

        -- TODO: Add back in check that inserters don't "softlock"
    end
end

rand.inserter_speed = function(prototype)
    if prototype.type == "inserter" then
        randomize_numerical_property({
            group_params = {
                {
                    prototype = prototype,
                    property = "rotation_speed",
                    inertia_function = inertia_function.inserter_rotation_speed,
                    property_info = property_info.inserter_rotation_speed
                },
                {
                    prototype = prototype,
                    property = "extension_speed",
                    inertia_function = inertia_function.inserter_extension_speed,
                    property_info = property_info.inserter_extension_speed
                }
            }
        })
    end
end

rand.inventory_sizes = function(prototype)
    if prototype_tables.inventory_names[prototype.type] ~= nil then
        for _, property_name in pairs(prototype_tables.inventory_names[prototype.type]) do
            -- I have to turn these to numbers because some modders are writing inventory sizes as strings somehow
            prototype[property_name] = tonumber(prototype[property_name])

            -- Don't randomize inventories of size zero (they probably are meant to be empty)
            if prototype[property_name] > 0 then
                local property_info_to_use
                if prototype[property_name] < 10 then
                    property_info_to_use = property_info.small_nonempty_inventory
                else
                    property_info_to_use = property_info.large_inventory
                end

                randomize_numerical_property({
                    prototype = prototype,
                    property = property_name,
                    inertia_function = inertia_function.inventory_size,
                    property_info = property_info_to_use
                })
            end
        end
    end
end

rand.lab_research_speed = function(prototype)
    if prototype.type == "lab" then
        if prototype.researching_speed == nil then
            prototype.researching_speed = 1
        end

        randomize_numerical_property({
            prototype = prototype,
            property = "researching_speed",
            inertia_function = inertia_function.researching_speed,
            property_info = property_info.researching_speed
        })
    end
end

rand.landmine_damage = function(prototype)
    if prototype.type == "land-mine" and prototype.action ~= nil then
        rand.trigger(prototype, prototype.action, "randomize-damage-loose")
    end
end

rand.landmine_effect_radius = function(prototype)
    if prototype.type == "land-mine" and prototype.action ~= nil then
        rand.trigger(prototype, prototype.action, "randomize-effect-radius")
    end
end

rand.landmine_trigger_radius = function(prototype)
    if prototype.type == "land-mine" then
        randomize_numerical_property({
            prototype = prototype,
            property = "trigger_radius",
            property_info = property_info.limited_range
        })
    end
end

rand.landmine_timeout = function(prototype)
    if prototype.type == "land-mine" then
        if prototype.timeout == nil then
            prototype.timeout = 120
        end

        randomize_numerical_property({
            prototype = prototype,
            property = "timeout",
            property_info = property_info.limited_range
        })
    end
end

rand.machine_pollution = function(prototype)
    if prototype_tables.polluting_machine_classes[prototype.type] ~= nil then
        -- TODO: This can probably just be a single property and not a table
        for _, polluting_energy_source_name in pairs(prototype_tables.polluting_machine_classes[prototype.type]) do
            randomize_numerical_property({
                prototype = prototype,
                tbl = prototype[polluting_energy_source_name],
                property = "emissions_per_minute",
                property_info = property_info.machine_pollution
            })
        end
    end
end

rand.mining_drill_dropoff_location = function(prototype)
    if prototype.type == "mining-drill" then
        -- TODO: Need to check that this isn't a purely fluid-based thing, which is usually indicated by a (0,0) place vector
        -- Fluid-based dropoffs can't be changed due to fluid-box restrictions
        if prototype.vector_to_place_result[1] ~= 0 or prototype.vector_to_place_result[2] ~= 0 then
            randomize_numerical_property({
                prototype = prototype,
                tbl = prototype.vector_to_place_result,
                property = 1,
                inertia_function = inertia_function.mining_drill_dropoff,
                property_info = property_info.mining_drill_dropoff_horizontal
            })

            -- TODO: How to deal with mining drill offsets being near original dropoff vertically a lot
            randomize_numerical_property({
                prototype = prototype,
                tbl = prototype.vector_to_place_result,
                property = 2,
                inertia_function = inertia_function.mining_drill_dropoff,
                property_info = property_info.mining_drill_dropoff_vertical
            })
        end
    end
end

rand.mining_results_tree_rock = function(prototype)
    -- Assume it's a rock if it's a simple entity and its autoplace is non-nil
    -- TODO: Is there a better way to do this? Maybe keep this setting off in case of mod incompatibilities
    -- TODO: Hard code rocks in the future, but I'll need to do this for alien biomes too
    if (prototype.type == "tree" or prototype.type == "simple-entity") and prototype.autoplace ~= nil and prototype.minable ~= nil then
        local minable = prototype.minable
    
        -- TODO: Do a reformat on minable properties
        if minable.results ~= nil then
            for _, result in pairs(minable.results) do
                reformat.type.product_prototyte(result)
      
                randomize_numerical_property({
                    prototype = prototype,
                    tbl = result,
                    property = "amount",
                    property_info = property_info.limited_range
                })
      
                randomize_numerical_property({
                    group_params = {
                        {
                            prototype = prototype,
                            tbl = result,
                            property = "amount_min",
                            property_info = property_info.limited_range
                        },
                        {
                            prototype = prototype,
                            tbl = result,
                            property = "amount_max",
                            property_info = property_info.limited_range
                        }
                    }
                })
            end
        else
            if minable.count == nil then
                minable.count = 1
            end
    
            randomize_numerical_property({
                prototype = prototype,
                tbl = minable,
                property = "count",
                property_info = property_info.limited_range
            })
        end
    end
end

rand.mining_speeds = function(prototype)
    if prototype.type == "mining-drill" then
        -- Note: No more burner machine bias for now
        randomize_numerical_property({
            prototype = prototype,
            property = "mining_speed",
            inertia_function = inertia_function.machine_speed,
            property_info = property_info.mining_speed
        })
    end
end

rand.module_slots = function(prototype)
    if prototype_tables.machines_with_module_slots_as_keys[prototype.type] then
        -- TODO: Maybe randomize adding module slots to things that don't have module slots
        -- I used to do this but then decided against recently

        if prototype.module_specification ~= nil and prototype.module_specification.module_slots ~= nil and prototype.module_specification.module_slots > 0 then
            randomize_numerical_property({
                prototype = prototype,
                tbl = prototype.module_specification,
                property = "module_slots",
                inertia_function = inertia_function.module_specification,
                property_info = property_info.small_nonempty_inventory -- TODO: In chaos mode, allow zero module slots
            })
        end
    end
end

rand.offshore_pump_speed = function(prototype)
    if prototype.type == "offshore-pump" then
        randomize_numerical_property({
            prototype = prototype,
            property = "pumping_speed",
            inertia_function = inertia_function.offshore_pumping_speed,
            property_info = property_info.offshore_pumping_speed,
            walk_params = walk_params.offshore_pumping_speed
        })
    end
end

rand.pump_pumping_speed = function(prototype)
    if prototype.type == "pump" then
        -- Need to make sure fluid box is similarly modified to allow for the increased/decreased pumping speed
        if prototype.fluid_box.height == nil then
            prototype.fluid_box.height = 1
        end
        local old_fluid_box_height = prototype.fluid_box.height

        randomize_numerical_property({
            group_params = {
                {
                    prototype = prototype,
                    property = "pumping_speed",
                    property_info = property_info.pump_pumping_speed
                },
                {
                    prototype = prototype,
                    tbl = prototype.fluid_box,
                    property = "height"
                }
            }
        })

        if prototype.fluid_box.base_area == nil then
            prototype.fluid_box.base_area = 1
        end
        -- Fluid box height must be greater than zero so we don't need to check for that
        prototype.fluid_box.base_area = prototype.fluid_box.base_area * old_fluid_box_height / prototype.fluid_box.height
    end
end

rand.radar_search_area = function(prototype)
    if prototype.type == "radar" then
        randomize_numerical_property({
            prototype = prototype,
            property = "max_distance_of_sector_revealed",
            inertia_function = inertia_function.radar,
            property_info = property_info.radar_reveal_areas
        })
    end
end

rand.radar_reveal_area = function(prototype)
    if prototype.type == "radar" then
        randomize_numerical_property({
            prototype = prototype,
            property = "max_distance_of_nearby_sector_revealed",
            inertia_function = inertia_function.radar,
            property_info = property_info.radar_reveal_areas
        })
    end
end

rand.reactor_neighbour_bonus = function(prototype) -- TODO: Move this to energy randomizer
    if prototype.type == "reactor" then
        if prototype.neighbour_bonus == nil then
            prototype.neighbour_bonus = 1
        end

        randomize_numerical_property{
            prototype = prototype,
            property = "neighbour_bonus",
            property_info = property_info.neighbour_bonus
        }
    end
end

rand.rocket_parts_required = function(prototype)
    if prototype.type == "rocket-silo" then
        randomize_numerical_property({
            prototype = prototype,
            property = "rocket_parts_required",
            property_info = property_info.rocket_silo_rockets_required
        })
    end
end

rand.rocket_silo_launch_time = function(prototype)
    if prototype.type == "rocket-silo" then
        randomize_numerical_property({
            prototype = prototype,
            property = "times_to_blink",
            inertia_function = inertia_function.rocket_launch_length,
            walk_params = walk_params.rocket_launch_length,
            property_info = property_info.rocket_launch_length
        })
      
        randomize_numerical_property({
            prototype = prototype,
            property = "light_blinking_speed",
            inertia_function = inertia_function.rocket_launch_length,
            walk_params = walk_params.rocket_launch_speed,
            property_info = property_info.rocket_launch_speed
        })
      
        randomize_numerical_property({
            prototype = prototype,
            property = "door_opening_speed",
            inertia_function = inertia_function.rocket_launch_length,
            walk_params = walk_params.rocket_launch_speed,
            property_info = property_info.rocket_launch_speed
        })
      
        if prototype.rocket_rising_delay == nil then
            prototype.rocket_rising_delay = 30
        end
        randomize_numerical_property({
            prototype = prototype,
            property = "rocket_rising_delay",
            inertia_function = inertia_function.rocket_launch_length,
            walk_params = walk_params.rocket_launch_length,
            property_info = property_info.rocket_launch_length
        })
      
        if prototype.launch_wait_time == nil then
            prototype.launch_wait_time = 120
        end
        randomize_numerical_property({
            prototype = prototype,
            property = "launch_wait_time",
            inertia_function = inertia_function.rocket_launch_length,
            walk_params = walk_params.rocket_launch_length,
            property_info = property_info.rocket_launch_length
        })
    end
end

rand.roboport_inventory = function(prototype)
    if prototype.type == "roboport" then
        randomize_numerical_property({
            prototype = prototype,
            property = "material_slots_count",
            inertia_function = inertia_function.inventory_slots,
            property_info = property_info.inventory_slots
        })
        
        randomize_numerical_property({
            prototype = prototype,
            property = "robot_slots_count",
            inertia_function = inertia_function.inventory_slots,
            property_info = property_info.inventory_slots
        })
    end
end

rand.roboport_charging_energy = function(prototype)
    if prototype.type == "roboport" then
        -- TODO: Add checks to make sure roboport charging energy isn't too low for engine to complain
        rand.energy({
            is_power = true,
            prototype = prototype,
            tbl = prototype,
            property = "charging_energy",
            property_info = property_info.limited_range
        })
    end
end

rand.roboport_charging_station_count = function(prototype)
    if prototype.type == "roboport" then
        -- TODO: Keep the charging offsets instead of discarding these vectors entirely (or just make them charge in a circle)
        if prototype.charging_station_count == nil or prototype.charging_station_count == 0 then
            if prototype.charging_offsets ~= nil then
                prototype.charging_station_count = #prototype.charging_offsets
            else
                prototype.charging_station_count = 0
            end
        end

        -- Don't randomize roboports that can't charge bots anyways
        if prototype.charging_station_count ~= 0 then
            randomize_numerical_property({
                prototype = prototype,
                property = "charging_station_count",
                inertia_function = inertia_function.charging_station_count,
                property_info = property_info.charging_station_count
            })
        end
    end
end

rand.roboport_logistic_radius = function(prototype)
    if prototype.type == "roboport" then
        if prototype.logistics_connection_distance == nil then
            prototype.logistics_connection_distance = prototype.logistics_radius
        end
        local old_logistics_radius = prototype.logistics_radius

        randomize_numerical_property({
            prototype = prototype,
            property = "logistics_radius",
            property_info = property_info.roboport_radius
        })

        if old_logistics_radius ~= 0 then
            prototype.logistics_connection_distance = prototype.logistics_connection_distance * prototype.logistics_radius / old_logistics_radius
        end
    end
end

rand.roboport_construction_radius = function(prototype)
    if prototype.type == "roboport" then
        local keep_construction_radius_bigger = false
        if prototype.construction_radius >= prototype.logistics_radius + 1 then
            keep_construction_radius_bigger = true
        end

        randomize_numerical_property({
            prototype = prototype,
            property = "construction_radius",
            property_info = property_info.roboport_radius
        })

        if keep_construction_radius_bigger and prototype.construction_radius < prototype.logistics_radius + 1 then
            prototype.construction_radius = prototype.logistics_radius + 1
        end
    end
end

rand.storage_tank_capacity = function(prototype)
    if prototype.type == "storage-tank" then
        if prototype.fluid_box.base_area == nil then
            prototype.fluid_box.base_area = 1
        end
        
        randomize_numerical_property({
            prototype = prototype,
            tbl = prototype.fluid_box,
            property = "base_area",
            property_info = property_info.limited_range
        })
    end
end

rand.turret_damage_modifier = function(prototype)
    if prototype_tables.turret_classes_as_keys[prototype.type] then
        local attack_parameters = prototype.attack_parameters

        if attack_parameters.damage_modifier == nil then
            attack_parameters.damage_modifier = 1
        end

        randomize_numerical_property({
            prototype = prototype,
            tbl = attack_parameters,
            property = "damage_modifier",
            inertia_function = inertia_function.turret_damage_modifier,
            property_info = property_info.limited_range
        })
    end
end

rand.turret_min_attack_distance = function(prototype)
    if prototype_tables.turret_classes_as_keys[prototype.type] then
        local attack_parameters = prototype.attack_parameters

        if attack_parameters.min_attack_distance ~= nil and attack_parameters.min_attack_distance ~= 0 then
            local old_min_attack_distance = attack_parameters.min_attack_distance

            randomize_numerical_property({
                prototype = prototype,
                tbl = attack_parameters,
                property = "min_attack_distance",
                inertia_function = inertia_function.sensitive_very,
                property_info = property_info.attack_parameters_range
            })

            -- Scale range by min attack distance increase
            -- Notice that this essentially results in range/min attack distance being scaled twice
            attack_parameters.range = attack_parameters.range * attack_parameters.min_attack_distance / old_min_attack_distance
            if attack_parameters.min_range ~= nil then
                attack_parameters.min_range = attack_parameters.min_range * attack_parameters.min_attack_distance / old_min_attack_distance
            end
        end
    end
end

rand.turret_range = function(prototype)
    if prototype_tables.turret_classes_as_keys[prototype.type] then
        local attack_parameters = prototype.attack_parameters

        local old_range = attack_parameters.range

        randomize_numerical_property({
            prototype = prototype,
            tbl = attack_parameters,
            property = "range",
            inertia_function = inertia_function.sensitive_very,
            property_info = property_info.attack_parameters_range
        })
        -- Randomize minimum range by a proportional amount if it exists
        -- TODO: Make this a "scaled" group randomization
        if attack_parameters.min_range ~= nil and old_range ~= 0 then
            attack_parameters.min_range = attack_parameters.min_range * attack_parameters.range / old_range
        end
        if attack_parameters.min_attack_distance ~= nil and old_range ~= 0 then
            attack_parameters.min_attack_distance = attack_parameters.min_attack_distance * attack_parameters.range / old_range
        end
    end
end

rand.turret_rotation_speed = function(prototype)
    if prototype_tables.turret_classes_as_keys[prototype.type] then
        -- TODO: Fix with reformatting
        if prototype.rotation_speed == nil then
            prototype.rotation_speed = 1
        end

        randomize_numerical_property({ -- TODO: Custom inertia function?
            prototype = prototype,
            property = "rotation_speed",
            property_info = property_info.turret_turning_speed
        })
    end

    -- Car turret rotation speed
    if prototype.type == "car" then
        -- For some reason the default here is 0.01 and the default on "normal" turrets is 1, I've double checked this so this isn't an error
        if prototype.turret_rotation_speed == nil then
            prototype.turret_rotation_speed = 0.01
        end
        
        randomize_numerical_property({
            prototype = prototype,
            property = "turret_rotation_speed",
            property_info = property_info.turret_turning_speed
        })
    end
end

rand.turret_shooting_speed = function(prototype)
    if prototype_tables.turret_classes_as_keys[prototype.type] then
        randomize_numerical_property({
            prototype = prototype,
            tbl = prototype.attack_parameters,
            property = "cooldown",
            property_info = property_info.attack_parameters_cooldown
        })
    end
end

rand.underground_belt_distance = function(prototype)
    if prototype.type == "underground-belt" then
        randomize_numerical_property({
            prototype = prototype,
            property = "max_distance",
            inertia_function = inertia_function.underground_belt_length,
            property_info = property_info.underground_length,
            walk_params = walk_params.underground_belt_length
        })
    end
end

rand.pipe_to_ground_distance = function(prototype)
    if prototype.type == "pipe-to-ground" then
        for _, pipe_connection in pairs(prototype.fluid_box.pipe_connections) do
            if pipe_connection.max_underground_distance ~= nil and pipe_connection.max_underground_distance > 0 then
                randomize_numerical_property({
                    prototype = prototype,
                    tbl = pipe_connection,
                    property = "max_underground_distance",
                    inertia_function = inertia_function.underground_belt_length,
                    property_info = property_info.underground_length,
                    walk_params = walk_params.underground_belt_length
                })
            end
        end
    end
end

rand.unit_attack_speed = function(prototype)
    if prototype.type == "unit" then
        randomize_numerical_property({
            prototype = prototype,
            tbl = prototype.attack_parameters,
            property = "cooldown",
            property_info = property_info.attack_parameters_cooldown_unit
        })
    end
end

rand.unit_melee_damage = function(prototype)
    if prototype.type == "unit" then
        local attack_parameters = prototype.attack_parameters

        if attack_parameters.damage_modifier == nil then
            attack_parameters.damage_modifier = 1
        end

        randomize_numerical_property({
            prototype = prototype,
            tbl = attack_parameters,
            property = "damage_modifier",
            property_info = property_info.limited_range_inverse
        })
    end
end

rand.unit_movement_speed = function(prototype)
    if prototype.type == "unit" then
        local old_movement_speed = prototype.movement_speed

        randomize_numerical_property({
            prototype = prototype,
            property = "movement_speed",
            inertia_function = inertia_function.sensitive,
            property_info = property_info.limited_range_strict_inverse
        })

        if prototype.old_movement_speed ~= 0 then
            prototype.distance_per_frame = prototype.distance_per_frame * prototype.movement_speed / old_movement_speed
        end
    end
end

rand.unit_pollution_to_join_attack = function(prototype)
    if prototype.type == "unit" then
        randomize_numerical_property({
            prototype = prototype,
            property = "pollution_to_join_attack",
            property_info = property_info.limited_range
        })
    end
end

rand.unit_range = function(prototype)
    if prototype.type == "unit" then
        -- TODO: attack_parameters randomization function so I don't have to duplicate code
        -- Note that this is difficult atm since I have to use different property infos
        -- Maybe hold off until new randomization methods
        local attack_parameters = prototype.attack_parameters

        local old_range = attack_parameters.range

        randomize_numerical_property({
            prototype = prototype,
            tbl = attack_parameters,
            property = "range",
            inertia_function = inertia_function.sensitive_very,
            property_info = property_info.attack_parameters_range_unit
        })
        -- Randomize minimum range by a proportional amount if it exists
        -- TODO: Make this a "scaled" group randomization
        if attack_parameters.min_range ~= nil and old_range ~= 0 then
            attack_parameters.min_range = attack_parameters.min_range * attack_parameters.range / old_range
        end
        if attack_parameters.min_attack_distance ~= nil and old_range ~= 0 then
            attack_parameters.min_attack_distance = attack_parameters.min_attack_distance * attack_parameters.range / old_range
        end
    end
end

rand.unit_vision_distance = function(prototype)
    if prototype.type == "unit" then
        randomize_numerical_property({
            prototype = prototype,
            property = "vision_distance",
            property_info = property_info.unit_vision_distance
        })
    end
end

rand.vehicle_crash_damage = function(prototype)
    if prototype_tables.vehicle_classes_as_keys[prototype.type] then
        local old_energy_per_hit_point = prototype.energy_per_hit_point

        randomize_numerical_property({
            prototype = prototype,
            property = "energy_per_hit_point",
            inertia_function = inertia_function.vehicle_crash_damage,
            property_info = property_info.limited_range
        })

        -- Increase flat impact resistance for higher crash damages so that this isn't just a glass cannon
        -- Doesn't apply if vehicle didn't have any impact resistance to start with
        if prototype.resistances then
            for _, resistance in pairs(prototype.resistances) do
                if resistance.type == "impact" then
                    -- energy_per_hit_point can't be zero, so we don't need to check for that
                    resistance.decrease = resistance.decrease * prototype.energy_per_hit_point / old_energy_per_hit_point
                end
            end
        end
    end
end

rand.vehicle_power = function(prototype)
    if prototype_tables.vehicle_speed_keys[prototype.type] then
        local old_speed_power = 60 * util.parse_energy(prototype[prototype_tables.vehicle_speed_keys[prototype.type]])

        rand.energy({
            is_power = true,
            prototype = prototype,
            tbl = prototype,
            property = prototype_tables.vehicle_speed_keys[prototype.type],
            inertia_function = inertia_function.vehicle_speed,
            walk_params = walk_params.vehicle_speed,
            property_info = property_info.limited_range
        })
        local new_speed_power = 60 * util.parse_energy(prototype[prototype_tables.vehicle_speed_keys[prototype.type]])

        if old_speed_power ~= 0 then
            -- Scale braking force with the new consumption for improved user experience
            if prototype.braking_power ~= nil then
                braking_power_as_number = 60 * util.parse_energy(prototype.braking_power)
                braking_power_as_number = braking_power_as_number * new_speed_power / old_speed_power
                prototype.braking_power = braking_power_as_number .. "W"
            else
                -- In this case, prototype.braking_force must be set
                prototype.braking_force = prototype.braking_force * new_speed_power / old_speed_power
            end

            -- Note: I used to scale hitpoints taken inversely so that the same amount of damage would be done, but I'll hold off on that now
        end
    end
end