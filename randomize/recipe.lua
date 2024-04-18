local reformat = require("utilities/reformat")

local inertia_function = require("randomizer-parameter-data/inertia-function-tables")
local property_info = require("randomizer-parameter-data/property-info-tables")
local prototype_tables = require("randomizer-parameter-data/prototype-tables")
local walk_params = require("randomizer-parameter-data/walk-params-tables")

rand.crafting_times = function(prototype)
    if prototype.type == "recipe" then
        reformat.prototype.recipe(prototype)

        if prototype.energy_required == nil then
            prototype.energy_required = 0.5
        end

        -- If any result of this recipe is an intermediate (i.e.- used in another recipe), then randomize it more carefully
        local is_end_product = true
        for _, result in pairs(prototype.results) do
            if prototype_tables.intermediate_item_names[result.name] then
                is_end_product = false
            end
        end
      
        local slope = 3
        if is_end_product then
            slope = 10
        end
      
        randomize_numerical_property({
            prototype = prototype,
            property = "energy_required",
            inertia_function = {
                ["type"] = "proportional", -- TODO: Add separate inertia functions and locate those in inertia function tables
                slope = slope
            },
            walk_params = walk_params.recipe_crafting_time,
            property_info = property_info.recipe_crafting_time
        })
    end
end