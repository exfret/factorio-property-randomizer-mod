require("energy-randomizer")
require("linking-utils")
require("util-randomizer")

require("random-utils/random")
require("random-utils/randomization-algorithms")

-- TODO: organize this section

local belt_speed_property_info = {
  min = 0.00390625,
  max = 255,
  round = {
    [2] = {
      modulus = 0.00390625 * 2.0
    },
    [3] = {
      modulus = 0.00390625 * 4.0
    }
  }
}

local machine_speed_property_info = {
  min = 0.001,
  round = {
    [2] = {
      modulus = 0.01
    },
    [3] = {
      modulus = 0.1
    }
  }
}

local inventory_slots_property_info = {
  min = 1,
  max = 10,
  round = {
    [1] = {
      modulus = 1
    },
    [2] = {
      modulus = 1
    }
  }
}

local small_inventory_property_info = {
  min = 0,
  max = 65535,
  round = {
    [1] = {
      modulus = 1
    },
    [2] = {
      modulus = 1
    },
    [3] = {
      modulus = 1
    }
  }
}

local small_nonempty_inventory_property_info = {
  min = 1,
  max = 65535,
  round = {
    [1] = {
      modulus = 1
    },
    [2] = {
      modulus = 1
    },
    [3] = {
      modulus = 1
    }
  }
}

local large_inventory_property_info = {
  min = 1,
  max = 65535,
  round = {
    [1] = {
      modulus = 1
    },
    [2] = {
      left_digits_to_keep = 2,
      modulus = 5
    }
  }
}

local supply_area_property_info = {
  min = 2,
  max = 64,
  round = {
    [1] = {
      modulus = 0.5
    },
    [2] = {
      modulus = 0.5
    },
    [3] = {
      modulus = 0.5
    }
  }
}

local wire_distance_property_info = {
  min = 1.5,
  max = 64,
  round = {
    [3] = {
      modulus = 1
    }
  }
}

local effectivity_property_info = {
  min = 0.001,
  round = {
    [2] = {
      modulus = 0.01
    },
    [3] = {
      modulus = 0.1
    }
  }
}

-- TODO: Find a more general way to make tools for dealing with entity classes
local entities_with_health = {
  "accumulator",
  "artillery-turret",
  "beacon",
  "boiler",
  "burner-generator",
  "character",
  "arithmetic-combinator",
  "decider-combinator",
  "constant-combinator",
  "container",
  "logistic-container",
  "infinity-container",
  "assembling-machine",
  "rocket-silo",
  "furnace",
  "electric-energy-interface",
  "electric-pole",
  "unit-spawner",
  "combat-robot",
  "construction-robot",
  "logistic-robot",
  "gate",
  "generator",
  "heat-interface",
  "heat-pipe",
  "inserter",
  "lab",
  "lamp",
  "land-mine",
  "linked-container",
  "market",
  "mining-drill",
  "offshore-pump",
  "pipe",
  "infinity-pipe",
  "pipe-to-ground",
  "player-port",
  "power-switch",
  "programmable-speaker",
  "pump",
  "radar",
  "curved-rail",
  "straight-rail",
  "rail-chain-signal",
  "rail-signal",
  "reactor",
  "roboport",
  "simple-entity-with-owner",
  "simple-entity-with-force",
  "solar-panel",
  "storage-tank",
  "train-stop",
  "linked-belt",
  "loader-1x1",
  "loader",
  "splitter",
  "transport-belt",
  "underground-belt",
  "turret",
  "ammo-turret",
  "electric-turret",
  "fluid-turret",
  "unit",
  "car",
  "artillery-wagon",
  "cargo-wagon",
  "fluid-wagon",
  "locomotive",
  "spider-vehicle",
  "wall",
  "fish",
  "simple-entity",
  "spider-leg",
  "tree"
}

-- TODO
local entity_trigger_effect_keys_to_modify = {
  
}

local transport_belt_classes = {
  "transport-belt",
  "underground-belt",
  "splitter",
  "linked-belt",
  "loader-1x1",
  "loader"
}

---------------------------------------------------------------------------------------------------
-- randomize_assembly_machine_groups
---------------------------------------------------------------------------------------------------

