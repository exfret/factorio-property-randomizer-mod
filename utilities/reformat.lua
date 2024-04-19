require("docs")

local reformat = {}

-- TODO: double check vectors
-- TODO: Recheck for properties that could be strings or tables

--------------------------------------------------------------------------------
-- Table Types
--------------------------------------------------------------------------------

reformat.type = {}
reformat.prototype = {}
reformat.common = {}
reformat.test = {}

function reformat.type.ingredient_prototyte(ingredient)
    if ingredient.name == nil or ingredient.amount == nil then
        ingredient.name = ingredient[1]
        ingredient[1] = nil
        ingredient.amount = ingredient[2]
        ingredient[2] = nil
    end
    if ingredient.type == nil then
        ingredient.type = "item"
    end
end

function reformat.type.product_prototyte(product)
    if product[1] then
        product.name = product[1]
        product[1] = nil
        product.amount = product[2]
        product[2] = nil
    end
    if product.type == nil then
        product.type = "item"
    end
end

function reformat.type.recipe_ingredients(recipe)
    if recipe.normal ~= nil then
        reformat.type.recipe_ingredients(recipe.normal)
    end
    if recipe.expensive ~= nil then
        reformat.type.recipe_ingredients(recipe.expensive)
    end
    if recipe.ingredients ~= nil then
        for _, ingredient in pairs(recipe.ingredients) do
            reformat.type.ingredient_prototyte(ingredient)
        end
    else
        recipe.ingredients = recipe.normal.ingredients
    end
end

function reformat.type.recipe_products(recipe)
    if recipe.normal ~= nil then
        reformat.type.recipe_products(recipe.normal)
    end
    if recipe.expensive ~= nil then
        reformat.type.recipe_products(recipe.expensive)
    end
    if recipe.result ~= nil then
        if recipe.result_count == nil then
            recipe.result_count = 1
        end
        recipe.results = {
            {name = recipe.result, amount = recipe.result_count}
        }
    end
    if recipe.results == nil then
        recipe.results = recipe.normal.results
    end
    if recipe.results ~= nil then
        recipe.result = nil
        recipe.result_count = nil

        for _, result in pairs(recipe.results) do
            reformat.type.product_prototyte(result)
        end
    end
end

function reformat.prototype.recipe(recipe)
    reformat.type.recipe_ingredients(recipe)
    reformat.type.recipe_products(recipe)

    if recipe.normal ~= nil then
        for name, value in pairs(recipe.normal) do
            recipe[name] = value
        end
        recipe.normal = nil
    end
    if recipe.expensive ~= nil then
        recipe.expensive = nil
    end
end

-- Don't allow normal versus expensive mode
function reformat.prototype.technology(technology)
    local tech_table = nil
    if technology.normal then
        tech_table = technology.normal
    elseif technology.expensive then
        tech_table = technology.expensive
    end

    if tech_table ~= nil then
        for k, v in pairs(tech_table) do
            technology[k] = v
        end
    end

    technology.normal = nil
    technology.expensive = nil

    if technology.effects == nil then
        technology.effects = {}
    end
end

reformat.add_defaults = function()
    for class_name, class in pairs(data.raw) do
        for _, prototype in pairs(class) do
        end
    end
end

return reformat