require("globals")

local inertia_function = require("randomizer-parameter-data/inertia-function-tables")
local property_info = require("randomizer-parameter-data/property-info-tables")
local prototype_tables = require("randomizer-parameter-data/prototype-tables")
local walk_params = require("randomizer-parameter-data/walk-params-tables")

require("random-utils/randomization-algorithms")

projectile_list = {}
for prototype_name, _ in pairs(data.raw.projectile) do
  table.insert(projectile_list, prototype_name)
end

function randomize_trigger_effect(prototype, trigger)
  if trigger.type == "damage" then
    randomize_numerical_property{
      prototype = prototype,
      tbl = trigger.damage,
      property = "amount",
      inertia_function = inertia_function.trigger_damage,
      property_info = property_info.trigger_damage,
      walk_params = walk_params.trigger_damage
    }
  elseif trigger.type == "create-entity" then
    -- TODO
  elseif trigger.type == "create-explosion" then
    -- TODO
  elseif trigger.type == "create-fire" then
    -- TODO
  elseif trigger.type == "create-smoke" then
    -- TODO
  elseif trigger.type == "create-trivial-smoke" then
    -- TODO
  elseif trigger.type == "create-particle" then
    -- TODO
  elseif trigger.type == "create-sticker" then
    -- TODO
  elseif trigger.type == "nested-result" then
    randomize_trigger_item(prototype, trigger.action)
  elseif trigger.type == "play-sound" then
    -- TODO
  elseif trigger.type == "push-back" then
    randomize_numerical_property{
      prototype = prototype,
      tbl = trigger,
      property = "distance",
      property_info = property_info.limited_range
    }
  elseif trigger.type == "destroy-cliffs" then
    randomize_numerical_property{
      prototype = prototype,
      tbl = trigger,
      property = "radius", -- TODO: Make it smaller by default?
      property_info = property_info.limited_range
    }
  elseif trigger.type == "show-explosion-on-chart" then
    -- TODO
  elseif trigger.type == "insert-item" then
    -- TODO
  elseif trigger.type == "script" then
    -- Nothing to change
  elseif trigger.type == "set-tile" then
    -- TODO
  elseif trigger.type == "invoke-tile-trigger" then
    -- TODO
  elseif trigger.type == "destroy-decoratives" then
    -- TODO
  elseif trigger.type == "camera-effect" then
    -- TODO
  end
end