function randomize_assembly_machine_groups ()
  local upgrade_groups = find_upgrade_groups("assembling-machine")

  for _, upgrade_group in pairs(upgrade_groups) do
    local group_params = {}
    for _, prototype_in_upgrade_group in pairs(upgrade_group) do
      table.insert(group_params, {
        prototype = prototype_in_upgrade_group,
        property = "crafting_speed",
        inertia_function = {
          ["type"] = "proportional",
          slope = 2
        },
        property_info = machine_speed_property_info
      })
    end

    randomize_numerical_property{
      -- TODO: Add custom prg keys for groups depending on the most upgraded version
      group_params = group_params
    }
  end
end

---------------------------------------------------------------------------------------------------
-- randomize_beacon_properties
---------------------------------------------------------------------------------------------------

function randomize_beacon_properties ()
  for _, prototype in pairs(data.raw.beacon) do
    randomize_numerical_property{
      prototype = prototype,
      property = "supply_area_distance",
      inertia_function = {
        ["type"] = "linear",
        slope = 3.5,
        ["x-intercept"] = 1.5
      },
      property_info = supply_area_property_info
    }

    randomize_numerical_property{
      prototype = prototype,
      property = "distribution_effectivity",
      inertia_function = {
        ["type"] = "proportional",
        slope = 4
      },
      property_info = effectivity_property_info
    }
  end
end

---------------------------------------------------------------------------------------------------
-- randomize_belt_speed
---------------------------------------------------------------------------------------------------

-- TODO: Option to sync belt tiers
function randomize_belt_speed ()
  for _, belt_class in pairs(transport_belt_classes) do
    for _, prototype in pairs(data.raw[belt_class]) do
      -- TODO: round to nearest multiple of 0.4 / 480?
      randomize_numerical_property{
        prototype = prototype,
        property = "speed",
        inertia_function = {
          {0, 0},
          {5 / 480, 3 / 480},
          {10 / 480, 21 / 480},
          {255, 1200}
        },
        property_info = belt_speed_property_info
      }
    end
  end
end

---------------------------------------------------------------------------------------------------
-- randomize_bot_speed
---------------------------------------------------------------------------------------------------

local bot_classes = {
  "combat-robot",
  "construction-robot",
  "logistic-robot"
}

-- TODO: Make sure to also randomize max_speed if it is non-nil
function randomize_bot_speed ()
  for _, class_name in pairs(bot_classes) do
    for _, prototype in pairs(data.raw[class_name]) do
      -- Speed is mandatory
      local old_speed = prototype.speed

      randomize_numerical_property{
        prototype = prototype,
        property = "speed",
        inertia_function = {
          ["type"] = "proportional",
          slope = 5 -- Can be higher since bots aren't as necessary
        },
        property_info = {
          min = 0.1 / 216,
          round = {
            [2] = {
              modulus = 1 / 216
            }
          }
        }
      }

      -- Make sure max_speed is at least speed
      if prototype.max_speed ~= nil then
        prototype.max_speed = prototype.max_speed * prototype.speed / old_speed
      end
    end
  end
end

---------------------------------------------------------------------------------------------------
-- randomize_car_rotation_speed
---------------------------------------------------------------------------------------------------

function randomize_car_rotation_speed ()
  for _, prototype in pairs(data.raw.car) do
    randomize_numerical_property{
      prototype = prototype,
      property = "rotation_speed",
      inertia_function = {
        ["type"] = "proportional",
        slope = 5
      }
    }
  end
end

---------------------------------------------------------------------------------------------------
-- randomize_character_corpse_time_to_live
---------------------------------------------------------------------------------------------------

function randomize_character_corpse_time_to_live ()
  for _, prototype in pairs(data.raw["character-corpse"]) do
    randomize_numerical_property{
      prototype = prototype,
      property = "time_to_live",
      inertia_function = {
        ["type"] = "proportional",
        slope = 10
      },
      round = {
        [2] = {
          modulus = 3600
        }
      }
    }
  end
end

---------------------------------------------------------------------------------------------------
-- randomize_character_respawn_time
---------------------------------------------------------------------------------------------------

function randomize_character_respawn_time ()
  for _, prototype in pairs(data.raw.character) do
    if prototype.respawn_time == nil then
      prototype.respawn_time = 10
    end

    randomize_numerical_property{
      prototype = prototype,
      property = "respawn_time",
      round = {
        [2] = {
          round = 60
        }
      }
    }
  end
end

---------------------------------------------------------------------------------------------------
-- randomize_electric_poles
---------------------------------------------------------------------------------------------------

