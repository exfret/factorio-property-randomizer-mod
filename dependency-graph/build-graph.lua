local reformat = require("utilities/reformat")

local build_graph = {}

local build_graph.dependency_graph = {}

-- TODO: Refactor out some code into build_graph_utils

-- For trees and rocks in vanilla
function build_graph.add_non_resource_autoplace()
    for entity_class, _ in pairs(defines.prototypes.entities) do
        for _, entity in pairs(data.raw[entity_class]) do
            if entity.type ~= "resource" then
                if entity.autoplace ~= nil then
                    -- It's too difficult to tell from noise expressions what the cost will be like, so ignore that for now
                    if entity.minable ~= nil then
                        if entity.minable.results == nil then -- TODO: Do this in reformatting
                            entity.minable.results = {
                                {name = entity.minable.result, count = entity.minable.count}
                            }
                            entity.minable.result = nil
                        end

                        -- Don't add nodes that don't produce anything anyways
                        if #entity.minable.results > 0 then
                            local node = {
                                type = "autoplace_node",
                                name = entity.name,
                                prereq = {}
                            }
                        end

                        -- Don't account for fluid prereqs (I think they only apply to resources)
                        -- This will be a root node, it will be depended on in an item_node or fluid_node

                        build_graph.dependency_graph[prg.get_key(node)] = node
                    end
                end
            end
        end
    end
end

function build_graph.add_recipes()
    for _, recipe in pairs(data.raw.recipe) do
        reformat.recipe(recipe)

        local node = {
            type = "recipe_node",
            name = recipe.name,
            prereqs = {}
        }

        -- Recipe category prereq
        if recipe.category == nil then
            table.insert(node.prereqs, {
                type = "recipe_category_node",
                name = "crafting",
                amount = 1
            })
        else
            table.insert(node.prereqs, {
                type = "recipe_category_node",
                name = recipe.category,
                amount = 1
            })
        end
        
        -- Recipe ingredient prereq (no support for expensive mode)
        local recipe_ingredients = {}
        if recipe.normal ~= nil then
            recipe_ingredients = recipe.normal.ingredients
        else
            recipe_ingredients = recipe.ingredients
        end
        for _, ingredient in pairs(recipe_ingredients) do
            table.insert(node.prereqs, {
                type = ingredient.type .. "_node",
                name = ingredient.name,
                amount = ingredient.amount
            })
        end

        -- Tech prereq
        local recipe_tech_unlock_node = {
            type = "recipe_tech_unlock_node",
            name = recipe.name,
            prereqs = {}
        }
        for _, technology in pairs(data.raw.technology) do
            local unlocks_recipe = false
        
            if technology.effects ~= nil then
                for _, unlock_effect in pairs(technology.effects) do
                    if unlock_effect.type == "unlock-recipe" and unlock_effect.recipe == recipe.name then
                        unlocks_recipe = true
                    end
                end
            end
        
            if unlocks_recipe then
                table.insert(recipe_tech_unlock_node.prereqs, {
                    type = "technology_node",
                    name = technology.name,
                    amount = 1
                })
            end
        end
    end
end

function build_graph.find_product_amounts(recipe, name, type)
    if recipe.normal then
        return build_graph.find_product_amounts(recipe.normal, name, type)
    end
    -- Don't support expensive mode

    local product_prototype = recipe.results

    local amount_product = 0

    for _, result in pairs(product_prototype) do
        if result.type == type and result.name == name then
            local result_amount = 0
            
            if result.amount ~= nil then
                result_amount = result_amount + result.amount
            else
                result_amount = (result.amount_min + result.amount_max) / 2
            end

            if result.probability ~= nil then
                result_amount = result_amount * result.probability
            end

            amount_product = amount_product + result_amount
        end
    end

    return amount_product
end

-- Add items and fluids
function build_graph.add_items_and_fluids()
    local function add_item_or_fluid(name, type)
        local node = {
            type = type .. "_node",
            name = name
            prereqs = {}
        }

        -- Add recipe results
        for _, recipe in pairs(data.raw.recipe) do
            -- TODO: Add blacklist back later

            reformat.recipe(recipe)
            local product_amount = build_graph.find_product_amounts(recipe, name, type)

            if product_amount > 0 then
                table.insert(node.prereqs, {
                    type = "recipe_node",
                    name = recipe.name,
                    amount = 1 / product_amount
                })
            end
        end

        -- Add minable results for resources
        for _, resource in pairs(data.raw.recipe) do
            if resource.autoplace ~= nil
                -- Resources may have to be minable, but I'm checking just in case
                if resource.minable ~= nil then
                    if resource.minable.results == nil then -- TODO: Do this in reformatting
                        resource.minable.results = {
                            {name = resource.minable.result, count = resource.minable.count}
                        }
                        resource.minable.result = nil
                    end

                    -- TODO: I may need to rename this function since it's supporting minable now too
                    reformat.recipe_products(resource.minable)

                    local product_amount = build_graph.find_product_amounts(resource.minable, name, type)

                    if product_amount > 0 then
                        table.insert(node.prereqs, {
                            type = "resource_node",
                            name = resource.name,
                            amount = 1 / product_amount
                        })
                    end
                end
            end
        end

        -- Add minable results for non-resource autoplaced entities TODO
        for entity_class in pairs(defines.prototypes.entity) do
            if entity_class ~= "resource" do
                for _, entity in pairs(data.raw[entity_class]) do
                    if entity.autoplace ~= nil
                        if entity.minable ~= nil then
                            if entity.minable.results == nil then -- TODO: Do this in reformatting
                                entity.minable.results = {
                                    {name = entity.minable.result, count = entity.minable.count}
                                }
                                entity.minable.result = nil
                            end

                            -- TODO: I may need to rename this function since it's supporting minable now too
                            reformat.recipe_products(entity.minable)

                            local product_amount = build_graph.find_product_amounts(entity.minable, name, type)

                            if product_amount > 0 then
                                table.insert(node.prereqs, {
                                    type = "autoplace_node",
                                    name = entity.name,
                                    amount = 1 / product_amount
                                })
                            end
                        end
                    end
                end
            end
        end

        -- TODO: Space rocket launch... and a few other things

        build_graph.dependency_graph[prg.get_key(node)] = node
    end

    for item_class, _ in pairs(defines.prototypes.item) do
        for _, item in pairs(data.raw[item_class]) do
            add_item_or_fluid(item.name, "item")
        end
    end
    for _, fluid in pairs(data.raw.fulid) do
        add_item_or_fluid(fluid.name, "fluid")
    end
end

