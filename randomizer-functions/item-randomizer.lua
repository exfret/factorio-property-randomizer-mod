require("util-randomizer")

local inertia_function = require("randomizer-parameter-data/inertia-function-tables")
local property_info = require("randomizer-parameter-data/property-info-tables")
local prototype_tables = require("randomizer-parameter-data/prototype-tables")
local walk_params = require("randomizer-parameter-data/walk-params-tables")

require("random-utils/random")
require("random-utils/randomization-algorithms")

local reformat = require("utilities/reformat")

function randomize_capsule_action (prototype, capsule_action)
  if capsule_action.type == "throw" then
    randomize_attack_parameters(prototype, capsule_action.attack_parameters)
  elseif capsule_action.type == "equipment-remote" then
  elseif capsule_action.type == "use-on-self" then
    randomize_attack_parameters(prototype, capsule_action.attack_parameters)
  elseif capsule_action.type == "artillery-remote" then
    -- Not much to randomize
  elseif capsule_action.type == "destroy_cliffs" then
    randomize_attack_parameters(prototype, capsule_action.attack_parameters)
    randomize_numerical_property{
      prototype = prototype,
      tbl = capsule_action,
      property = "radius"
    }
  end
end

---------------------------------------------------------------------------------------------------
-- randomize_ammo
---------------------------------------------------------------------------------------------------

function randomize_ammo ()
  for _, prototype in pairs(data.raw["ammo"]) do
    if prototype.magazine_size == nil then
      prototype.magazine_size = 1
    end
    if prototype.magazine_size ~= 1 then
      randomize_numerical_property{
        prototype = prototype,
        property = "magazine_size",
        property_info = property_info.magazine_size,
        walk_params = walk_params.magazine_size
      }
    end

    --[[if prototype.reload_time == nil then
      prototype.reload_time = 0
    end
    randomize_numerical_property{
      prototype = prototype,
      property = "reload_time",
      inertia_function = {
        ["type"] = "linear",
        slope = 4,
        ["x-intercept"] = -60
      },
      property_info = {
        min = 0
      }
    }]] -- This would just always make reload time worse... Maybe randomize it later?

    if prototype.ammo_type.category then
      randomize_ammo_type(prototype, prototype.ammo_type)
    else
      for _, ammo_type in pairs(prototype.ammo_type) do
        randomize_ammo_type(prototype, ammo_type)
      end
    end
  end
end

---------------------------------------------------------------------------------------------------
-- randomize_armor_resistances
---------------------------------------------------------------------------------------------------

function randomize_armor_resistances ()
  --[[for _, prototype in pairs(data.raw.armor) do
    if prototype.resistances then
      randomize_resistances{
        prototypes = {prototype},
        variance = 0.6
      }
    end
  end]] -- This needs to not use variance
end

---------------------------------------------------------------------------------------------------
-- randomize_capsules
---------------------------------------------------------------------------------------------------

function randomize_capsules ()
  for _, prototype in pairs(data.raw.capsule) do
    -- capsule_action is a mandatory property, so no need to check it
    randomize_capsule_action(prototype, prototype.capsule_action)
  end
end

---------------------------------------------------------------------------------------------------
-- randomize_gun_damage_modifier
---------------------------------------------------------------------------------------------------

function randomize_gun_damage_modifier ()
  for _, prototype in pairs(data.raw.gun) do
    prototype.attack_parameters.damage_modifier = prototype.attack_parameters.damage_modifier or 1

    randomize_numerical_property{
      prototype = prototype,
      tbl = prototype.attack_parameters,
      property = "damage_modifier",
      walk_params = walk_params.gun_damage_modifier,
      property_info = property_info.limited_range_strict
    }
  end
end

---------------------------------------------------------------------------------------------------
-- randomize_gun_range
---------------------------------------------------------------------------------------------------

function randomize_gun_range ()
  for _, prototype in pairs(data.raw.gun) do
    randomize_numerical_property{
      prototype = prototype,
      tbl = prototype.attack_parameters,
      property = "range",
      property_info = property_info.gun_shooting_range
    }
  end
end

---------------------------------------------------------------------------------------------------
-- randomize_gun_speed
---------------------------------------------------------------------------------------------------

function randomize_gun_speed ()
  for _, prototype in pairs(data.raw.gun) do
    randomize_numerical_property{
      prototype = prototype,
      tbl = prototype.attack_parameters,
      property = "cooldown", -- I would round, but that requires taking the inverses into account,
      property_info = property_info.gun_cooldown
    }
  end
end

---------------------------------------------------------------------------------------------------
-- randomize_item_stack_sizes
---------------------------------------------------------------------------------------------------