function randomize_electric_poles ()
  for _, prototype in pairs(data.raw["electric-pole"]) do
    randomize_numerical_property{
      prototype = prototype,
      property = "supply_area_distance",
      inertia_function = {
        {-2, 3},
        {1.5, 3},
        {2, 6},
        {4, 45},
        {10, 60},
        {50, 150},
        {64, 0}
      },
      property_info = supply_area_property_info,
      randomization_params = {
        bias = 0.565
      }
    }

    randomize_numerical_property{
      prototype = prototype,
      property = "maximum_wire_distance",
      inertia_function = {
        {1.5, 0},
        {3.5, 3},
        {5, 18},
        {15, 100},
        {50, 300},
        {64, 0}
      },
      property_info = wire_distance_property_info
    }
  end
end

---------------------------------------------------------------------------------------------------
-- randomize_enemy_spawning
---------------------------------------------------------------------------------------------------

-- TODO: Balance this better and fix it up
function randomize_enemy_spawning ()
  for _, prototype in pairs(data.raw["unit-spawner"]) do
    local key = prg.get_key(prototype)

    for _, unit in pairs(prototype.result_units) do
      local evolution_shift = (prg.int(key, 100) - 60) / 400

      for _, spawn_point in pairs(unit[2]) do
        local spawn_point_evolution_factor
        if spawn_point[1] then
          spawn_point_evolution_factor = spawn_point[1]
        else
          spawn_point_evolution_factor = spawn_point.evolution_factor
        end

        local spawn_point_spawn_weight
        if spawn_point[2] then
          spawn_point_spawn_weight = spawn_point[2]
        else
          spawn_point_spawn_weight = spawn_point.spawn_weight
        end

        spawn_point[1] = nil
        spawn_point[2] = nil

        spawn_point.evolution_factor = spawn_point_evolution_factor + evolution_shift
        spawn_point.spawn_weight = spawn_point_spawn_weight * randomize_numerical_property()
      end
    end
  end
end

---------------------------------------------------------------------------------------------------
-- randomize_entity_interaction_speed
---------------------------------------------------------------------------------------------------

