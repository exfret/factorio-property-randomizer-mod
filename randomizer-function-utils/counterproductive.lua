-- How often a recipe succeeds
local recipe_success_chance = COUNTERPRODUCTIVE_SUCCESS_CHANCE

local recipes_not_to_modify = {}
local recipes_to_add = {}
local recipe_categories_to_add = {}
local character_crafting_categories_to_add = {}

-- Make new player-only recipes
for _, character in pairs(data.raw.character) do
  for crafting_category_key, crafting_category in pairs(character.crafting_categories) do
    table.insert(recipe_categories_to_add, {["type"] = "recipe-category", name = crafting_category .. "exfret_hand_crafting"})

    for _, recipe in pairs(data.raw.recipe) do
      if recipe.category == crafting_category.name then
        table.insert(recipes_to_add, recipe)

        recipes_not_to_modify[recipe.name .. "exfret_hand_crafting"] = true
      end
    end

    table.insert(character_crafting_categories_to_add, {crafting_category .. "exfret_hand_crafting", character})
  end

  for _, recipe in pairs(data.raw.recipe) do
    if recipe.category == nil or recipe.category == "crafting" then
      table.insert(recipes_to_add, recipe)

      recipes_not_to_modify[recipe.name .. "exfret_hand_crafting"] = true
    end
  end
end

-- Remove previous crafting categories
for _, character in pairs(data.raw.character) do
  character.crafting_categories = {}
end

for _, crafting_category_character_pair in pairs(character_crafting_categories_to_add) do
  table.insert(crafting_category_character_pair[2].crafting_categories, crafting_category_character_pair[1])
end
for _, recipe_category in pairs(recipe_categories_to_add) do
  data:extend({
    recipe_category
  })
end
for _, recipe in pairs(recipes_to_add) do
  local new_recipe = util.table.deepcopy(recipe)
  new_recipe.name = recipe.name .. "exfret_hand_crafting"
  if recipe.category then
    new_recipe.category = recipe.category .. "exfret_hand_crafting"
  else
    new_recipe.category = "craftingexfret_hand_crafting"
  end
  data:extend({
    new_recipe
  })
end

-- Add new recipe unlocks to techs
for _, technology in pairs(data.raw.technology) do
  if technology.effects == nil then
    technology.effects = {}
  end

  for _, effect in pairs(technology.effects) do
    if effect.type == "unlock-recipe" then
      if (not recipes_not_to_modify[effect.recipe]) and data.raw.recipe[effect.recipe .. "exfret_hand_crafting"] ~= nil then
        table.insert(technology.effects, { type = "unlock-recipe", recipe = effect.recipe .. "exfret_hand_crafting" })
      end
    end
  end
end

-- Modify recipe success chance
function modify_recipe_success_chance (recipe)
  if recipe.results then
    for _, result in pairs(recipe.results) do
      -- Convert from short from to long form
      if result[1] then
        result.name = result[1]
        result.amount = 1
        if result[2] then
          result.amount = result[2]
        end

        result[1] = nil
        result[2] = nil
      end

      success_probability = recipe_success_chance
      if result.probability then
        success_probability = result.probability * recipe_success_chance
      end

      result.probability = success_probability
    end
  else
    recipe_result_count = 1
    if recipe.result_count then
      recipe_result_count = recipe.result_count
    end

    recipe.results = {{name = recipe.result, amount = recipe_result_count, probability = recipe_success_chance}}
  end
end

-- Modify recipe success chances
for _, recipe in pairs(data.raw.recipe) do
  if not recipes_not_to_modify[recipe.name] then
    if recipe.normal then
      modify_recipe_success_chance(recipe.normal)
    end
    if recipe.expensive then
      modify_recipe_success_chance(recipe.expensive)
    end
    modify_recipe_success_chance(recipe)
  end
end