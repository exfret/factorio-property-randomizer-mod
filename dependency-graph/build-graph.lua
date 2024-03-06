local prototype_tables = require("randomizer-parameter-data/prototype-tables")

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

-- TODO: Power for the machine
local function build_graph.add_building_prereqs(building_node, building)
    for item_class, _ in pairs(defines.prototypes.item) do
        for _, item in pairs(data.raw[item_class]) do
            if item.place_result ~= nil and item.place_result == building.name then
                table.insert(building_node.prereqs, {
                    type = "item_node",
                    name = item.name,
                    amount = 1
                })
            end
        end
    end

    -- Ability to power the building if applicable
    if building.energy_source ~= nil then
        local building_energy_source_node = {
            type = "energy_source_node",
            name = building.name,
            prereqs = {}
        }

        if building.energy_source.type == "electric" then
            table.insert(building_energy_source_node.prereqs, {
                type = "electricity_node",
                name = "electricity",
                amount = 1
            })
        elseif building.energy_source.type == "burner" then
            -- TODO: Format fuel categories
            if building.energy_source.fuel_categories ~= nil then
                for _, category in pairs(building.energy_source.fuel_categories) do
                    table.insert(building_energy_source_node.prereqs, {
                        type = "fuel_category_node",
                        name = building.energy_source.fuel_category,
                        amount = 1
                    })
                end
            elseif building.energy_source.fuel_category ~= nil then
                table.insert(building_energy_source_node.prereqs, {
                    type = "fuel_category_node",
                    name = building.energy_source.fuel_category,
                    amount = 1
                })
            else
                table.insert(building_energy_source_node.prereqs, {
                    type = "fuel_category_node",
                    name = "chemical",
                    amount = 1
                })
            end
        elseif building.energy_source.type == "heat" then
            -- TODO
        elseif building.energy_source.type == "fluid" then
            if building.energy_source.burns_fluid == nil then
                building.energy_source.burns_fluid = false
            end

            -- TODO: Account for filtered fluid boxes
            if building.energy_source.burns_fluid then
                table.insert(building_energy_source_node.prereqs, {
                    type = "fluid_fuel_node",
                    name = "fluid_fuel",
                    amount = 1
                })
            else
                -- TODO: Account for temperature-based fluid fueling
            end
        elseif building.energy_source.type == "heat" then
            -- TODO: Heat energy sources...
        end
    end

    table.insert(building_node.prereqs, building_energy_source_node)
end

function build_graph.add_fuel_categories()
    for _, fuel_category in pairs(data.raw["fuel-category"]) do
        local node = {
            type = "fuel-category-ndoe",
            name = fuel_category.name,
            prereqs = {}
        }

        for item_class, _ in pairs(defines.prototypes.item) do
            for _, item in pairs(data.raw[item_class]) do
                if item.fuel_category ~= nil and item.fuel_category == fuel_category.name then
                    -- We actually need to check that fuel value is more than zero
                    if item.fuel_value ~= nil then
                        local fuel_value = util.parse_energy(item.fuel_value)
                        if fuel_value > 0 then
                            table.insert(node.prereqs, {
                                type = "item_node",
                                name = item.name,
                                amount = 1 / fuel_value
                            })
                        end
                    end
                end
            end
        end
    end
end

