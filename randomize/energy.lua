local inertia_function = require("randomizer-parameter-data/inertia-function-tables")
local property_info = require("randomizer-parameter-data/property-info-tables")
local prototype_tables = require("randomizer-parameter-data/prototype-tables")
local walk_params = require("randomizer-parameter-data/walk-params-tables")

-- TODO: Put rand.energy into a utilities file

-- is_power (optional)
-- prototype
-- tbl
-- property
-- inertia_function (optional)
-- walk_params (optional)
-- property_info (optional)
rand.energy = function(passed_params)
    local params = table.deepcopy(passed_params)
    params.tbl = passed_params.tbl -- Make sure this is a real copy

    local multiplier = 1
    local suffix = "J"
    if params.is_power then
        multiplier = 60
        suffix = "W"
    end

    local energy_as_number = multiplier * util.parse_energy(params.tbl[params.property])
    energy_as_number = randomize_numerical_property({
        dummy = energy_as_number,
        prg_key = prg.get_key(params.prototype),
        inertia_function = params.inertia_function,
        walk_params = params.walk_params,
        property_info = params.property_info
    })
    params.tbl[params.property] = energy_as_number .. suffix
end

rand.heat_buffer_max_transfer = function(prototype)
    if prototype_tables.has_heat_buffer[prototype.type] then
        rand.energy({
            is_power = true,
            prototype = prototype,
            tbl = prototype.heat_buffer,
            property = "max_transfer",
            inertia_function = inertia_function.sensitive,
            property_info = property_info.power_generation
        })
    end
end

rand.heat_buffer_specific_heat = function(prototype)
    if prototype_tables.has_heat_buffer[prototype.type] then
        rand.energy({
            prototype = prototype,
            tbl = prototype.heat_buffer,
            property = "specific_heat",
            inertia_function = inertia_function.sensitive,
            property_info = property_info.energy
        })
    end
end

rand.heat_buffer_temperatures = function(prototype)
    if prototype_tables.has_heat_buffer[prototype.type] then
        prototype.heat_buffer.default_temperature = prototype.heat_buffer.default_temperature or 15
        prototype.heat_buffer.min_working_temperature = prototype.heat_buffer.min_working_temperature or 15

        randomize_numerical_property({
            group_params = {
                {
                    prototype = prototype,
                    tbl = prototype.heat_buffer,
                    property = "max_temperature",
                    inertia_function = inertia_function.sensitive,
                    walk_params = walk_params.temperature,
                    property_info = property_info.temperature
                },
                {
                    prototype = prototype,
                    tbl = prototype.heat_buffer,
                    property = "default_temperature",
                    inertia_function = inertia_function.sensitive,
                    walk_params = walk_params.temperature,
                    property_info = property_info.temperature
                },
                {
                    prototype = prototype,
                    tbl = prototype.heat_buffer,
                    property = "min_working_temperature",
                    inertia_function = inertia_function.sensitive,
                    walk_params = walk_params.temperature,
                    property_info = property_info.temperature
                }
            }
        })
    end
end

rand.energy_source_electric_buffer_capacity = function(prototype)
    -- Just do buffers of accumulators for now
    if prototype.type == "accumulator" and prototype.energy_source.buffer_capacity ~= nil then
        rand.energy({
            prototype = prototype,
            tbl = prototype.energy_source,
            property = "buffer_capacity",
            property_info = property_info.power_good
        })
    end
end

rand.energy_source_electric_input_flow_limit = function(prototype)
    -- Just for accumulators for now
    if prototype.type == "accumulator" and prototype.energy_source.input_flow_limit ~= nil then
        rand.energy({
            prototype = prototype,
            tbl = prototype.energy_source,
            property = "input_flow_limit",
            property_info = property_info.power_good
        })
    end
end

rand.energy_source_electric_output_flow_limit = function(prototype)
    -- Just for accumulators for now
    if prototype.type == "accumulator" and prototype.energy_source.output_flow_limit ~= nil then
        rand.energy({
            prototype = prototype,
            tbl = prototype.energy_source,
            property = "output_flow_limit",
            property_info = property_info.power_good
        })
    end
end

