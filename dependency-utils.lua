require("random-utils.random")
local prototype_tables = require("randomizer-parameter-data.prototype-tables")

-- TODO: Add support for starting items
-- TODO: Add support for trees and rocks (they are special cases since they're not "automatable")
-- TODO Add support for custom autoplace in general (like, for example, in the ruins mod)
-- TODO: Add support for fuels (there's also burnt products and such...)
-- TODO: Support min_temperatures and max_temperatures on fluids in recipes

--[[[[

local recipe_dependency_utils = {}

-- Entries will be tables with id = {type = type of node (source, recipe, abstract, etc.), prereqs = node prereqs ids}
-- source-manual indicates it can be made, but not very well (mining trees being the primary example), currently not implemented
local dependency_graph = {}
local recipes_not_added = {}
for _, recipe in pairs(data.raw.recipe) do
  recipes_not_added[prg.get_key(recipe)] = true
end
local crafting_entities_not_added = {}
for _, crafting_machine_class in pairs(prototype_tables.crafting_machine_classes) do
  for _, crafting_machine in pairs(data.raw[crafting_machine_class]) do
    crafting_entities_not_added[prg.get_key(crafting_machine)] = true
  end
end
local items_and_fluids_not_added = {}
for item_class, _ in pairs(defines.prototypes["item"]) do
  for _, item in pairs(data.raw[item_class]) do
    items_and_fluids_not_added[prg.get_key({type = "itemorfluid", name = item.name})] = true
  end
end
for _, fluid in pairs(data.raw.fluid) do
  items_and_fluids_not_added[prg.get_key({type = "itemorfluid", name = fluid.name})] = true
end
local technologies_not_added = {}
for _, technology in pairs(data.raw.technology) do
  technologies_not_added[prg.get_key(technology)] = true
end
local recipe_categories_not_added = {}
for _, recipe_category in pairs(data.raw["recipe-category"]) do
  recipe_categories_not_added[prg.get_key(recipe_category)] = true
end

function find_minable_source_nodes ()
  for _, resource in pairs(data.raw.resource) do
    dependency_graph[prg.get_key(resource)] = {
      type = "source",
      prereqs = {}
    }
  end
end

function find_source_nodes ()
  find_minable_source_nodes()
end

for _, recipe in pairs(recipes_not_added) do
  local node = {
    type = "recipe",
    prereqs = {}
  }
  
  if recipe.category == nil then
    table.insert(node.prereqs, prg.get_key({type = "recipe-category", name = "crafting"}))
  else
    table.insert(node.prereqs, prg.get_key({type = "recipe-category", name = recipe.name}))
  end

  local function get_recipe_ingredients (recipe)
    recipe_ingredients = {}

    for _, ingredient in pairs(recipe.ingredients) do
      if ingredient[1] then
        table.insert(recipe_ingredients, {name = ingredient[1], amount = ingredient[2]})
      else
        --TODO
        if ingre

        table.insert(recipe_ingredients, ingredient.name)
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
    table.insert(node.prereqs, prg.get_key({type = "itemorfluid", name = ingredient.name, amount = ingredient.amount}))
  end

  dependency_graph[prg.get_key(recipe)] = node
end

-- Assume cheap mode for now
local function recipe_has_product_amount (recipe, itemorfluid) do
  if recipe.normal then
    return recipe_dependency_utils.recipe_has_product(recipe.normal, itemorfluid)
  end

  if recipe.result then
    if recipe.result == itemorfluid.name then
      return recipe.result_count or 1
    else
      return 0
    end
  end

  local amount_product
  if recipe.results then
    for _, ingredient in recipe.results
  end
end

for _, itemorfluid in pairs(items_and_fluids_not_added) do
  local node = {
    type = "itemorfluid",
    prereqs = {}
  }

  for _, recipe in pairs(data.raw.recipe) do
    if recipe_has_product(recipe, itemorfluid)
  end
end





function recipe_dependency_utils.has_immediate_prereqs (item_list, item)
  for _, recipe in pairs(data.raw.recipe) do
    -- If recipe has item as a product, check if building it's made in and ingredients are in item_list
    -- Also check if tech that unlocks it involves science packs that are already on the left
    
  end
end

recipe_dependency_utils.dependency_graph = dependency_graph

return recipe_dependency_utils

]]