-- Hacked together electricity node
function build_graph.add_electricity_node()
    local electricity_node = { -- AND
        type = "electricity_node",
        name = "electricity",
        prereqs = {}
    }

    local electricity_distribution_node = { -- OR
        type = "electricity_distribution_node",
        name = "electricity_distribution",
        prereqs = {}
    }
    for _, electric_pole in pairs(data.raw["electric-pole"]) do
        local electric_pole_node = {
            type = "electric_pole_node",
            name = electric_pole.name,
            prereqs = {}
        }

        add_building_prereqs(electric_pole_node, electric_pole)

        dependency_graph[prg.get_key(electric_pole_node)] = electric_pole_node

        table.insert(electricity_distribution_node.prereqs, {
            type = "electric_pole_node",
            name = electric_pole.name,
            amount = 1
        })
    end
    dependency_graph[prg.get_key(electricity_distribution_node)] = electricity_distribution_node
    table.insert(electricity_node.prereqs, {
        type = "electricity_distribution_node",
        name = "electricity_distribution",
        amount = 1
    })

    -- This is the hacky part
    local electricity_production_node = { -- OR
        type = "electricity_production_node",
        name = "electricity_production",
        prereqs = {}
    }

    local burner_generator_node = { -- OR
        type = "burner_generator_electricity_production_node",
        name = "burner_generator_electricity_production",
        prereqs = {}
    }
    for _, burner_generator in pairs(data.raw["burner-generator"])

    local steam_node = { -- AND
        type = "steam_electricity_node",
        name = "steam_electricity",
        prereqs = {}
    }

    local offshore_pump_node = { --
    }

    local boiler_node = { -- OR
    }

    local steam_engine_node = { -- OR
    }
end

-- TODO: Ignore electricity_node for now and just make it depend on some hardcoded things or smth
blop.blop = nil

function build_graph.add_crafting_entities()
    for _, crafting_entity_class in pairs(prototype_tables.crafting_machine_classes) do
        for _, crafting_entity in pairs(data.raw[crafting_entity_class]) do
            local node = {
                type = "crafting_entity_node",
                name = crafting_entity.name,
                prereqs = {}
            }

            build_graph.add_building_prereqs(node, crafting_entity)

            dependency_graph[prg.get_key(node)] = node
        end
    end
end

function build_graph.add_technologies()
    for _, technology in pairs(data.raw.technology) do
        local node = {
            type = "technology_node",
            name = technology.name,
            prereqs = {}
        }

        reformat.technology(technology) -- TODO: Move all reformatting to beginning of data-final-fixes

        -- Prerequisite techs
        if technology.prerequisites ~= nil then
            for _, prereq in pairs(technology.prerequisites) do
                table.insert(node.prereqs, {
                    type = technology_node,
                    name = prereq,
                    amount = 1
                })
            end
        end

        -- Just assume count is 1000 if count_formula is defined, too hard to evaluate the formula atm
        -- TODO: Evaluate the formula in future versions
        local num_packs_needed = technology.unit.count or 1000
        local packs_used = {}
        for _, science_pack in pairs(technology.unit.ingredients) do
            -- TODO: reformat tech unit ingredients
            if science_pack[1] ~= nil then
                table.insert(node.prereqs, {
                    type = "item_node",
                    name = science_pack[1],
                    amount = science_pack[2]
                })
                table.insert(packs_used, science_pack[1])
            else
                table.insert(node.prereqs, {
                    type = "item_node",
                    name = science_pack.name,
                    amount = science_packe.amount
                })
                table.insert(packs_used, science_pack.name)
            end
        end

        -- Lab prereq (we need a lab to research this)
        local lab_tech_node = {
            type = "lab_tech_node",
            name = technology.name,
            prereqs = {}
        }
        for _, lab in pairs(data.raw.lab) do
            local can_research = true
            for _, pack_used in pairs(packs_used) do
                local has_pack = false
                for _, input in pairs(lab.inputs) do
                    if input == pack_used then
                        has_pack = true
                    end
                end
                if not has_pack then
                    can_research = false
                end
            end

            if can_research then
                table.insert(lab_tech_node.prereqs, {
                    type = "lab_node",
                    name = lab.name,
                    amount = 1 -- TODO: Make amount based on lab productivity or speed or something such?
                })
            end
        end
        table.insert(node.prereqs, lab_tech_node)

        dependency_graph[prg.get_key(node)] = node
    end
end

-- Lab prereqs
function build_graph.add_labs()
    for _, lab in pairs(data.raw.lab) do
        local node = {
            type = "lab_node",
            name = lab.name,
            prereqs = {}
        }

        build_graph.add_building_prereqs(node)

        dependency_graph[prg.get_key(node)] = node
    end
end