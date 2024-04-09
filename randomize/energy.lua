local property_info = require("randomizer-parameter-data/property-info-tables")
local prototype_tables = require("randomizer-parameter-data/prototype-tables")

-- is_power (optional)
-- prototype
-- tbl
-- property
-- property_info (optional)
rand.energy = function(passed_params)
    local params = table.deepcopy(passed_params)

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
                    walk_params = walk_params.temperature,
                    property_info = property_info.temperature
                },
                {
                    prototype = prototype,
                    tbl = prototype.heat_buffer,
                    property = "default_temperature",
                    walk_params = walk_params.temperature,
                    property_info = property_info.temperature
                },
                {
                    prototype = prototype,
                    tbl = prototype.heat_buffer,
                    property = "min_working_temperature",
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
            property_info = property_info.energy -- TODO: Should this be power gen. property info?
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
            property_info = property_info.power_generation
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
            property_info = property_info.power_generation
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

    for energy_source in pairs(energy_sources)
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

return energy