rand.energy_source_electric_drain = function(prototype)
    -- TODO: Later, we'll be able to test if it has an electric energy source directly, but for now need to just see if the drain property is there
    -- Burner energy sources sometimes have a different key ("burner"), but electric energy sources are always "energy_source", so we don't need to worry about that
    if prototype.energy_source ~= nil and prototype.energy_source.drain ~= nil then
        rand.energy({
            prototype = prototype,
            tbl = prototype.energy_source,
            property = "drain",
            property_info = property_info.limited_range_loose_inverse
        })
    end
end

rand.energy_source_burner_effectivity = function(prototype)
    -- TODO: Check assumption that only "burner" property can be forced to burner energy source type is true
    local energy_sources = {}
    if prototype.energy_source and prototype.energy_source.type == "burner" then
        table.insert(energy_sources, prototype.energy_source)
    end
    if prototype.burner ~= nil then
        table.insert(energy_sources, prototype.burner)
    end

    for _, energy_source in pairs(energy_sources) do
        energy_source.effectivity = energy_source.effecitivity or 1

        randomize_numerical_property({
            prototype = prototype,
            tbl = energy_source,
            property = "effectivity",
            property_info = property_info.effectivity
        })
    end
end

rand.energy_source_fluid_effectivity = function(prototype)
    if prototype.energy_source ~= nil and prototype.energy_source.type == "fluid" then
        prototype.energy_source.effectivity = prototype.energy_source.effecitivity or 1

        randomize_numerical_property({
            prototype = prototype,
            tbl = prototype.energy_source,
            property = "effectivity",
            property_info = property_info.effectivity
        })
    end
end

rand.energy_source_fluid_maximum_temperature = function(prototype)
    if prototype.energy_source ~= nil and prototype.energy_source == "fluid" and prototype.energy_source.maximum_temperature ~= nil then
        randomize_numerical_property({
            prototype = prototoype,
            tbl = prototype.energy_source,
            property = "maximum_temperature",
            walk_params = walk_params.temperature,
            property_info = property_info.temperature
        })
    end
end

rand.boiler_energy_consumption = function(prototype)
    if prototype.type == "boiler" then
        rand.energy({
            is_power = true,
            prototype = prototype,
            tbl = prototype,
            property = "energy_consumption",
            property_info = property_info.boiler_consumption
        })
    end
end

rand.boiler_target_temperature = function(prototype)
    if prototype.type == "boiler" then
        randomize_numerical_property({
            prototype = prototype,
            property = "target_temperature",
            walk_params = walk_params.temperature,
            property_info = property_info.temperature
        })
    end
end

rand.burner_generator_max_power_output = function(prototype)
    if prototype.type == "burner-generator" then
        rand.energy({
            is_power = true,
            prototype = prototype,
            tbl = prototype,
            property = "max_power_output",
            property_info = property_info.power_generation
        })
    end
end

rand.electric_energy_interface_energy_production = function(prototype)
    if prototype.type == "electric-energy-interface" and prototype.energy_production ~= nil then
        rand.energy({
            is_power = true,
            prototype = prototype,
            tbl = prototype,
            property = "energy_production",
            property_info = property_info.power_generation
        })
    end
end

rand.electric_energy_interface_energy_usage = function(prototype)
    if prototype.type == "electric-energy-interface" and prototype.energy_usage ~= nil then
        rand.energy({
            is_power = true,
            prototype = prototype,
            tbl = prototype,
            property = "energy_usage",
            property_info = property_info.power
        })
    end
end

rand.generator_effectivity = function(prototype)
    if prototype.type == "generator" then
        if prototype.effectivity == nil then
            prototype.effectivity = 1
        end

        randomize_numerical_property({
            prototype = prototype,
            property = "effectivity",
            property_info = property_info.effectivity
        })
    end
end

rand.generator_fluid_usage = function(prototype)
    if prototype.type == "generator" then
        randomize_numerical_property({
            prototype = prototype,
            property = "fluid_usage_per_tick",
            property_info = property_info.fluid_usage_good
        })
    end
end

rand.generator_maximum_temperature = function(prototype)
    if prototype.type == "generator" then
        randomize_numerical_property({
            prototype = prototype,
            property = "maximum_temperature",
            walk_params = walk_params.temperature,
            property_info = property_info.temperature
        })
    end
end

rand.reactor_consumption = function(prototype)
    if prototype.type == "reactor" then
        rand.energy({
            is_power = true,
            prototype = prototype,
            tbl = prototype,
            property = "consumption",
            property_info = property_info.power_generation
        })
    end
end

