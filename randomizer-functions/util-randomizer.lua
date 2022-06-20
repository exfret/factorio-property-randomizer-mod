require("random-utils/randomization-algorithms")

projectile_list = {}
for prototype_name, _ in pairs(data.raw.projectile) do
  table.insert(projectile_list, prototype_name)
end

function randomize_trigger_effect (prototype, trigger)
  if trigger.type == "damage" then
    randomize_numerical_property{
      prototype = prototype,
      tbl = trigger.damage,
      property = "amount"
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
    }
  elseif trigger.type == "destroy-cliffs" then
    randomize_numerical_property{
      prototype = prototype,
      tbl = trigger,
      property = "radius" -- TODO: Make it smaller by default?
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

function randomize_trigger_delivery (prototype, trigger)
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

function randomize_trigger_item (prototype, trigger)
  if trigger.action_delivery then
    if trigger.action_delivery.type then
      randomize_trigger_delivery(prototype, trigger.action_delivery)
    else
      for _, trigger_delivery in pairs(trigger.action_delivery) do
        randomize_trigger_delivery(prototype, trigger_delivery)
      end
    end
  end

  -- AreaTriggerItem
  if trigger.radius then
    trigger.radius = trigger.radius * random_modifier()
  end

  -- LineTriggerItem
  if trigger.range then
    trigger.range = trigger.range * random_modifier()
  end
  if trigger.width then
    trigger.width = trigger.width * random_modifier()
  end
  if trigger.range_effects then
    randomize_trigger_effect(prototype, trigger.range_effects)
  end

  -- ClusterTriggerItem
  if trigger.cluster_count then
    trigger.cluster_count = trigger.cluster_count * random_modifier()
  end
  if trigger.distance then
    trigger.distance = trigger.distance * random_modifier()
  end
  if trigger.distance_deviation then
    trigger.distance_deviation = trigger.distance_deviation * random_modifier()
  end
end

function randomize_ammo_type (prototype, ammo_type)
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
    property = "range_modifier"
  }
end

-- TODO: Need to make sure artillery *manual range* and artillery *automatic range* are set so automatic < manual
function randomize_attack_parameters (prototype, attack_parameters)
  if attack_parameters.ammo_type then
    randomize_ammo_type(prototype, attack_parameters.ammo_type)
  end

  local old_range = attack_parameters.range
  randomize_numerical_property{
    prototype = prototype,
    tbl = attack_parameters,
    property = "range"
  }
  -- Randomize minimum range by a proportional amount if it exists
  if attack_parameters.min_range then
    attack_parameters.min_range = attack_parameters.min_range * attack_parameters[range] / old_range
  end
  if attack_parameters.min_attack_distance then
    attack_parameters.min_attack_distance = attack_parameters.min_attack_distance * attack_parameters[range] / old_range
  end

  -- TODO: Implement turn_range

  randomize_numerical_property{
    prototype = prototype,
    tbl = attack_parameters,
    property = "cooldown"
  }

  randomize_numerical_property{
    prototype = prototype,
    tbl = attack_parameters,
    property = "fluid_consumption"
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
    property = "damage_modifier"
  }
  randomize_numerical_property{
    prototype = prototype,
    tbl = attack_parameters,
    property = "ammo_consumption_modifier"
  }

  if attack_parameters.fluids then
    for _, fluid in pairs(attack_parameters.fluids) do
      if fluid.damage_modifier == nil then
        fluid.damage_modifier = 1
      end
      randomize_numerical_property{
        prototype = prototype,
        tbl = fluid,
        property = "damage_modifier"
      }
    end
  end
end

-- TODO: Do this in a cooler way?
function randomize_resistances (prototype, resistances)
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
    if resistance.decrease == nil then
      resistance.decrease = 0
    end
    if resistance.percent == nil then
      resistance.percent = 0
    end

    randomize_numerical_property{
      prototype = prototype,
      tbl = resistance,
      property = "decrease",
      property_info = {
        round = {
          [2] = {
            modulus = 1
          }
        }
      }
    }

    randomize_numerical_property{
      prototype = prototype,
      tbl = resistance,
      property = "percent",
      inertia_function = {
        {-100, 300},
        {50, 300},
        {110, 0}
      },
      property_info = {
        round = {
          [2] = {
            modulus = 1
          },
          [3] = {
            modulus = 10
          }
        }
      }
    }
  end
end