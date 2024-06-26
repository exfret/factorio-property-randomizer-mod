require("random-utils.random")
require("globals")
require("simplex")

local prototype_tables = require("randomizer-parameter-data/prototype-tables")
local reformat = require("utilities/reformat")
local build_graph = require("dependency-graph/build-graph")

local VOID_COST = 1
local do_recipe_unlock_nodes = false
local do_tech_node_randomization = true
local do_recipe_category_randomization = false
local do_recipe_randomization = true

local old_data_raw_data = table.deepcopy(data.raw)

--[[for _, technology in pairs(data.raw.technology) do
  if technology.effects ~= nil then
    local effects = {}
    for _, effect in pairs(technology.effects) do
      if effect.type == "unlock-recipe" then
        table.insert(effects, table.deepcopy(effect))
      end
    end

    for _, effect in pairs(effects) do
      table.insert(technology.effects, effect)
    end
  end
end]]

if do_recipe_category_randomization then
    -- Form recipes for each item
    local recipe_to_old_category = {}
    local category_to_old_recipes = {}
    for _, category in pairs(data.raw["recipe-category"]) do
      category_to_old_recipes[category.name] = {}
    end

    -- Temporarily remove other categories so they don't get randomized

    recipe_categories = table.deepcopy(data.raw["recipe-category"])
    data.raw["recipe-category"] = {}

    local new_cats = {}
    for _, recipe in pairs(data.raw.recipe) do

      -- blacklist rocket silo manually for now

      if recipe.name ~= "rocket-part" then
        -- blacklist recipes with fluid products or ingredients
        reformat.prototype.recipe(recipe)
        local to_blacklist = false
        for _, ingredient in pairs(recipe.ingredients) do
          if ingredient.type == "fluid" then
            to_blacklist = true
          end
        end
        for _, result in pairs(recipe.results) do
          if result.type == "fluid" then
            to_blacklist = true
          end
        end

        if not to_blacklist then

      recipe_to_old_category[recipe.name] = recipe.category or "crafting"
      table.insert(category_to_old_recipes[recipe.category or "crafting"], recipe)
      new_cats["exfret-" .. recipe.name] = true
      recipe.category = "exfret-" .. recipe.name
      data:extend({
        {
          type = "recipe-category",
          name = "exfret-" .. recipe.name
        }
      })
    end
      end
    end

    for _, machine in pairs(data.raw["assembling-machine"]) do
      for _, category in pairs(machine.crafting_categories) do
        if not new_cats[category] then
        for _, recipe in pairs(category_to_old_recipes[category]) do
          table.insert(machine.crafting_categories, "exfret-" .. recipe.name)
        end
      end
      end
    end
    for _, machine in pairs(data.raw["furnace"]) do
      for _, category in pairs(machine.crafting_categories) do
        if not new_cats[category] then
        for _, recipe in pairs(category_to_old_recipes[category]) do
          table.insert(machine.crafting_categories, "exfret-" .. recipe.name)
        end
      end
      end
    end
    for _, character in pairs(data.raw["character"]) do
      for _, category in pairs(character.crafting_categories) do
        if not new_cats[category] then
          for _, recipe in pairs(category_to_old_recipes[category]) do
          table.insert(character.crafting_categories, "exfret-" .. recipe.name)
          end
        end
      end
    end
end

-- HOTFIX - Add certain tech unlocks twice just to make sure
-- NOT WORKING!
--[[table.insert(data.raw.technology["logistics"].effects, {
  type = "unlock-recipe",
  recipe = "assembling-machine-1"
})
table.insert(data.raw.technology["optics"].effects, {
  type = "unlock-recipe",
  recipe = "assembling-machine-1"
})
table.insert(data.raw.technology["automation"].effects, {
  type = "unlock-recipe",
  recipe = "underground-belt"
})
table.insert(data.raw.technology["optics"].effects, {
  type = "unlock-recipe",
  recipe = "splitter"
})
table.insert(data.raw.technology["optics"].effects, {
  type = "unlock-recipe",
  recipe = "gun-turret"
})]]

-- Unlock everything in general an extra time as well
--[[local techs = table.deepcopy(data.raw.technology)
for _, prototype in pairs(techs) do
  if prototype.effects ~= nil then
    for _, unlock in pairs(prototype.effects) do
      if unlock.type == "unlock-recipe" then
        table.insert(data.raw.technology[prototype.name].effects, {
          type = "unlock-recipe",
          recipe = unlock.recipe
        })
      end
    end
  end
end]]

-- TODO: Add support for starting items
-- TODO: Add support for trees and rocks (they are special cases since they're not "automatable")
-- TODO: Add support for custom autoplace in general (like, for example, in the ruins mod)
-- TODO: Add support for fuels (there's also burnt products and such...)
-- TODO: Support min_temperatures and max_temperatures on fluids in recipes
-- TODO: Support for recipes with no ingredients (gives another way to get infinite resources)
-- TODO: Test if lab is craftable
-- TODO: Account for crafting as a special recipe category
-- TODO: Amount in prereq for machines/buildings set correctly
-- TODO: Offshore pump giving water
-- TODO: Fluid/item limits on assembling machines
-- TODO: Deal with infinite techs
-- TODO: Actual recipe editing still messes up with normal versus expensive ugh
-- TODO: Special attention needs to be paid to crafting categories and fluids, since regular crafting category can't have them
-- TODO: Take special care with recipes that involve smelting/furnaces (no repeat ingredients, only one ingredient, etc.)
-- TODO: Rocket launch products
-- TODO: Reachable character classes
-- TODO: Required fluid boxes
-- TODO: Minable properties of buildings

local dependency_utils = {}

-- Entries will be tables with id = {type = type of node (source, recipe, abstract, etc.), prereqs = node prereqs ids}
-- source-manual indicates it can be made, but not very well (mining trees being the primary example), currently not implemented
local dependency_graph = {}
local recipes_not_added = {}
--[[local blacklisted_recipes = {
  ["empty-crude-oil-barrel"] = true,
  ["empty-heavy-oil-barrel"] = true,
  ["empty-light-oil-barrel"] = true,
  ["empty-lubricant-barrel"] = true,
  ["empty-petroleum-gas-barrel"] = true,
  ["empty-sulfuric-acid-barrel"] = true,
  ["empty-water-barrel"] = true,
  ["fill-crude-oil-barrel"] = true,
  ["fill-heavy-oil-barrel"] = true,
  ["fill-light-oil-barrel"] = true,
  ["fill-lubricant-barrel"] = true,
  ["fill-petroleum-gas-barrel"] = true,
  ["fill-sulfuric-acid-barrel"] = true,
  ["fill-water-barrel"] = true,
  ["coal-liquefaction"] = true,
  ["advanced-oil-processing"] = true
}]]
for _, recipe in pairs(data.raw.recipe) do
  --if not blacklisted_recipes[recipe.name] then
    table.insert(recipes_not_added, recipe)
  --end
end
local crafting_entities_not_added = {}
for _, crafting_machine_class in pairs(prototype_tables.crafting_machine_classes) do
  for _, crafting_machine in pairs(data.raw[crafting_machine_class]) do
    table.insert(crafting_entities_not_added, crafting_machine)
  end
end
local items_and_fluids_not_added = {}
for item_class, _ in pairs(defines.prototypes["item"]) do
  for _, item in pairs(data.raw[item_class]) do
    table.insert(items_and_fluids_not_added, item)
  end
end
for _, fluid in pairs(data.raw.fluid) do
  table.insert(items_and_fluids_not_added, fluid)
end
local technologies_not_added = {}
for _, technology in pairs(data.raw.technology) do
  table.insert(technologies_not_added, technology)
end
local recipe_categories_not_added = {}
for _, recipe_category in pairs(data.raw["recipe-category"]) do
  table.insert(recipe_categories_not_added, recipe_category)
end
local resources_not_added = {}
for _, resource in pairs(data.raw.resource) do
  table.insert(resources_not_added, resource)
end
local resource_categories_not_added = {}
for _, resource_category in pairs(data.raw["resource-category"]) do
  table.insert(resource_categories_not_added, resource_category)
end
local mining_machines_not_added = {}
for _, mining_machine in pairs(data.raw["mining-drill"]) do
  table.insert(mining_machines_not_added, mining_machine)
end

for _, recipe in pairs(recipes_not_added) do
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
      amount = 1})
  else
    table.insert(node.prereqs, {
      type = "recipe_category_node",
      name = recipe.category,
      amount = 1})
  end

  -- Recipe ingredient prereq
  local function get_recipe_ingredients (recipe)
    local recipe_ingredients = {}

    for _, ingredient in pairs(recipe.ingredients) do
      if ingredient[1] and ingredient[2] then
        table.insert(recipe_ingredients, {name = ingredient[1], amount = ingredient[2]})
      else
        table.insert(recipe_ingredients, {name = ingredient.name, amount = ingredient.amount}) -- TODO: probabilities and such
      end
    end

    return recipe_ingredients
  end

  -- Now add recipe ingredients
  local recipe_ingredients = {}
  if recipe.normal then
    recipe_ingredients = get_recipe_ingredients(recipe.normal)
  else
    recipe_ingredients = get_recipe_ingredients(recipe)
  end
  for _, ingredient in pairs(recipe_ingredients) do
    --- Note, the node may represent an item or fluid
    table.insert(node.prereqs, {
      type = "itemorfluid_node",
      name = ingredient.name,
      amount = ingredient.amount
    })
  end

  -- Now add tech prerequisites
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
      -- Pretend like there are two unlocks for the recipes for recipe unlock rando
      table.insert(recipe_tech_unlock_node.prereqs, {
        type = "technology_node",
        name = technology.name,
        amount = 1
      })
    end
  end

  -- Only add the tech prereq if the recipe isn't already unlocked from start of game
  local requires_technology = false
  if recipe.enabled ~= nil and not recipe.enabled then
    requires_technology = true
  elseif recipe.normal ~= nil and recipe.normal.enabled ~= nil and not recipe.normal.enabled then
    requires_technology = true
  end

  if requires_technology then
    dependency_graph[prg.get_key(recipe_tech_unlock_node)] = recipe_tech_unlock_node

    table.insert(node.prereqs, {
      type = recipe_tech_unlock_node.type,
      name = recipe_tech_unlock_node.name,
      amount = 1
    })
  end

  dependency_graph[prg.get_key(node)] = node
end

local function product_prototype_has_product_amount (product_prototype, itemorfluid)
  local amount_product = 0

  for _, result in pairs(product_prototype) do
    if result[1] ~= nil and result[1] == itemorfluid.name then
      amount_product = amount_product + result[2]
    elseif result.name ~= nil and result.name == itemorfluid.name then
      local result_amount = 0

      if result.amount then
        result_amount = result_amount + result.amount
      else
        result_amount = (result.amount_min + result.amount_max) / 2
      end

      if result.probability then
        result_amount = result_amount * result.probability
      end

      amount_product = amount_product + result_amount
    end
  end

  return amount_product
end

-- Assume cheap mode for now
local function recipe_has_product_amount (recipe, itemorfluid)
  if recipe.normal then
    return recipe_has_product_amount(recipe.normal, itemorfluid)
  end

  if recipe.results ~= nil then
    return product_prototype_has_product_amount(recipe.results, itemorfluid)
  end

  if recipe.result then
    if recipe.result == itemorfluid.name then
      return recipe.result_count or 1
    else
      return 0
    end
  end
end

-- Add special void "item"
--[[dependency_graph[prg.get_key({type = "itemorfluid_node", name = "void"})] = {
  type = "itemorfluid_node",
  name = "void",
  prereqs = {}
}
for _, itemorfluid in pairs(items_and_fluids_not_added) do
  table.insert(dependency_graph[prg.get_key({type = "itemorfluid_node", name = "void"})].prereqs, {
    type = "recipe_node",
    name = "void_" .. itemorfluid.name,
    amount = 1
  })
end]]
for _, itemorfluid in pairs(items_and_fluids_not_added) do
  -- Add void recipe
  --[[dependency_graph[prg.get_key({type = "recipe_node", name = "void_" .. itemorfluid.name})] = {
    type = "recipe_node",
    name = "void_" .. itemorfluid.name,
    prereqs = {
      {
        type = "itemorfluid_node",
        name = itemorfluid.name,
        amount = 1 / VOID_COST
      }
    }
  }]]

  local node = {
    type = "itemorfluid_node",
    name = itemorfluid.name,
    prereqs = {}
  }

  -- Add recipe products
  for _, recipe in pairs(data.raw.recipe) do
    --if not blacklisted_recipes[recipe.name] then
      local product_amount = recipe_has_product_amount(recipe, itemorfluid)

      if product_amount > 0 then
        table.insert(node.prereqs, {
          type = "recipe_node",
          name = recipe.name,
          amount = 1 / product_amount
        })
      end
    --end
  end

  -- Add minable results
  for _, resource in pairs(data.raw.resource) do
    if resource.minable ~= nil then
      local product_amount
      
      if resource.minable.result ~= nil and resource.minable.result == itemorfluid.name then
        if resource.minable.count == nil then
          resource.minable.count = 1
        end

        product_amount = resource.minable.count
      elseif resource.minable.results ~= nil then
        product_amount = product_prototype_has_product_amount(resource.minable.results, itemorfluid)
      end

      if product_amount ~= nil and product_amount > 0 then
        table.insert(node.prereqs, {type = "resource_node", name = resource.name, amount = 1 / product_amount})
      end
    end
  end

  -- TODO: Deal with fluids better
  dependency_graph[prg.get_key(node)] = node
end

for _, crafting_entity in pairs(crafting_entities_not_added) do
  local node = {
    type = "crafting_entity_node",
    name = crafting_entity.name,
    prereqs = {}
  }

  for item_class, _ in pairs(defines.prototypes.item) do
    for _, item in pairs(data.raw[item_class]) do
      if item.place_result ~= nil and item.place_result == crafting_entity.name then
        table.insert(node.prereqs, {
          type = "itemorfluid_node",
          name = item.name,
          amount = 1 -- TODO: Sometimes placing down something can use more than one of the item, so account for this
        })
      end
    end
  end

  dependency_graph[prg.get_key(node)] = node
end

for _, technology in pairs(technologies_not_added) do
  local node = {
    type = "technology_node",
    name = technology.name,
    prereqs = {}
  }

  if technology.prerequisites ~= nil then
    for _, prereq in pairs(technology.prerequisites) do
      table.insert(node.prereqs, {
        type = "technology_node",
        name = prereq,
        amount = 1
      })
    end
  end

  for _, science_pack in pairs(technology.unit.ingredients) do
    if science_pack[1] ~= nil then
      table.insert(node.prereqs, {
        type = "itemorfluid_node",
        name = science_pack[1],
        amount = 1 -- TODO: Find actual amount instead of assuming this is just one
      })
    else
      table.insert(node.prereqs, {
        type = "itemorfluid_node",
        name = science_pack.name,
        amount = 1
      })
    end
  end

  dependency_graph[prg.get_key(node)] = node
end

for _, recipe_category in pairs(recipe_categories_not_added) do
  local node = {
    type = "recipe_category_node",
    name = recipe_category.name,
    prereqs = {}
  }

  for _, crafting_machine in pairs(crafting_entities_not_added) do
    for _, crafting_category in pairs(crafting_machine.crafting_categories) do
      if crafting_category == recipe_category.name then
        table.insert(node.prereqs, {
          type = "crafting_entity_node",
          name = crafting_machine.name,
          amount = 1
        })
      end
    end
  end

  for _, character in pairs(data.raw.character) do
    if character.crafting_categories ~= nil then
      for _, character_crafting_category in pairs(character.crafting_categories) do
        if character_crafting_category == recipe_category.name then
          table.insert(node.prereqs, {
            type = "character_crafting_node",
            name = character.name,
            amount = 1
          })
        end
      end
    end
  end

  dependency_graph[prg.get_key(node)] = node
end

-- Todo: add better support for other resource categories
for _, resource in pairs(resources_not_added) do
  local node = {
    type = "resource_node",
    name = resource.name,
    prereqs = {}
  }

  if resource.minable ~= nil then
    if resource.minable.fluid_amount ~= nil and resource.minable.fluid_amount > 0 and resource.minable.required_fluid ~= nil then
      table.insert(node.prereqs, {
        type = "itemorfluid_node",
        name = resource.minable.required_fluid,
        amount = resource.minable.fluid_amount
      })
    end
  end

  if resource.category == nil then
    resource.category = "basic-solid"
  end
  --[[table.insert(node.prereqs, {
    type = "resource_category_node",
    name = resource.category,
    amount = 1
  })]] -- TODO URGENT: ADD THIS BACK

  dependency_graph[prg.get_key(node)] = node
end

for _, mining_machine in pairs(mining_machines_not_added) do
  local node = {
    type = "mining_machine_node",
    name = mining_machine.name,
    prereqs = {}
  }

  for item_class, _ in pairs(defines.prototypes.item) do
    for _, item in pairs(data.raw[item_class]) do
      if item.place_result ~= nil and item.place_result == mining_machine.name then
        table.insert(node.prereqs, {
          type = "itemorfluid_node",
          name = item.name,
          amount = 1
        })
      end
    end
  end

  dependency_graph[prg.get_key(node)] = node
end

