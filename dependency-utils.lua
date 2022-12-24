require("random-utils.random")
local prototype_tables = require("randomizer-parameter-data.prototype-tables")

-- TODO: Add support for starting items
-- TODO: Add support for trees and rocks (they are special cases since they're not "automatable")
-- TODO Add support for custom autoplace in general (like, for example, in the ruins mod)
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

--[[local dependency_utils = {}

-- Entries will be tables with id = {type = type of node (source, recipe, abstract, etc.), prereqs = node prereqs ids}
-- source-manual indicates it can be made, but not very well (mining trees being the primary example), currently not implemented
local dependency_graph = {}
local recipes_not_added = {}
for _, recipe in pairs(data.raw.recipe) do
  table.insert(recipes_not_added, recipe)
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
      amount = 0})
  else
    table.insert(node.prereqs, {
      type = "recipe_category_node",
      name = recipe.category,
      amount = 0})
  end

  -- Recipe ingredient prereq
  local function get_recipe_ingredients (recipe)
    recipe_ingredients = {}

    for _, ingredient in pairs(recipe.ingredients) do
      if ingredient[1] then
        table.insert(recipe_ingredients, {name = ingredient[1], amount = ingredient[2]})
      else
        table.insert(recipe_ingredients, {name = ingredient.name, amount = ingredient.amount})
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
        amount = 0
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

    table.insert(node.prereqs, recipe_tech_unlock_node)
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

  if recipe.result then
    if recipe.result == itemorfluid.name then
      return recipe.result_count or 1
    else
      return 0
    end
  end

  -- In this case, recipe.results must be defined
  return product_prototype_has_product_amount(recipe.results, itemorfluid)
end

for _, itemorfluid in pairs(items_and_fluids_not_added) do
  local node = {
    type = "itemorfluid_node",
    name = itemorfluid.name,
    prereqs = {}
  }

  -- Add recipe products
  for _, recipe in pairs(data.raw.recipe) do
    local product_amount = recipe_has_product_amount(recipe, itemorfluid)

    if product_amount > 0 then
      table.insert(node.prereqs, {
        type = "recipe_node",
        name = recipe.name,
        amount = 1 / product_amount
      })
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

  -- TODO: Remove!
  if itemorfluid.type ~= "fluid" then
    dependency_graph[prg.get_key(node)] = node
  end
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
        amount = 0
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
          amount = 0
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
  table.insert(node.prereqs, {
    type = "resource_category_node",
    name = resource.category,
    amount = 1
  })

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
          amount = 0
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

dependency_utils.dependency_graph = dependency_graph

---------------------------------------------------------------------------------------------------
-- Do the randomization now
---------------------------------------------------------------------------------------------------

local old_dependency_graph = table.deepcopy(dependency_graph)
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

local recipes = data.raw.recipe

return dependency_utils]]--