function randomize_item_stack_sizes ()
  for _, class_key in pairs(prototype_tables.item_classes_to_randomize_stack_size) do
    for _, prototype in pairs(data.raw[class_key]) do
      local not_stackable = false
      if prototype.flags then
        for _, flag in pairs(prototype.flags) do
          if flag == "not-stackable" then
            not_stackable = true
          end
        end
      end

      local property_info_to_use = property_info.stack_size
      -- Use sensitive stack size if it is a building or if it is used in making a building
      for _, recipe in pairs(data.raw.recipe) do
        reformat.prototype.recipe(recipe) -- TODO: Reformat beforehand and remove this

        for _, ingredient in pairs(recipe.ingredients) do
          if ingredient.name == prototype.name then
            for _, result in pairs(recipe.results) do
              for item_class, _ in pairs(defines.prototypes.item) do
                if item_class[result.name] ~= nil then
                  if item_class[result.name].place_result ~= nil then
                    property_info_to_use = property_info.stack_size_sensitive
                  end
                end
              end
            end
          end
        end
      end
      if prototype.place_result ~= nil then
        property_info_to_use = property_info.stack_size_sensitive
      end

      if not not_stackable then
        randomize_numerical_property{
          prototype = prototype,
          property = "stack_size",
          inertia_function = inertia_function.stack_size,
          property_info = property_info_to_use,
          walk_params = walk_params.stack_size
        }
      end
    end
  end
end

---------------------------------------------------------------------------------------------------
-- randomize_module_effects
---------------------------------------------------------------------------------------------------

-- TODO: randomly add a very small amount of productivity
-- Productivity shouldn't be changed much
-- TODO: Make higher tier modules more likely to receive better effects, like productivity
-- (I'm given tier info so might as well use it)
-- TODO: Randomize whether to even add/remove effects, instead of just randomizing each effect into a slurry
-- TODO: Figure out a smarter way to deal with the OP productivity effect
-- TODO: Balance the modules/soft link or smth
function randomize_module_effects ()
  for _, prototype in pairs(data.raw.module) do
    if prototype.effect.consumption == nil then
      prototype.effect.consumption = {bonus = 0}
    end
    if prototype.effect.consumption.bonus == nil then
      prototype.effect.consumption = {bonus = 0}
    end
    randomize_numerical_property{
      prototype = prototype,
      tbl = prototype.effect.consumption,
      property = "bonus",
      inertia_function = inertia_function.consumption_effect,
      property_info = property_info.consumption_effect
    }

    if prototype.effect.speed == nil then
      prototype.effect.speed = {bonus = 0}
    end
    if prototype.effect.speed.bonus == nil then
      prototype.effect.speed = {bonus = 0}
    end
    randomize_numerical_property{
      prototype = prototype,
      tbl = prototype.effect.speed,
      property = "bonus",
      inertia_function = inertia_function.speed_effect,
      property_info = property_info.speed_effect
    }

    if prototype.effect.productivity == nil then
      prototype.effect.productivity = {bonus = 0}
    end
    if prototype.effect.productivity.bonus == nil then
      prototype.effect.productivity = {bonus = 0}
    end
    randomize_numerical_property{
      prototype = prototype,
      tbl = prototype.effect.productivity,
      property = "bonus",
      inertia_function = inertia_function.productivity_effect,
      walk_params = walk_params.productivity_effect,
      property_info = property_info.productivity_effect
    }

    if prototype.effect.pollution == nil then
      prototype.effect.pollution = {bonus = 0}
    end
    if prototype.effect.pollution.bonus == nil then
      prototype.effect.pollution = {bonus = 0}
    end
    randomize_numerical_property{
      prototype = prototype,
      tbl = prototype.effect.pollution,
      property = "bonus",
      inertia_function = inertia_function.pollution_effect,
      property_info = property_info.pollution_effect
    }
  end
end

---------------------------------------------------------------------------------------------------
-- randomize_tools
---------------------------------------------------------------------------------------------------

function randomize_tools ()
  for _, class_name in pairs(prototype_tables.tool_classes) do
    -- TODO: Reimplement this once I figure out how to blacklist science packs
    --[[for _, prototype in pairs(data.raw[class_name]) do
      randomize_numerical_property{
        prototype = prototype,
        property = "durability",
        property_info = property_info.tool_durability
      }
    end]]
  end

  for _, prototype in pairs(data.raw["repair-tool"]) do
    randomize_numerical_property{
      prototype = prototype,
      property = "speed",
      property_info = property_info.repair_tool_speed
    }
  end
end