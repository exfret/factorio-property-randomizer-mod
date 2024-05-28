local prototype_tables = require("randomizer-parameter-data/prototype-tables")

local reformat = require("utilities/reformat")

local build_graph = {}

-- TODO: Refactor out some code into build_graph_utils
-- TODO: Rocket launch products

--------------------------------------------------------------------------------
-- Utilities
--------------------------------------------------------------------------------

function build_graph.find_product_amounts(product_prototype, name, type)
    local amount_product = 0

    for _, result in pairs(product_prototype) do
        if result.type == type and result.name == name then
            local result_amount = 0
            
            if result.amount ~= nil then
                result_amount = result_amount + result.amount
            elseif result.count ~= nil then
                result_amount = result_amount + result.count
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

-- TODO: Power for the machine
function build_graph.add_building_prereqs(building_node, building)
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
    -- TODO: Check that I have the right energy source keys...
    -- TODO: If I need to check vehicles can be fueled, I need to modify this as well
    local energy_source_key = "energy_source"
    if building.type == "burner-generator" then
        energy_source_key = "burner"
    end
    -- The energy source for generators isn't what runs the machine, so don't check for it
    if building[energy_source_key] ~= nil and building.type ~= "generator" then
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

--------------------------------------------------------------------------------
-- Graph building
--------------------------------------------------------------------------------

-- For trees and rocks in vanilla
function build_graph.add_non_resource_autoplace(dependency_graph)
    for entity_class, _ in pairs(defines.prototypes.entity) do
        for _, entity in pairs(data.raw[entity_class]) do
            if entity.type ~= "resource" then
                if entity.autoplace ~= nil then
                    -- It's too difficult to tell from noise expressions what the cost will be like, so ignore that for now
                    if entity.minable ~= nil then
                        if entity.minable.results == nil and entity.minable.result ~= nil then -- TODO: Do this in reformatting
                            entity.minable.results = {
                                {name = entity.minable.result, amount = entity.minable.count or 1}
                            }
                            entity.minable.result = nil
                            entity.minable.count = nil
                        end

                        -- Don't add nodes that don't produce anything anyways
                        if #entity.minable.results > 0 then
                            local node = {
                                type = "autoplace_node",
                                name = entity.name,
                                prereqs = {}
                            }

                            -- Don't account for fluid prereqs (I think they only apply to resources)
                            -- This will be a root node, it will be depended on in an item_node or fluid_node
    
                            dependency_graph[prg.get_key(node)] = node
                        end
                    end
                end
            end
        end
    end
end

