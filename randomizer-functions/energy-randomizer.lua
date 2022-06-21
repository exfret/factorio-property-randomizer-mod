require("random-utils/randomization-algorithms")

local prototype_tables = require("randomizer-parameter-data/prototype-tables")

local temperature_property_info = {
  round = {
    [2] = {
      modulus = 1
    }
  }
}

-- TODO: Only apply min if the property wasn't originally zero
local energy_property_info = {
  min = 0.01,
  round = {
    [2] = {
      left_digits_to_keep = 3,
      modulus = 1
    }
  }
}

local power_property_info = {
  min = 0.01,
  round = {
    [2] = {
      left_digits_to_keep = 3,
      modulus = 0.01
    }
  }
}

local effectivity_property_info = {
  min = 0.001,
  round = {
    [2] = {
      modulus = 0.01
    },
    [3] = {
      modulus = 0.1
    }
  }
}

local fluid_usage_property_info = {
  min = 0.1,
  round = {
    [2] = {
      left_digits_to_keep = 3
    },
    [3] = {
      modulus = 1
    }
  }
}

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
        property_info = temperature_property_info
      },
      {
        prototype = prototype,
        tbl = heat_buffer,
        property = "default_temperature",
        property_info = temperature_property_info
      },
      {
        prototype = prototype,
        tbl = heat_buffer,
        property = "min_working_temperature",
        property_info = temperature_property_info
      }
    }
  }

  -- Max transfer
  local max_transfer_as_number = 60 * util.parse_energy(heat_buffer.max_transfer)
  max_transfer_as_number = randomize_numerical_property{
    dummy = max_transfer_as_number,
    prg_key = prg.get_key(prototype),
    property_info = power_property_info
  }
  heat_buffer.max_transfer = max_transfer_as_number .. "W"

  -- Specific heat
  local specific_heat_as_number = util.parse_energy(heat_buffer.specific_heat)
  specific_heat_as_number = randomize_numerical_property{
    dummy = specific_heat_as_number,
    prg_key = prg.get_key(prototype),
    property_info = energy_property_info
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
        property_info = energy_property_info
      }
      energy_source.buffer_capacity = buffer_capacity .. "J"
    end

    if energy_source.input_flow_limit then
      local input_flow_limit = 60 * util.parse_energy(energy_source.input_flow_limit)
      input_flow_limit = randomize_numerical_property{
        dummy = input_flow_limit,
        prg_key = prg.get_key(prototype),
        property_info = power_property_info
      }
      energy_source.input_flow_limit = input_flow_limit .. "W"
    end

    if energy_source.output_flow_limit then
      local output_flow_limit = 60 * util.parse_energy(energy_source.output_flow_limit)
      output_flow_limit = randomize_numerical_property{
        dummy = output_flow_limit,
        prg_key = prg.get_key(prototype),
        property_info = power_property_info
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
      property_info = effectivity_property_info
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
      property_info = effectivity_property_info
    }

    -- Note: there are complicated rules on how to "fill in" this type when it is not nil... get around to using those rules later
    if energy_source.fluid_usage_per_tick ~= nil then
      randomize_numerical_property{
        prototype = prototype,
        tbl = energy_source,
        property = "fluid_usage_per_tick",
        property_info = fluid_usage_property_info
      }
    end

    if energy_source.maximum_temperature ~= nil then
      randomize_numerical_property{
        prototype = prototype,
        tbl = energy_source,
        property = "maximum_temperature",
        property_info = temperature_property_info
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
        if prototype[property] then
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
      property_info = power_property_info
    }
    prototype.energy_consumption = energy_consumption_as_number .. "W"

    -- target_temperature
    randomize_numerical_property{
      prototype = prototype,
      property = "target_temperature",
      property_info = temperature_property_info
    }
  end

  for _, prototype in pairs(data.raw["burner-generator"]) do
    local max_power_output_as_number = 60 * util.parse_energy(prototype.max_power_output)
    max_power_output_as_number = randomize_numerical_property{
      dummy = max_power_output_as_number,
      prg_key = prg.get_key(prototype),
      property_info = power_property_info
    }
    prototype.max_power_output = max_power_output_as_number .. "W"
  end

  for _, prototype in pairs(data.raw["electric-energy-interface"]) do
    if prototype.energy_production then
      local energy_production_as_number = 60 * util.parse_energy(prototype.energy_production)
      energy_production_as_number = randomize_numerical_property{
        dummy = energy_production_as_number,
        prg_key = prg.get_key(prototype),
        property_info = power_property_info
      }
      prototype.energy_production = energy_production_as_number .. "W"
    end

    if prototype.energy_usage then
      local energy_usage_as_number = 60 * util.parse_energy(prototype.energy_usage)
      energy_usage_as_number = randomize_numerical_property{
        dummy = energy_usage_as_number,
        prg_key = prg.get_key(prototype),
        property_info = power_property_info
      }
      prototype.energy_usage = energy_usage_as_number .. "W"
    end
  end

  for _, prototype in pairs(data.raw.generator) do
    randomize_numerical_property{
      prototype = prototype,
      property = "effectivity",
      property_info = effectivity_property_info
    }

    randomize_numerical_property{
      prototype = prototype,
      property = "fluid_usage_per_tick",
      property_info = fluid_usage_property_info
    }

    randomize_numerical_property{
      prototype = prototype,
      property = "maximum_temperature",
      property_info = temperature_property_info
    }

    if prototype.max_power_output then
      local max_power_output_as_number = 60 * util.parse_energy(prototype.max_power_output)
      max_power_output_as_number = randomize_numerical_property{
        dummy = max_power_output_as_number,
        prg_key = prg.get_key(prototype),
        property_info = power_property_info
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
      property_info = power_property_info
    }
    prototype.consumption = consumption_as_number .. "W"

    randomize_heat_buffer_power_production_properties(prototype, prototype.heat_buffer)
  end

  for _, prototype in pairs(data.raw["solar-panel"]) do
    local production_as_number = 60 * util.parse_energy(prototype.production)
    production_as_number = randomize_numerical_property{
      dummy = production_as_number,
      prg_key = prg.get_key(prototype),
      property_info = power_property_info
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
            property_info = power_property_info
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
            property_info = energy_property_info
          }
          prototype[property] = energy_as_number .. "J"
        end
      end
    end
  end
  -- Don't randomize minimum consumption for now