function randomize_trigger_delivery(prototype, trigger)
  if trigger.target_effects then
    if trigger.target_effects.type then
      randomize_trigger_effect(prototype, trigger.target_effects)
    else
      for _, trigger_effect in pairs(trigger.target_effects) do
        randomize_trigger_effect(prototype, trigger_effect)
      end
    end
  end

  if trigger.source_effects then
    if trigger.source_effects.type then
      randomize_trigger_effect(prototype, trigger.source_effects)
    else
      for _, trigger_effect in pairs(trigger.source_effects) do
        randomize_trigger_effect(prototype, trigger_effect)
      end
    end
  end

  if trigger.type == "instant" then
    -- Nothing special
  elseif trigger.type == "projectile" then
    -- TODO: Switch around projectiles
    --if prg.value(prototype.type .. "aaa" .. prototype.name) < 1 then -- With 10% chance, change the projectile this shoots
    --  trigger.projectile = projectile_list[prg.range(prototype.type .. "aaa" .. prototype.name, 1, #projectile_list)]
    --end
  -- TODO
  end
end

-- Actually randomizes trigger
function randomize_trigger_item(prototype, trigger)
  if trigger.action_delivery then
    if trigger.action_delivery.type then
      randomize_trigger_delivery(prototype, trigger.action_delivery)
    else
      for _, trigger_delivery in pairs(trigger.action_delivery) do
        randomize_trigger_delivery(prototype, trigger_delivery)
      end
    end
  end
end

function randomize_ammo_type(prototype, ammo_type)
  if ammo_type.action then
    if ammo_type.action.type then
      randomize_trigger_item(prototype, ammo_type.action)
    else
      for _, trigger in pairs(ammo_type.action) do
        randomize_trigger_item(prototype, trigger)
      end
    end
  end

  if ammo_type.range_modifier == nil then
    ammo_type.range_modifier = 1
  end
  randomize_numerical_property{
    prototype = prototype,
    tbl = ammo_type,
    property = "range_modifier",
    inertia_function = inertia_function.sensitive_very,
    property_info = property_info.ammo_type_range_modifier
  }
end

-- TODO: Need to make sure artillery *manual range* and artillery *automatic range* are set so automatic < manual
function randomize_attack_parameters(prototype, attack_parameters)
  -- TODO: Make this not a hotfix
  -- This currently just ignores biters since it messes them up too much
  if attack_parameters.ammo_type ~= nil and prototype.type ~= "unit" then
    randomize_ammo_type(prototype, attack_parameters.ammo_type)
  end

  local old_range = attack_parameters.range
  randomize_numerical_property{
    prototype = prototype,
    tbl = attack_parameters,
    property = "range",
    inertia_function = inertia_function.sensitive_very,
    property_info = property_info.attack_parameters_range
  }
  -- Randomize minimum range by a proportional amount if it exists
  -- TODO: Make this a group randomization
  if attack_parameters.min_range ~= nil and old_range ~= nil then
    attack_parameters.min_range = attack_parameters.min_range * attack_parameters.range / old_range
  end
  if attack_parameters.min_attack_distance and old_range ~= nil then
    attack_parameters.min_attack_distance = attack_parameters.min_attack_distance * attack_parameters.range / old_range
  end

  -- TODO: Implement turn_range

  randomize_numerical_property{
    prototype = prototype,
    tbl = attack_parameters,
    property = "cooldown",
    property_info = property_info.attack_parameters_cooldown
  }

  randomize_numerical_property{
    prototype = prototype,
    tbl = attack_parameters,
    property = "fluid_consumption",
    property_info = property_info.fluid_consumption
  }

  if attack_parameters.damage_modifier == nil then
    attack_parameters.damage_modifier = 1
  end
  if attack_parameters.ammo_consumption_modifier == nil then
    attack_parameters.ammo_consumption_modifier = 1
  end
  randomize_numerical_property{
    prototype = prototype,
    tbl = attack_parameters,
    property = "damage_modifier",
    inertia_function = inertia_function.turret_damage_modifier, -- TODO: Make property info/inertia function respect that things actually start at -1
    property_info = property_info.damage_modifier
  }
  -- TODO: Rerandomize; was just confusing before
  --[[randomize_numerical_property{
    prototype = prototype,
    tbl = attack_parameters,
    property = "ammo_consumption_modifier", -- TODO: Make property info/inertia function respect that things actually start at -1
    property_info = property_info.consumption_modifier
  }]]

  if attack_parameters.fluids then
    for _, fluid in pairs(attack_parameters.fluids) do
      if fluid.damage_modifier == nil then
        fluid.damage_modifier = 1
      end
      randomize_numerical_property{
        prototype = prototype,
        tbl = fluid,
        property = "damage_modifier", -- TODO: Make property info/inertia function respect that things actually start at -1
        property_info = property_info.damage_modifier
      }
    end
  end
end

-- TODO: Do this in a better way?
function randomize_resistances(params)
  local group_params = {}
  for damage_type, _ in pairs(data.raw["damage-type"]) do
    group_params[damage_type] = {decrease = {}, percent = {}}
  end

  local variance = 1
  if params.variance ~= nil then
    variance = params.variance
  end

  for _, prototype in pairs(params.prototypes) do
    local resistances = prototype.resistances

    if resistances == nil then
      resistances = {}
    end

    local resistances_already_defined = {}

    for _, resistance in pairs(resistances) do
      resistances_already_defined[resistance.type] = true
    end

    for _, damage_type in pairs(data.raw["damage-type"]) do
      if not resistances_already_defined[damage_type.name] then
        table.insert(resistances, {type = damage_type.name, decrease = 0, percent = 0})
      end
    end

    for _, resistance in pairs(resistances) do
      if prg.range(prg.get_key(nil, "dummy"), 1, 10) == 1 then
        if resistance.decrease == nil then
          resistance.decrease = 0
        end
        if resistance.percent == nil then
          resistance.percent = 0
        end

        -- TODO prg_key
        table.insert(group_params[resistance.type]["decrease"], {
          prototype = prototype,
          tbl = resistance,
          property = "decrease",
          inertia_function = {
            ["type"] = "proportional",
            slope = DEFAULT_INERTIA_FUNCTION_SLOPE * variance
          },
          property_info = property_info.resistance_decrease
        })

        table.insert(group_params[resistance.type]["percent"], {
          prototype = prototype,
          tbl = resistance,
          property = "percent",
          inertia_function = {
            {-100, 300 * variance},
            {50, 300 * variance},
            {110, 0}
          },
          property_info = property_info.resistance_percent
        })
      end
    end
  end

  for _, group_param_resistance_table in pairs(group_params) do
    randomize_numerical_property{
      group_params = group_param_resistance_table["decrease"]
    }
    randomize_numerical_property{
      group_params = group_param_resistance_table["percent"]
    }
  end
end