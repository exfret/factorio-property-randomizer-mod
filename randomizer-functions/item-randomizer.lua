require("util-randomizer")

local inertia_function = require("randomizer-parameter-data/inertia-function-tables")
local property_info = require("randomizer-parameter-data/property-info-tables")
local prototype_tables = require("randomizer-parameter-data/prototype-tables")
local walk_params = require("randomizer-parameter-data/walk-params-tables")

require("random-utils/random")
require("random-utils/randomization-algorithms")

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
    randomize_numerical_property{
      prototype = prototype,
      property = "magazine_size",
      property_info = property_info.magazine_size,
      walk_params = walk_params.magazine_size
    }

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
  for _, prototype in pairs(data.raw.armor) do
    if prototype.resistances then
      randomize_resistances{
        prototypes = {prototype},
        variance = 0.6
      }
    end
  end
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
-- randomize_item_stack_sizes
---------------------------------------------------------------------------------------------------

function randomize_item_stack_sizes ()
  for _, class_key in pairs(prototype_tables.item_classes_to_randomize_stack_size) do
    for _, prototype in pairs(data.raw[class_key]) do
      local not_stackable = false
      if prototype.flags then
        for _, flag in pairs(prototype.flags) do
          if flag == "not_stackable" then
            not_stackable = true
          end
        end
      end

      if not not_stackable then
        randomize_numerical_property{
          prototype = prototype,
          property = "stack_size",
          inertia_function = inertia_function.stack_size,
          property_info = property_info.stack_size,
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
    for _, prototype in pairs(data.raw[class_name]) do
      randomize_numerical_property{
        prototype = prototype,
        property = "durability",
        property_info = property_info.tool_durability
      }
    end
  end

  for _, prototype in pairs(data.raw["repair-tool"]) do
    randomize_numerical_property{
      prototype = prototype,
      property = "speed",
      property_info = property_info.repair_tool_speed
    }
  end
end