end

---------------------------------------------------------------------------------------------------
-- Some past randomized things that I'll add back in the near future
---------------------------------------------------------------------------------------------------

--[[function randomize_energy_source_properties(energy_source)
  -- Electric energy source

  if energy_source.buffer_capacity then
    energy_source.buffer_capacity = randomize_energy(energy_source.buffer_capacity)
  end

  if energy_source.input_flow_limit then
    energy_source.input_flow_limit = randomize_power(energy_source.input_flow_limit)
  end

  if energy_source.output_flow_limit then
    energy_source.output_flow_limit = randomize_power(energy_source.output_flow_limit)
  end

    -- Min consumption
  if energy_source.drain then
    energy_source.drain = randomize_power(energy_source.drain)
  end

  if emissions_per_minute then
    emissions_per_minute = emissions_per_minute * random_modifier()
  end

  -- Burner energy source

  if energy_source.fuel_inventory_size then
    energy_source.fuel_inventory_size = randomize_small_int(energy_source.fuel_inventory_size, 1, 5)
  end

  -- Heat energy source

  if energy_source.max_temperature then
    -- Default temperature must be at most max temperature, so define one modifier to make sure this stays the case
    local temperature_modifier = random_modifier()

    if energy_source.default_temperature then
      energy_source.default_temperature = energy_source.default_temperature * temperature_modifer
    else
      energy_source.default_temperature = 15 * temperature_modifier
    end

    if energy_source.min_working_temperature then
      energy_source.min_working_temperature = energy_source.min_working_temperature * temperature_modifier
    else
      energy_source.min_working_temperature = 15 * temperature_modifier
    end

    energy_source.max_temperature = energy_source.max_temperature * temperature_modifier
  end

  if energy_source.specific_heat then
    energy_source.specific_heat = randomize_energy(energy_source.specific_heat)
  end

  if energy_source.max_transfer then
    energy_source.max_transfer = randomize_power(energy_source.max_transfer)
  end

  if energy_source.min_temperature_gradient then
    energy_source.min_temperature_gradient = energy_source.min_temperature_gradient * random_modifier()
  else
    energy_source.min_temperature_gradient = random_modifier()
  end

  -- Fluid energy source

  if energy_source.maximum_temperature then
    energy_source.maximum_temperature = energy_source.maximum_temperature * random_modifier()
  end

  -- Used for multiple sources

  if energy_source.effectivity then
    energy_source.effectivity = energy_source.effectivity * random_modifier()
  end
end

function randomize_energy_properties (prototype)
  -- Items and fluids

  if prototype.fuel_value then
    prototype.fuel_value = randomize_energy(prototype.fuel_value)
  end

  -- Fluids

  if prototype.heat_capacity then
    prototype.heat_capacity = randomize_energy(prototype.heat_capacity)
  end

  -- Crafting machines

  if prototype.energy_usage then
    prototype.energy_usage = randomize_power(prototype.energy_usage)
  end

  -- Some equipment stuff

  if prototype.charging_energy then
  	prototype.charging_energy = randomize_power(prototype.charging_energy)
  end

  if prototype.energy_input then
  	prototype.energy_input = randomize_power(prototype.energy_input)
  end

  if prototype.energy_consumption then
    prototype.energy_consumption = randomize_power(prototype.energy_consumption)
  end

  if prototype.energy_per_shield then
    prototype.energy_per_shield = randomize_energy(prototype.energy_per_shield)
  end

  if prototype.power then
    prototype.power = randomize_power(prototype.power)
  end

  if prototype.burner then
    randomize_energy_source_properties(prototype.burner)
  end

  -- Generators

  if prototype.max_power_output then
    prototype.max_power_output = randomize_power(prototype.max_power_output)
  end

  -- Things with an electric energy interface

  if prototype.energy_source then
    randomize_energy_source_properties(prototype.energy_source)
  end
end]]--