require("random-utils/randomization-algorithms")

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

  local temperature_multiplier = randomize_numerical_property{
    dummy = 1,
    prg_key = prg.get_key(prototype)
  }

  heat_buffer.max_temperature = heat_buffer.max_temperature * temperature_multiplier
  heat_buffer.default_temperature = heat_buffer.default_temperature * temperature_multiplier
  heat_buffer.min_working_temperature = heat_buffer.min_working_temperature * temperature_multiplier

  -- Max transfer
  local max_transfer_as_number = 60 * util.parse_energy(heat_buffer.max_transfer)
  max_transfer_as_number = randomize_numerical_property{
    dummy = max_transfer_as_number,
    prg_key = prg.get_key(prototype)
  }
  heat_buffer.max_transfer = max_transfer_as_number .. "W"

  -- Specific heat
  local specific_heat_as_number = util.parse_energy(heat_buffer.specific_heat)
  specific_heat_as_number = randomize_numerical_property{
    dummy = specific_heat_as_number,
    prg_key = prg.get_key(prototype)
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
        prg_key = prg.get_key(prototype)
      }
      energy_source.buffer_capacity = buffer_capacity .. "J"
    end

    if energy_source.input_flow_limit then
      local input_flow_limit = 60 * util.parse_energy(energy_source.input_flow_limit)
      input_flow_limit = randomize_numerical_property{
        dummy = input_flow_limit,
        prg_key = prg.get_key(prototype)
      }
      energy_source.input_flow_limit = input_flow_limit .. "W"
    end

    if energy_source.output_flow_limit then
      local output_flow_limit = 60 * util.parse_energy(energy_source.output_flow_limit)
      output_flow_limit = randomize_numerical_property{
        dummy = output_flow_limit,
        prg_key = prg.get_key(prototype)
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
      property = "effectivity"
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
      property = "effectivity"
    }

    -- Note: there are complicated rules on how to "fill in" this type when it is not nil... get around to using those rules later
    if energy_source.fluid_usage_per_tick ~= nil then
      randomize_numerical_property{
        prototype = prototype,
        tbl = energy_source,
        property = "fluid_usage_per_tick"
      }
    end

    if energy_source.maximum_temperature ~= nil then
      randomize_numerical_property{
        prototype = prototype,
        tbl = energy_source,
        property = "maximum_temperature"
      }
    end
  end
end

local prototype_energy_source_keys = {
  accumulator = {"energy_source"},
  beacon = {"energy_source"},
  boiler = {"energy_source"},
  ["burner-generator"] = {"burner", "energy_source"},
  car = {"burner", "energy_source"},
  ["arithmetic-combinator"] = {"energy_source"},
  ["decider-combinator"] = {"energy_source"},
  ["assembling-machine"] = {"energy_source"},
  ["rocket-silo"] = {"energy_source"},
  furnace = {"energy_source"},
  ["electric-energy-interface"] = {"energy_source"},
  ["electric-turret"] = {"energy_source"},
  generator = {"energy_source"},
  inserter = {"energy_source"},
  lab = {"energy_source"},
  lamp = {"energy_source"},
  locomotive = {"burner", "energy_source"},
  ["mining-drill"] = {"energy_source"},
  ["programmable-speaker"] = {"energy_source"},
  pump = {"energy_source"},
  radar = {"energy_source"},
  reactor = {"energy_source"},
  roboport = {"energy_source"},
  ["solar-panel"] = {"energy_source"},
  ["spider-vehicle"] = {"burner", "energy_source"},
  ["active-defense-equipment"] = {"energy_source"},
  ["battery-equipment"] = {"energy_source"},
  ["belt-immunity-equipment"] = {"energy_source"},
  ["energy-shield-equipment"] = {"energy_source"},
  ["generator-equipment"] = {"burner", "energy_source"},
  ["movement-bonus-equipment"] = {"energy_source"},
  ["night-vision-equipment"] = {"energy_source"},
  ["roboport-equipment"] = {"burner", "energy_source"},
  ["solar-panel-equipment"] = {"energy_source"}
}

