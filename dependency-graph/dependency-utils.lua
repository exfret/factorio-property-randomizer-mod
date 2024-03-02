require("random-utils.random")
require("globals")
require("simplex")

local prototype_tables = require("randomizer-parameter-data/prototype-tables")
local reformat = require("utilities/reformat")

local VOID_COST = 1

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
-- TODO: If node is an OR, only force one prereq
-- TODO: Actual recipe editing still messes up with normal versus expensive ugh
-- TODO: Special attention needs to be paid to crafting categories and fluids, since regular crafting category can't have them
-- TODO: Take special care with recipes that involve smelting/furnaces (no repeat ingredients, only one ingredient, etc.)
-- TODO: Rocket launch products

local dependency_utils = {}

-- Entries will be tables with id = {type = type of node (source, recipe, abstract, etc.), prereqs = node prereqs ids}
-- source-manual indicates it can be made, but not very well (mining trees being the primary example), currently not implemented
local dependency_graph = {}
local recipes_not_added = {}
local blacklisted_recipes = {
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
}
for _, recipe in pairs(data.raw.recipe) do
  if not blacklisted_recipes[recipe.name] then
    table.insert(recipes_not_added, recipe)
  end
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
      if ingredient[1] then
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
    if not blacklisted_recipes[recipe.name] then
      local product_amount = recipe_has_product_amount(recipe, itemorfluid)

      if product_amount > 0 then
        table.insert(node.prereqs, {
          type = "recipe_node",
          name = recipe.name,
          amount = 1 / product_amount
        })
      end
    end
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

--[[local new_node_for_ash = {
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
dependency_graph[prg.get_key(new_node_for_gas)] = new_node_for_gas

-- TEST
local new_node_for_wood = {
  type = "itemorfluid_node",
  name = "wood",
  prereqs = {}
}
table.insert(new_node_for_wood.prereqs, {
  type = "itemorfluid_node",
  name = "water",
  amount = 1
})
dependency_graph[prg.get_key(new_node_for_wood)] = new_node_for_wood]]

log("Wrapping up forward connections...")

for _, node in pairs(dependency_graph) do
  node.dependents = {}
end

for _, node in pairs(dependency_graph) do
  for _, prereq in pairs(node.prereqs) do
    if dependency_graph[prg.get_key(prereq)] == nil then
      log(node.name)
      log(prereq.name)
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

log("Adding resource recipes...")

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
end

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

-- Do 1000 swaps
for i=1,1000 do
  -- Just start at 20 for now lol
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
    reformat.recipe(recipe)

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