rand.solar_panel_production = function(prototype)
    if prototype.type == "solar-panel" then
        rand.energy({
            is_power = true,
            prototype = prototype,
            tbl = prototype,
            property = "production",
            property_info = property_info.power_generation
        })
    end
end

rand.machine_energy_usage = function(prototype)
    if prototype_tables.machine_energy_keys[prototype.type] ~= nil then
        for _, energy_usage_property in pairs(prototype_tables.machine_energy_keys[prototype.type]) do
            -- TODO: Remove nil checks when reformat is done
            if prototype[energy_usage_property] ~= nil then
                rand.energy({
                    prototype = prototype,
                    tbl = prototype,
                    property = energy_usage_property,
                    property_info = property_info.power
                })
            end
        end
    end

    if prototype_tables.machine_power_keys[prototype.type] ~= nil then
        for _, power_usage_property in pairs(prototype_tables.machine_power_keys[prototype.type]) do
            if prototype[power_usage_property] ~= nil then
                rand.energy({
                    is_power = true,
                    prototype = prototype,
                    tbl = prototype,
                    property = power_usage_property,
                    property_info = property_info.power
                })
            end
        end
    end
end

rand.equipment_energy_usage = function(prototype)
    if prototype_tables.equipment_energy_properties[prototype.type] ~= nil then
        for _, energy_usage_property in pairs(prototype_tables.equipment_energy_properties[prototype.type]) do
            if prototype[energy_usage_property] ~= nil then
                rand.energy({
                    prototype = prototype,
                    tbl = prototype,
                    property = energy_usage_property,
                    property_info = property_info.power
                })
            end
        end
    end

    if prototype_tables.equipment_power_properties[prototype.type] ~= nil then
        for _, power_usage_property in pairs(prototype_tables.equipment_power_properties[prototype.type]) do
            if prototype[power_usage_property] ~= nil then
                rand.energy({
                    is_power = true,
                    prototype = prototype,
                    tbl = prototype,
                    property = power_usage_property,
                    property_info = property_info.power
                })
            end
        end
    end
end

rand.fluid_fuel_value = function(prototype)
    if prototype.type == "fluid" then
        if prototype.fuel_value ~= nil then
            rand.energy({
                prototype = prototype,
                tbl = prototype,
                property = "fuel_value",
                inertia_function = inertia_function.sensitive,
                property_info = property_info.energy
            })
        end
    end
end

rand.fluid_heat_capacity = function(prototype)
    if prototype.type == "fluid" then
        if prototype.heat_capacity == nil then
            prototype.heat_capacity = "1KJ"
        end

        rand.energy({
            prototype = prototype,
            tbl = prototype,
            property = "heat_capacity",
            inertia_function = inertia_function.sensitive,
            property_info = property_info.energy
        })
    end
end

rand.item_fuel_value = function(prototype)
    if defines.prototypes.item[prototype.type] then
        if prototype.fuel_value ~= nil then
            rand.energy({
                prototype = prototype,
                tbl = prototype,
                property = "fuel_value",
                inertia_function = inertia_function.sensitive,
                property_info = property_info.energy
            })
        end
    end
end

rand.bot_energy = function(prototype)
    if prototype_tables.bot_energy_keys[prototype.type] then
        for _, energy_usage_property in pairs(prototype_tables.bot_energy_keys[prototype.type]) do
            if prototype[energy_usage_property] ~= nil then
                rand.energy({
                    prototype = prototype,
                    tbl = prototype,
                    property = energy_usage_property,
                    property_info = property_info.power
                })
            end
        end
    end
end

rand.inserter_energy = function(prototype)
    if prototype_tables.inserter_energy_keys[prototype.type] then
        for _, energy_usage_property in pairs(prototype_tables.inserter_energy_keys[prototype.type]) do
            if prototype[energy_usage_property] ~= nil then
                rand.energy({
                    prototype = prototype,
                    tbl = prototype,
                    property = energy_usage_property,
                    property_info = property_info.power
                })
            end
        end
    end
end

rand.turret_energy_usage = function(prototype)
    if prototype.type == "electric-turret" then
        if prototype.attack_parameters.ammo_type ~= nil then
            local ammo_type = prototype.attack_parameters.ammo_type

            rand.energy({
                prototype = prototype,
                tbl = ammo_type,
                property = "energy_consumption",
                property_info = property_info.limited_range
            })
        end
    end
end

return energy