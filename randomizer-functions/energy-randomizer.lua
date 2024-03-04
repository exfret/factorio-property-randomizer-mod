require("random-utils/randomization-algorithms")

local property_info = require("randomizer-parameter-data/property-info-tables")
local prototype_tables = require("randomizer-parameter-data/prototype-tables")

---------------------------------------------------------------------------------------------------
-- randomize_power_production_properties
---------------------------------------------------------------------------------------------------

-- TODO: Randomize max temperature and stuff more smartly
function randomize_heat_buffer_power_production_properties (prototype, heat_buffer)
  -- Temperature properties
  if heat_buffer.default_temperature == nil then
    heat_buffer.default_temperature = 15
  end
  if heat_buffer.min_working_temperature == nil then
    heat_buffer.min_working_temperature = 15
  end

  randomize_numerical_property{
    group_params = {
      {
        prototype = prototype,
        tbl = heat_buffer,
        property = "max_temperature",
        property_info = property_info.temperature
      },
      {
        prototype = prototype,
        tbl = heat_buffer,
        property = "default_temperature",
        property_info = property_info.temperature
      },
      {
        prototype = prototype,
        tbl = heat_buffer,
        property = "min_working_temperature",
        property_info = property_info.temperature
      }
    }
  }

  -- Max transfer
  local max_transfer_as_number = 60 * util.parse_energy(heat_buffer.max_transfer)
  max_transfer_as_number = randomize_numerical_property{
    dummy = max_transfer_as_number,
    prg_key = prg.get_key(prototype),
    property_info = property_info.power
  }
  heat_buffer.max_transfer = max_transfer_as_number .. "W"

  -- Specific heat
  local specific_heat_as_number = util.parse_energy(heat_buffer.specific_heat)
  specific_heat_as_number = randomize_numerical_property{
    dummy = specific_heat_as_number,
    prg_key = prg.get_key(prototype),
    property_info = property_info.energy
  }
  heat_buffer.specific_heat = specific_heat_as_number .. "J"
end

-- TODO: Randomize max temperature and stuff more smartly
function randomize_energy_source_power_production_properties (prototype, energy_source)
  if energy_source.type == "electric" then
    if energy_source.buffer_capacity then
      local buffer_capacity = util.parse_energy(energy_source.buffer_capacity)
      buffer_capacity = randomize_numerical_property{
        dummy = buffer_capacity,
        prg_key = prg.get_key(prototype),
        property_info = property_info.energy
      }
      energy_source.buffer_capacity = buffer_capacity .. "J"
    end

    if energy_source.input_flow_limit then
      local input_flow_limit = 60 * util.parse_energy(energy_source.input_flow_limit)
      input_flow_limit = randomize_numerical_property{
        dummy = input_flow_limit,
        prg_key = prg.get_key(prototype),
        property_info = property_info.power
      }
      energy_source.input_flow_limit = input_flow_limit .. "W"
    end

    if energy_source.output_flow_limit then
      local output_flow_limit = 60 * util.parse_energy(energy_source.output_flow_limit)
      output_flow_limit = randomize_numerical_property{
        dummy = output_flow_limit,
        prg_key = prg.get_key(prototype),
        property_info = property_info.power
      }
      energy_source.output_flow_limit = output_flow_limit .. "W"
    end
  elseif energy_source.type == "burner" then
    if energy_source.effectivity == nil then
      energy_source.effectivity = 1
    end
    randomize_numerical_property{
      prototype = prototype,
      tbl = energy_source,
      property = "effectivity",
      property_info = property_info.power
    }
  elseif energy_source.type == "heat" then
    -- This has the same properties as a heat buffer and is randomized the same way if type == heat
    randomize_heat_buffer_power_production_properties(prototype, energy_source)
  elseif energy_source.type == "void" then
    -- No further action needed
  elseif energy_source.type == "fluid" then
    randomize_numerical_property{
      prototype = prototype,
      tbl = energy_source,
      property = "effectivity",
      property_info = property_info.power
    }

    -- TODO: there are complicated rules on how to "fill in" this type when it is not nil... get around to using those rules later
    if energy_source.fluid_usage_per_tick ~= nil then
      randomize_numerical_property{
        prototype = prototype,
        tbl = energy_source,
        property = "fluid_usage_per_tick",
        property_info = property_info.power
      }
    end

    if energy_source.maximum_temperature ~= nil then
      randomize_numerical_property{
        prototype = prototype,
        tbl = energy_source,
        property = "maximum_temperature",
        property_info = property_info.power
      }
    end
  end
end