-- TODO: Randomize boiler consumption, burner_generator max_power_output, generator effectivity, etc.
-- TODO: heat_interface
-- TODO: heat_buffers
function randomize_power_production_properties ()
  for class, properties_to_randomize in pairs(prototype_energy_source_keys) do
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
      prg_key = prg.get_key(prototype)
    }
    prototype.energy_consumption = energy_consumption_as_number .. "W"

    -- target_temperature
    randomize_numerical_property{
      prototype = prototype,
      property = "target_temperature"
    }
  end

  for _, prototype in pairs(data.raw["burner-generator"]) do
    local max_power_output_as_number = 60 * util.parse_energy(prototype.max_power_output)
    max_power_output_as_number = randomize_numerical_property{
      dummy = max_power_output_as_number,
      prg_key = prg.get_key(prototype)
    }
    prototype.max_power_output = max_power_output_as_number .. "W"
  end

  for _, prototype in pairs(data.raw["electric-energy-interface"]) do
    if prototype.energy_production then
      local energy_production_as_number = 60 * util.parse_energy(prototype.energy_production)
      energy_production_as_number = randomize_numerical_property{
        dummy = energy_production_as_number,
        prg_key = prg.get_key(prototype)
      }
      prototype.energy_production = energy_production_as_number .. "W"
    end

    if prototype.energy_usage then
      local energy_usage_as_number = 60 * util.parse_energy(prototype.energy_usage)
      energy_usage_as_number = randomize_numerical_property{
        dummy = energy_usage_as_number,
        prg_key = prg.get_key(prototype)
      }
      prototype.energy_usage = energy_usage_as_number .. "W"
    end
  end

  for _, prototype in pairs(data.raw.generator) do
    randomize_numerical_property{
      prototype = prototype,
      property = "effectivity"
    }

    randomize_numerical_property{
      prototype = prototype,
      property = "fluid_usage_per_tick"
    }

    randomize_numerical_property{
      prototype = prototype,
      property = "maximum_temperature"
    }

    if prototype.max_power_output then
      local max_power_output_as_number = 60 * util.parse_energy(prototype.max_power_output)
      max_power_output_as_number = randomize_numerical_property{
        dummy = max_power_output_as_number,
        prg_key = prg.get_key(prototype)
      }
      prototype.max_power_output = max_power_output_as_number .. "W"
    end
  end

  for _, prototype in pairs(data.raw.reactor) do
    -- Consumption
    local consumption_as_number = 60 * util.parse_energy(prototype.consumption)
    consumption_as_number = randomize_numerical_property{
      dummy = consumption_as_number,
      prg_key = prg.get_key(prototype)
    }
    prototype.consumption = consumption_as_number .. "W"

    randomize_heat_buffer_power_production_properties(prototype, prototype.heat_buffer)
  end

  for _, prototype in pairs(data.raw["solar-panel"]) do
    local production_as_number = 60 * util.parse_energy(prototype.production)
    production_as_number = randomize_numerical_property{
      dummy = production_as_number,
      prg_key = prg.get_key(prototype)
    }
    prototype.production = production_as_number .. "W"
  end
end

---------------------------------------------------------------------------------------------------
-- randomize_energy_properties
---------------------------------------------------------------------------------------------------

local prototype_power_keys = {
  beacon = {"energy_usage"},
  ["arithmetic-combinator"] = {"active_energy_usage"},
  ["decider-combinator"] = {"active_energy_usage"},
  ["assembling-machine"] = {"energy_usage"},
  ["rocket-silo"] = {"energy_usage"},
  furnace = {"energy_usage"},
  lab = {"energy_usage"},
  ["mining-drill"] = {"energy_usage"},
  pump = {"energy_usage"},
  roboport = {"energy_usage"},
  --car = {"consumption"}, I think this just increases the car power
  ["belt-immunity-equipment"] = {"energy_consumption"},
  ["movement-bonus-equipment"] = {"energy_consumption"},
  ["night-vision-equipment"] = {"energy_input"},
  radar = {"energy_usage"}
}

local prototype_energy_keys = {
  fluid = {"heat_capacity", "fuel_value"},
  ["combat-robot"] = {"energy_per_move", "energy_per_tick"},
  ["construction-robot"] = {"energy_per_move", "energy_per_tick"},
  ["logistic-robot"] = {"energy_per_move", "energy_per_tick"},
  inserter = {"energy_per_movement", "energy_per_rotation"},
  lamp = {"energy_usage_per_tick"},
  ["programmable-speaker"] = {"energy_usage_per_tick"},
  ["energy-shield-equipment"] = {"energy_per_shield"}
}
-- Also anything extending Prototype/Item (fluid fuel values already randomized above)
for item, _ in pairs(defines.prototypes["item"]) do
  prototype_energy_keys[item] = {"fuel_value"}
end

-- TODO: Randomize vehicle effectivity
function randomize_energy_properties ()
  for class_key, property_list in pairs(prototype_power_keys) do
    for _, prototype in pairs(data.raw[class_key]) do
      for _, property in pairs(property_list) do
        if prototype[property] ~= nil then
          local energy_as_number = 60 * util.parse_energy(prototype[property])
          energy_as_number = randomize_numerical_property{
            dummy = energy_as_number,
            prg_key = prg.get_key(prototype)
          }
          prototype[property] = energy_as_number .. "W"
        end
      end
    end
  end

  for class_key, property_list in pairs(prototype_energy_keys) do
    for _, prototype in pairs(data.raw[class_key]) do
      for _, property in pairs(property_list) do
        if prototype[property] ~= nil then
          local energy_as_number = util.parse_energy(prototype[property])
          energy_as_number = randomize_numerical_property{
            dummy = energy_as_number,
            prg_key = prg.get_key(prototype)
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