for _, resource_category in pairs(resource_categories_not_added) do
  local node = {
    type = "resource_category_node",
    name = resource_category.name,
    prereqs = {}
  }

  -- TODO: Not necessarily assuming this character is available from the start
  -- (This could be messed up by, for example, bob's classes mod)
  for _, character in pairs(data.raw.character) do
    if character.mining_categories ~= nil then
      for _, mining_category in pairs(character.mining_categories) do
        if mining_category == resource_category.name then
          table.insert(node.prereqs, {
            type = "character_mining_node",
            name = character.name,
            amount = 1
          })
        end
      end
    end
  end

  for _, mining_machine in pairs(mining_machines_not_added) do
    for _, mining_category in pairs(mining_machine.resource_categories) do
      if mining_category == resource_category.name then
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

for _, character in pairs(data.raw.character) do
  local node = {
    type = "character_mining_node",
    name = character.name,
    prereqs = {}
  }

  dependency_graph[prg.get_key(node)] = node
end

for _, character in pairs(data.raw.character) do
  local node = {
    type = "character_crafting_node",
    name = character.name,
    prereqs = {}
  }

  dependency_graph[prg.get_key(node)] = node
end

-- TODO: get this to work for other offshore pump prototypes in general
table.insert(dependency_graph[prg.get_key({type = "itemorfluid_node", name = "water"})].prereqs, {
  type = "itemorfluid_node",
  name = "offshore-pump",
  amount = 1 / 1200
})

--[[
local new_node_for_ash = {
  type = "itemorfluid_node",
  name = "ash",
  prereqs = {}
}
table.insert(new_node_for_ash.prereqs, {
  type = "itemorfluid_node",
  name = "water",
  amount = 1
})
dependency_graph[prg.get_key(new_node_for_ash)] = new_node_for_ash
local new_node_for_log = {
  type = "itemorfluid_node",
  name = "log",
  prereqs = {}
}
table.insert(new_node_for_log.prereqs, {
  type = "itemorfluid_node",
  name = "water",
  amount = 1
})
dependency_graph[prg.get_key(new_node_for_log)] = new_node_for_log
local new_node_for_moss = {
  type = "itemorfluid_node",
  name = "moss",
  prereqs = {}
}
table.insert(new_node_for_moss.prereqs, {
  type = "itemorfluid_node",
  name = "water",
  amount = 1
})
dependency_graph[prg.get_key(new_node_for_moss)] = new_node_for_moss
local new_node_for_fish = {
  type = "itemorfluid_node",
  name = "fish",
  prereqs = {}
}
table.insert(new_node_for_fish.prereqs, {
  type = "itemorfluid_node",
  name = "water",
  amount = 1
})
dependency_graph[prg.get_key(new_node_for_fish)] = new_node_for_fish
local new_node_for_steam = {
  type = "itemorfluid_node",
  name = "steam",
  prereqs = {}
}
table.insert(new_node_for_steam.prereqs, {
  type = "itemorfluid_node",
  name = "water",
  amount = 1
})
dependency_graph[prg.get_key(new_node_for_steam)] = new_node_for_steam
local new_node_for_sap = {
  type = "itemorfluid_node",
  name = "sap",
  prereqs = {}
}
table.insert(new_node_for_sap.prereqs, {
  type = "itemorfluid_node",
  name = "water",
  amount = 1
})
dependency_graph[prg.get_key(new_node_for_sap)] = new_node_for_sap
local new_node_for_oil = {
  type = "itemorfluid_node",
  name = "crude-oil",
  prereqs = {}
}
table.insert(new_node_for_oil.prereqs, {
  type = "itemorfluid_node",
  name = "water",
  amount = 1
})
dependency_graph[prg.get_key(new_node_for_oil)] = new_node_for_oil
local new_node_for_gas = {
  type = "itemorfluid_node",
  name = "raw-gas",
  prereqs = {}
}
table.insert(new_node_for_gas.prereqs, {
  type = "itemorfluid_node",
  name = "water",
  amount = 1
})
dependency_graph[prg.get_key(new_node_for_gas)] = new_node_for_gas]]

-- TEST
--[[local new_node_for_wood = {
  type = "itemorfluid_node",
  name = "wood",
  prereqs = {}
}
table.insert(new_node_for_wood.prereqs, {
  type = "itemorfluid_node",
  name = "water",
  amount = 1
})
local new_node_for_basic_tech_card = {
  type = "itemorfluid_node",
  name = "basic-tech-card",
  prereqs = {
    {
      type = "itemorfluid_node",
      name = "wood",
      amount = 1
    }
  }
}
dependency_graph[prg.get_key(new_node_for_wood)] = new_node_for_wood
dependency_graph[prg.get_key(new_node_for_basic_tech_card)] = new_node_for_basic_tech_card]]

log("Wrapping up forward connections...")

for _, node in pairs(dependency_graph) do
  node.dependents = {}
end

for _, node in pairs(dependency_graph) do
  for _, prereq in pairs(node.prereqs) do
    if dependency_graph[prg.get_key(prereq)] == nil then
      --[[log(node.type)
      log(node.name)
      log(prereq.type)
      log(prereq.name)]]
    else
      table.insert(dependency_graph[prg.get_key(prereq)].dependents, {
        type = node.type,
        name = node.name,
        amount = prereq.amount
      })
    end
  end
end

--[[for _, node in pairs(dependency_graph) do
  node.prereqs_satisfied = {}
  for _, prereq in pairs(node.prereqs) do
    node.prereqs_satisfied[prg.get_key(prereq)] = false
  end
end]]

--[[log("Adding resource recipes...")

for _, node in pairs(dependency_graph) do
  -- Quick and hacky!
  if node.type == "resource_node" then
    --log(serpent.block(node))

    if (data.raw.resource[node.name].minable.results ~= nil) then
      for _, result in pairs(data.raw.resource[node.name].minable.results) do
        dependency_graph[prg.get_key({type = "recipe_node", name = node.name})] = {
          type = "recipe_node",
          name = node.name,
          prereqs = {},
          dependents = {{
            type = "itemorfluid_node",
            name = result[1] or result.name,
            amount = 1
          }}
        }
        table.insert(dependency_graph[prg.get_key({type = "itemorfluid_node", name = result[1] or result.name})].prereqs, {
          type = "recipe_node",
          name = node.name,
          amount = 1
        })
      end
    elseif data.raw.resource[node.name].minable.result ~= nil and node.name ~= "uranium-ore" and node.name ~= "crude-oil" then
      dependency_graph[prg.get_key({type = "recipe_node", name = node.name})] = {
        type = "recipe_node",
        name = node.name,
        prereqs = {},
        dependents = {{
          type = "itemorfluid_node",
          name = data.raw.resource[node.name].minable.result,
          amount = 1
        }}
      }
      table.insert(dependency_graph[prg.get_key({type = "itemorfluid_node", name = data.raw.resource[node.name].minable.result})].prereqs, {
        type = "recipe_node",
        name = node.name,
        amount = 1
      })
    end
  end
end]]

-- DEPENDENCY GRAPH BUILDING DONE
--dependency_graph = build_graph.construct()

-- Apply swaps if one doesn't depend on the other idea

local dependency_graph_keys = {}
for key, _ in pairs(dependency_graph) do
  table.insert(dependency_graph_keys, key)
end

local node_type_operation = {
  recipe_node = "AND",
  itemorfluid_node = "OR",
  technology_node = "AND",
  recipe_tech_unlock_node = "OR",
  recipe_category_node = "OR",
  crafting_entity_node = "OR",
  character_crafting_node = "AND", -- No prereqs, so essentially a source
  mining_machine_node = "OR",
  resource_node = "AND",
  resource_category_list_node = "OR",
  resource_category_node = "OR",
  character_mining_node = "AND" -- No prereqs, so essentially a source
}

if false then

-- Which things can be reached without thing
local function reachable_without(thing)
  local dependency_graph_without_thing = table.deepcopy(dependency_graph)
  dependency_graph_without_thing[prg.get_key(thing)] = nil

  local accessible_list = {}
  local added_to_accessible_list = {}

  local source_nodes = {}
  local source_nodes_size = 0
  for _, node in pairs(dependency_graph_without_thing) do
    node.prereqs_satisfied = {}
    for _, prereq in pairs(node.prereqs) do
      node.prereqs_satisfied[prg.get_key(prereq)] = false
    end

    if node_type_operation[node.type] == "AND" and next(node.prereqs) == nil then
      source_nodes_size = source_nodes_size + 1
      source_nodes[source_nodes_size] = node
    end
  end

  for i=1,REALLY_BIG_FLOAT_NUM do
    if i > source_nodes_size then
      break
    end
    local curr_node = source_nodes[i]
  
    if not added_to_accessible_list[prg.get_key(curr_node)] then
      table.insert(accessible_list, curr_node)
      added_to_accessible_list[prg.get_key(curr_node)] = true
    end
    for _, dependent in pairs(curr_node.dependents) do
      local dependent_node = dependency_graph_without_thing[prg.get_key(dependent)]
      if dependent_node ~= nil then
        if not added_to_accessible_list[prg.get_key(dependent_node)] then
          if node_type_operation[dependent_node.type] == "OR" then
            source_nodes_size = source_nodes_size + 1
            source_nodes[source_nodes_size] = dependent_node
          elseif node_type_operation[dependent_node.type] == "AND" then
            dependent_node.prereqs_satisfied[prg.get_key(curr_node)] = true
    
            local all_prereqs_satisfied = true
            for _, prereq_satisfied in pairs(dependent_node.prereqs_satisfied) do
              if prereq_satisfied == false then
                all_prereqs_satisfied = false
              end
            end
    
            if all_prereqs_satisfied then
              source_nodes_size = source_nodes_size + 1
              source_nodes[source_nodes_size] = dependent_node
            end
          end
        end
      end
    end
  end

  return added_to_accessible_list
end

local accessible_forbidden_list = {}
local num_done = 0
for _, node in pairs(dependency_graph) do
  if node.type == "technology_node" then
    log(num_done .. ": " .. serpent.block(node))
    accessible_forbidden_list[prg.get_key(node)] = reachable_without(node)
    num_done = num_done + 1
  end
end

log(serpent.block(accessible_forbidden_list))

log("did it")

local tech_list = {}
for _, node in pairs(dependency_graph) do
  if node.type == "technology_node" then
    table.insert(tech_list, node)
  end
end

local permutation = {}
for i=1,#tech_list do
  permutation[i] = i
end
for i=1,10000000 do
  local first = math.random(1,#tech_list)
  local second = math.random(1,#tech_list)

  if accessible_forbidden_list[prg.get_key(tech_list[first])][prg.get_key(tech_list[second])] and accessible_forbidden_list[prg.get_key(tech_list[second])][prg.get_key(tech_list[first])] then
    log("succeeded")

    local temp = permutation[first]
    permutation[first] = permutation[second]
    permutation[second] = temp
  end
end

for i, node in pairs(tech_list) do
  data.raw.technology[node.name].prerequisites = {}

  for _, prereq in pairs(tech_list[permutation[i]].prereqs) do
    if prereq.type == "technology_node" then
      table.insert(data.raw.technology[node.name].prerequisites, prereq.name)
    end
  end
end

end

function add_to_source(node, top_sort, source_nodes, source_nodes_went_through_table, nodes_left)
  local source_nodes_went_through = source_nodes_went_through_table[1]

  if not source_nodes[prg.get_key(node)] then
    top_sort[source_nodes_went_through] = node
    source_nodes[prg.get_key(node)] = true
    source_nodes_went_through_table[1] = source_nodes_went_through + 1
    nodes_left[prg.get_key(node)] = nil
  end
end

if do_recipe_unlock_nodes then

  function recipe_unlocks_randomization()

-- Start with recipe_tech_unlock_node
-- Categorize recipes as a specific building prototype, or intermediate, or science? Basically just classify by class
-- Recipes with multiple products can be their own class for now
-- How to prevent from becoming impossible? - pull with priority

local recipe_tech_unlock_node_to_type = {}
for _, node in pairs(dependency_graph) do
  if node.type == "recipe_tech_unlock_node" then
    if data.raw.recipe[node.name] == nil then
      recipe_tech_unlock_node_to_type[prg.get_key(node)] = "NULL"
    else
      local recipe = data.raw.recipe[node.name]

      -- TODO: Move to main reformatting)
      reformat.prototype.recipe(recipe)

      if #recipe.results == 1 then
        local result = recipe.results[1]

        if recipe.category == "centrifuging" then
          recipe_tech_unlock_node_to_type[prg.get_key(node)] = "CENTRIFUGE"
        elseif recipe.category == "chemistry" then
          recipe_tech_unlock_node_to_type[prg.get_key(node)] = "CHEMISTRY"
        elseif recipe.category == "oil-processing" then
          recipe_tech_unlock_node_to_type[prg.get_key(node)] = "OIL"
        elseif recipe.category == "rocket-building" then
          recipe_tech_unlock_node_to_type[prg.get_key(node)] = "ROCKET"
        elseif recipe.category == "smelting" then
          recipe_tech_unlock_node_to_type[prg.get_key(node)] = "SMELT"
        else
          log(serpent.block(result))
          local result_prototype
          for item_class, _ in pairs(defines.prototypes.item) do
            if data.raw[item_class][result.name] ~= nil then
              result_prototype = data.raw[item_class][result.name]
            end
          end
          if data.raw.fluid[result.name] ~= nil then
            result_prototype = "fluid"
          end

          if result_prototype.type ~= "item" then
            recipe_tech_unlock_node_to_type[prg.get_key(node)] = result_prototype.type
          else
            if result_prototype.place_result ~= nil then
              local result_place_prototype
              for entity_class, _ in pairs(defines.prototypes.entity) do
                if data.raw[entity_class][result_prototype.place_result] ~= nil then
                  result_place_prototype = data.raw[entity_class][result_prototype.place_result]
                end
              end

              recipe_tech_unlock_node_to_type[prg.get_key(node)] = result_place_prototype.type
            else
              recipe_tech_unlock_node_to_type[prg.get_key(node)] = "INTERMEDIATE"
            end
          end
        end
      else
        recipe_tech_unlock_node_to_type[prg.get_key(node)] = "COMPLEX_MEH"
      end
    end
  end
end

local top_sort = {}
local source_nodes = {}
local source_nodes_went_through_table = {1}
local nodes_left = table.deepcopy(dependency_graph)

for _, node in pairs(dependency_graph) do
  if node_type_operation[node.type] == "AND" and #node.prereqs == 0 then
    add_to_source(node, top_sort, source_nodes, source_nodes_went_through_table, nodes_left)
  end
end

local num_nodes = 0
for _, _ in pairs(dependency_graph) do
  num_nodes = num_nodes + 1
end

for i=1,num_nodes do
  if #top_sort >= i then
    local next_node = top_sort[i]

    if next_node.dependents ~= nil then
      for _, dependent in pairs(next_node.dependents) do
        if node_type_operation[dependent.type] == "OR" then
          add_to_source(table.deepcopy(dependency_graph[prg.get_key(dependent)]), top_sort, source_nodes, source_nodes_went_through_table, nodes_left)
        else
          local satisfied = true
          for _, prereq in pairs(dependency_graph[prg.get_key(dependent)].prereqs) do
            if not source_nodes[prg.get_key(prereq)] then
              satisfied = false
            end
          end
          if satisfied then
            add_to_source(table.deepcopy(dependency_graph[prg.get_key(dependent)]), top_sort, source_nodes, source_nodes_went_through_table, nodes_left)
          end
        end
      end
    end
  end
end

local recipe_unlock_node_list = {}
for _, node in pairs(top_sort) do
  if node.type == "recipe_tech_unlock_node" then
    table.insert(recipe_unlock_node_list, node)
  end
end

-- Recipe unlock node list is fine

local recipe_unlock_node_list_sorted = table.deepcopy(recipe_unlock_node_list)
local type_to_indices_sorted = {}
local indices_to_types_sorted = {}
local types_to_its_sorted = {}
for ind, node in pairs(recipe_unlock_node_list) do
  if type_to_indices_sorted[recipe_tech_unlock_node_to_type[prg.get_key(node)]] == nil then
    type_to_indices_sorted[recipe_tech_unlock_node_to_type[prg.get_key(node)]] = {}
    types_to_its_sorted[recipe_tech_unlock_node_to_type[prg.get_key(node)]] = 1
  end
  table.insert(type_to_indices_sorted[recipe_tech_unlock_node_to_type[prg.get_key(node)]], ind)
  indices_to_types_sorted[ind] = recipe_tech_unlock_node_to_type[prg.get_key(node)]
end

-- recipe_unlock_node_list has no repeats
--log(serpent.block(recipe_unlock_node_list))

prg.shuffle("shuffle_me_pls", recipe_unlock_node_list)

-- After shuffling it's fine

-- Now sort the sub-lists of the recipe_unlock_node_list, then try to carry over

local type_to_indices = {}
local indices_to_types = {}
local types_to_its = {}
for ind, node in pairs(recipe_unlock_node_list) do
  if type_to_indices[recipe_tech_unlock_node_to_type[prg.get_key(node)]] == nil then
    type_to_indices[recipe_tech_unlock_node_to_type[prg.get_key(node)]] = {}
    types_to_its[recipe_tech_unlock_node_to_type[prg.get_key(node)]] = 1
  end
  table.insert(type_to_indices[recipe_tech_unlock_node_to_type[prg.get_key(node)]], ind)
  indices_to_types[ind] = recipe_tech_unlock_node_to_type[prg.get_key(node)]
end

--log(serpent.block(recipe_tech_unlock_node_to_type))
-- It is indeed mixed up
--[[log(serpent.block(indices_to_types))
log("separator")
log(serpent.block(indices_to_types_sorted))]]

local function find_reachable_tech_unlock_nodes(tech_unlock_node_list)
  local top_sort = {}
  local source_nodes = {}
  local source_nodes_went_through_table = {1}
  local nodes_left = table.deepcopy(dependency_graph)

  -- Remove tech unlock nodes except for ones in list
  for _, node in pairs(nodes_left) do
    if node.type == "recipe_tech_unlock_node" and not tech_unlock_node_list[prg.get_key(node)] then
      nodes_left[prg.get_key(node)] = nil
    end
  end

  for _, node in pairs(dependency_graph) do
    if node_type_operation[node.type] == "AND" and #node.prereqs == 0 then
      add_to_source(node, top_sort, source_nodes, source_nodes_went_through_table, nodes_left)
    end
  end
  
  local num_nodes = 0
  for _, _ in pairs(dependency_graph) do
    num_nodes = num_nodes + 1
  end
  
  for i=1,num_nodes do
    if #top_sort >= i then
      local next_node = top_sort[i]
  
      for _, dependent in pairs(next_node.dependents) do
        if node_type_operation[dependent.type] == "OR" then
          add_to_source(table.deepcopy(dependency_graph[prg.get_key(dependent)]), top_sort, source_nodes, source_nodes_went_through_table, nodes_left)
        else
          local satisfied = true
          for _, prereq in pairs(dependency_graph[prg.get_key(dependent)].prereqs) do
            if (not source_nodes[prg.get_key(prereq)]) or (prereq.type == "recipe_tech_unlock_node" and (not tech_unlock_node_list[prg.get_key(prereq)])) then
              satisfied = false
            end
          end
          if satisfied then
            add_to_source(table.deepcopy(dependency_graph[prg.get_key(dependent)]), top_sort, source_nodes, source_nodes_went_through_table, nodes_left)
          end
        end
      end
    end
  end

  local reachable_tech_unlock_nodes = {}
  for _, node in pairs(top_sort) do
    if node.type == "recipe_tech_unlock_node" then
      reachable_tech_unlock_nodes[prg.get_key(node)] = true
    end
  end

  return reachable_tech_unlock_nodes
end

local indices_of_recipe_tech_unlock_nodes_added = {}
local recipe_unlocks_added = {}
local recipe_unlock_order = {}
for i=1,#recipe_unlock_node_list do
  local reachable_tech_unlock_nodes = find_reachable_tech_unlock_nodes(recipe_unlocks_added)

  for j=1,#recipe_unlock_node_list do
    if not indices_of_recipe_tech_unlock_nodes_added[j] then
      -- attempt to add next thing of type at index j
      local type = indices_to_types[j]

      if reachable_tech_unlock_nodes[prg.get_key(recipe_unlock_node_list_sorted[type_to_indices_sorted[type][types_to_its_sorted[type]]])] then
        -- This is reachable, so add it

        indices_of_recipe_tech_unlock_nodes_added[j] = true
        recipe_unlocks_added[prg.get_key(recipe_unlock_node_list_sorted[type_to_indices_sorted[type][types_to_its_sorted[type]]])] = true

        -- But this is a table always: recipe_unlock_node_list_sorted[type_to_indices_sorted[type][types_to_its_sorted[type]]]
        -- Oh, it's adding copies
        table.insert(recipe_unlock_order, table.deepcopy(recipe_unlock_node_list_sorted[type_to_indices_sorted[type][types_to_its_sorted[type]]]))

        types_to_its_sorted[type] = types_to_its_sorted[type] + 1

        break
      end
    end
  end
end

-- recipe_unlock_order has random 0's (these aren't zero values though?)
-- No more duplicates!
--log(serpent.block(recipe_unlock_order))

-- Now we just need to fix up the data.raw stuff

-- 183 recipe unlocks, but roboports are counted twice so I guess 182?
-- No wait chests too so 179?
--[[local num_recipes = 0
for _,tech in pairs(data.raw.technology) do
  if tech.effects ~= nil then
    for _, effect in pairs(tech.effects) do
      if effect.type == "unlock-recipe" then
        num_recipes = num_recipes + 1
      end
    end
  end
end
log(num_recipes)]]

-- First remove all normal recipe unlocks
local technology_unlock_slots = {}
for _, technology in pairs(data.raw.technology) do
  -- TODO: Move all reformatting to beginning of data-final-fixes
  reformat.prototype.technology(technology)

  technology_unlock_slots[technology.name] = 0

  local recipe_unlock_effect_ids = {}
  for i, effect in pairs(technology.effects) do
    if effect.type == "unlock-recipe" then
      technology_unlock_slots[technology.name] = technology_unlock_slots[technology.name] + 1
      recipe_unlock_effect_ids[i] = true
    end
  end

  -- TODO: Change 100 here lol
  for j = 100,0,-1 do
    if recipe_unlock_effect_ids[j] then
      table.remove(technology.effects, j)
    end
  end
end

-- num techs is 192
--[[local num_techs = 0
for _,_ in pairs(data.raw.technology) do
  num_techs = num_techs + 1
end
log(num_techs)]]
--[[
local tech_unlock_number = 1
log(serpent.block(recipe_unlock_order))
for i, node in pairs(dependency_graph) do
  if node.type == "recipe_tech_unlock_node" then
    --log(serpent.block(recipe_unlock_order[tech_unlock_number]))
    log(tech_unlock_number)
    -- recipe_unlock_order[tech_unlock_number] is nil here at 142
    -- NOTE/TODO: We don't get all the recipe unlocks!! We are missing about 40 but I guess that's fine since there's a lot of stuff with rockets and used uranium and weirdness? 40 is still a lot...
    if tech_unlock_number >= 142 then
      break
    end
    local recipe_name = node.name--recipe_unlock_order[tech_unlock_number].name

    for _, prereq in pairs(recipe_unlock_order[tech_unlock_number].prereqs) do
      table.insert(data.raw.technology[prereq.name].effects, {
        type = "unlock-recipe",
        recipe = recipe_name,
        icon = data.raw.recipe[recipe_name].icon,
        icon_size = data.raw.recipe[recipe_name].icon_size
      })
    end

    tech_unlock_number = tech_unlock_number + 1
  end
end]]

local blacklisted_recipes_doop = {
  ["electric-energy-interface"] = true,
  ["loader"] = true,
  ["fast-loader"] = true,
  ["express-loader"] = true
}

local innnnn = {}
for _, blop in pairs(dependency_graph) do
  if blop.type == "recipe_tech_unlock_node" then
    if not blacklisted_recipes_doop[blop.name] then
      innnnn[blop.name] = true
    end
  end
end
for i, node in pairs(recipe_unlock_node_list_sorted) do
  if recipe_unlock_order[i] == nil then
    break
  end
  -- We're overwriting the data from node here with data from recipe_unlock_order
  for _, prereq in pairs(node.prereqs) do
    if prereq.type == "technology_node" then
      innnnn[recipe_unlock_order[i].name] = nil

      technology_unlock_slots[prereq.name] = technology_unlock_slots[prereq.name] - 1

      table.insert(data.raw.technology[prereq.name].effects, {
        type = "unlock-recipe",
        recipe = recipe_unlock_order[i].name,
        icon = data.raw.recipe[recipe_unlock_order[i].name].icon,
        icon_size = data.raw.recipe[recipe_unlock_order[i].name].icon_size
      })
    end
  end
end

for innn, _ in pairs(innnnn) do
  for _, technology in pairs(data.raw.technology) do
    if technology_unlock_slots[technology.name] > 0 then
      technology_unlock_slots[technology.name] = technology_unlock_slots[technology.name] - 1
      table.insert(technology.effects, {
        type = "unlock-recipe",
        recipe = innn,
        icon = data.raw.recipe[innn].icon,
        icon_size = data.raw.recipe[innn].icon_size,
      })

      break
    end
  end
end

end

end

if do_tech_node_randomization then

  function randomize_technologies()

local function find_reachable_tech_unlock_nodes_top(added_techs)
  local top_sort = {}
  local source_nodes = {}
  local source_nodes_went_through_table = {1}
  local nodes_left = table.deepcopy(dependency_graph)

  -- Remove tech unlock nodes except for ones in list
  for _, node in pairs(nodes_left) do
    if node.type == "technology_node" and (not added_techs[prg.get_key(node)]) then
      nodes_left[prg.get_key(node)] = nil
    end
  end

  for _, node in pairs(dependency_graph) do
    if node_type_operation[node.type] == "AND" and #node.prereqs == 0 then
      add_to_source(node, top_sort, source_nodes, source_nodes_went_through_table, nodes_left)
    end
  end
  
  local num_nodes = 0
  for _, _ in pairs(dependency_graph) do
    num_nodes = num_nodes + 1
  end
  
  for i=1,num_nodes do
    if #top_sort >= i then
      local next_node = top_sort[i]
  
      for _, dependent in pairs(next_node.dependents) do
        if node_type_operation[dependent.type] == "OR" then
          add_to_source(table.deepcopy(dependency_graph[prg.get_key(dependent)]), top_sort, source_nodes, source_nodes_went_through_table, nodes_left)
        else
          local satisfied = true
          for _, prereq in pairs(dependency_graph[prg.get_key(dependent)].prereqs) do
            if not source_nodes[prg.get_key(prereq)] or (prereq.type == "technology_node" and (not added_techs[prg.get_key(prereq)])) then
              satisfied = false
            end
          end
          if satisfied then
            add_to_source(table.deepcopy(dependency_graph[prg.get_key(dependent)]), top_sort, source_nodes, source_nodes_went_through_table, nodes_left)
          end
        end
      end
    end
  end

  local reachable_tech_unlock_nodes = {}
  for _, node in pairs(top_sort) do
    if node.type == "technology_node" then
      reachable_tech_unlock_nodes[prg.get_key(node)] = true
    end
  end

  return {top_sort = top_sort, reachable = reachable_tech_unlock_nodes}
end

local all_techs = {}
for _, tech in pairs(data.raw.technology) do
  all_techs[prg.get_key({type = "technology_node", name = tech.name})] = true
end
local top_sort = find_reachable_tech_unlock_nodes_top(all_techs).top_sort

for _, thing in pairs(top_sort) do
  --log(thing.name)
end

local tech_sort = {}
for _, node in pairs(top_sort) do
  if node.type == "technology_node" then
    table.insert(tech_sort, table.deepcopy(node))
  end
end

--log(serpent.block(tech_sort))

--[[for i, tech in pairs(tech_sort) do

end]]

local color_tech_to_tech_inds = {}
color_tech_to_tech_inds["space"] = {}
color_tech_to_tech_inds["yp"] = {}
color_tech_to_tech_inds["y"] = {}
color_tech_to_tech_inds["p"] = {}
color_tech_to_tech_inds["b"] = {}
color_tech_to_tech_inds["g"] = {}
color_tech_to_tech_inds["r"] = {}
for ind, tech in pairs(tech_sort) do
  local technology = data.raw.technology[tech.name]

  local ing = {}
  for _, thing in pairs(technology.unit.ingredients) do
    ing[thing[1] or thing.name] = true
  end

  if ing["space-science-pack"] then
    table.insert(color_tech_to_tech_inds["space"], ind)
  elseif ing["utility-science-pack"] and ing["production-science-pack"] then
    table.insert(color_tech_to_tech_inds["yp"], ind)
  elseif ing["utility-science-pack"] then
    table.insert(color_tech_to_tech_inds["y"], ind)
  elseif ing["production-science-pack"] then
    table.insert(color_tech_to_tech_inds["p"], ind)
  elseif ing["chemical-science-pack"] then
    table.insert(color_tech_to_tech_inds["b"], ind)
  elseif ing["logistic-science-pack"] then
    table.insert(color_tech_to_tech_inds["g"], ind)
  elseif ing["automation-science-pack"] then
    table.insert(color_tech_to_tech_inds["r"], ind)
  else
    error()
  end
end


local tech_shuffle = table.deepcopy(tech_sort)

local tech_table = {}
for color, tech_inds in pairs(color_tech_to_tech_inds) do
  tech_table[color] = {}

  for _, ind in pairs(tech_inds) do
    table.insert(tech_table[color], tech_sort[ind])
  end

  prg.shuffle("pls_shuffle", tech_table[color])

  for i, ind in pairs(tech_inds) do
    tech_shuffle[ind] = tech_table[color][i]
  end
end

--prg.shuffle("pls_shuffle", tech_shuffle)


local new_new_dependency_graph = table.deepcopy(dependency_graph)
local added_techs = {}
local stripped_nodes = {}
for i=1,#tech_sort do
  local reachable_nodes = find_reachable_tech_unlock_nodes_top(added_techs).reachable

  -- move j's prereqs to i
  for j=1,#tech_shuffle do
    if (not stripped_nodes[prg.get_key(tech_shuffle[j])]) and reachable_nodes[prg.get_key(tech_shuffle[j])] then
      --log("boop  " .. i .. " : " .. j)
  
      local node_i = tech_sort[i]
      local node_j = tech_shuffle[j]
  
      new_new_dependency_graph[prg.get_key(node_i)].prereqs = node_j.prereqs

      added_techs[prg.get_key(node_i)] = true
      stripped_nodes[prg.get_key(node_j)] = true

      break
    end
  end
end

for _, node in pairs(new_new_dependency_graph) do
  if node.type == "technology_node" then
    data.raw.technology[node.name].prerequisites = {}
    for _, prereq in pairs(node.prereqs) do
      if prereq.type == "technology_node" then
        table.insert(data.raw.technology[node.name].prerequisites, prereq.name)
      end
    end
  end
end

end

end

for _, tech in pairs(data.raw.technology) do
  tech.upgrade = false
end

--[[table.insert(data.raw.technology["automation"].effects, {
  type = "unlock-recipe",
  recipe = "assembling-machine-1"
})
table.insert(data.raw.technology["optics"].effects, {
  type = "unlock-recipe",
  recipe = "underground-belt"
})
table.insert(data.raw.technology["logistics"].effects, {
  type = "unlock-recipe",
  recipe = "splitter"
})
table.insert(data.raw.technology["gun-turret"].effects, {
  type = "unlock-recipe",
  recipe = "gun-turret"
})
table.insert(data.raw.technology["automation-2"].effects, {
  type = "unlock-recipe",
  recipe = "assembling-machine-2"
})
table.insert(data.raw.technology["steel-processing"].effects, {
  type = "unlock-recipe",
  recipe = "steel-plate"
})]]

if do_recipe_category_randomization then

  local function find_reachable_recipe_category_nodes(added_categories)
    local top_sort = {}
    local source_nodes = {}
    local source_nodes_went_through_table = {1}
    local nodes_left = table.deepcopy(dependency_graph)
  
    -- Remove tech unlock nodes except for ones in list
    for _, node in pairs(nodes_left) do
      if node.type == "recipe_category_node" and (not added_categories[prg.get_key(node)]) then
        nodes_left[prg.get_key(node)] = nil
      end
    end
  
    for _, node in pairs(dependency_graph) do
      if node_type_operation[node.type] == "AND" and #node.prereqs == 0 then
        add_to_source(node, top_sort, source_nodes, source_nodes_went_through_table, nodes_left)
      end
    end
    
    local num_nodes = 0
    for _, _ in pairs(dependency_graph) do
      num_nodes = num_nodes + 1
    end
    
    for i=1,num_nodes do
      if #top_sort >= i then
        local next_node = top_sort[i]
    
        for _, dependent in pairs(next_node.dependents) do
          if node_type_operation[dependent.type] == "OR" then
            add_to_source(table.deepcopy(dependency_graph[prg.get_key(dependent)]), top_sort, source_nodes, source_nodes_went_through_table, nodes_left)
          else
            local satisfied = true
            for _, prereq in pairs(dependency_graph[prg.get_key(dependent)].prereqs) do
              if not source_nodes[prg.get_key(prereq)] or (prereq.type == "recipe_category_node" and (not added_categories[prg.get_key(prereq)])) then
                satisfied = false
              end
            end
            if satisfied then
              add_to_source(table.deepcopy(dependency_graph[prg.get_key(dependent)]), top_sort, source_nodes, source_nodes_went_through_table, nodes_left)
            end
          end
        end
      end
    end
  
    local reachable_category_nodes = {}
    for _, node in pairs(top_sort) do
      if node.type == "recipe_category_node" then
        reachable_category_nodes[prg.get_key(node)] = true
      end
    end

    local reachable_machine_nodes = {}
    for _, node in pairs(top_sort) do
      if node.type == "crafting_entity_node" then
        reachable_machine_nodes[prg.get_key(node)] = true
      end
    end
  
    return {top_sort = top_sort, reachable = reachable_category_nodes, reachable_machine = reachable_machine_nodes}
  end

  local all_categories = {}
for _, category in pairs(data.raw["recipe-category"]) do
  all_categories[prg.get_key({type = "recipe_category_node", name = category.name})] = true
end
local top_sort = find_reachable_recipe_category_nodes(all_categories).top_sort


local machine_sort = {}
table.insert(machine_sort, dependency_graph[prg.get_key({type = "character_crafting_node", name = "character"})])
for _, node in pairs(top_sort) do
  if node.type == "crafting_entity_node" then
    table.insert(machine_sort, table.deepcopy(node))
  end
end

local cat_machine_sort = {}
local machines_per_cat_sort = {}
for _, machine in pairs(machine_sort) do
  local class
  if data.raw["assembling-machine"][machine.name] then
    class = "assembling-machine"
  elseif data.raw["furnace"][machine.name] then
    class = "furnace"
  elseif data.raw.character[machine.name] then
    class = "character"
  end

  for _, cat in pairs(data.raw[class][machine.name].crafting_categories) do
    table.insert(cat_machine_sort, dependency_graph[prg.get_key({type = "recipe_category_node", name = cat})])
    table.insert(machines_per_cat_sort, machine)
  end

  --[[
  for _, machine in pairs(data.raw["assembling-machine"]) do
    local is_in_categories = false
    for _, cat in pairs(machine.crafting_categories) do
      if cat == node.name then
        table.insert(cat_machine_sort, cat)
        table.insert(machines_per_cat_sort, machine)
      end
    end
  end
  for _, machine in pairs(data.raw.furnace) do
    local is_in_categories = false
    for _, cat in pairs(machine.crafting_categories) do
      if cat == node.name then
        table.insert(cat_machine_sort, cat)
        table.insert(machines_per_cat_sort, machine)
      end
    end
  end
  for _, machine in pairs(data.raw.character) do
    local is_in_categories = false
    for _, cat in pairs(machine.crafting_categories) do
      if cat == node.name then
        table.insert(cat_machine_sort, cat)
        table.insert(machines_per_cat_sort, machine)
      end
    end
  end]]
end

-- Need a way to tell what's reachable *with the modified connections*

-- We're rewiring the recipe-building connections

-- Recipe categories hold buildings, not the other way around!

-- Test if a building can be reached and add that!

--cat_machine_sort_shuffled = table.deepcopy(cat_machine_sort)
machines_per_cat_sort_shuffled = table.deepcopy(machines_per_cat_sort)

-- Just need if a *machine* is reachable with a set of categories
-- How do we stop all of a machine's "slots" from being used up for unnecessary things?
-- Just shuffle machines for now

prg.shuffle("pls_shuffle", machines_per_cat_sort_shuffled)

-- TODO: REMOVE
prg.shuffle("pls_shuffle", cat_machine_sort)

--[[for _, machine in pairs(machines_per_cat_sort_shuffled) do
  log(machine.name)
end]]

local used_machine_indices = {}

local added_categories = {}
local machines_in_order = {}
local cats_to_machines = {}
for _, cat in pairs(cat_machine_sort) do
  cats_to_machines[cat.name] = {}
end
for i, cat in pairs(cat_machine_sort) do
  local reachable_machines = find_reachable_recipe_category_nodes(added_categories).reachable_machine

  for j = 1, #machines_per_cat_sort_shuffled do

    if not used_machine_indices[j] and (reachable_machines[prg.get_key(machines_per_cat_sort_shuffled[j])] or machines_per_cat_sort_shuffled[j].type == "character_crafting_node") and not cats_to_machines[cat.name][prg.get_key(machines_per_cat_sort_shuffled[j])] then
      used_machine_indices[j] = true
      -- This stops the same machine from being used multiple times for a single category
      cats_to_machines[cat.name][prg.get_key(machines_per_cat_sort_shuffled[j])] = true
      table.insert(machines_in_order, machines_per_cat_sort_shuffled[j])
      added_categories[prg.get_key(cat)] = true
    end
  end
end

--[[for _, machine in pairs(machines_in_order) do
  log(machine.name)
end]]

-- Clear old crafting categories
for i, machine in pairs(machines_in_order) do
  local class
  if data.raw["assembling-machine"][machine.name] then
    class = "assembling-machine"
  elseif data.raw["furnace"][machine.name] then
    class = "furnace"
  elseif data.raw.character[machine.name] then
    class = "character"
  end

  data.raw[class][machine.name].crafting_categories = {}
end

for i, machine in pairs(machines_in_order) do
  local class
  if data.raw["assembling-machine"][machine.name] then
    class = "assembling-machine"
  elseif data.raw["furnace"][machine.name] then
    class = "furnace"
  elseif data.raw.character[machine.name] then
    class = "character"
  end

  table.insert(data.raw[class][machine.name].crafting_categories, cat_machine_sort[i].name)
end

-- Add back rocket silo recipe and things with fluid

for _, category in pairs(recipe_categories) do
  data:extend({
    category
  })
end

local stone_furnace = table.deepcopy(data.raw.furnace["stone-furnace"])
stone_furnace.name = "stupid-thing"

for name, furnace in pairs(data.raw.furnace) do
  furnace.type = "assembling-machine"

  data:extend({
    furnace
  })

  data.raw.furnace[name] = nil
end

data:extend({
  stone_furnace
})

-- TODO: Don't change what can be handcrafted!






if false then

--[[for _, node in pairs(top_sort) do
  log(node.name)
end]]

local cat_sort = {}
for _, node in pairs(top_sort) do
  if node.type == "recipe_category_node" then
    table.insert(cat_sort, table.deepcopy(node))
  end
end

local cat_shuffle = table.deepcopy(cat_sort)
prg.shuffle("pls_shuffle", cat_shuffle)

local added_cats = {}
local cats_in_order = {}
for i = 1, #cat_sort do
  local reachable = find_reachable_recipe_category_nodes(added_cats).reachable

  for _, cat in pairs(cat_shuffle) do
    if reachable[prg.get_key(cat)] and not added_cats[prg.get_key(cat)] then
      added_cats[prg.get_key(cat)] = true
      table.insert(cats_in_order, cat)
    end
  end
end

--[[for _, node in pairs(cat_sort) do
  log(node.name)
end
for _, node in pairs(cats_in_order) do
  log(node.name)
end]]

for i, category_original in pairs(cat_sort) do
  local category_new = cats_in_order[i]

  for _, recipe in pairs(data.raw.recipe) do
    if recipe.category == category_original.name then
      log(category_original.name)
      log(category_new.name)
      recipe.category = category_new.name
    end
  end
end

-- Add back rocket silo recipe and things with fluid

for _, category in pairs(recipe_categories) do
  data:extend({
    category
  })
end



end

end


if false then



local accessible_list = {}
local added_to_accessible_list = {}

local source_nodes = {}
local source_nodes_size = 0
for _, node in pairs(dependency_graph) do
  node.prereqs_satisfied = {}
  for _, prereq in pairs(node.prereqs) do
    node.prereqs_satisfied[prg.get_key(prereq)] = false
  end

  if node_type_operation[node.type] == "AND" and next(node.prereqs) == nil then
    source_nodes_size = source_nodes_size + 1
    source_nodes[source_nodes_size] = node
  end
end

for i=1,REALLY_BIG_FLOAT_NUM do
  if i > source_nodes_size then
    break
  end
  local curr_node = source_nodes[i]

  if not added_to_accessible_list[prg.get_key(curr_node)] then
    table.insert(accessible_list, curr_node)
    added_to_accessible_list[prg.get_key(curr_node)] = true
  end
  for _, dependent in pairs(curr_node.dependents) do
    local dependent_node = dependency_graph[prg.get_key(dependent)]
    if not added_to_accessible_list[prg.get_key(dependent_node)] then
      if node_type_operation[dependent_node.type] == "OR" then
        source_nodes_size = source_nodes_size + 1
        source_nodes[source_nodes_size] = dependent_node
      elseif node_type_operation[dependent_node.type] == "AND" then
        dependent_node.prereqs_satisfied[prg.get_key(curr_node)] = true

        local all_prereqs_satisfied = true
        for _, prereq_satisfied in pairs(dependent_node.prereqs_satisfied) do
          if prereq_satisfied == false then
            all_prereqs_satisfied = false
          end
        end

        if all_prereqs_satisfied then
          source_nodes_size = source_nodes_size + 1
          source_nodes[source_nodes_size] = dependent_node
        end
      end
    end
  end
end

local simple_accessible_list = {}

for _, node in pairs(accessible_list) do
  local new_node = {}
  new_node.type = node.type
  new_node.name = node.name
  table.insert(simple_accessible_list, new_node)
end
--log(serpent.block(simple_accessible_list))

local costs = {}
for item_class, _ in pairs(defines.prototypes.item) do
  for _, item in pairs(data.raw[item_class]) do
    log("Creating recipe-item matrix...")

    local recipe_to_col = {}
    local itemorfluid_to_row = {}
    local col_name = {}
    local row_name = {}
    local matrix = {}
    matrix[1] = {}
    local index = 2
    matrix[1][1] = 1
    col_name[1] = {name = "special"}
    for _, node in pairs(dependency_graph) do
      if node.type == "recipe_node" then
        matrix[1][index] = 1

        recipe_to_col[node.name] = index
        col_name[index] = node
        index = index + 1
      end
    end
    matrix[1][#matrix[1]+1] = 0
    col_name[#matrix[1]] = {name = "special"}

    row_name[1] = {name = "special"}
    local index_1 = 2
    for _, node1 in pairs(dependency_graph) do
      if node1.type == "itemorfluid_node" then
        matrix[index_1] = {}

        index_2 = 2
        matrix[index_1][1] = 0
        for _, node2 in pairs(dependency_graph) do
          if node2.type == "recipe_node" then
            matrix[index_1][index_2] = 0
            index_2 = index_2 + 1
          end
        end
        
        -- Goal node
        if node1.name == item.name then
          matrix[index_1][#matrix[index_1] + 1] = -1
        else
          matrix[index_1][#matrix[index_1] + 1] = 0
        end

        itemorfluid_to_row[node1.name] = index_1
        row_name[index_1] = node1
        index_1 = index_1 + 1
      end
    end

    for _, node in pairs(dependency_graph) do
      if node.type == "itemorfluid_node" and (not (next(node.prereqs) == nil and next(node.dependents) == nil)) then
        for _, prereq in pairs(node.prereqs) do
          if prereq.type == "recipe_node" then
            matrix[itemorfluid_to_row[node.name]][recipe_to_col[prereq.name]] = 1/prereq.amount
          end
        end
        for _, dependent in pairs(node.dependents) do
          if dependent.type == "recipe_node" then
            matrix[itemorfluid_to_row[node.name]][recipe_to_col[dependent.name]] = -dependent.amount
          end
        end
      end
    end

    -- Put first row on bottom and then back on top for technical reasons
    local first_row = matrix[1]
    matrix[1] = matrix[#matrix]
    matrix[#matrix] = first_row
    local first_name = row_name[1]
    row_name[1] = row_name[#row_name]
    row_name[#row_name] = first_name

    -- Transpose
    local new_matrix = {}
    for i=1,#matrix[1] do
      new_matrix[i] = {}
      for j=1,#matrix do
        new_matrix[i][j] = matrix[j][i]
      end
    end
    matrix = new_matrix
    local row_name_temp = row_name
    row_name = col_name
    col_name = row_name_temp

    first_row = matrix[1]
    matrix[1] = matrix[#matrix]
    matrix[#matrix] = first_row
    local first_name = row_name[1]
    row_name[1] = row_name[#row_name]
    row_name[#row_name] = first_name

    -- Add new columns
    local old_col_name_size = #col_name
    for i=1,#matrix do
      for j=#matrix+#matrix[1],#matrix+1,-1 do
        matrix[i][j] = matrix[i][j-#matrix]
      end
      for j=1,#matrix do
        if i == j then
          matrix[i][j] = 1
        else
          matrix[i][j] = 0
        end
      end

      if row_name[i].name ~= nil then
        col_name[old_col_name_size + i] = {prototype = row_name[i], type = "void", name = "void_" .. row_name[i].name}
      else
        col_name[old_col_name_size + i] = {name = "void_special"}
      end
    end

    --log(serpent.block(matrix))

    -- Solve

    log("Solving matrix...")

    local col_weights = {}
    for i=1,#col_name do
      col_weights[i] = {}
      for j=1,#col_name do
        col_weights[i][j] = i == j
      end
    end

    local row_weights = {}
    for i=1,#matrix do
      row_weights[i] = {}
      for j=1,#matrix do
        row_weights[i][j] = 0
      end
      row_weights[i][i] = 1
    end

    local permutation = {}
    for i=1,#matrix[1] do
      permutation[i] = i
    end

    local params = {matrix = matrix, row_weights = row_weights, permutation = permutation}

    log("Cost of " .. tostring(solve_system(params)))

    costs[item.name] = solve_system(params)

    --log(serpent.block(params.row_weights))
    --log(serpent.block(params.permutation))

    --[[for i=1,#params.matrix do
      if params.matrix[i][#params.matrix[i] ] < 0 then
        log("\nRECIPE with value " .. params.matrix[i][#params.matrix[i] ] .. " NAMED " .. row_name[i].name .. "\nHAS:")
        for j=1,#row_weights[i] do
          if row_weights[i][j] ~= 0 then
            log("\n" .. row_weights[i][j] .. " PORTION OF " .. row_name[j].name)
          end
        end
      end
    end]]

    for j=2,#params.matrix[1] do
      if params.matrix[1][j] ~= 0 and row_name[params.permutation[j]] ~= nil then
        --log("\n" .. params.matrix[1][j] .. " PORTION OF " .. row_name[params.permutation[j]].name)
      end
    end
  end
end

log(serpent.block(costs))

-- starto

-- Shuffle within intermediates for item/recipes

end -- End of recipe cost evaluation

if do_recipe_randomization then

local vanilla_costs = {
  accumulator = 48,
  ["advanced-circuit"] = 46,
  ["arithmetic-combinator"] = 46,
  ["artillery-shell"] = 208.5,
  ["artillery-targeting-remote"] = 284.40000000000003,
  ["artillery-turret"] = 1455,
  ["artillery-wagon"] = 2931,
  ["artillery-wagon-cannon"] = 100000000000,
  ["assembling-machine-1"] = 66.5,
  ["assembling-machine-2"] = 137,
  ["assembling-machine-3"] = 1349,
  ["atomic-bomb"] = 6299.2142857142862,
  ["automation-science-pack"] = 8,
  battery = 8.5999999999999996,
  ["battery-equipment"] = 154,
  ["battery-mk2-equipment"] = 4879.5,
  beacon = 1196,
  ["belt-immunity-equipment"] = 341,
  ["big-electric-pole"] = 78,
  blueprint = 100000000000,
  ["blueprint-book"] = 100000000000,
  boiler = 19,
  ["burner-generator"] = 100000000000,
  ["burner-inserter"] = 8,
  ["burner-mining-drill"] = 28,
  ["cannon-shell"] = 26.5,
  car = 280,
  ["cargo-wagon"] = 311,
  centrifuge = 3641,
  ["chemical-plant"] = 133.5,
  ["chemical-science-pack"] = 59.899999999999999,
  ["cliff-explosives"] = 35.5,
  ["cluster-grenade"] = 210.5,
  coal = 1,
  coin = 100000000000,
  ["combat-shotgun"] = 1,
  concrete = 1.9000000000000002,
  ["constant-combinator"] = 23.5,
  ["construction-robot"] = 108.19999999999999,
  ["copper-cable"] = 1.5,
  ["copper-ore"] = 1,
  ["copper-plate"] = 2,
  ["copy-paste-tool"] = 100000000000,
  ["cut-paste-tool"] = 100000000000,
  ["decider-combinator"] = 46,
  ["deconstruction-planner"] = 100000000000,
  ["defender-capsule"] = 131.5,
  ["destroyer-capsule"] = 2929.5,
  ["discharge-defense-equipment"] = 5962.5,
  ["discharge-defense-remote"] = 8.5,
  ["distractor-capsule"] = 665,
  ["dummy-steel-axe"] = 100000000000,
  ["effectivity-module"] = 268.5,
  ["effectivity-module-2"] = 1754.5,
  ["effectivity-module-3"] = 9893,
  ["electric-energy-interface"] = 42.5,
  ["electric-engine-unit"] = 41.699999999999996,
  ["electric-furnace"] = 371,
  ["electric-mining-drill"] = 68.5,
  ["electronic-circuit"] = 7.5,
  ["empty-barrel"] = 100000000000,
  ["energy-shield-equipment"] = 341,
  ["energy-shield-mk2-equipment"] = 3650.5,
  ["engine-unit"] = 23,
  ["exoskeleton-equipment"] = 3435,
  ["explosive-cannon-shell"] = 28,
  ["explosive-rocket"] = 18,
  ["explosive-uranium-cannon-shell"] = 29.507049345417926,
  explosives = 5,
  ["express-loader"] = 746,
  ["express-splitter"] = 495.90000000000003,
  ["express-transport-belt"] = 84.600000000000009,
  ["express-underground-belt"] = 325.09999999999997,
  ["fast-inserter"] = 35.5,
  ["fast-loader"] = 322,
  ["fast-splitter"] = 190.5,
  ["fast-transport-belt"] = 30,
  ["fast-underground-belt"] = 121,
  ["filter-inserter"] = 66.5,
  ["firearm-magazine"] = 9,
  flamethrower = 106,
  ["flamethrower-ammo"] = 156,
  ["flamethrower-turret"] = 551,
  ["fluid-wagon"] = 347,
  ["flying-robot-frame"] = 92.199999999999989,
  ["fusion-reactor-equipment"] = 43381,
  gate = 54,
  ["green-wire"] = 10,
  grenade = 21,
  ["gun-turret"] = 111,
  ["hazard-concrete"] = 2,
  ["heat-exchanger"] = 341,
  ["heat-interface"] = 100000000000,
  ["heat-pipe"] = 151,
  ["heavy-armor"] = 751,
  ["infinity-chest"] = 100000000000,
  ["infinity-pipe"] = 100000000000,
  inserter = 15.5,
  ["iron-chest"] = 17,
  ["iron-gear-wheel"] = 5,
  ["iron-ore"] = 1,
  ["iron-plate"] = 2,
  ["iron-stick"] = 1.5,
  ["item-unknown"] = 100000000000,
  ["item-with-inventory"] = 100000000000,
  ["item-with-label"] = 100000000000,
  ["item-with-tags"] = 100000000000,
  lab = 142,
  ["land-mine"] = 3.75,
  landfill = 21,
  ["laser-turret"] = 474.20000000000005,
  ["light-armor"] = 81,
  ["linked-belt"] = 100000000000,
  ["linked-chest"] = 100000000000,
  loader = 100000000000,
  locomotive = 866,
  ["logistic-chest-active-provider"] = 158.5,
  ["logistic-chest-buffer"] = 158.5,
  ["logistic-chest-passive-provider"] = 158.5,
  ["logistic-chest-requester"] = 158.5,
  ["logistic-chest-storage"] = 158.5,
  ["logistic-robot"] = 141.20000000000002,
  ["logistic-science-pack"] = 20.5,
  ["long-handed-inserter"] = 23.5,
  ["low-density-structure"] = 123,
  ["medium-electric-pole"] = 33,
  ["military-science-pack"] = 42.5,
  ["modular-armor"] = 1931,
  ["night-vision-equipment"] = 341,
  ["nuclear-fuel"] = 154.85714285714286,
  ["nuclear-reactor"] = 19451,
  ["offshore-pump"] = 24,
  ["oil-refinery"] = 351,
  ["personal-laser-defense-equipment"] = 6710,
  ["personal-roboport-equipment"] = 1048,
  ["personal-roboport-mk2-equipment"] = 26591,
  ["piercing-rounds-magazine"] = 31,
  ["piercing-shotgun-shell"] = 51,
  pipe = 3,
  ["pipe-to-ground"] = 20.5,
  pistol = 21,
  ["plastic-bar"] = 12,
  ["player-port"] = 100000000000,
  ["poison-capsule"] = 66.5,
  ["power-armor"] = 9247,
  ["power-armor-mk2"] = 103380,
  ["power-switch"] = 33.5,
  ["processing-unit"] = 199.89999999999998,
  ["production-science-pack"] = 286,
  ["productivity-module"] = 268.5,
  ["productivity-module-2"] = 1754.5,
  ["productivity-module-3"] = 9893,
  ["programmable-speaker"] = 50.5,
  pump = 38,
  pumpjack = 173.5,
  radar = 83.5,
  rail = 7.25,
  ["rail-chain-signal"] = 18.5,
  ["rail-signal"] = 18.5,
  ["raw-fish"] = 100000000000,
  ["red-wire"] = 10,
  ["refined-concrete"] = 6.4000000000000004,
  ["refined-hazard-concrete"] = 6.5,
  ["repair-pack"] = 26,
  roboport = 2791,
  rocket = 14,
  ["rocket-control-unit"] = 359.40000000000003,
  ["rocket-fuel"] = 27,
  ["rocket-launcher"] = 73.5,
  ["rocket-part"] = 4385,
  ["rocket-silo"] = 61101,
  satellite = 50408.5,
  ["selection-tool"] = 100000000000,
  shotgun = 1,
  ["shotgun-shell"] = 9,
  ["simple-entity-with-force"] = 100000000000,
  ["simple-entity-with-owner"] = 100000000000,
  ["slowdown-capsule"] = 43,
  ["small-electric-pole"] = 100000000000,
  ["small-lamp"] = 15,
  ["solar-panel"] = 178.5,
  ["solar-panel-equipment"] = 326.5,
  ["solid-fuel"] = 15,
  ["space-science-pack"] = 300,
  ["speed-module"] = 268.5,
  ["speed-module-2"] = 1754.5,
  ["speed-module-3"] = 9893,
  spidertron = 10000,
  ["spidertron-remote"] = 443.90000000000003,
  ["spidertron-rocket-launcher-1"] = 100000000000,
  ["spidertron-rocket-launcher-2"] = 100000000000,
  ["spidertron-rocket-launcher-3"] = 100000000000,
  ["spidertron-rocket-launcher-4"] = 100000000000,
  splitter = 64.5,
  ["stack-filter-inserter"] = 308.5,
  ["stack-inserter"] = 270,
  ["steam-engine"] = 76,
  ["steam-turbine"] = 411,
  ["steel-chest"] = 89,
  ["steel-furnace"] = 97,
  ["steel-plate"] = 11,
  stone = 1.3,
  ["stone-brick"] = 3,
  ["stone-furnace"] = 6,
  ["stone-wall"] = 16,
  ["storage-tank"] = 96,
  ["submachine-gun"] = 81,
  substation = 351,
  sulfur = 10,
  tank = 1822,
  ["tank-cannon"] = 100000000000,
  ["tank-flamethrower"] = 100000000000,
  ["tank-machine-gun"] = 100000000000,
  ["train-stop"] = 92.5,
  ["transport-belt"] = 4,
  ["underground-belt"] = 20.5,
  ["upgrade-planner"] = 100000000000,
  ["uranium-235"] = 142.85714285714286,
  ["uranium-238"] = 1.0070493454179255,
  ["uranium-cannon-shell"] = 28.257049345417926,
  ["uranium-fuel-cell"] = 16.385714285714286,
  ["uranium-ore"] = 100000000000,
  ["uranium-rounds-magazine"] = 33.007049345417926,
  ["used-up-uranium-fuel-cell"] = 100000000000,
  ["utility-science-pack"] = 232.33333333333337,
  ["vehicle-machine-gun"] = 100000000000,
  ["wood"] = 100000000000,
  ["wooden-chest"] = 100000000000,
  ["crude-oil-barrel"] = 100000000000,
  ["petroleum-gas-barrel"] = 100000000000,
  ["sulfuric-acid-barrel"] = 100000000000,
  ["light-oil-barrel"] = 100000000000,
  ["heavy-oil-barrel"] = 100000000000,
  ["lubricant-barrel"] = 100000000000,
  ["water-barrel"] = 100000000000,
  ["crude-oil"] = 0.1,
  ["petroleum-gas"] = 0.1,
  ["light-oil"] = 0.5,
  ["heavy-oil"] = 1.5,
  ["lubricant"] = 1.5,
  ["sulfuric-acid"] = 10,
  ["water"] = 0.02
}

--[[local recipe_data = {}

for _, recipe in pairs(data.raw.recipe) do
    if recipe.normal ~= nil then
        for key, val in pairs(recipe.normal) do
            recipe[key] = val
        end
    end

    if recipe.results == nil then
        recipe.result_count = recipe.result_count or 1

        recipe.results = {
            {name = recipe.result, amount = recipe.result_count}
        }
    end

    recipe.energy_required = recipe.energy_required or 0.5

    for _, result in pairs(recipe.results) do
        if result[1] ~= nil then
            result.name = result[1]
            result.amount = result[2]
            result[1] = nil
            result[2] = nil
        end

        local actual_amount = result.amount
        if result.amount == nil then
            actual_amount = (result.amount_min + result.amount_max) / 2
        end

        local probability = 1 or result.probability
        actual_amount = probability * actual_amount
    end

    for _, ingredient in pairs(recipe.ingredients) do
        if ingredient[1] ~= nil then
            ingredient.name = ingredient[1]
            ingredient.amount = ingredient[2]
            ingredient[1] = nil
            ingredient[2] = nil
        end
    end

    recipe_data[recipe.name] = {
        ["ingredients"] = recipe.ingredients,
        ["results"] = recipe.results,
        ["time"] = recipe.energy_required
    }
end]]

-- Preserve how many recipes an item is used it, and how many to produce it
-- Preserve number inputs/outputs of a recipe

-- resume

function randomize_recipes()

  local function find_reachable_recipe_nodes(added_recipes)
    local top_sort = {}
    local source_nodes = {}
    local source_nodes_went_through_table = {1}
    local nodes_left = table.deepcopy(dependency_graph)
  
    -- Remove tech unlock nodes except for ones in list
    for _, node in pairs(nodes_left) do
      if node.type == "recipe_node" and (not added_recipes[prg.get_key(node)]) then
        nodes_left[prg.get_key(node)] = nil
      end
    end
  
    for _, node in pairs(dependency_graph) do
      if node_type_operation[node.type] == "AND" and #node.prereqs == 0 then
        add_to_source(node, top_sort, source_nodes, source_nodes_went_through_table, nodes_left)
      end
    end
    
    local num_nodes = 0
    for _, _ in pairs(dependency_graph) do
      num_nodes = num_nodes + 1
    end
    
    for i=1,num_nodes do
      if #top_sort >= i then
        local next_node = top_sort[i]
    
        for _, dependent in pairs(next_node.dependents) do
          -- Check that this isn't a blocking recipe
          if dependent.type ~= "recipe_node" or added_recipes[prg.get_key(dependent)] then
            if node_type_operation[dependent.type] == "OR" then
              add_to_source(table.deepcopy(dependency_graph[prg.get_key(dependent)]), top_sort, source_nodes, source_nodes_went_through_table, nodes_left)
            else
              local satisfied = true
              for _, prereq in pairs(dependency_graph[prg.get_key(dependent)].prereqs) do
                if not source_nodes[prg.get_key(prereq)] or (prereq.type == "recipe_node" and (not added_recipes[prg.get_key(prereq)])) then
                  satisfied = false
                end
              end
              if satisfied then
                add_to_source(table.deepcopy(dependency_graph[prg.get_key(dependent)]), top_sort, source_nodes, source_nodes_went_through_table, nodes_left)
              end
            end
          end
        end
      end
    end
  
    local reachable_category_nodes = {}
    for _, node in pairs(top_sort) do
      if node.type == "recipe_node" then
        reachable_category_nodes[prg.get_key(node)] = true
      end
    end

    local reachable_itemorfluids = {}
    for _, node in pairs(top_sort) do
      if node.type == "itemorfluid_node" then
        reachable_itemorfluids[prg.get_key(node)] = true
      end
    end
  
    return {top_sort = top_sort, reachable = reachable_category_nodes, reachable_2 = reachable_itemorfluids}
  end

  local all_categories = {}
for _, recipe in pairs(data.raw["recipe"]) do
  all_categories[prg.get_key({type = "recipe_node", name = recipe.name})] = true
end
local top_sort = find_reachable_recipe_nodes(all_categories).top_sort

local recipe_list_with_conn_number = {}
local item_or_fluid_list = {}
local blacklisted_recipes = {}
for _, node in pairs(top_sort) do
  if node.type == "recipe_node" then
    local blacklisted = false

    local num_in_conns = 0
    local fluid_tags = {}
    local amounts_in = {}
    local costs_in = {}
    for _, prereq in pairs(node.prereqs) do
      if prereq.type == "itemorfluid_node" then
        if vanilla_costs[prereq.name] ~= 100000000000 then
          table.insert(item_or_fluid_list, dependency_graph[prg.get_key(prereq)])
          num_in_conns = num_in_conns + 1

          if data.raw.fluid[prereq.name] then
            table.insert(fluid_tags, true)
          else
            table.insert(fluid_tags, false)
          end

          table.insert(amounts_in, prereq.amount)
          table.insert(costs_in, vanilla_costs[prereq.name])
        else
          blacklisted = true
          blacklisted_recipes[node.name] = true
        end
      end
    end

    if not blacklisted then
      table.insert(recipe_list_with_conn_number, {recipe = node, num_ingredients = num_in_conns, fluid_tags = fluid_tags, new_ins = {}, amounts_in = amounts_in, costs_in = costs_in})
    end
  end
end

for _, node in pairs(top_sort) do
  if node.type == "itemorfluid_node" then
    -- Random extras
    table.insert(item_or_fluid_list, node)
    table.insert(item_or_fluid_list, node)
  end
end

--[[for _, recipe_info in pairs(recipe_list_with_conn_number) do
  log(recipe_info.recipe.name)
end]]

-- TODO: Add some random other items for funsies

prg.shuffle("recipe-randomization", item_or_fluid_list)

local ind_to_num_uses = {}
for ind, itemorfluid in pairs(item_or_fluid_list) do
  ind_to_num_uses[ind] = 0
end
local added_recipes = {}
for _, recipe_info in pairs(recipe_list_with_conn_number) do
  log("fixing " .. recipe_info.recipe.name)

  local product_cost = 0
  for _, dependent in pairs(recipe_info.recipe.dependents) do
    if dependent.type == "itemorfluid_node" then
      product_cost = product_cost + dependent.amount * vanilla_costs[dependent.name]
    end
  end

  local reachable = find_reachable_recipe_nodes(added_recipes).reachable
  local reachable_2 = find_reachable_recipe_nodes(added_recipes).reachable_2

  local added_ingredients = {}
  for i = 1, recipe_info.num_ingredients do
    local this_ingredient_cost = recipe_info.amounts_in[i] * recipe_info.costs_in[i]

    is_fluid = recipe_info.fluid_tags[i]

    local pass_num = 0
    local found_conn = false
    while true do
      for j = 1, #item_or_fluid_list do
        --log("checking " .. item_or_fluid_list[j].name)
        -- Check that is/is not fluid
        local passes_fluid_check = false
        if is_fluid and data.raw.fluid[item_or_fluid_list[j].name] then
          passes_fluid_check = true
        elseif (not is_fluid) and (not data.raw.fluid[item_or_fluid_list[j].name]) then
          passes_fluid_check = true
        end

        if passes_fluid_check then
          --log("passed fluid check")
          -- Check that cost is good
          -- This is a hacky metric for now
          --log(item_or_fluid_list[j].name)

          local cost_single = recipe_info.amounts_in[i] * vanilla_costs[item_or_fluid_list[j].name]
          local target_cost = this_ingredient_cost
          local target_cost_factor = 0.2
          local_target_cost_additive = 0.3

          local max_multiplier = 10
          local multiplier
          for i = 1, max_multiplier do
            if math.abs(cost_single * i - target_cost) <= target_cost * target_cost_factor + local_target_cost_additive then
              multiplier = i
            end
          end

          if multiplier ~= nil then
            --log("passed cost check")
            -- Check that it hasn't been used yet
            if ind_to_num_uses[j] <= pass_num then
              -- Make sure no duplicate ingredients
              if not added_ingredients[item_or_fluid_list[j].name] then
                --log("passed usage check")
                -- Check reachability
                local to_be_added = false
                if reachable_2[prg.get_key(item_or_fluid_list[j])] then
                  to_be_added = true
                end

                if to_be_added then
                  --log("passed reachability check")
                  -- Add this item
                  recipe_info.amounts_in[i] = multiplier * recipe_info.amounts_in[i]
                  table.insert(recipe_info.new_ins, item_or_fluid_list[j].name)
                  product_cost = product_cost - recipe_info.amounts_in[i] * vanilla_costs[item_or_fluid_list[j].name]
                  ind_to_num_uses[j] = ind_to_num_uses[j] + 1
                  added_ingredients[item_or_fluid_list[j].name] = true

                  found_conn = true
                  break
                end
              end
            end
          end
        end
      end

      if found_conn then
        break
      end

      pass_num = pass_num + 1
    end
  end

  added_recipes[prg.get_key(recipe_info.recipe)] = true
end

-- Fix data.raw

for _, recipe_info in pairs(recipe_list_with_conn_number) do
  local recipe = data.raw.recipe[recipe_info.recipe.name]

  if not blacklisted_recipes[recipe.name] then
    local new_ingredients = {}

    for ind, new_ing in pairs(recipe_info.new_ins) do
      local type_of_thing = "item"
      if recipe_info.fluid_tags[ind] then
        type_of_thing = "fluid"
      end
      table.insert(new_ingredients, {
        type = type_of_thing,
        name = new_ing,
        amount = recipe_info.amounts_in[ind]
      })
    end

    recipe.ingredients = new_ingredients
  end
end

end

end


randomize_recipes()
--randomize_technologies()
--recipe_unlocks_randomization()

-- delete_after_this


if false then

-- More recipe unlocks!
for _, technology in pairs(data.raw.technology) do
  if old_data_raw_data.technology[technology.name].effects ~= nil then
    for _, effect in pairs(old_data_raw_data.technology[technology.name].effects) do
      if effect.type == "unlock-recipe" then
        table.insert(technology.effects, table.deepcopy(effect))
      end
    end
  end
end










-- Super dumb... wanted to do this again so here we go with a huge copy paste



-- HOTFIX - Add certain tech unlocks twice just to make sure
-- NOT WORKING!
--[[table.insert(data.raw.technology["logistics"].effects, {
  type = "unlock-recipe",
  recipe = "assembling-machine-1"
})
table.insert(data.raw.technology["optics"].effects, {
  type = "unlock-recipe",
  recipe = "assembling-machine-1"
})
table.insert(data.raw.technology["automation"].effects, {
  type = "unlock-recipe",
  recipe = "underground-belt"
})
table.insert(data.raw.technology["optics"].effects, {
  type = "unlock-recipe",
  recipe = "splitter"
})
table.insert(data.raw.technology["optics"].effects, {
  type = "unlock-recipe",
  recipe = "gun-turret"
})]]

-- Unlock everything in general an extra time as well
--[[local techs = table.deepcopy(data.raw.technology)
for _, prototype in pairs(techs) do
  if prototype.effects ~= nil then
    for _, unlock in pairs(prototype.effects) do
      if unlock.type == "unlock-recipe" then
        table.insert(data.raw.technology[prototype.name].effects, {
          type = "unlock-recipe",
          recipe = unlock.recipe
        })
      end
    end
  end
end]]

-- TODO: Add support for starting items
-- TODO: Add support for trees and rocks (they are special cases since they're not "automatable")
-- TODO: Add support for custom autoplace in general (like, for example, in the ruins mod)
-- TODO: Add support for fuels (there's also burnt products and such...)
-- TODO: Support min_temperatures and max_temperatures on fluids in recipes
-- TODO: Support for recipes with no ingredients (gives another way to get infinite resources)
-- TODO: Test if lab is craftable
-- TODO: Account for crafting as a special recipe category
-- TODO: Amount in prereq for machines/buildings set correctly
-- TODO: Offshore pump giving water
-- TODO: Fluid/item limits on assembling machines
-- TODO: Deal with infinite techs
-- TODO: Actual recipe editing still messes up with normal versus expensive ugh
-- TODO: Special attention needs to be paid to crafting categories and fluids, since regular crafting category can't have them
-- TODO: Take special care with recipes that involve smelting/furnaces (no repeat ingredients, only one ingredient, etc.)
-- TODO: Rocket launch products
-- TODO: Reachable character classes
-- TODO: Required fluid boxes
-- TODO: Minable properties of buildings

local dependency_utils = {}

-- Entries will be tables with id = {type = type of node (source, recipe, abstract, etc.), prereqs = node prereqs ids}
-- source-manual indicates it can be made, but not very well (mining trees being the primary example), currently not implemented
local dependency_graph = {}
local recipes_not_added = {}
--[[local blacklisted_recipes = {
  ["empty-crude-oil-barrel"] = true,
  ["empty-heavy-oil-barrel"] = true,
  ["empty-light-oil-barrel"] = true,
  ["empty-lubricant-barrel"] = true,
  ["empty-petroleum-gas-barrel"] = true,
  ["empty-sulfuric-acid-barrel"] = true,
  ["empty-water-barrel"] = true,
  ["fill-crude-oil-barrel"] = true,
  ["fill-heavy-oil-barrel"] = true,
  ["fill-light-oil-barrel"] = true,
  ["fill-lubricant-barrel"] = true,
  ["fill-petroleum-gas-barrel"] = true,
  ["fill-sulfuric-acid-barrel"] = true,
  ["fill-water-barrel"] = true,
  ["coal-liquefaction"] = true,
  ["advanced-oil-processing"] = true
}]]
for _, recipe in pairs(data.raw.recipe) do
  --if not blacklisted_recipes[recipe.name] then
    table.insert(recipes_not_added, recipe)
  --end
end
local crafting_entities_not_added = {}
for _, crafting_machine_class in pairs(prototype_tables.crafting_machine_classes) do
  for _, crafting_machine in pairs(data.raw[crafting_machine_class]) do
    table.insert(crafting_entities_not_added, crafting_machine)
  end
end
local items_and_fluids_not_added = {}
for item_class, _ in pairs(defines.prototypes["item"]) do
  for _, item in pairs(data.raw[item_class]) do
    table.insert(items_and_fluids_not_added, item)
  end
end
for _, fluid in pairs(data.raw.fluid) do
  table.insert(items_and_fluids_not_added, fluid)
end
local technologies_not_added = {}
for _, technology in pairs(data.raw.technology) do
  table.insert(technologies_not_added, technology)
end
local recipe_categories_not_added = {}
for _, recipe_category in pairs(data.raw["recipe-category"]) do
  table.insert(recipe_categories_not_added, recipe_category)
end
local resources_not_added = {}
for _, resource in pairs(data.raw.resource) do
  table.insert(resources_not_added, resource)
end
local resource_categories_not_added = {}
for _, resource_category in pairs(data.raw["resource-category"]) do
  table.insert(resource_categories_not_added, resource_category)
end
local mining_machines_not_added = {}
for _, mining_machine in pairs(data.raw["mining-drill"]) do
  table.insert(mining_machines_not_added, mining_machine)
end

for _, recipe in pairs(recipes_not_added) do
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
      amount = 1})
  else
    table.insert(node.prereqs, {
      type = "recipe_category_node",
      name = recipe.category,
      amount = 1})
  end

  -- Recipe ingredient prereq
  local function get_recipe_ingredients (recipe)
    local recipe_ingredients = {}

    for _, ingredient in pairs(recipe.ingredients) do
      if ingredient[1] and ingredient[2] then
        table.insert(recipe_ingredients, {name = ingredient[1], amount = ingredient[2]})
      else
        table.insert(recipe_ingredients, {name = ingredient.name, amount = ingredient.amount}) -- TODO: probabilities and such
      end
    end

    return recipe_ingredients
  end

  -- Now add recipe ingredients
  local recipe_ingredients = {}
  if recipe.normal then
    recipe_ingredients = get_recipe_ingredients(recipe.normal)
  else
    recipe_ingredients = get_recipe_ingredients(recipe)
  end
  for _, ingredient in pairs(recipe_ingredients) do
    --- Note, the node may represent an item or fluid
    table.insert(node.prereqs, {
      type = "itemorfluid_node",
      name = ingredient.name,
      amount = ingredient.amount
    })
  end

  -- Now add tech prerequisites
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
      -- Pretend like there are two unlocks for the recipes for recipe unlock rando
      table.insert(recipe_tech_unlock_node.prereqs, {
        type = "technology_node",
        name = technology.name,
        amount = 1
      })
    end
  end

  -- Only add the tech prereq if the recipe isn't already unlocked from start of game
  local requires_technology = false
  if recipe.enabled ~= nil and not recipe.enabled then
    requires_technology = true
  elseif recipe.normal ~= nil and recipe.normal.enabled ~= nil and not recipe.normal.enabled then
    requires_technology = true
  end

  if requires_technology then
    dependency_graph[prg.get_key(recipe_tech_unlock_node)] = recipe_tech_unlock_node

    table.insert(node.prereqs, {
      type = recipe_tech_unlock_node.type,
      name = recipe_tech_unlock_node.name,
      amount = 1
    })
  end

  dependency_graph[prg.get_key(node)] = node
end

local function product_prototype_has_product_amount (product_prototype, itemorfluid)
  local amount_product = 0

  for _, result in pairs(product_prototype) do
    if result[1] ~= nil and result[1] == itemorfluid.name then
      amount_product = amount_product + result[2]
    elseif result.name ~= nil and result.name == itemorfluid.name then
      local result_amount = 0

      if result.amount then
        result_amount = result_amount + result.amount
      else
        result_amount = (result.amount_min + result.amount_max) / 2
      end

      if result.probability then
        result_amount = result_amount * result.probability
      end

      amount_product = amount_product + result_amount
    end
  end

  return amount_product
end

-- Assume cheap mode for now
local function recipe_has_product_amount (recipe, itemorfluid)
  if recipe.normal then
    return recipe_has_product_amount(recipe.normal, itemorfluid)
  end

  if recipe.results ~= nil then
    return product_prototype_has_product_amount(recipe.results, itemorfluid)
  end

  if recipe.result then
    if recipe.result == itemorfluid.name then
      return recipe.result_count or 1
    else
      return 0
    end
  end
end

-- Add special void "item"
--[[dependency_graph[prg.get_key({type = "itemorfluid_node", name = "void"})] = {
  type = "itemorfluid_node",
  name = "void",
  prereqs = {}
}
for _, itemorfluid in pairs(items_and_fluids_not_added) do
  table.insert(dependency_graph[prg.get_key({type = "itemorfluid_node", name = "void"})].prereqs, {
    type = "recipe_node",
    name = "void_" .. itemorfluid.name,
    amount = 1
  })
end]]
for _, itemorfluid in pairs(items_and_fluids_not_added) do
  -- Add void recipe
  --[[dependency_graph[prg.get_key({type = "recipe_node", name = "void_" .. itemorfluid.name})] = {
    type = "recipe_node",
    name = "void_" .. itemorfluid.name,
    prereqs = {
      {
        type = "itemorfluid_node",
        name = itemorfluid.name,
        amount = 1 / VOID_COST
      }
    }
  }]]

  local node = {
    type = "itemorfluid_node",
    name = itemorfluid.name,
    prereqs = {}
  }

  -- Add recipe products
  for _, recipe in pairs(data.raw.recipe) do
    --if not blacklisted_recipes[recipe.name] then
      local product_amount = recipe_has_product_amount(recipe, itemorfluid)

      if product_amount > 0 then
        table.insert(node.prereqs, {
          type = "recipe_node",
          name = recipe.name,
          amount = 1 / product_amount
        })
      end
    --end
  end

  -- Add minable results
  for _, resource in pairs(data.raw.resource) do
    if resource.minable ~= nil then
      local product_amount
      
      if resource.minable.result ~= nil and resource.minable.result == itemorfluid.name then
        if resource.minable.count == nil then
          resource.minable.count = 1
        end

        product_amount = resource.minable.count
      elseif resource.minable.results ~= nil then
        product_amount = product_prototype_has_product_amount(resource.minable.results, itemorfluid)
      end

      if product_amount ~= nil and product_amount > 0 then
        table.insert(node.prereqs, {type = "resource_node", name = resource.name, amount = 1 / product_amount})
      end
    end
  end

  -- TODO: Deal with fluids better
  dependency_graph[prg.get_key(node)] = node
end

for _, crafting_entity in pairs(crafting_entities_not_added) do
  local node = {
    type = "crafting_entity_node",
    name = crafting_entity.name,
    prereqs = {}
  }

  for item_class, _ in pairs(defines.prototypes.item) do
    for _, item in pairs(data.raw[item_class]) do
      if item.place_result ~= nil and item.place_result == crafting_entity.name then
        table.insert(node.prereqs, {
          type = "itemorfluid_node",
          name = item.name,
          amount = 1 -- TODO: Sometimes placing down something can use more than one of the item, so account for this
        })
      end
    end
  end

  dependency_graph[prg.get_key(node)] = node
end

for _, technology in pairs(technologies_not_added) do
  local node = {
    type = "technology_node",
    name = technology.name,
    prereqs = {}
  }

  if technology.prerequisites ~= nil then
    for _, prereq in pairs(technology.prerequisites) do
      table.insert(node.prereqs, {
        type = "technology_node",
        name = prereq,
        amount = 1
      })
    end
  end

  for _, science_pack in pairs(technology.unit.ingredients) do
    if science_pack[1] ~= nil then
      table.insert(node.prereqs, {
        type = "itemorfluid_node",
        name = science_pack[1],
        amount = 1 -- TODO: Find actual amount instead of assuming this is just one
      })
    else
      table.insert(node.prereqs, {
        type = "itemorfluid_node",
        name = science_pack.name,
        amount = 1
      })
    end
  end

  dependency_graph[prg.get_key(node)] = node
end

for _, recipe_category in pairs(recipe_categories_not_added) do
  local node = {
    type = "recipe_category_node",
    name = recipe_category.name,
    prereqs = {}
  }

  for _, crafting_machine in pairs(crafting_entities_not_added) do
    for _, crafting_category in pairs(crafting_machine.crafting_categories) do
      if crafting_category == recipe_category.name then
        table.insert(node.prereqs, {
          type = "crafting_entity_node",
          name = crafting_machine.name,
          amount = 1
        })
      end
    end
  end

  for _, character in pairs(data.raw.character) do
    if character.crafting_categories ~= nil then
      for _, character_crafting_category in pairs(character.crafting_categories) do
        if character_crafting_category == recipe_category.name then
          table.insert(node.prereqs, {
            type = "character_crafting_node",
            name = character.name,
            amount = 1
          })
        end
      end
    end
  end

  dependency_graph[prg.get_key(node)] = node
end

-- Todo: add better support for other resource categories
for _, resource in pairs(resources_not_added) do
  local node = {
    type = "resource_node",
    name = resource.name,
    prereqs = {}
  }

  if resource.minable ~= nil then
    if resource.minable.fluid_amount ~= nil and resource.minable.fluid_amount > 0 and resource.minable.required_fluid ~= nil then
      table.insert(node.prereqs, {
        type = "itemorfluid_node",
        name = resource.minable.required_fluid,
        amount = resource.minable.fluid_amount
      })
    end
  end

  if resource.category == nil then
    resource.category = "basic-solid"
  end
  --[[table.insert(node.prereqs, {
    type = "resource_category_node",
    name = resource.category,
    amount = 1
  })]] -- TODO URGENT: ADD THIS BACK

  dependency_graph[prg.get_key(node)] = node
end

for _, mining_machine in pairs(mining_machines_not_added) do
  local node = {
    type = "mining_machine_node",
    name = mining_machine.name,
    prereqs = {}
  }

  for item_class, _ in pairs(defines.prototypes.item) do
    for _, item in pairs(data.raw[item_class]) do
      if item.place_result ~= nil and item.place_result == mining_machine.name then
        table.insert(node.prereqs, {
          type = "itemorfluid_node",
          name = item.name,
          amount = 1
        })
      end
    end
  end

  dependency_graph[prg.get_key(node)] = node
end

for _, resource_category in pairs(resource_categories_not_added) do
  local node = {
    type = "resource_category_node",
    name = resource_category.name,
    prereqs = {}
  }

  -- TODO: Not necessarily assuming this character is available from the start
  -- (This could be messed up by, for example, bob's classes mod)
  for _, character in pairs(data.raw.character) do
    if character.mining_categories ~= nil then
      for _, mining_category in pairs(character.mining_categories) do
        if mining_category == resource_category.name then
          table.insert(node.prereqs, {
            type = "character_mining_node",
            name = character.name,
            amount = 1
          })
        end
      end
    end
  end

  for _, mining_machine in pairs(mining_machines_not_added) do
    for _, mining_category in pairs(mining_machine.resource_categories) do
      if mining_category == resource_category.name then
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

for _, character in pairs(data.raw.character) do
  local node = {
    type = "character_mining_node",
    name = character.name,
    prereqs = {}
  }

  dependency_graph[prg.get_key(node)] = node
end

for _, character in pairs(data.raw.character) do
  local node = {
    type = "character_crafting_node",
    name = character.name,
    prereqs = {}
  }

  dependency_graph[prg.get_key(node)] = node
end

-- TODO: get this to work for other offshore pump prototypes in general
table.insert(dependency_graph[prg.get_key({type = "itemorfluid_node", name = "water"})].prereqs, {
  type = "itemorfluid_node",
  name = "offshore-pump",
  amount = 1 / 1200
})

--[[
local new_node_for_ash = {
  type = "itemorfluid_node",
  name = "ash",
  prereqs = {}
}
table.insert(new_node_for_ash.prereqs, {
  type = "itemorfluid_node",
  name = "water",
  amount = 1
})
dependency_graph[prg.get_key(new_node_for_ash)] = new_node_for_ash
local new_node_for_log = {
  type = "itemorfluid_node",
  name = "log",
  prereqs = {}
}
table.insert(new_node_for_log.prereqs, {
  type = "itemorfluid_node",
  name = "water",
  amount = 1
})
dependency_graph[prg.get_key(new_node_for_log)] = new_node_for_log
local new_node_for_moss = {
  type = "itemorfluid_node",
  name = "moss",
  prereqs = {}
}
table.insert(new_node_for_moss.prereqs, {
  type = "itemorfluid_node",
  name = "water",
  amount = 1
})
dependency_graph[prg.get_key(new_node_for_moss)] = new_node_for_moss
local new_node_for_fish = {
  type = "itemorfluid_node",
  name = "fish",
  prereqs = {}
}
table.insert(new_node_for_fish.prereqs, {
  type = "itemorfluid_node",
  name = "water",
  amount = 1
})
dependency_graph[prg.get_key(new_node_for_fish)] = new_node_for_fish
local new_node_for_steam = {
  type = "itemorfluid_node",
  name = "steam",
  prereqs = {}
}
table.insert(new_node_for_steam.prereqs, {
  type = "itemorfluid_node",
  name = "water",
  amount = 1
})
dependency_graph[prg.get_key(new_node_for_steam)] = new_node_for_steam
local new_node_for_sap = {
  type = "itemorfluid_node",
  name = "sap",
  prereqs = {}
}
table.insert(new_node_for_sap.prereqs, {
  type = "itemorfluid_node",
  name = "water",
  amount = 1
})
dependency_graph[prg.get_key(new_node_for_sap)] = new_node_for_sap
local new_node_for_oil = {
  type = "itemorfluid_node",
  name = "crude-oil",
  prereqs = {}
}
table.insert(new_node_for_oil.prereqs, {
  type = "itemorfluid_node",
  name = "water",
  amount = 1
})
dependency_graph[prg.get_key(new_node_for_oil)] = new_node_for_oil
local new_node_for_gas = {
  type = "itemorfluid_node",
  name = "raw-gas",
  prereqs = {}
}
table.insert(new_node_for_gas.prereqs, {
  type = "itemorfluid_node",
  name = "water",
  amount = 1
})
dependency_graph[prg.get_key(new_node_for_gas)] = new_node_for_gas]]

-- TEST
--[[local new_node_for_wood = {
  type = "itemorfluid_node",
  name = "wood",
  prereqs = {}
}
table.insert(new_node_for_wood.prereqs, {
  type = "itemorfluid_node",
  name = "water",
  amount = 1
})
local new_node_for_basic_tech_card = {
  type = "itemorfluid_node",
  name = "basic-tech-card",
  prereqs = {
    {
      type = "itemorfluid_node",
      name = "wood",
      amount = 1
    }
  }
}
dependency_graph[prg.get_key(new_node_for_wood)] = new_node_for_wood
dependency_graph[prg.get_key(new_node_for_basic_tech_card)] = new_node_for_basic_tech_card]]

log("Wrapping up forward connections...")

for _, node in pairs(dependency_graph) do
  node.dependents = {}
end

for _, node in pairs(dependency_graph) do
  for _, prereq in pairs(node.prereqs) do
    if dependency_graph[prg.get_key(prereq)] == nil then
      --[[log(node.type)
      log(node.name)
      log(prereq.type)
      log(prereq.name)]]
    else
      table.insert(dependency_graph[prg.get_key(prereq)].dependents, {
        type = node.type,
        name = node.name,
        amount = prereq.amount
      })
    end
  end
end

--[[for _, node in pairs(dependency_graph) do
  node.prereqs_satisfied = {}
  for _, prereq in pairs(node.prereqs) do
    node.prereqs_satisfied[prg.get_key(prereq)] = false
  end
end]]

--[[log("Adding resource recipes...")

for _, node in pairs(dependency_graph) do
  -- Quick and hacky!
  if node.type == "resource_node" then
    --log(serpent.block(node))

    if (data.raw.resource[node.name].minable.results ~= nil) then
      for _, result in pairs(data.raw.resource[node.name].minable.results) do
        dependency_graph[prg.get_key({type = "recipe_node", name = node.name})] = {
          type = "recipe_node",
          name = node.name,
          prereqs = {},
          dependents = {{
            type = "itemorfluid_node",
            name = result[1] or result.name,
            amount = 1
          }}
        }
        table.insert(dependency_graph[prg.get_key({type = "itemorfluid_node", name = result[1] or result.name})].prereqs, {
          type = "recipe_node",
          name = node.name,
          amount = 1
        })
      end
    elseif data.raw.resource[node.name].minable.result ~= nil and node.name ~= "uranium-ore" and node.name ~= "crude-oil" then
      dependency_graph[prg.get_key({type = "recipe_node", name = node.name})] = {
        type = "recipe_node",
        name = node.name,
        prereqs = {},
        dependents = {{
          type = "itemorfluid_node",
          name = data.raw.resource[node.name].minable.result,
          amount = 1
        }}
      }
      table.insert(dependency_graph[prg.get_key({type = "itemorfluid_node", name = data.raw.resource[node.name].minable.result})].prereqs, {
        type = "recipe_node",
        name = node.name,
        amount = 1
      })
    end
  end
end]]

-- DEPENDENCY GRAPH BUILDING DONE
--dependency_graph = build_graph.construct()

-- Apply swaps if one doesn't depend on the other idea

local dependency_graph_keys = {}
for key, _ in pairs(dependency_graph) do
  table.insert(dependency_graph_keys, key)
end

local node_type_operation = {
  recipe_node = "AND",
  itemorfluid_node = "OR",
  technology_node = "AND",
  recipe_tech_unlock_node = "OR",
  recipe_category_node = "OR",
  crafting_entity_node = "OR",
  character_crafting_node = "AND", -- No prereqs, so essentially a source
  mining_machine_node = "OR",
  resource_node = "AND",
  resource_category_list_node = "OR",
  resource_category_node = "OR",
  character_mining_node = "AND" -- No prereqs, so essentially a source
}

randomize_recipes()
randomize_technologies()
recipe_unlocks_randomization()
randomize_recipes()
randomize_recipes()

-- final fixes

-- Changed from iron plate (copper) since iron ore is used in, like, nothing
data.raw.recipe["steel-plate"].ingredients = {
  {name = "iron-ore", amount = 6}
}

data.raw.recipe["stone-brick"].ingredients = {
  {name = "iron-ore", amount = 2}
}





















if false then

-- Make accessibility list

local accessible_list = {}
local added_to_accessible_list = {}

local node_type_operation = {
  recipe_node = "AND",
  itemorfluid_node = "OR",
  technology_node = "AND",
  recipe_tech_unlock_node = "OR",
  recipe_category_node = "OR",
  crafting_entity_node = "OR",
  character_crafting_node = "AND", -- No prereqs, so essentially a source
  mining_machine_node = "OR",
  resource_node = "AND",
  resource_category_list_node = "OR",
  resource_category_node = "OR",
  character_mining_node = "AND" -- No prereqs, so essentially a source
}

local source_nodes = {}
local source_nodes_size = 0
for _, node in pairs(dependency_graph) do
  node.prereqs_satisfied = {}
  for _, prereq in pairs(node.prereqs) do
    node.prereqs_satisfied[prg.get_key(prereq)] = false
  end

  if node_type_operation[node.type] == "AND" and next(node.prereqs) == nil then
    source_nodes_size = source_nodes_size + 1
    source_nodes[source_nodes_size] = node
  end
end

for i=1,REALLY_BIG_FLOAT_NUM do
  if i > source_nodes_size then
    break
  end
  local curr_node = source_nodes[i]

  if not added_to_accessible_list[prg.get_key(curr_node)] then
    table.insert(accessible_list, curr_node)
    added_to_accessible_list[prg.get_key(curr_node)] = true
  end
  for _, dependent in pairs(curr_node.dependents) do
    local dependent_node = dependency_graph[prg.get_key(dependent)]
    if not added_to_accessible_list[prg.get_key(dependent_node)] then
      if node_type_operation[dependent_node.type] == "OR" then
        source_nodes_size = source_nodes_size + 1
        source_nodes[source_nodes_size] = dependent_node
      elseif node_type_operation[dependent_node.type] == "AND" then
        dependent_node.prereqs_satisfied[prg.get_key(curr_node)] = true

        local all_prereqs_satisfied = true
        for _, prereq_satisfied in pairs(dependent_node.prereqs_satisfied) do
          if prereq_satisfied == false then
            all_prereqs_satisfied = false
          end
        end

        if all_prereqs_satisfied then
          source_nodes_size = source_nodes_size + 1
          source_nodes[source_nodes_size] = dependent_node
        end
      end
    end
  end
end

local simple_accessible_list = {}

for _, node in pairs(accessible_list) do
  local new_node = {}
  new_node.type = node.type
  new_node.name = node.name
  table.insert(simple_accessible_list, new_node)
end
log(serpent.block(simple_accessible_list))

local costs = {}
for item_class, _ in pairs(defines.prototypes.item) do
  for _, item in pairs(data.raw[item_class]) do
    log("Creating recipe-item matrix...")

    local recipe_to_col = {}
    local itemorfluid_to_row = {}
    local col_name = {}
    local row_name = {}
    local matrix = {}
    matrix[1] = {}
    local index = 2
    matrix[1][1] = 1
    col_name[1] = {name = "special"}
    for _, node in pairs(dependency_graph) do
      if node.type == "recipe_node" then
        matrix[1][index] = 1

        recipe_to_col[node.name] = index
        col_name[index] = node
        index = index + 1
      end
    end
    matrix[1][#matrix[1]+1] = 0
    col_name[#matrix[1]] = {name = "special"}

    row_name[1] = {name = "special"}
    local index_1 = 2
    for _, node1 in pairs(dependency_graph) do
      if node1.type == "itemorfluid_node" then
        matrix[index_1] = {}

        index_2 = 2
        matrix[index_1][1] = 0
        for _, node2 in pairs(dependency_graph) do
          if node2.type == "recipe_node" then
            matrix[index_1][index_2] = 0
            index_2 = index_2 + 1
          end
        end
        
        -- Goal node
        if node1.name == item.name then
          matrix[index_1][#matrix[index_1] + 1] = -1
        else
          matrix[index_1][#matrix[index_1] + 1] = 0
        end

        itemorfluid_to_row[node1.name] = index_1
        row_name[index_1] = node1
        index_1 = index_1 + 1
      end
    end

    for _, node in pairs(dependency_graph) do
      if node.type == "itemorfluid_node" and (not (next(node.prereqs) == nil and next(node.dependents) == nil)) then
        for _, prereq in pairs(node.prereqs) do
          if prereq.type == "recipe_node" then
            matrix[itemorfluid_to_row[node.name]][recipe_to_col[prereq.name]] = 1/prereq.amount
          end
        end
        for _, dependent in pairs(node.dependents) do
          if dependent.type == "recipe_node" then
            matrix[itemorfluid_to_row[node.name]][recipe_to_col[dependent.name]] = -dependent.amount
          end
        end
      end
    end

    -- Put first row on bottom and then back on top for technical reasons
    local first_row = matrix[1]
    matrix[1] = matrix[#matrix]
    matrix[#matrix] = first_row
    local first_name = row_name[1]
    row_name[1] = row_name[#row_name]
    row_name[#row_name] = first_name

    -- Transpose
    local new_matrix = {}
    for i=1,#matrix[1] do
      new_matrix[i] = {}
      for j=1,#matrix do
        new_matrix[i][j] = matrix[j][i]
      end
    end
    matrix = new_matrix
    local row_name_temp = row_name
    row_name = col_name
    col_name = row_name_temp

    first_row = matrix[1]
    matrix[1] = matrix[#matrix]
    matrix[#matrix] = first_row
    local first_name = row_name[1]
    row_name[1] = row_name[#row_name]
    row_name[#row_name] = first_name

    -- Add new columns
    local old_col_name_size = #col_name
    for i=1,#matrix do
      for j=#matrix+#matrix[1],#matrix+1,-1 do
        matrix[i][j] = matrix[i][j-#matrix]
      end
      for j=1,#matrix do
        if i == j then
          matrix[i][j] = 1
        else
          matrix[i][j] = 0
        end
      end

      if row_name[i].name ~= nil then
        col_name[old_col_name_size + i] = {prototype = row_name[i], type = "void", name = "void_" .. row_name[i].name}
      else
        col_name[old_col_name_size + i] = {name = "void_special"}
      end
    end

    --log(serpent.block(matrix))

    -- Solve

    log("Solving matrix...")

    local col_weights = {}
    for i=1,#col_name do
      col_weights[i] = {}
      for j=1,#col_name do
        col_weights[i][j] = i == j
      end
    end

    local row_weights = {}
    for i=1,#matrix do
      row_weights[i] = {}
      for j=1,#matrix do
        row_weights[i][j] = 0
      end
      row_weights[i][i] = 1
    end

    local permutation = {}
    for i=1,#matrix[1] do
      permutation[i] = i
    end

    local params = {matrix = matrix, row_weights = row_weights, permutation = permutation}

    log("Cost of " .. tostring(solve_system(params)))

    costs[item.name] = solve_system(params)

    --log(serpent.block(params.row_weights))
    --log(serpent.block(params.permutation))

    --[[for i=1,#params.matrix do
      if params.matrix[i][#params.matrix[i] ] < 0 then
        log("\nRECIPE with value " .. params.matrix[i][#params.matrix[i] ] .. " NAMED " .. row_name[i].name .. "\nHAS:")
        for j=1,#row_weights[i] do
          if row_weights[i][j] ~= 0 then
            log("\n" .. row_weights[i][j] .. " PORTION OF " .. row_name[j].name)
          end
        end
      end
    end]]

    for j=2,#params.matrix[1] do
      if params.matrix[1][j] ~= 0 and row_name[params.permutation[j]] ~= nil then
        --log("\n" .. params.matrix[1][j] .. " PORTION OF " .. row_name[params.permutation[j]].name)
      end
    end
  end
end

log(serpent.block(costs))

log("donedone")

-- Do 1000 swaps
for i=1,1000 do
  -- Just start at 50 for now lol
  local first_to_swap = prg.range("dummy", 50, #accessible_list-1)

  local temp_value = accessible_list[first_to_swap]
  accessible_list[first_to_swap] = accessible_list[first_to_swap+1]
  accessible_list[first_to_swap+1] = temp_value
end

-- Now redo connections
local recipe_new_connections = {}
for i=1,#accessible_list do
  if accessible_list[i].type == "recipe_node" and data.raw.recipe[accessible_list[i].name] ~= nil and data.raw.recipe[accessible_list[i].name].category ~= "smelting" then

    recipe_new_connections[i] = {}

    local num_ingredients = 0
    for j=i-1,1,-1 do
      if num_ingredients == 0 then
        if accessible_list[j].type == "itemorfluid_node" and accessible_list[j].name ~= "uranium-ore" and accessible_list[j].name ~= "water" and costs[accessible_list[j].name] ~= nil then
          num_ingredients = num_ingredients + 1

          table.insert(recipe_new_connections[i], accessible_list[j])
        end
      elseif num_ingredients < 3 and accessible_list[j].type == "itemorfluid_node" then
        if prg.float_range(prg.get_key(nil, "dummy"), 0, 1) < 0.2 and accessible_list[j].name ~= "water" and accessible_list[j].name ~= "uranium-ore" and costs[accessible_list[j].name] ~= nil  then
          num_ingredients = num_ingredients + 1

          table.insert(recipe_new_connections[i], accessible_list[j])
        end
      end
    end
  elseif accessible_list[i].type == "itemorfluid_node" then

  end
end

for i=1,#accessible_list do
  if accessible_list[i].type == "recipe_node" and data.raw.recipe[accessible_list[i].name] ~= nil and data.raw.recipe[accessible_list[i].name].category ~= "smelting" then
    local recipe = data.raw.recipe[accessible_list[i].name]

    -- Calculate recipe costs
    reformat.prototype.recipe(recipe)

    local recipe_cost = 0
    for _, result in pairs(recipe.results) do
      if costs[result.name] ~= nil then
        recipe_cost = recipe_cost + costs[result.name] * result.amount -- TODO: Include probabilities and such
      end
    end

    weights = {}
    local total_weights = 0
    local new_ingredients = {}
    local amounts_of_ingredients = {}
    for j, ingredient in pairs(recipe_new_connections[i]) do
      local weight = math.random(1, 10) / 10 * math.random(1, 10) / 10
      weights[j] = weight
      total_weights = total_weights + weight
    end
    for j, ingredient in pairs(recipe_new_connections[i]) do
      amounts_of_ingredients[j] = 10 * weights[j] / total_weights

      -- TODO: Do this properly
      local type_of_thing = "item"
      -- Don't randomize fluids yet
      if data.raw.fluid[ingredient.name] ~= nil then
        type_of_thing = "fluid"
      else
        if amounts_of_ingredients[j] == 0 then
          amounts_of_ingredients[j] = 1
        end
  
        table.insert(new_ingredients, {type = type_of_thing, name = ingredient.name, amount = math.ceil(amounts_of_ingredients[j])})
      end
    end

    local ingredient_cost = 0
    for j, ingredient in pairs(recipe_new_connections[i]) do
      if costs[ingredient.name] ~= nil then
        ingredient_cost = ingredient_cost + costs[ingredient.name] * amounts_of_ingredients[j]
      end
    end

    if ingredient_cost > recipe_cost then
      local multiplier
      if recipe_cost > 0 then
        multiplier = ingredient_cost / recipe_cost
      else
        multiplier = 1
      end

      -- Also multiply recipe time
      if recipe.energy_required == nil then
        recipe.energy_required = 0.5
      end
      if multiplier > 0 then
        recipe.energy_required = recipe.energy_required * multiplier
      end

      for ind, result in pairs(recipe.results) do
        local not_stackable = false
        for item_class, _ in pairs(defines.prototypes.item) do
          for _, item in pairs(data.raw[item_class]) do
            if item.name == result.name then
              if item.flags ~= nil then
                for _, flag in pairs(item.flags) do
                  if flag == "not-stackable" then
                    not_stackable = true
                  end
                end
              end
            end
          end
        end
        if (not not_stackable) and result.name ~= "modular-armor" then
          result.amount = round(result.amount * multiplier)
        end
      end
    else
      local multiplier = recipe_cost / ingredient_cost

      for j, ingredient in pairs(recipe_new_connections[i]) do
        local not_stackable = false
        for item_class, _ in pairs(defines.prototypes.item) do
          for _, item in pairs(data.raw[item_class]) do
            if item.name == ingredient.name then
              if item.flags ~= nil then
                for _, flag in pairs(item.flags) do
                  if flag == "not-stackable" then
                    not_stackable = true
                  end
                end
              end
            end
          end
        end
        if not not_stackable then
          ingredient.amount = math.min(10000, round(amounts_of_ingredients[j] * multiplier))
        end
      end
    end

    local occurrences = {}
    for ind, ingredient in pairs(new_ingredients) do
      if occurrences[ind] ~= nil then
        occurrences[ind] = occurrences[ind] + 1
      else
        occurrences[ind] = 1
      end
    end
    for ind, thing in pairs(occurrences) do
      if thing > 1 then
        table.remove(new_ingredients, ind)
      end
    end

    log("setting new ingredients")
    recipe.ingredients = new_ingredients
  end
end

-- TODO: Don't include the wonky things in ingredients, maybe then I can actually do a playthrough

if false then







-- Trim unnecessary rows

for i=#matrix,1,-1 do
  local all_zeroes = true
  for j=1,#matrix[i] do
    if matrix[i][j] ~= 0 then
      all_zeroes = false
      break
    end
  end
  if all_zeroes then
    table.remove(matrix, i)
  end
end

log("Should be less than 206: " .. tostring(#matrix))
log(#matrix[1])
log(#matrix[2])
--log(serpent.block(matrix))

-- Normalize/canonicalize

for i=1,#matrix do
  -- We can assume no all-zero rows because of what we just did

  local largest_pivot = 0
  local largest_pivot_ind = 0
  for col_scan=i,#matrix[i] do
    if math.abs(matrix[i][col_scan]) > largest_pivot then
      largest_pivot = math.abs(matrix[i][col_scan])
      largest_pivot_ind = col_scan
    end
  end
  
  -- Switch column of largest pivot with column i

  -- First save old column
  local temp_col = {}
  for k=1,#matrix do
    temp_col[k] = matrix[k][i]
  end

  -- Save this column to column i
  for k=1,#matrix do
    matrix[k][i] = matrix[k][largest_pivot_ind]
  end

  -- Save column i to this column
  for k=1,#matrix do
    matrix[k][largest_pivot_ind] = temp_col[k]
  end

  -- Do the pivot on lower rows
  for j=i+1,#matrix do
    local scale_factor = matrix[j][i] / matrix[i][i]
    for k=1,#matrix[j] do
      matrix[j][k] = matrix[j][k] - scale_factor * matrix[i][k]
    end
  end
end

-- Now do pivot on upper rows from the bottom
for i=#matrix,1,-1 do
  for j=i-1,1,-1 do
    local scale_factor = matrix[j][i] / matrix[i][i]

    for k=1,#matrix[j] do
      matrix[j][k] = matrix[j][k] - scale_factor * matrix[i][k]
    end
  end
end

--[[
local heads = {}
local running_col = 2
for j=2,#matrix do
  local largest_ind = 0
  local largest_abs = 0
  for i=j,#matrix do
    if math.abs(matrix[i][running_col]) > largest_abs then
      largest_abs = math.abs(matrix[i][running_col])
      largest_ind = i
    end
  end
  -- Swap rows i and j
  if largest_abs > 0 then
    local temp_row = matrix[largest_ind]
    matrix[largest_ind] = matrix[j]
    matrix[j] = temp_row

    -- All the rows below, get rid of this entry
    for i=j+1,#matrix do
      local scale_factor = matrix[i][running_col] / matrix[j][running_col]
      for k=1,#matrix[i] do
        matrix[i][k] = matrix[i][k] - scale_factor * matrix[j][k]
      end
    end
  end

  running_col = running_col + 1
end

-- Move heads to "front"
for i=1,#matrix do
  for j=i,#matrix[i] do
    if matrix[i][j] > 0 then
      -- Switch col.s j and i

      local temp_col = {}
      for k=1,#matrix do
        temp_col[k] = matrix[k][i]
      end
      for k=1,#matrix do
        matrix[k][i] = matrix[k][j]
      end
      for k=1,#matrix do
        matrix[k][j] = temp_col[k]
      end
    end
  end
end

-- Now backwards
for i=#matrix,1,-1 do
  if matrix[i][i] == 0 then
    log("NO THIS ONE")
  end

  -- Rescale row
  local scale_factor = 1 / matrix[i][i]
  for j=i,#matrix[i] do
      matrix[i][j] = scale_factor * matrix[i][j]
  end

  for k=i-1,1,-1 do
    scale_factor = matrix[k][i]

    for j=1,#matrix[k] do
      matrix[k][j] = matrix[k][j] - scale_factor * matrix[i][j]
    end
  end
end]]

--[[for i=1,#matrix do
  local largest_pivot_ind = 0
  local largest_pivot_abs = 0
  for j=1,#matrix[i] do
    if math.abs(matrix[i][j]) > largest_pivot_abs then
      largest_pivot_abs = math.abs(matrix[i][j])
      largest_pivot_ind = j
    end
  end

  if largest_pivot_abs > 0 then
    pivot({matrix = matrix, row = i, col = largest_pivot_ind})
  end
end]]

--log(serpent.block(permutation))

--log(serpent.block(matrix))
log(solve_system({matrix = matrix}))

--if false then








for _, node in pairs(dependency_graph) do
  node.sanitized_name = string.gsub(node.name, "-", "_")
  node.sanitized_name = string.gsub(node.sanitized_name, " ", "__")
  node.sanitized_name = string.gsub(node.sanitized_name, ",", "___")
  node.sanitized_name = string.gsub(node.sanitized_name, "%%", "____")
end

local string_to_print = ""

for _, node in pairs(dependency_graph) do
  if node.type == "recipe_node" then
    string_to_print = string_to_print .. ("var recipe_" .. node.sanitized_name .. " >= 0;\n")
  --[[elseif node.type == "resource_node" then
    string_to_print = string_to_print .. ("var resource_" .. node.sanitized_name .. " >= 0;\n");]]
  elseif node.type == "itemorfluid_node" then
    string_to_print = string_to_print .. ("var itemorfluid_" .. node.sanitized_name .. " >= 0;\n")
  end
end

string_to_print = string_to_print .. ("minimize z: ")
for _, node in pairs(dependency_graph) do
  if (node.type == "recipe_node") then
    string_to_print = string_to_print .. ("recipe_" .. node.sanitized_name .. " + ")
  end
end

--[[for _, node in pairs(dependency_graph) do
  if node.type == "resource_node" then
    for _, dependent in pairs(node.dependents) do
      if dependent.type == "itemorfluid_node" then
        string_to_print = string_to_print .. ("subject to " .. "resource_node)
      end
    end
  end
end]]

--[[string_to_print = string_to_print .. (";\n")
for _, node in pairs(dependency_graph) do
  if node.type == "recipe_node" then
    string_to_print = string_to_print .. ("subject to " .. "recipe_node_constraint" .. node.sanitized_name .. ": recipe_" .. node.sanitized_name .. " = ")

    for _, dependent in pairs(node.dependents) do
      if dependent.type == "itemorfluid_node" then
        string_to_print = string_to_print .. (dependent.amount .. "*itemorfluid_" .. dependency_graph[prg.get_key(dependent)].sanitized_name)
        string_to_print = string_to_print .. "+"
      end
    end
    for _, prereq in pairs(node.prereqs) do
      if prereq.type == "itemorfluid_node" then
        string_to_print = string_to_print .. ("(-" .. prereq.amount .. "*itemorfluid_" .. dependency_graph[prg.get_key(prereq)].sanitized_name .. ")")
        string_to_print = string_to_print .. "+"
      end
    end

    string_to_print = string.sub(string_to_print, 1, -2)
    string_to_print = string_to_print .. (";\n")
  end
end]]

string_to_print = string_to_print .. "\n";

for _, node in pairs(dependency_graph) do
  if node.type == "itemorfluid_node" and (not (next(node.prereqs) == nil and next(node.dependents) == nil)) then
    string_to_print = string_to_print .. ("subject to " .. "itemorfluid_node_constraint" .. node.sanitized_name .. ": itemorfluid_" .. node.sanitized_name .. " = ")

    for _, prereq in pairs(node.prereqs) do
      if prereq.type == "recipe_node" then
        string_to_print = string_to_print .. (prereq.amount .. "*recipe_" .. dependency_graph[prg.get_key(prereq)].sanitized_name)
        string_to_print = string_to_print .. "+"
      end
    end
    for _, dependent in pairs(node.dependents) do
      if dependent.type == "recipe_node" then
        string_to_print = string_to_print .. ("(-" .. dependent.amount .. "*recipe_" .. dependency_graph[prg.get_key(dependent)].sanitized_name .. ")")
        string_to_print = string_to_print .. "+"
      end
    end

    string_to_print = string.sub(string_to_print, 1, -2)
    string_to_print = string_to_print .. (";\n")
  end
end

log(string_to_print)

dependency_utils.dependency_graph = dependency_graph

return dependency_utils

--[[local accessible_list = {}
local added_to_accessible_list = {}

local node_type_operation = {
  recipe_node = "AND",
  itemorfluid_node = "OR",
  technology_node = "AND",
  recipe_tech_unlock_node = "OR",
  recipe_category_node = "OR",
  crafting_entity_node = "OR",
  character_crafting_node = "AND", -- No prereqs, so essentially a source
  mining_machine_node = "OR",
  resource_node = "AND",
  resource_category_list_node = "OR",
  resource_category_node = "OR",
  character_mining_node = "AND" -- No prereqs, so essentially a source
}

local source_nodes = {}
local source_nodes_size = 0
for _, node in pairs(dependency_graph) do
  if node_type_operation[node.type] == "AND" and next(node.prereqs) == nil then
    source_nodes_size = source_nodes_size + 1
    source_nodes[source_nodes_size] = node
  end
end

for i=1,REALLY_BIG_FLOAT_NUM do
  if i > source_nodes_size then
    break
  end
  local curr_node = source_nodes[i]

  if not added_to_accessible_list[prg.get_key(curr_node)] then
    table.insert(accessible_list, curr_node)
    added_to_accessible_list[prg.get_key(curr_node)] = true
  end
  for _, dependent in pairs(curr_node.dependents) do
    local dependent_node = dependency_graph[prg.get_key(dependent)]
    if not added_to_accessible_list[prg.get_key(dependent_node)] then
      if node_type_operation[dependent_node.type] == "OR" then
        source_nodes_size = source_nodes_size + 1
        source_nodes[source_nodes_size] = dependent_node
      elseif node_type_operation[dependent_node.type] == "AND" then
        dependent_node.prereqs_satisfied[prg.get_key(curr_node)] = true

        local all_prereqs_satisfied = true
        for _, prereq_satisfied in pairs(dependent_node.prereqs_satisfied) do
          if prereq_satisfied == false then
            all_prereqs_satisfied = false
          end
        end

        if all_prereqs_satisfied then
          source_nodes_size = source_nodes_size + 1
          source_nodes[source_nodes_size] = dependent_node
        end
      end
    end
  end
end

local simple_accessible_list = {}

for _, node in pairs(accessible_list) do
  local new_node = {}
  new_node.type = node.type
  new_node.name = node.name
  table.insert(simple_accessible_list, new_node)
end
--log(serpent.block(simple_accessible_list))

-- Not really random now, but whatevs
--[[for _, node in pairs(dependency_graph) do
  for _, possible_next_node in pairs(dependency_graph) do
    if node_type_operation[possible_next_node.type] == "OR" then
      local reachable = false

      for _, prereq in pairs(possible_next_node.prereqs) do
        if added_to_accessible_list[prg.get_key(prereq)] then
          reachable = true
        end
      end

      if reachable and (not added_to_accessible_list[prg.get_key(possible_next_node)]) then
        table.insert(accessible_list, possible_next_node)
        added_to_accessible_list[prg.get_key(possible_next_node)] = true
      end
    elseif node_type_operation[possible_next_node.type] == "AND" then
      local reachable = true

      for _, prereq in pairs(possible_next_node.prereqs) do
        if not added_to_accessible_list[prg.get_key(prereq)] then
          reachable = false
        end
      end

      if reachable and (not added_to_accessible_list[prg.get_key(possible_next_node)]) then
        table.insert(accessible_list, possible_next_node)
        added_to_accessible_list[prg.get_key(possible_next_node)] = true
      end
    end
  end
end

local item_indices = {}
for ind, node in pairs(accessible_list) do
  if node.type == "itemorfluid_node" then
    table.insert(item_indices, ind)
  end
end

local tech_indices = {}
for ind, node in pairs(accessible_list) do
  if node.type == "technology_node" then
    table.insert(tech_indices, ind)
  end
end

local recipe_indices = {}
for ind, node in pairs(accessible_list) do
  if node.type == "recipe_node" then
    table.insert(recipe_indices, ind)
  end
end

--log(serpent.block(dependency_graph))

-- Find "initial cost" of an item
local item_cost = {}
for _, ind in pairs(item_indices) do
  local curr_item = dependency_graph[prg.get_key(accessible_list[ind])]

  local open = {}
  local open_size = 0
  local cost = {}
  for _, node in pairs(dependency_graph) do
    if node_type_operation[node.type] == "AND" and #(node.prereqs) == 0 then
      open_size = open_size + 1
      open[open_size] = node
      cost[prg.get_key(node)] = 100
    end
  end

  for i=1,SEARCH_SIZE_FOR_COMPLEXITY do
    if (open_size < i) then
      break
    end

    local curr_node = open[i]

    -- Recalculate costs to see if they're cheaper
    local new_cost
    if (node_type_operation[curr_node.type] == "AND") and (next(curr_node.prereqs) ~= nil) then
      new_cost = 0
      for _, prereq in pairs(curr_node.prereqs) do
        new_cost = new_cost + prereq.amount * cost[prg.get_key(prereq)]
      end
    elseif (node_type_operation[curr_node.type] == "OR") then
      for _, prereq in pairs(curr_node.prereqs) do
        if not (prereq.type == curr_item.type and prereq.name == curr_item.name) then
          if (cost[prg.get_key(prereq)] ~= nil) and ((new_cost == nil) or (prereq.amount * cost[prg.get_key(prereq)] < new_cost)) then
            new_cost = prereq.amount * cost[prg.get_key(prereq)]
          end
        end
      end
    end

    local cost_changed = false
    if (node_type_operation[curr_node.type] == "AND") and (next(curr_node.prereqs) == nil) then
      cost_changed = true
    end
    if (new_cost ~= nil) and (cost[prg.get_key(curr_node)] == nil or new_cost < cost[prg.get_key(curr_node)]) then
      cost_changed = true
      cost[prg.get_key(curr_node)] = new_cost
    end

    if cost_changed then
      -- Add new elements to open, but only if the cost changed
      for _, dependent in pairs(curr_node.dependents) do
        if not (dependent.type == curr_item.type and dependent.name == curr_item.name) then
          if (node_type_operation[dependent.type] == "OR") then
            open_size = open_size + 1
            open[open_size] = dependency_graph[prg.get_key(dependent)]
          elseif (node_type_operation[dependent.type] == "AND") then
            local all_prereqs_satisfied = true

            for _, prereq in pairs(dependency_graph[prg.get_key(dependent)].prereqs) do
              if cost[prg.get_key(prereq)] == nil then
                all_prereqs_satisfied = false
              end
            end

            if all_prereqs_satisfied then
              open_size = open_size + 1
              open[open_size] = dependency_graph[prg.get_key(dependent)]
            end
          end
        end
      end
    end
  end

  local curr_item_cost
  -- Items are always "or" types
  local prereq_satisfied = false
  for _, prereq in pairs(curr_item.prereqs) do
    if cost[prg.get_key(prereq)] ~= nil and (curr_item_cost == nil or cost[prg.get_key(prereq)] < curr_item_cost) then
      prereq_satisfied = true
      curr_item_cost = cost[prg.get_key(prereq)] * prereq.amount
    end
  end
  if not prereq_satisfied then
    --log(serpent.block(curr_item));
    curr_item_cost = REALLY_BIG_FLOAT_NUM
  end

  item_cost[prg.get_key(curr_item)] = curr_item_cost
end

for item_ind, item_thing in pairs(item_cost) do
  if (item_thing == REALLY_BIG_FLOAT_NUM) then
    item_cost[item_ind] = nil
  end
end

for item_ind, item_thing in pairs(item_cost) do
  item_cost[item_ind] = math.floor(item_thing / 10) / 10
end

log(serpent.block(item_cost))

return dependency_utils

--[[for _, ind in pairs(item_indices) do
  local req = {}

  local curr_item = dependency_graph[prg.get_key(accessible_list[ind])]

  req[prg.get_key(curr_item)] = 1

  open = {}
  table.insert(open, curr_item)

  for i=1,SEARCH_SIZE_FOR_COMPLEXITY do
    if (next(open) == nil) then
      break
    end

    curr_node = open[1]
    table.remove(open, 1)

    local no_self_use
    if node_type_operation[curr_node.type] == "AND" then
      no_self_use = true
      for _, prereq in pairs(curr_node.prereqs) do
        if prereq.type == "itemorfluid_node" and prereq.name == curr_item.name then
          no_self_use = false
        end
      end
    elseif node_type_operation[curr_node.type] == "OR" then
      no_self_use = false
      for _, prereq in pairs(curr_node.prereqs) do
        if not (prereq.type == "itemorfluid_node" and prereq.name == curr_item.name) then
          no_self_use = true
        end
      end
    end

    if no_self_use then
      
    end
  end
end]]

-- Costs (maybe for getting item in certain amount of time)
-- Randomization with topological order

-- Figure out costs? Wait, do we even need this?
-- Maybe assign cost/complexities to each thing and make it similar cost/complexity
-- Yeah keep costs, how do we count for technological complexity?
-- Maybe, like, an "upfront" cost
-- View it more as a function: put in this much cost how much can you get out?

--[[for recipe_num, recipe_ind in pairs(recipe_indices) do
  local tech_name = accessible_list[recipe_ind].name

  local new_science_pack = table.deepcopy(data.raw.tool["automation-science-pack"])
  new_science_pack.name = "new-science-pack-" .. tech_name
  local new_science_pack_recipe = table.deepcopy(data.raw.recipe["automation-science-pack"])
  new_science_pack_recipe.name = "new-science-pack-recipe-" .. tech_name
  new_science_pack_recipe.ingredients = {}
  new_science_pack_recipe.results = {{type = "item", name = "new-science-pack-" .. tech_name, amount = 1}}
  for _, item_index in pairs(item_indices) do
    if item_index < recipe_ind then
      table.insert(new_science_pack_recipe.ingredients, {
        type = "item",
        name = accessible_list[item_index].name,
        amount = 1
      })
    end
  end
  data:extend({
    new_science_pack,
    new_science_pack_recipe
  })
  table.insert(data.raw.lab.lab.inputs, "new-science-pack-" .. tech_name)
end]]

--[[local recipes = data.raw.recipe

local recipe_item_matrix = {}

for _, recipe_ind in pairs(recipe_indices) do
  function add_ingredients_to_matrix (recipe_data, recipe_name)
    for _, ingredient in pairs(recipe_data.ingredients) do
      local ingredient_name
      local ingredient_amount

      if ingredient.name ~= nil then
        ingredient_name = ingredient_name
        ingredient_amount = ingredient_
      end

      recipe_item_matrix[recipe_name][ingredient_name] = 
    end
  end
end

--[[
local dependency_graph_as_list = {}

for key, _ in pairs(dependency_graph) do
  table.insert(dependency_graph_as_list, key)
end

local function choose_random_element (list)
  return list[math.random(#list)]
end

local node_type_operation = {
  recipe_node = "AND",
  itemorfluid_node = "OR",
  technology_node = "AND",
  recipe_tech_unlock_node = "OR",
  recipe_category_node = "OR",
  crafting_entity_node = "OR",
  character_crafting_node = "AND", -- No prereqs, so essentially a source
  mining_machine_node = "OR",
  resource_node = "AND",
  resource_category_list_node = "OR",
  resource_category_node = "OR",
  character_mining_node = "AND" -- No prereqs, so essentially a source
}

local function find_reachable_nodes (tbl)
  local reachable_nodes = {}

  for _,_ in pairs(tbl) do
    for _, node in pairs(tbl) do
      if node_type_operation[node.type] == "AND" then
        local reachable = true
        for _, prereq in pairs(node.prereqs) do
          if not (reachable_nodes[prg.get_key(prereq)]) then
            reachable = false
          end
        end
        if reachable then
          reachable_nodes[prg.get_key(node)] = true
        end
      elseif node_type_operation[node.type] == "OR" then
        local reachable = false
        for _, prereq in pairs(node.prereqs) do
          if reachable_nodes[prg.get_key(prereq)] then
            reachable = true
          end
        end
        if reachable then
          reachable_nodes[prg.get_key(node)] = true
        end
      end
    end
  end

  return reachable_nodes
end

for i=1,5000 do
  local curr_node = dependency_graph[choose_random_element(dependency_graph_as_list)]
  local new_node_prereq = dependency_graph[choose_random_element(dependency_graph_as_list)]
  if #(curr_node.prereqs) >= 1 then
    local prereq_index = math.random(#(curr_node.prereqs))
    if curr_node.prereqs[prereq_index].type == new_node_prereq.type then
      if (find_reachable_nodes(dependency_graph))[prg.get_key(new_node_prereq)] then
        local possible_new_graph = table.deepcopy(dependency_graph)
        local node_in_possible_graph = possible_new_graph[prg.get_key(curr_node)]
        node_in_possible_graph.prereqs[prereq_index].name = new_node_prereq.name
        if find_reachable_nodes(possible_new_graph)[prg.get_key(node_in_possible_graph)] then
          curr_node.prereqs[prereq_index].name = new_node_prereq.name
        end
      end
    end
  end
end

-- Now fix the prototypes to have the new data
local function do_recipe_fix (recipe, curr_node)
  if curr_node ~= nil then
    local new_ingredients = {}
    local new_products = {}

    for _, prereq in pairs(curr_node.prereqs) do
      if prereq.type == "itemorfluid_node" then
        local type_of_ingredient = "item"
        if data.raw.fluid[prereq.name] ~= nil then
          type_of_ingredient = "fluid"
        end

        table.insert(new_ingredients, {
          type = type_of_ingredient,
          name = prereq.name,
          amount = prereq.amount
        })
      end
    end

    for _, node in pairs(dependency_graph) do
      if node.type == "itemorfluid_node" then
        for _, prereq in pairs(node.prereqs) do
          if prereq.type == "recipe_node" and prereq.name == recipe.name then
            local type_of_product = "item"
            if data.raw.fluid[node.name] ~= nil then
              type_of_product = "fluid"
            end

            table.insert(new_products, {
              type = type_of_product,
              name = node.name,
              amount = 1,
            })
          end
        end
      end
    end

    recipe.ingredients = new_ingredients
    if #new_products > 0 then
      recipe.results = new_products

      if recipe.main_product == nil then
        recipe.main_product = recipe.results[1].name
      end

      recipe.result = nil
    end
  end
end

for _, recipe in pairs(recipes_not_added) do
  if recipe.ingredients ~= nil then
    do_recipe_fix(recipe, dependency_graph[prg.get_key({type = "recipe_node", name = recipe.name})])
  end
  if recipe.normal ~= nil then
    do_recipe_fix(recipe.normal, dependency_graph[prg.get_key({type = "recipe_node", name = recipe.name})])
  end
  if recipe.expensive ~= nil then
    do_recipe_fix(recipe.expensive, dependency_graph[prg.get_key({type = "recipe_node", name = recipe.name})])
  end
end


for _, technology in pairs(data.raw.technology) do
  local curr_node = dependency_graph[prg.get_key({type = "technology_node", name = technology.name})]

  technology.prerequisites = {}

  if not (curr_node == nil) then
    technology.prerequisites = {}
    for _, prereq in pairs(curr_node.prereqs) do
      if prereq.type == "technology_node" and (not (prereq.name == technology.name)) then
        table.insert(technology.prerequisites, prereq.name)
      end
    end
  end
end

return dependency_utils

---------------------------------------------------------------------------------------------------
-- Do the randomization now
---------------------------------------------------------------------------------------------------

--[[local old_dependency_graph = table.deepcopy(dependency_graph)
local new_dependency_graph = {}

-- Node types:
--     1) recipe_node: AND
--     2) itemorfluid_node: OR
--     3) technology_node: AND
--     4) recipe_tech_unlock_node: OR
--     5) recipe_category_node: OR
--     6) crafting_entity_node: OR
--     7) mining_machine_node: OR
--     8) resource_node: AND
--     9) resource_category_list_node: OR -- I believe this isn't used? Remove
--     10) resource_category_node: OR
--     11) character_mining_node: AND (without prereqs)
local node_type_operation = {
  recipe_node = "AND",
  itemorfluid_node = "OR",
  technology_node = "AND",
  recipe_tech_unlock_node = "OR",
  recipe_category_node = "OR",
  crafting_entity_node = "OR",
  character_crafting_node = "AND", -- No prereqs, so essentially a source
  mining_machine_node = "OR",
  resource_node = "AND",
  resource_category_list_node = "OR",
  resource_category_node = "OR",
  character_mining_node = "AND" -- No prereqs, so essentially a source
}

local function choose_random_element (list)
  return list[math.random(#list)]
end

-- TODO: Don't allow hand crafting/mining to be forced for recipes that need mass production
-- Note: Some items will be forever unreachable, like editor mode items
-- Note: This is really. really. slow right now...
--while next(old_dependency_graph) ~= nil do
-- Temporarily do a for loop to prevent infinite loops
for i=1,20000 do
  local old_dependency_graph_as_list = {}

  for key, _ in pairs(old_dependency_graph) do
    table.insert(old_dependency_graph_as_list, key)
  end

  -- TODO: Use my own random function here
  local curr_node = old_dependency_graph[choose_random_element(old_dependency_graph_as_list)]

  local prereqs_satisfied
  if node_type_operation[curr_node.type] == "OR" then
    prereqs_satisfied = false

    for _, prereq in pairs(curr_node.prereqs) do
      if new_dependency_graph[prg.get_key(prereq)] ~= nil then
        prereqs_satisfied = true
      end
    end
  elseif node_type_operation[curr_node.type] == "AND" then
    prereqs_satisfied = true

    for _, prereq in pairs(curr_node.prereqs) do
      if new_dependency_graph[prg.get_key(prereq)] == nil then
        prereqs_satisfied = false
      end
    end
  end

  if prereqs_satisfied then
    old_dependency_graph[prg.get_key(curr_node)] = nil
    new_dependency_graph[prg.get_key(curr_node)] = curr_node

    -- Add new prereqs
    local new_prereqs = {}
    if curr_node.type == "recipe_node" then
      -- New recipe category
      local recipe_categories_list = {}
      for _, node in pairs(new_dependency_graph) do
        if node.type == "recipe_category_node" then
          table.insert(recipe_categories_list, node)
        end
      end

      local new_recipe_category = choose_random_element(recipe_categories_list)

      table.insert(new_prereqs, {
        type = "recipe_category_node",
        name = new_recipe_category.name,
        amount = 0
      })

      -- New recipe ingredients (just require up to three random ingredients for now)
      local itemorfluids_list = {}
      for _, node in pairs(new_dependency_graph) do
        if node.type == "itemorfluid_node" then
          table.insert(itemorfluids_list, node)
        end
      end

      local new_ingredients = {}
      local new_ingredient1 = choose_random_element(itemorfluids_list)
      local new_ingredient2 = choose_random_element(itemorfluids_list)
      local new_ingredient3 = choose_random_element(itemorfluids_list)
      new_ingredients[prg.get_key(new_ingredient1)] = new_ingredient1
      new_ingredients[prg.get_key(new_ingredient2)] = new_ingredient2
      new_ingredients[prg.get_key(new_ingredient3)] = new_ingredient3

      for _, new_ingredient in pairs(new_ingredients) do
        table.insert(new_prereqs, {
          type = "itemorfluid_node",
          name = new_ingredient.name,
          amount = 1
        })
      end

      -- Have the same recipe tech unlock node
      local recipe_tech_unlock_node = nil
      for _, prereq in pairs(curr_node.prereqs) do
        if prereq.type == "recipe_tech_unlock_node" then
          table.insert(new_prereqs, prereq)
        end
      end

    elseif curr_node.type == "itemorfluid_node" then
      -- Change what recipe it comes from
      
      -- Count how many recipes the original item came from and preserve this
      local production_recipes = 0
      for _, prereq in pairs(curr_node.prereqs) do
        if (prereq.type == "recipe_node") then
          production_recipes = production_recipes + 1
        end
      end

      local recipes_list = {}
      for _, node in pairs(new_dependency_graph) do
        if node.type == "recipe_node" then
          table.insert(recipes_list, node)
        end
      end

      local new_recipes = {}
      for i=1,production_recipes do
        local new_recipe = choose_random_element(recipes_list)
        new_recipes[prg.get_key(new_recipe)] = new_recipe
      end
      
      for _, new_recipe in pairs(new_recipes) do
        table.insert(new_prereqs, {
          type = "recipe_node",
          name = new_recipe.name,
          amount = 1
        })
      end

      -- If it comes from an ore, still have it come from an ore
      for _, prereq in pairs(curr_node.prereqs) do
        if prereq.type == "resource_node" then
          table.insert(new_prereqs, prereq)
        end
      end
    elseif curr_node.type == "technology_node" then
      -- Choose three random prereqs
      local technologies_accessible = {}
      for _, node in pairs(new_dependency_graph) do
        if node.type == "technology_node" then
          table.insert(technologies_accessible, node)
        end
      end

      local new_tech_prereqs = {}
      local new_tech_prereq1 = choose_random_element(technologies_accessible)
      local new_tech_prereq2 = choose_random_element(technologies_accessible)
      local new_tech_prereq3 = choose_random_element(technologies_accessible)
      new_tech_prereqs[prg.get_key(new_tech_prereq1)] = new_tech_prereq1
      new_tech_prereqs[prg.get_key(new_tech_prereq2)] = new_tech_prereq2
      new_tech_prereqs[prg.get_key(new_tech_prereq3)] = new_tech_prereq3

      for _, new_tech_prereq in pairs(new_tech_prereqs) do
        table.insert(new_prereqs, {
          type = "technology_node",
          name = new_tech_prereq.name,
          amount = 0
        })
      end

      -- Choose random tools (science packs)
      local tool_list = {}
      for _, node in pairs(new_dependency_graph) do
        if data.raw.tool[node.name] ~= nil then
          table.insert(tool_list, node)
        end
      end

      local num_original_tools = 0
      for _, prereq in pairs(curr_node.prereqs) do
        if prereq.type == "itemorfluid_node" then
          num_original_tools = num_original_tools + 1
        end
      end

      local new_tools = {}
      for i=1,num_original_tools do
        local new_tool = choose_random_element(tool_list)
        new_tools[prg.get_key(new_tool)] = new_tool
      end

      for _, tool in pairs(new_tools) do
        table.insert(new_prereqs, {
          type = "itemorfluid_node",
          name = tool.name,
          amount = 1
        })
      end
    elseif curr_node.type == "recipe_tech_unlock_node" then
      -- Add a tech that unlocks this
      local technologies_list = {}
      for _, node in pairs(new_dependency_graph) do
        if node.type == "technology_node" then
          table.insert(technologies_list, node)
        end
      end

      local new_tech_prereq = choose_random_element(technologies_list)

      table.insert(new_prereqs, {
        type = "technology_node",
        name = new_tech_prereq.name,
        amount = 0
      })
    elseif curr_node.type == "recipe_category_node" then
      local crafting_machines_list = {}
      for _, node in pairs(new_dependency_graph) do
        if node.type == "crafting_entity_node" then
          table.insert(crafting_machines_list, node)
        end
      end

      local old_num_crafters = 0
      for _, prereq in pairs(curr_node.prereqs) do
        if prereq.type == "crafting_entity_node" then
          old_num_crafters = old_num_crafters + 1
        end
      end

      local new_crafters = {}
      for i=1,old_num_crafters do
        -- TEMPORARY: Need to do this in a better way later also taking character crafting node into account
        if #crafting_machines_list > 0 then
          local new_crafter = choose_random_element(crafting_machines_list)
          new_crafters[prg.get_key(new_crafter)] = new_crafter
        end
      end

      for _, crafter in pairs(new_crafters) do
        table.insert(new_prereqs, {
          type = "crafting_entity_node",
          name = crafter.name,
          amount = 0
        })
      end
    elseif curr_node.type == "crafting_entity_node" then
      -- Have the same prereqs if we're just depending on a building (this just means buildings are built by the same items)
      new_prereqs = curr_node.prereqs
    elseif curr_node.type == "character_crafting_node" then
      new_prereqs = curr_node.prereqs
    elseif curr_node.type == "mining_machine_node" then
      new_prereqs = curr_node.prereqs
    elseif curr_node.type == "resource_node" then
      -- If the old one required fluid, randomize that
      local fluids_available_list = {}
      for _, node in pairs(new_dependency_graph) do
        if node.type == "itemorfluid_node" and data.raw.fluid[node.name] ~= nil then
          table.insert(fluids_available_list, node)
        end
      end

      for _, prereq in pairs(curr_node.prereqs) do
        if prereq.type == "itemorfluid_node" and data.raw.fluid[prereq.name] ~= nil then
          local new_fluid_req = choose_random_element(fluids_available_list)

          table.insert(new_prereqs, {
            type = "itemorfluid_node",
            name = new_fluid_req.name,
            amount = 1
          })
        end
      end

      -- Keep the resource categories
      for _, prereq in pairs(curr_node.prereqs) do
        if prereq.type == "resource_category_list_node" then
          table.insert(new_prereqs, prereq)
        end
      end
    elseif curr_node.type == "resource_category_list_node" then
      -- Keep this the same, don't want to mess this up too much
      new_prereqs = curr_node.prereqs
    elseif curr_node.type == "resource_category_node" then
      new_prereqs = curr_node.prereqs
    elseif curr_node.type == "character_mining_node" then
      new_prereqs = curr_node.prereqs
    end

    curr_node.prereqs = new_prereqs
  end
end

-- TODO: We should really just be iterating over nodes again

local function do_recipe_fix (recipe)
  local curr_node = new_dependency_graph[prg.get_key({type = "recipe_node", name = recipe.name})]

  if curr_node ~= nil then
    -- Ignore normal and expensive modes...
    local new_ingredients = {}
    local new_products = {}

    for _, prereq in pairs(curr_node.prereqs) do
      if prereq.type == "itemorfluid_node" then
        local type_of_ingredient = "item"
        if data.raw.fluid[prereq.name] ~= nil then
          type_of_ingredient = "fluid"
        end

        table.insert(new_ingredients, {
          type = type_of_ingredient,
          name = prereq.name,
          amount = prereq.amount
        })
      end
    end

    for _, node in pairs(new_dependency_graph) do
      if node.type == "itemorfluid_node" then
        for _, prereq in pairs(node.prereqs) do
          if prereq.type == "recipe_node" and prereq.name == recipe.name then
            local type_of_product = "item"
            if data.raw.fluid[node.name] ~= nil then
              type_of_product = "fluid"
            end

            table.insert(new_products, {
              type = type_of_product,
              name = node.name,
              amount = 1,
            })
          end
        end
      end
    end

    recipe.ingredients = new_ingredients
    if #new_products > 0 then
      recipe.results = new_products

      if recipe.main_product == nil then
        recipe.main_product = recipe.results[1].name
      end

      recipe.result = nil
    end
  end
end

-- Now fix the prototypes to have the new data
for _, recipe in pairs(recipes_not_added) do
  if recipe.ingredients ~= nil then
    do_recipe_fix(recipe)
  end
  if recipe.normal ~= nil then
    do_recipe_fix(recipe)
  end
  if recipe.expensive ~= nil then
    do_recipe_fix(recipe)
  end
end


for _, technology in pairs(data.raw.technology) do
  local curr_node = new_dependency_graph[prg.get_key({type = "technology_node", name = technology.name})]

  technology.prerequisites = {}

  if not (curr_node == nil) then
    technology.prerequisites = {}
    for _, prereq in pairs(curr_node.prereqs) do
      if prereq.type == "technology_node" and (not (prereq.name == technology.name)) then
        table.insert(technology.prerequisites, prereq.name)
      end
    end
  end
end

local recipes = data.raw.recipe

return dependency_utils]]

end
end
end