function build_graph.add_recipes(dependency_graph)
    for _, recipe in pairs(data.raw.recipe) do
        reformat.prototype.recipe(recipe)

        local node = { -- AND
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
        local recipe_tech_unlock_node = { -- OR
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

        dependency_graph[prg.get_key(node)] = node
    end
end

-- Add items and fluids
function build_graph.add_items_and_fluids(dependency_graph)
    local function add_item_or_fluid(dependency_graph, name, type)
        local node = {
            type = type .. "_node",
            name = name,
            prereqs = {}
        }

        -- Add recipe results
        for _, recipe in pairs(data.raw.recipe) do
            -- TODO: Add blacklist back later

            reformat.prototype.recipe(recipe)
            results = recipe.results
            if recipe.normal ~= nil then
                results = recipe.normal.results
            end
            local product_amount = build_graph.find_product_amounts(results, name, type)

            if product_amount > 0 then
                table.insert(node.prereqs, {
                    type = "recipe_node",
                    name = recipe.name,
                    amount = 1 / product_amount
                })
            end
        end

        -- Add minable results for resources
        for _, resource in pairs(data.raw.resource) do
            if resource.autoplace ~= nil then
                -- Resources may have to be minable, but I'm checking just in case
                -- TODO: This is duplicate code, refactor
                if resource.minable ~= nil then
                    if resource.minable.results == nil then -- TODO: Do this in reformatting
                        resource.minable.results = {
                            {name = resource.minable.result, amount = resource.minable.count or 1}
                        }
                        resource.minable.result = nil
                        resource.minable.count = nil
                    end

                    -- TODO: I may need to rename this function since it's supporting minable now too
                    reformat.type.recipe_products(resource.minable)

                    local product_amount = build_graph.find_product_amounts(resource.minable, name, type)

                    if product_amount > 0 then
                        -- TODO: Not triggering
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
            if entity_class ~= "resource" then
                for _, entity in pairs(data.raw[entity_class]) do
                    if entity.autoplace ~= nil then
                        if entity.minable ~= nil then
                            if entity.minable.results == nil then -- TODO: Do this in reformatting
                                entity.minable.results = {
                                    {name = entity.minable.result, amount = entity.minable.count}
                                }
                                entity.minable.result = nil
                                entity.minable.count = nil
                            end

                            -- TODO: I may need to rename this function since it's supporting minable now too
                            reformat.type.recipe_products(entity.minable)

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
        for item_class, _ in pairs(defines.prototypes.item) do
            for _, item in pairs(data.raw[item_class]) do
                if item.rocket_launch_product ~= nil and item.rocket_launch_products == nil then
                    item.rocket_launch_products = {item.rocket_launch_product}
                    item.rocket_launch_product = nil
                end

                local amount_product = 0
                if item.rocket_launch_products ~= nil then
                    amount_product = amount_product + build_graph.find_product_amounts(item.rocket_launch_products, name, type)
                end

                if amount_product > 0 then
                    table.insert(node.prereqs, {
                        type = "item_node",
                        name = item.name,
                        amount = amount_product
                    })
                end
            end
        end

        dependency_graph[prg.get_key(node)] = node
    end

    for item_class, _ in pairs(defines.prototypes.item) do
        for _, item in pairs(data.raw[item_class]) do
            add_item_or_fluid(dependency_graph, item.name, "item")
        end
    end
    for _, fluid in pairs(data.raw.fluid) do
        add_item_or_fluid(dependency_graph, fluid.name, "fluid")

        -- Offshore pumps
        for _, offshore_pump in pairs(data.raw["offshore-pump"]) do
            if offshore_pump.fluid == fluid.name then
                table.insert(dependency_graph[prg.get_key({type = "fluid_node", name = fluid.name})].prereqs, {
                    type = "offshore_pump_node",
                    name = offshore_pump.name,
                    amount = 1 / offshore_pump.pumping_speed
                })
            end
        end
    end
end

function build_graph.add_fuel_categories(dependency_graph)
    for _, fuel_category in pairs(data.raw["fuel-category"]) do
        local node = { -- OR
            type = "fuel_category_node",
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

        dependency_graph[prg.get_key(node)] = node
    end
end

function build_graph.add_fluid_fuel(dependency_graph)
    local fluid_fuel_node = { -- OR
        type = "fluid_fuel_node",
        name = "fluid_fuel",
        prereqs = {}
    }
    
    for _, fluid in pairs(data.raw.fluid) do
        if fluid.fuel_value ~= nil and util.parse_energy(fluid.fuel_value) > 0 then
            table.insert(fluid_fuel_node.prereqs, {
                type = "fluid_node",
                name = fluid.name,
                amount = 1 / util.parse_energy(fluid.fuel_value)
            })
        end
    end

    dependency_graph[fluid_fuel_node] = fluid_fuel_node
end

-- Hacked together electricity node
function build_graph.add_electricity_node(dependency_graph)
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

        build_graph.add_building_prereqs(electric_pole_node, electric_pole)

        dependency_graph[prg.get_key(electric_pole_node)] = electric_pole_node

        table.insert(electricity_distribution_node.prereqs, {
            type = electric_pole_node.type,
            name = electric_pole.name,
            amount = 1
        })
    end
    
    dependency_graph[prg.get_key(electricity_distribution_node)] = electricity_distribution_node
    
    table.insert(electricity_node.prereqs, {
        type = electricity_distribution_node.type,
        name = electricity_distribution_node.name,
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

    for _, burner_generator in pairs(data.raw["burner-generator"]) do
        local prototype_node = { -- OR
            type = "burner_generator_node",
            name = burner_generator.name,
            prereqs = {}
        }

        build_graph.add_building_prereqs(prototype_node, burner_generator)

        dependency_graph[prg.get_key(prototype_node)] = prototype_node

        table.insert(burner_generator_node.prereqs, {
            type = prototype_node.type,
            name = prototype_node.name,
            amount = 1
        })
    end

    dependency_graph[prg.get_key(burner_generator_node)] = burner_generator_node
    
    table.insert(electricity_production_node.prereqs, {
        type = burner_generator_node.type,
        name = burner_generator_node.name,
        amount = 1
    })

    local fluid_generator_electricity_node = { -- OR
        type = "fluid_generator_electricity_node",
        name = "fluid_generator_electricity",
        prereqs = {}
    }

    for _, generator in pairs(data.raw.generator) do
        local fluid_generator_node = { -- AND
            type = "fluid_generator_node",
            name = generator.name,
            prereqs = {}
        }

        local fluid_generator_building_node = { -- OR
            type = "fluid_generator_building_node",
            name = generator.name,
            prereqs = {}
        }

        build_graph.add_building_prereqs(fluid_generator_building_node, generator)

        dependency_graph[prg.get_key(fluid_generator_building_node)] = fluid_generator_building_node

        table.insert(fluid_generator_node.prereqs, {
            type = fluid_generator_building_node.type,
            name = fluid_generator_building_node.name,
            amount = 1
        })

        local fluid_generator_steam_node = { -- OR
            type = "fluid_generator_steam_node",
            name = generator.name,
            prereqs = {}
        }
        if generator.fluid_box.filter ~= nil then
            table.insert(fluid_generator_steam_node.prereqs, {
                type = "fluid_node",
                name = generator.fluid_box.filter,
                amount = 1
            })
        else
            table.insert(fluid_generator_steam_node.prereqs, {
                type = "fluid_fuel_node",
                name = "fluid_fuel",
                amount = 1
            })
        end

        dependency_graph[prg.get_key(fluid_generator_steam_node)] = fluid_generator_steam_node

        table.insert(fluid_generator_node.prereqs, {
            type = fluid_generator_steam_node.type,
            name = fluid_generator_steam_node.name,
            amount = 1
        })

        dependency_graph[prg.get_key(fluid_generator_node)] = fluid_generator_node

        table.insert(fluid_generator_electricity_node.prereqs, {
            type = fluid_generator_node.type,
            name = fluid_generator_node.name,
            amount = 1
        })
    end

    dependency_graph[prg.get_key(fluid_generator_electricity_node)] = fluid_generator_electricity_node

    table.insert(electricity_production_node.prereqs, {
        type = fluid_generator_electricity_node.type,
        name = fluid_generator_electricity_node.name,
        amount = 1
    })

    dependency_graph[prg.get_key(electricity_production_node)] = electricity_production_node

    table.insert(electricity_node.prereqs, {
        type = electricity_production_node.type,
        name = electricity_production_node.name,
        amount = 1
    })

    dependency_graph[prg.get_key(electricity_node)] = electricity_node
end
-- TODO: Check boilers with fluids

function build_graph.add_crafting_entities(dependency_graph)
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

function build_graph.add_technologies(dependency_graph)
    for _, technology in pairs(data.raw.technology) do
        local node = {
            type = "technology_node",
            name = technology.name,
            prereqs = {}
        }

        reformat.prototype.technology(technology) -- TODO: Move all reformatting to beginning of data-final-fixes

        -- Prerequisite techs
        if technology.prerequisites ~= nil then
            for _, prereq in pairs(technology.prerequisites) do
                table.insert(node.prereqs, {
                    type = "technology_node",
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
                    amount = science_pack.amount
                })
                table.insert(packs_used, science_pack.name)
            end
        end

        -- Lab prereq (we need a lab to research this)
        local lab_tech_node = { -- OR
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
        dependency_graph[prg.get_key(lab_tech_node)] = lab_tech_node

        table.insert(node.prereqs, lab_tech_node)

        dependency_graph[prg.get_key(node)] = node
    end
end

-- Lab prereqs
function build_graph.add_labs(dependency_graph)
    for _, lab in pairs(data.raw.lab) do
        local node = {
            type = "lab_node",
            name = lab.name,
            prereqs = {}
        }

        build_graph.add_building_prereqs(node, lab)

        dependency_graph[prg.get_key(node)] = node
    end
end

function build_graph.add_recipe_categories(dependency_graph)
    for _, category in pairs(data.raw["recipe-category"]) do
        local node = {
            type = "recipe_category_node",
            name = category.name,
            prereqs = {}
        }

        for _, crafting_class in pairs(prototype_tables.crafting_machine_classes) do
            for _, crafting_machine in pairs(data.raw[crafting_class]) do
                for _, machine_category in pairs(crafting_machine.crafting_categories) do
                    if machine_category == category.name then
                        table.insert(node.prereqs, {
                            type = "crafting_entity_node",
                            name = crafting_machine.name,
                            amount = 1
                        })
                    end
                end
            end
        end

        for _, character in pairs(data.raw.character) do
            if character.crafting_categories ~= nil then
                for _, character_category in pairs(character.crafting_categories) do
                    if character_category == category.name then
                        table.insert(node.prereqs, {
                            type = "character_node",
                            name = character.name,
                            amount = 1
                        })
                    end
                end
            end
        end

        dependency_graph[prg.get_key(node)] = node
    end
end

function build_graph.add_resources(dependency_graph)
    for _, resource in pairs(data.raw.resource) do
        local node = {
            type = "resource_node",
            name = resource.name,
            prereqs = {}
        }

        if resource.minable ~= nil then
            if resource.minable.fluid_amount ~= nil and resource.minable.fluid_amount > 0 and resource.minable.required_fluid ~= nil then
                table.insert(node.prereqs, {
                    type = "fluid_node",
                    name = resource.minable.required_fluid,
                    amount = resource.minable.fluid_amount
                })
            end
        end

        -- TODO: Do this in reformatting!
        if resource.category == nil then
            resource.category = "basic-solid"
        end
        table.insert(node.prereqs, {
            type = "resource_category_node",
            name = resource.category,
            amount = 1
        })

        dependency_graph[prg.get_key(node)] = node
    end
end

function build_graph.add_resource_categories(dependency_graph)
    for _, category in pairs(data.raw["resource-category"]) do
        local node = {
            type = "resource_category_node",
            name = category.name,
            prereqs = {}
        }

        for _, character in pairs(data.raw.character) do
            if character.mining_categories ~= nil then
                for _, mining_category in pairs(character.mining_categories) do
                    if mining_category == category.name then
                        table.insert(node.prereqs, {
                            type = "character_node",
                            name = character.name,
                            amount = 1
                        })
                    end
                end
            end
        end

        for _, mining_machine in pairs(data.raw["mining-drill"]) do
            for _, mining_category in pairs(mining_machine.resource_categories) do
                if mining_category == category.name then
                    table.insert(node.prereqs, {
                        type = "mining_machine_node",
                        name = mining_machine.name,
                        amount = 1
                    })
                end
            end
        end

        dependency_graph[prg.get_key(node)] = node
    end
end

function build_graph.add_characters(dependency_graph)
    for _, character in pairs(data.raw.character) do
        local node = {
            type = "character_node",
            name = character.name,
            prereqs = {}
        }
        
        dependency_graph[prg.get_key(node)] = node
    end
end

function build_graph.add_offshore_pumps(dependency_graph)
    for _, offshore_pump in pairs(data.raw["offshore-pump"]) do
        local node = {
            type = "offshore_pump_node",
            name = offshore_pump.name,
            prereqs = {}
        }

        build_graph.add_building_prereqs(node, offshore_pump)

        dependency_graph[prg.get_key(node)] = node
    end
end

function build_graph.add_mining_entities(dependency_graph)
    for _, mining_machine in pairs(data.raw["mining-drill"]) do
        local node = {
            type = "mining_machine_node",
            name = mining_machine.name,
            prereqs = {}
        }

        build_graph.add_building_prereqs(node, mining_machine)

        dependency_graph[prg.get_key(node)] = node
    end
end

--------------------------------------------------------------------------------
-- Graph enhancements
--------------------------------------------------------------------------------

build_graph.add_forward_connections = function(dependency_graph)
    for _, node in pairs(dependency_graph) do
        node.dependents = {}
    end
      
    for _, node in pairs(dependency_graph) do
        for _, prereq in pairs(node.prereqs) do
            table.insert(dependency_graph[prg.get_key(prereq)].dependents, {
                type = node.type,
                name = node.name,
                amount = prereq.amount
            })
        end
    end
end

--------------------------------------------------------------------------------
-- Graph collection
--------------------------------------------------------------------------------

function build_graph.construct()
    local dependency_graph = {}

    build_graph.add_characters(dependency_graph)
    build_graph.add_crafting_entities(dependency_graph)
    build_graph.add_electricity_node(dependency_graph)
    build_graph.add_fluid_fuel(dependency_graph)
    build_graph.add_fuel_categories(dependency_graph)
    build_graph.add_items_and_fluids(dependency_graph)
    build_graph.add_labs(dependency_graph)
    build_graph.add_mining_entities(dependency_graph)
    build_graph.add_offshore_pumps(dependency_graph)
    build_graph.add_non_resource_autoplace(dependency_graph)
    build_graph.add_recipe_categories(dependency_graph)
    build_graph.add_recipes(dependency_graph)
    build_graph.add_resource_categories(dependency_graph)
    build_graph.add_resources(dependency_graph)
    build_graph.add_technologies(dependency_graph)

    build_graph.add_forward_connections(dependency_graph)

    return dependency_graph
end

--------------------------------------------------------------------------------
-- Metadata
--------------------------------------------------------------------------------

build_graph.op = {
    autoplace_node = "AND", -- Source node
    burner_generator_electricity_production_node = "OR",
    burner_generator_node = "OR",
    character_node = "AND", -- TODO: Check for unlockable characters, like in bob's classes mod
    crafting_entity_node = "OR",
    electric_pole_node = "OR",
    electricity_distribution_node = "OR",
    electricity_node = "AND",
    electricity_production_node = "OR",
    energy_source_node = "AND",
    fluid_generator_electricity_node = "OR",
    fluid_generator_node = "AND",
    fluid_generator_building_node = "OR",
    fluid_generator_steam_node = "OR",
    fluid_fuel_node = "OR",
    fluid_node = "OR",
    fuel_category_node = "OR",
    item_node = "OR",
    lab_node = "OR",
    lab_tech_node = "OR",
    mining_machine_node = "OR",
    offshore_pump_node = "OR",
    recipe_category_node = "OR",
    recipe_node = "AND",
    recipe_tech_unlock_node = "OR",
    resource_category_node = "OR",
    resource_node = "AND",
    technology_node = "AND"
}

--------------------------------------------------------------------------------
-- Return
--------------------------------------------------------------------------------

return build_graph