local entities_to_modify_mining_speed = {
  "character-corpse",
  "accumulator",
  "artillery-turret",
  "beacon",
  "boiler",
  "burner-generator",
  -- Not character
  "arithmetic-combinator",
  "decider-combinator",
  "constant-combinator",
  "container",
  "logistic-container",
  "infinity-container",
  "assembling-machine",
  "rocket-silo",
  "furnace",
  -- Not electric-energy-interface
  "electric-pole",
  "unit-spawner",
  "combat-robot",
  "construction-robot",
  "logistic-robot",
  "gate",
  "generator",
  -- Not heat-interface
  "heat-pipe",
  "inserter",
  "lab",
  "lamp",
  "land-mine",
  "linked-container",
  "market",
  "mining-drill",
  "offshore-pump",
  "pipe",
  "infinity-pipe",
  "pipe-to-ground",
  "player-port",
  "power-switch",
  "programmable-speaker",
  "pump",
  "radar",
  "curved-rail",
  "straight-rail",
  "rail-chain-signal",
  "rail-signal",
  "reactor",
  "roboport",
  -- Not simple-entity-with-owner or simple-entity-with-force (I don't know what they are really used for)
  "solar-panel",
  "storage-tank",
  "train-stop",
  "linked-belt",
  "loader-1x1",
  "loader",
  "splitter",
  "transport-belt",
  "underground-belt",
  "turret",
  "ammo-turret",
  "electric-turret",
  "fluid-turret",
  "unit",
  "car",
  "artillery-wagon",
  "cargo-wagon",
  "fluid-wagon",
  "locomotive",
  "spider-vehicle",
  "wall",
  "fish",
  -- Not simple-entity
  "tree",
  "item-entity",
  -- Not resource (that's too sensitive, must be randomized separately)
  "tile-ghost"
}

-- Right now randomizes repair speed and mining speed
-- TODO: randomize EntityGhost and tile-ghost mining speed to be above zero sometimes randomly
function randomize_entity_interaction_speed ()
  for _, class_name in pairs(entities_to_modify_mining_speed) do
    for _, prototype in pairs(data.raw[class_name]) do
      if prototype.minable then
        randomize_numerical_property{
          prototype = prototype,
          tbl = prototype.minable,
          property = "mining_time",
          inertia_function = {
            ["type"] = "proportional",
            slope = 5
          }
        }
      end
    end
  end

  for _, class_name in pairs(entities_with_health) do
    for _, prototype in pairs(data.raw[class_name]) do
      if prototype.repair_speed_modifier == nil then
        prototype.repair_speed_modifier = 1
      end
      randomize_numerical_property{
        prototype = prototype,
        property = "repair_speed_modifier",
        inertia_function = {
          ["type"] = "proportional",
          slope = 15
        }
      }
    end
  end
end

---------------------------------------------------------------------------------------------------
-- randomize_entity_triggers
---------------------------------------------------------------------------------------------------

-- This should be split up based on why we want to randomize the triggers

-- Entity is the only class with triggers
--[[local entity_trigger_keys_to_modify = {
  ["artillery-projectile"] = {"action", "final_action"},
  beam = {"action"},
  character = {"tool_attack_result"},
  ["combat-robot"] = {"destroy_action"},
  ["construction-robot"] = {"destroy_action"},
  ["logistic-robot"] = {"destroy_action"},
  ["land-mine"] = {"action"},
  reactor = {"meltdown_action"},
  fire = {"on_damage_tick_effect", "on_fuel_added_action"},
  stream = {"action", "initial_action"},
  projectile = {"action", "final_action"},
  ["smoke-with-trigger"] = {"action"}
}
-- All entities have a special created_effect Trigger key
for class_name, _ in pairs(defines.prototypes["entity"]) do
  if entity_trigger_keys_to_modify[class_name] == nil then
    entity_trigger_keys_to_modify[class_name] = {}
  end
  table.insert(entity_trigger_keys_to_modify[class_name], "created_effect")
end

function randomize_entity_triggers ()
  for class_name, property_list in pairs(entity_trigger_keys_to_modify) do
    for _, prototype in pairs(data.raw[class_name]) do
      for _, property in pairs(property_list) do
        if prototype[property] then
          if prototype[property].type then
            randomize_trigger_item(prototype, prototype[property])
          else
            for _, trigger_item in pairs(prototype[property]) do
              randomize_trigger_item(prototype, trigger_item)
            end
          end
        end
      end
    end
  end
end]]

---------------------------------------------------------------------------------------------------
-- randomize_gate_opening_speed
---------------------------------------------------------------------------------------------------

function randomize_gate_opening_speed ()
  for _, prototype in pairs(data.raw.gate) do
    randomize_numerical_property{
      prototype = prototype,
      property = "opening_speed",
      inertia_function = {
        ["type"] = "proportional",
        slope = 15
      }
    }
  end
end

---------------------------------------------------------------------------------------------------
-- randomize_group_belt_speed
---------------------------------------------------------------------------------------------------

function randomize_group_belt_speed ()
  for _, belt_class in pairs(transport_belt_classes) do
    local group_params = {}
    for _, prototype in pairs(data.raw[belt_class]) do
      table.insert(group_params, {
        prototype = prototype,
        property = "speed",
        inertia_function = {
          {0, 0},
          {5 / 480, 2 / 480},
          {10 / 480, 24 / 480},
          {255, 800}
        },
        property_info = belt_speed_property_info
      })
    end

    randomize_numerical_property{
      prg_key = prg.get_key(belt_class, "class"),
      group_params = group_params
    }
  end
end

---------------------------------------------------------------------------------------------------
-- randomize_health_properties
---------------------------------------------------------------------------------------------------

-- TODO: randomize resistances for entities that don't have them
-- TODO: randomize resistances in a smarter way
-- TODO: Round health/resistances to a whole number (or close) for niceness (at least resistances are an eyesore to look at)
function randomize_health_properties ()
  for _, class_name in pairs(entities_with_health) do
    for _, prototype in pairs(data.raw[class_name]) do
      if prototype.max_health == nil then
        prototype.max_health = 10
      end
      randomize_numerical_property{
        prototype = prototype,
        property = "max_health",
        property_info = {
          round = {
            [2] = {
              modulus = 5
            }
          }
        }
      }

      randomize_resistances(prototype, prototype.resistances)
      -- TODO: Get rid of showing all resistances
      prototype.hide_resistances = false -- Make it so that players can see that resistances were changed
    end
  end
end

---------------------------------------------------------------------------------------------------
-- randomize_inserter_insert_dropoff_positions
---------------------------------------------------------------------------------------------------

local inserter_insert_positions = {
  {0, 1.2}, -- Standard
  {0, 0.8}, -- Near
  {0, 2.2}, -- Far
  {1, 1}, -- Diagonal
  {0, -1.2} -- "Back where it came from"
}

local inserter_pickup_positions = {
  {0, -1}, -- Standard
  {0, -2}, -- Long-handed
  {1, 0}, -- To the side
  {-1.2, -0.2}, -- Diagonal, sorta?
  {-3.2, 9.2} -- Huh?
}

-- TODO: Add Bob's mods compatibility
function randomize_inserter_insert_dropoff_positions()
  for _, prototype in pairs(data.raw.inserter) do
    -- Test that this inserter is a "good" size
    if prototype.collision_box ~= nil and prototype.collision_box[1][1] == -0.15 and prototype.collision_box[1][2] == -0.15 and prototype.collision_box[2][1] == 0.15 and prototype.collisions_box[2][2] == 0.15 then
      local key = prototype.type .. "aaa" .. prototype.name

      local inserter_position_variable = prg.range(key, 1,8)

      -- 1/4 chance to change to a different type of insert position
      if 1 <= inserter_position_variable and inserter_position_variable <= 3 then
        prototype.insert_position = inserter_insert_positions[prg.range(key, 1, #inserter_insert_positions)]
      end

      -- 1/4 chance to change to a different type of pickup position
      if 2 <= inserter_position_variable and inserter_position_variable <= 4 then
        prototype.pickup_position = inserter_pickup_positions[prg.range(key, 1, #inserter_pickup_positions)]
      end
    end
  end
end

---------------------------------------------------------------------------------------------------
-- randomize_inserter_speed
---------------------------------------------------------------------------------------------------

function randomize_inserter_speed ()
  for _, prototype in pairs(data.raw.inserter) do
    randomize_numerical_property{
      prototype = prototype,
      property = "rotation_speed",
      inertia_function = {
        ["type"] = "proportional",
        slope = 3
      },
      property_info = {
        round = {
          [2] = {
            modulus = 10 / (360 * 60)
          },
          [3] = {
            modulus = 100 / (360 * 60)
          }
        }
      }
    }

    randomize_numerical_property{
      prototype = prototype,
      property = "extension_speed",
      inertia_function = {
        ["type"] = "proportional",
        slope = 4
      }
    }
  end
end

---------------------------------------------------------------------------------------------------
-- randomize_inventory_sizes
---------------------------------------------------------------------------------------------------

local entity_inventory_names_to_modify = {
  ["artillery-turret"] = {"inventory_size"},
  container = {"inventory_size"},
  ["logistic-container"] = {"inventory_size"},
  ["infinity-container"] = {"inventory_size"},
  ["rocket-silo"] = {"rocket_result_inventory_size"},
  furnace = {"result_inventory_size"}, -- source_inventory_size can't be anything other than 1 anyways
  ["linked-container"] = {"inventory_size"},
  ["ammo-turret"] = {"inventory_size"},
  car = {"inventory_size"},
  ["artillery-wagon"] = {"inventory_size"},
  ["cargo-wagon"] = {"inventory_size"},
  ["spider-vehicle"] = {"inventory_size", "trash_inventory_size"}
}
local entity_energy_source_inventories_to_modify = {
  boiler = {"energy_source"},
  ["burner-generator"] = {"burner"},
  ["assembling-machine"] = {"energy_source"},
  ["rocket-silo"] = {"energy_source"},
  furnace = {"energy_source"},
  inserter = {"energy_source"},
  lab = {"energy_source"},
  ["mining-drill"] = {"energy_source"},
  pump = {"energy_source"},
  radar = {"energy_source"},
  reactor = {"energy_source"},
  car = {"burner", "energy_source"},
  locomotive = {"burner", "energy_source"},
  ["spider-vehicle"] = {"burner", "energy_source"}
}

-- DON'T: Randomize material_slots_count and robot_slots_count of roboport (already randomized elsewhere)
-- Don't modify the character's inventory speed for now
-- Note: item_with_inventory inventory size is not randomized out of fear of packing tape incompatibility
function randomize_inventory_sizes ()
  for class_name, inventory_property_list in pairs(entity_inventory_names_to_modify) do
    for _, prototype in pairs(data.raw[class_name]) do
      for _, property_name in pairs(inventory_property_list) do
        if prototype[property_name] then
          local property_info_to_use
          if prototype[property_name] == 0 then
            property_info_to_use = small_inventory_property_info
          elseif prototype[property_name] < 10 then
            property_info_to_use = small_nonempty_inventory_property_info
          else
            property_info_to_use = large_inventory_property_info
          end
          randomize_numerical_property{
            prototype = prototype,
            property = property_name,
            inertia_function = {
              {-4, 100},
              {4, 100},
              {10, 80},
              {65535, 524280}
            },
            property_info = property_info_to_use
          }
        end
      end
    end
  end

  for class_name, energy_source_property_list in pairs(entity_energy_source_inventories_to_modify) do
    for _, prototype in pairs(data.raw[class_name]) do
      for _, property_name in pairs(energy_source_property_list) do
        if prototype[property_name] then
          randomize_numerical_property{
            prototype = prototype,
            tbl = prototype[property_name],
            property = "fuel_inventory_size",
            inertia_function = {
              ["type"] = "constant",
              value = 40
            },
            property_info = small_nonempty_inventory_property_info
          }

          randomize_numerical_property{
            prototype = prototype,
            tbl = prototype[property_name],
            property = "burnt_inventory_size",
            inertia_function = {
              ["type"] = "constant",
              value = 40
            },
            property_info = small_inventory_property_info
          }
        end
      end
    end
  end
end

---------------------------------------------------------------------------------------------------
-- randomize_machine_pollution
---------------------------------------------------------------------------------------------------

-- Note: not everything that has an EnergySource property actually supports pollution
local polluting_machine_classes = {
  boiler = {"energy_source"},
  ["burner-generator"] = {"burner"}, -- Emissions on energy_source are ignored, they must be put on burner
  ["assembling-machine"] = {"energy_source"},
  ["rocket-silo"] = {"energy_source"},
  furnace = {"energy_source"},
  generator = {"energy_source"},
  ["mining-drill"] = {"energy_source"},
  reactor = {"energy_source"}
}

function randomize_machine_pollution ()
  for class_name, energy_source_list in pairs(polluting_machine_classes) do
    for _, prototype in pairs(data.raw[class_name]) do
      for _, energy_source_name in pairs(energy_source_list) do
        randomize_numerical_property{
          prototype = prototype,
          tbl = prototype[energy_source_name],
          property = "emissions_per_minute",
          round = {
            [3] = {
              modulus = 1
            }
          }
        }
      end
    end
  end
end

---------------------------------------------------------------------------------------------------
-- randomize_machine_speed
---------------------------------------------------------------------------------------------------

local machine_classes = {
  "assembling-machine",
  "rocket-silo",
  "furnace",
  "lab",
  "mining-drill",
  "offshore-pump"
}

function randomize_machine_speed ()
  for _, class in pairs(machine_classes) do
    for _, prototype in pairs(data.raw[class]) do
      randomize_numerical_property{
        prototype = prototype,
        property = "crafting_speed",
        inertia_function = {
          ["type"] = "proportional",
          slope = 2
        },
        property_info = {
          min = 0,
          round = {
            [2] = {
              modulus = 0.01
            }
          }
        }
      }

      -- TODO: Make burner mining drill swingier?
      randomize_numerical_property{
        prototype = prototype,
        property = "mining_speed",
        inertia_function = {
          ["type"] = "proportional",
          slope = 2
        },
        property_info = machine_speed_property_info
      }

      randomize_numerical_property{
        prototype = prototype,
        property = "pumping_speed",
        inertia_function = {
          ["type"] = "proportional",
          slope = 8
        },
        property_info = {
          min = 10 / 60,
          round = {
            [2] = {
              modulus = 10 / 60
            }
          }
        }
      }

      randomize_numerical_property{
        prototype = prototype,
        property = "researching_speed",
        inertia_function = {
          ["type"] = "proportional",
          slope = 10
        },
        property_info = machine_speed_property_info
      }
    end
  end
end

---------------------------------------------------------------------------------------------------
-- randomize_mining_productivity
---------------------------------------------------------------------------------------------------

local resource_success_chance = 0.8

local function reduce_product_chance (minable_properties)
  if minable_properties.result then
    local result_count = 1
    if minable_properties.count ~= nil then
      result_count = minable_properties.count
    end

    minable_properties.results = {{name = minable_properties.result, amount = result_count, probability = resource_success_chance}}
    minable_properties.result = nil
  else
    for _, result in pairs(minable_properties.results) do
      if result[1] then
        result.name = result[1]
        result.amount = 1
        if result[2] then
          result.amount = result[2]
        end

        result[1] = nil
        result[2] = nil
      end

      success_probability = resource_success_chance
      if result.probability then
        success_probability = success_probability * result.probability
      end

      result.probability = success_probability
    end
  end
end

function randomize_mining_productivity ()
  -- First randomize chances of getting resources down
  for _, resource_prototype in pairs(data.raw.resource) do
    reduce_product_chance(resource_prototype.minable)
  end

  -- Now randomize base productivity
  for _, mining_drill_prototype in pairs(data.raw["mining-drill"]) do
    if mining_drill_prototype.base_productivity ~= nil then
      mining_drill_prototype.base_productivity = mining_drill_prototype.base_productivity + 0.25
    else
      mining_drill_prototype.base_productivity = 0.25
    end

    randomize_numerical_property{
      prototype = mining_drill_prototype,
      property = "base_productivity"
    }
  end
end

---------------------------------------------------------------------------------------------------
-- randomize_module_slots
---------------------------------------------------------------------------------------------------

local machines_with_module_slots = {
  beacon = "module_specification",
  ["assembling-machine"] = "module_specification",
  ["rocket-silo"] = "module_specification",
  furnace = "module_specification",
  lab = "module_specification",
  ["mining-drill"] = "module_specification"
}

function randomize_module_slots ()
  for prototype_name, module_specification_property in pairs(machines_with_module_slots) do
    for _, prototype in pairs(data.raw[prototype_name]) do
      if prototype[module_specification_property] then
        if prototype[module_specification_property].module_slots == nil then
          prototype[module_specification_property].module_slots = 0
        end

        randomize_numerical_property{
          prototype = prototype,
          tbl = prototype[module_specification_property],
          property = "module_slots",
          inertia_function = {
            ["type"] = "constant",
            value = 10
          },
          property_info = small_inventory_property_info
        }
      end
    end
  end
end

---------------------------------------------------------------------------------------------------
-- randomize_pump_speed
---------------------------------------------------------------------------------------------------

function randomize_pump_speed ()
  for _, prototype in pairs(data.raw.pump) do
    -- TODO
  end
end

---------------------------------------------------------------------------------------------------
-- randomize_reactor_neighbour_bonus
---------------------------------------------------------------------------------------------------

function randomize_reactor_neighbour_bonus ()
  for _, prototype in pairs(data.raw.reactor) do
    if prototype.neighbour_bonus == nil then
      prototype.neighbour_bonus = 1
    end
    randomize_numerical_property{
      prototype = prototype,
      property = "neighbour_bonus",
      round = {
        min = 0,
        [2] = {
          modulus = 0.1
        }
      }
    }
  end
end

---------------------------------------------------------------------------------------------------
-- randomize_roboports
---------------------------------------------------------------------------------------------------

function randomize_roboports ()
  for _, prototype in pairs(data.raw.roboport) do
    randomize_numerical_property{
      prototype = prototype,
      property = "material_slots_count",
      inertia_function = {
        ["type"] = "constant",
        value = 40
      },
      property_info = inventory_slots_property_info
    }
    
    randomize_numerical_property{
      prototype = prototype,
      property = "robot_slots_count",
      inertia_function = {
        ["type"] = "constant",
        value = 40
      },
      property_info = inventory_slots_property_info
    }

    -- Randomize how quickly robots charge
    local charging_energy = 60 * util.parse_energy(prototype.charging_energy)
    charging_energy = randomize_numerical_property{
      dummy = charging_energy
    }
    prototype.charging_energy = charging_energy .. "W"

    -- TODO: Keep the charging offsets instead of discarding these vectors entirely (or just make them charge in a circle)
    -- Randomize how many robots can charge at the roboport
    if prototype.charging_station_count == nil or prototype.charging_station_count == 0 then
      prototype.charging_station_count = #prototype.charging_offsets
    end
    randomize_numerical_property{
      prototype = prototype,
      property = "charging_station_count",
      inertia_function = {
        ["type"] = "constant",
        value = 40
      },
      property_info = {
        min = 1,
        round = {
          [1] = {
            modulus = 1
          },
          [2] = {
            modulus = 1
          }
        }
      }
    }

    -- Randomize carefully in a way so that logistics_connection_distance >= logistics_radius
    if prototype.logistics_connection_distance == nil then
      prototype.logistics_connection_distance = prototype.logistics_radius
    end
    local logistics_distance_multiplier = randomize_numerical_property{
      dummy = (prototype.logistics_radius + prototype.logistics_connection_distance) / 2,
      property_info = {
        min = 1,
        round = {
          [2] = {
            modulus = 1
          },
          [3] = {
            modulus = 5
          }
        }
      }
    }
    randomize_numerical_property{
      prototype = prototype,
      property = "logistics_radius",
      property_info = {
        min = 1,
        max = logistics_distance_multiplier,
        round = {
          [2] = {
            modulus = 1
          },
          [3] = {
            modulus = 5
          }
        }
      }
    }
    randomize_numerical_property{
      prototype = prototype,
      property = "logistics_connection_distance",
      property_info = {
        min = logistics_distance_multiplier,
        round = {
          [2] = {
            modulus = 1
          },
          [3] = {
            modulus = 5
          }
        }
      }
    }

    randomize_numerical_property{
      prototype = prototype,
      property = "construction_radius",
      property_info = {
        min = 1,
        round = {
          [2] = {
            modulus = 1
          },
          [3] = {
            modulus = 5
          }
        }
      }
    }
  end
end

---------------------------------------------------------------------------------------------------
-- randomize_underground_belt_distance
---------------------------------------------------------------------------------------------------

function randomize_underground_belt_distance ()
  -- Underground belt
  for _, prototype in pairs(data.raw["underground-belt"]) do
    randomize_numerical_property{
      prototype = prototype,
      property = "max_distance",
      inertia_function = {
        {-4, 30},
        {4, 30},
        {8, 60},
        {255, 3000}
      },
      property_info = {
        min = 2, -- TODO: Allow underground distance of 1 on extreme mode
        max = 255,
        round = {
          [1] = {
            modulus = 1
          },
          [2] = {
            modulus = 1
          },
          [3] = {
            modulus = 1
          }
        }
      },
      randomization_params = {
        bias = 0.525, -- Make bias towards a little higher to fight against the offshoot to the left I was having
      }
    }
  end
end

---------------------------------------------------------------------------------------------------
-- randomize_vehicle_crash_damage
---------------------------------------------------------------------------------------------------

local vehicle_clases = {
  "car",
  "artillery-wagon",
  "cargo-wagon",
  "fluid-wagon",
  "locomotive",
  "spider-vehicle"
}

function randomize_vehicle_crash_damage ()
  for _, class_key in pairs(vehicle_clases) do
    for _, prototype in pairs(data.raw[class_key]) do
      local old_energy_per_hit_point = prototype.energy_per_hit_point
      randomize_numerical_property{
        prototype = prototype,
        property = "energy_per_hit_point",
        inertia_function = {
          ["type"] = "proportional",
          slope = 20
        }
      }

      -- Increase impact resistance for higher crash damages so that this isn't just a glass cannon
      if prototype.resistances ~= nil and prototype.resistances.impact ~= nil then
        prototype.resistances.impact.decrease = prototype.resistances.impact.decrease * prototype.energy_per_hit_point / old_energy_per_hit_point
      end
    end
  end
end

---------------------------------------------------------------------------------------------------
-- randomize_vehicle_speed
---------------------------------------------------------------------------------------------------

local vehicles_to_modify_speed = {
  car = "consumption",
  ["spider-vehicle"] = "movement_energy_consumption",
  locomotive = "max_power"
}

function randomize_vehicle_speed ()
  for class_key, speed_key in pairs(vehicles_to_modify_speed) do
    for _, prototype in pairs(data.raw[class_key]) do
      energy_as_number = 60 * util.parse_energy(prototype[speed_key])
      local new_energy_as_number = randomize_numerical_property{
        dummy = energy_as_number,
        prg_key = prg.get_key(prototype),
        inertia_function = {
          ["type"] = "proportional",
          slope = 10
        }
      }
      prototype[speed_key] = new_energy_as_number .. "W"

      -- Scale braking force with the new consumption for improved user experience
      if prototype.braking_power and energy_as_number ~= 0 then
        braking_power_as_number = 60 * util.parse_energy(prototype.braking_power)
        braking_power_as_number = braking_power_as_number * new_energy_as_number / energy_as_number
        prototype.braking_power = braking_power_as_number .. "W"
      elseif prototype.braking_force then
        prototype.braking_force = prototype.braking_force * new_energy_as_number / energy_as_number
      end

      if energy_as_number ~= 0 then
        -- Scale impact hitpoints taken *inversely* cuz that's a bit more balanced and funny
        prototype.energy_per_hit_point = prototype.energy_per_hit_point * new_energy_as_number / energy_as_number
      end
    end
  end
end