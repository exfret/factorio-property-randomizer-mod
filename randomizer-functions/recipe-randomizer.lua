require("random-utils/randomization-algorithms")

local intermediate_item_names = {}

local function add_ingredients_to_intermediates_table (recipe_mode)
  if recipe_mode.ingredients == nil then
    return
  end

  for _, ingredient in pairs(recipe_mode.ingredients) do
    if ingredient[1] ~= nil then
      intermediate_item_names[ingredient[1]] = true
    else
      intermediate_item_names[ingredient.name] = true
    end
  end
end

for _, prototype in pairs(data.raw.recipe) do
  add_ingredients_to_intermediates_table(prototype)
  if prototype.normal then
    add_ingredients_to_intermediates_table(prototype.normal)
  end
  if prototype.expensive then
    add_ingredients_to_intermediates_table(prototype.expensive)
  end
end

-- TODO: Randomize this with even more sophisticated methods later
function randomize_crafting_times ()
  local function is_end_product_recipe (recipe_mode)
    if recipe_mode.results == nil or #recipe_mode.results == 1 then
      local result
      if recipe_mode.results and recipe_mode.results[1] and recipe_mode.results[1].name ~= nil then
        result = recipe_mode.results[1].name
      elseif recipe_mode.results and recipe_mode.results[1] and recipe_mode.results[1][1] ~= nil then
        result = recipe_mode.results[1][1]
      else
        result = recipe_mode.result
      end

      if not intermediate_item_names[result] then
        return true
      end
    end

    return false
  end

  local function randomize_crafting_time_of_recipe_mode (prototype, recipe_mode)
    if not recipe_mode.ingredients then
      return
    end

    if recipe_mode.energy_required == nil then
      recipe_mode.energy_required = 0.5
    end

    local slope = 3
    if is_end_product_recipe(recipe_mode) then
      slope = 10
    end

    randomize_numerical_property{
      prototype = prototype,
      tbl = recipe_mode,
      property = "energy_required",
      inertia_function = {
        ["type"] = "proportional",
        slope = slope
      }
    }
  end

  for _, prototype in pairs(data.raw.recipe) do
    if prototype.normal then
      randomize_crafting_time_of_recipe_mode(prototype, prototype.normal)
    end
    if prototype.expensive then
      randomize_crafting_time_of_recipe_mode(prototype, prototype.expensive)
    end
    randomize_crafting_time_of_recipe_mode(prototype, prototype)
  end
end