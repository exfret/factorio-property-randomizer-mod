local inertia_function = require("randomizer-parameter-data/inertia-function-tables")
local property_info = require("randomizer-parameter-data/property-info-tables")
local prototype_tables = require("randomizer-parameter-data/prototype-tables")
local walk_params = require("randomizer-parameter-data/walk-params-tables")

require("random-utils/randomization-algorithms")

function randomize_technology_science_cost ()
  for _, prototype in pairs(data.raw.technology) do
    if prototype.unit.count ~= nil then
      randomize_numerical_property{
        prototype = prototype,
        tbl = prototype.unit,
        property = "count",
        intertia_function = inertia_function.tech_count,
        property_info = property_info.tech_count
      }
    elseif prototype.unit.count_formula ~= nil then
      local formula_multiplier = randomize_numerical_property()
      prototype.unit.count_formula = formula_multiplier .. "*(" .. prototype.unit.count_formula .. ")"
    end
  end
end

function randomize_technology_time_cost ()
  for _, prototype in pairs(data.raw.technology) do
    randomize_numerical_property{
      prototype = prototype,
      tbl = prototype.unit,
      property = "time",
      inertia_function = inertia_function.tech_time,
      property_info = property_info.tech_time
    }
  end
end