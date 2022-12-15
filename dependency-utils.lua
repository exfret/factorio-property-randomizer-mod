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

local dependency_utils = {}

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

for _, recipe in pairs(recipes_not_added) do
  local node = {
    type = "recipe",
    name = recipe.name,
    prereqs = {}
  }
  
  -- Recipe category prereq
  if recipe.category == nil then
    table.insert(node.prereqs, prg.get_key({type = "recipe-category", name = "crafting", amount = 0}))
  else
    table.insert(node.prereqs, prg.get_key({type = "recipe-category", name = recipe.name, amount = 0}))
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
      type = "itemorfluid",
      name = ingredient.name,
      amount = ingredient.amount
    })
  end

  -- Now add tech prerquisites
  local recipe_tech_unlock_node = {
    type = "recipe_tech_unlock",
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
        type = "technology",
        name = technology.name,
        amount = 0
      })
    end
  end

  dependency_graph[prg.get_key(recipe_tech_unlock_node)] = recipe_tech_unlock_node

  table.insert(node.prereqs, {
    type = recipe_tech_unlock_node.type,
    name = recipe_tech_unlock_node.name,
    amount = 0
  })

  dependency_graph[prg.get_key(node)] = node
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

  local amount_product = 0

  if recipe.results then
    for _, result in pairs(recipe.results) do
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
  end

  return amount_product
end

for _, itemorfluid in pairs(items_and_fluids_not_added) do
  local node = {
    type = "itemorfluid",
    name = itemorfluid.name,
    prereqs = {}
  }

  for _, recipe in pairs(data.raw.recipe) do
    local product_amount = recipe_has_product_amount(recipe, itemorfluid)

    if product_amount > 0 then
      table.insert(node.prereqs, {type = "recipe", name = recipe.name, amount = 1 / product_amount})
    end
  end

  dependency_graph[prg.get_key(node)] = node
end

for _, crafting_entity in pairs(crafting_entities_not_added) do
  local node = {
    type = "crafting_entity",
    name = crafting_entity.name,
    prereqs = {}
  }

  for item_class, _ in pairs(defines.prototypes.item) do
    for _, item in pairs(data.raw[item_class]) do
      if item.place_result ~= nil and item.place_result == crafting_entity.name then
        table.insert(node.prereqs, {
          type = "itemorfluid",
          name = item.name,
          amount = 0
        })
      end
    end
  end

  dependency_graph[prg.get_key({type = "crafting_entity", name = crafting_entity.name})] = node
end

for _, technology in pairs(technologies_not_added) do
  local node = {
    type = "technology",
    name = technology.name,
    prereqs = {}
  }

  if technology.prerequisites ~= nil then
    for _, prereq in pairs(technology.prerequisites) do
      table.insert(node.prereqs, {
        type = "technology",
        name = prereq,
        amount = 0
      })
    end
  end

  for _, science_pack in pairs(technology.unit.ingredients) do
    if science_pack[1] ~= nil then
      table.insert(node.prereqs, {
        type = "itemorfluid",
        name = science_pack[1],
        amount = 0
      })
    else
      table.insert(node.prereqs, {
        type = "itemorfluid",
        name = science_pack.name,
        amount = 0
      })
    end
  end

  dependency_graph[prg.get_key(node)] = node
end

for _, recipe_category in pairs(recipe_categories_not_added) do
  local node = {
    type = "recipe_category",
    name = recipe_category.name,
    prereqs = {}
  }

  for _, crafting_machine in pairs(crafting_entities_not_added) do
    for _, crafting_category in pairs(crafting_machine.crafting_categories) do
      if crafting_category == recipe_category.name then
        table.insert(node.prereqs, {
          type = "crafting_machine",
          name = crafting_machine.name,
          amount = 0
        })
      end
    end
  end
end

dependency_utils.dependency_graph = dependency_graph

return dependency_utils