-- TODO: Randomize boiler consumption, burner_generator max_power_output, generator effectivity, etc.
-- TODO: heat_interface
-- TODO: heat_buffers
function randomize_power_production_properties ()
  for class, properties_to_randomize in pairs(prototype_tables.energy_source_names) do
    for _, prototype in pairs(data.raw[class]) do
      for _, property in pairs(properties_to_randomize) do
        if prototype[property] ~= nil then
          randomize_energy_source_power_production_properties(prototype, prototype[property])
        end
      end
    end
  end

  for _, prototype in pairs(data.raw.boiler) do
    -- energy_consumption
    local energy_consumption_as_number = 60 * util.parse_energy(prototype.energy_consumption)
    energy_consumption_as_number = randomize_numerical_property{
      dummy = energy_consumption_as_number,
      prg_key = prg.get_key(prototype),
      property_info = property_info.power
    }
    prototype.energy_consumption = energy_consumption_as_number .. "W"

    -- Mark this as an advanced feature - the min target temperature varies based on mods
    randomize_numerical_property{
      prototype = prototype,
      property = "target_temperature",
      property_info = property_info.temperature
    }
  end

  for _, prototype in pairs(data.raw["burner-generator"]) do
    local max_power_output_as_number = 60 * util.parse_energy(prototype.max_power_output)
    max_power_output_as_number = randomize_numerical_property{
      dummy = max_power_output_as_number,
      prg_key = prg.get_key(prototype),
      property_info = property_info.power
    }
    prototype.max_power_output = max_power_output_as_number .. "W"
  end

  for _, prototype in pairs(data.raw["electric-energy-interface"]) do
    if prototype.energy_production then
      local energy_production_as_number = 60 * util.parse_energy(prototype.energy_production)
      energy_production_as_number = randomize_numerical_property{
        dummy = energy_production_as_number,
        prg_key = prg.get_key(prototype),
        property_info = property_info.power
      }
      prototype.energy_production = energy_production_as_number .. "W"
    end

    if prototype.energy_usage then
      local energy_usage_as_number = 60 * util.parse_energy(prototype.energy_usage)
      energy_usage_as_number = randomize_numerical_property{
        dummy = energy_usage_as_number,
        prg_key = prg.get_key(prototype),
        property_info = property_info.power
      }
      prototype.energy_usage = energy_usage_as_number .. "W"
    end
  end

  for _, prototype in pairs(data.raw.generator) do
    randomize_numerical_property{
      prototype = prototype,
      property = "effectivity",
      property_info = property_info.effectivity
    }

    randomize_numerical_property{
      prototype = prototype,
      property = "fluid_usage_per_tick",
      property_info = property_info.fluid_usage
    }

    randomize_numerical_property{
      prototype = prototype,
      property = "maximum_temperature",
      property_info = property_info.temperature
    }

    if prototype.max_power_output then
      local max_power_output_as_number = 60 * util.parse_energy(prototype.max_power_output)
      max_power_output_as_number = randomize_numerical_property{
        dummy = max_power_output_as_number,
        prg_key = prg.get_key(prototype),
        property_info = property_info.power
      }
      prototype.max_power_output = max_power_output_as_number .. "W"
    end
  end

  for _, prototype in pairs(data.raw.reactor) do
    -- Consumption
    local consumption_as_number = 60 * util.parse_energy(prototype.consumption)
    consumption_as_number = randomize_numerical_property{
      dummy = consumption_as_number,
      prg_key = prg.get_key(prototype),
      property_info = property_info.power
    }
    prototype.consumption = consumption_as_number .. "W"

    randomize_heat_buffer_power_production_properties(prototype, prototype.heat_buffer)
  end

  for _, prototype in pairs(data.raw["solar-panel"]) do
    local production_as_number = 60 * util.parse_energy(prototype.production)
    production_as_number = randomize_numerical_property{
      dummy = production_as_number,
      prg_key = prg.get_key(prototype),
      property_info = property_info.power
    }
    prototype.production = production_as_number .. "W"
  end
end

---------------------------------------------------------------------------------------------------
-- randomize_energy_properties
---------------------------------------------------------------------------------------------------

-- TODO: Randomize vehicle effectivity
function randomize_energy_properties ()
  for class_key, property_list in pairs(prototype_tables.power_property_names) do
    for _, prototype in pairs(data.raw[class_key]) do
      for _, property in pairs(property_list) do
        if prototype[property] ~= nil then
          local power_as_number = 60 * util.parse_energy(prototype[property])
          power_as_number = randomize_numerical_property{
            dummy = power_as_number,
            prg_key = prg.get_key(prototype),
            property_info = property_info.power
          }
          prototype[property] = power_as_number .. "W"
        end
      end
    end
  end

  for class_key, property_list in pairs(prototype_tables.energy_property_names) do
    for _, prototype in pairs(data.raw[class_key]) do
      for _, property in pairs(property_list) do
        if prototype[property] ~= nil then
          local energy_as_number = util.parse_energy(prototype[property])
          energy_as_number = randomize_numerical_property{
            dummy = energy_as_number,
            prg_key = prg.get_key(prototype),
            property_info = property_info.energy
          }
          prototype[property] = energy_as_number .. "J"
        end
      end
    end
  end
  -- Don't randomize minimum consumption for now
end