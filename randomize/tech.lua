local reformat = require("utilities/reformat")

local inertia_function = require("randomizer-parameter-data/inertia-function-tables")
local property_info = require("randomizer-parameter-data/property-info-tables")
local prototype_tables = require("randomizer-parameter-data/prototype-tables")
local walk_params = require("randomizer-parameter-data/walk-params-tables")

rand.tech_costs = function(prototype)
    if prototype.type == "technology" then
        reformat.prototype.technology(prototype)

        -- I forget why I needed to check if count is a number (it has to be as specified in API docs), but there's probably a good reason and it doesn't hurt to check
        if prototype.unit.count ~= nil and type(prototype.unit.count) == "number" then
            randomize_numerical_property({
                prototype = prototype,
                tbl = prototype.unit,
                property = "count",
                intertia_function = inertia_function.tech_count,
                property_info = property_info.tech_count
            })

            log(serpent.block(property_info.tech_count))

        elseif prototype.unit.count_formula ~= nil then
            local formula_multiplier = randomize_numerical_property() -- TODO: Don't just do a dummy randomization!
            prototype.unit.count_formula = formula_multiplier .. "*(" .. prototype.unit.count_formula .. ")"
        end
    end
end

rand.tech_times = function(prototype)
    if prototype.type == "technology" then
        randomize_numerical_property({
            prototype = prototype,
            tbl = prototype.unit,
            property = "time",
            inertia_function = inertia_function.tech_time,
            property_info = property_info.tech_time
        })
    end
end