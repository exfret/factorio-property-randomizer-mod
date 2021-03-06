local property_info = {}

property_info.ammo_type_range_modifier = {
  round = {
    [2] = {
      modulus = 0.1
    }
  }
}

property_info.attack_parameters_cooldown = {
  --[[round = {
    [2] = {
      modulus = 6
    },
    [3] = {
      left_digits_to_keep = 0,
      modulus = 6
    }
  }]] -- Since the display value is *inversely proportional* to the actual value, rounding properly will be a little harder
}

property_info.attack_parameters_range = {
  round = {
    [2] = {
      modulus = 0.1
    },
    [3] = {
      modulus = 1
    }
  }
}

property_info.belt_speed = {
  min = 0.00390625,
  max = 255,
  round = {
    [1] = {
      modulus = 0.00390625
    },
    [2] = {
      modulus = 0.00390625 * 2.0
    },
    [3] = { -- TODO: Make left_digits_to_keep not apply here (or other places with weird moduli)
      modulus = 0.00390625 * 4.0
    }
  }
}

property_info.bot_speed = {
  min = 0.1 / 216,
  round = {
    [2] = {
      modulus = 1 / 216
    }
  }
}

property_info.character_respawn_time = {
  round = {
    [2] = {
      round = 60
    }
  }
}

property_info.character_corpse_time_to_live = {
  round = {
    [2] = {
      modulus = 3600
    }
  }
}

property_info.charging_station_count = {
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

property_info.consumption_effect = {
  min = -0.8,
  round = {
    [2] = {
      modulus = 0.01
    },
    [3] = {
      modulus = 0.1
    }
  }
}

property_info.discrete = {
  round = {
    [1] = {
      modulus = 1
    },
    [2] = {
      modulus = 1
    }
  }
}

property_info.discrete_positive = {
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

property_info.effectivity = {
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

-- TODO: Only apply min if the property was originally zero
property_info.energy = {
  min = 0.01,
  round = {
    [2] = {
      left_digits_to_keep = 3,
      modulus = 1
    }
  }
}

property_info.equipment_grid = {
  round = {
    [1] = {
      modulus = 1
    }
  }
}

property_info.fluid_emissions_multiplier = {
  round = {
    [2] = {
      modulus = 0.01
    },
    [3] = {
      modulus = 0.1
    }
  }
}

property_info.fluid_usage = {
  min = 0.1,
  round = {
    [2] = {
      left_digits_to_keep = 3
    },
    [3] = {
      modulus = 1
    }
  }
}

property_info.gate_opening_speed = {
  min = 0.01 / 60
}

property_info.gun_shooting_range = {
  min = 0.1,
  round = {
    [2] = {
      modulus = 1
    }
  }
}

property_info.inserter_rotation_speed = {
  round = {
    [2] = {
      modulus = 10 / (360 * 60)
    },
    [3] = {
      left_digits_to_keep = 0,
      modulus = 100 / (360 * 60)
    }
  }
}

property_info.inventory_slots = {
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

property_info.large_inventory = {
  min = 5,
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

property_info.machine_pollution = {
  round = {
    [3] = {
      modulus = 1
    }
  }
}

property_info.machine_speed = {
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

property_info.magazine_size = {
  min = 1,
  round = {
    [2] = {
      modulus = 1
    }
  }
}

property_info.max_health = {
  min = 1,
  round = {
    [1] = { -- Due to weird display bugs, I'm rounding even in no rounding mode
      modulus = 1
    },
    [2] = {
      modulus = 5
    }
  }
}

property_info.mining_drill_dropoff = {
  max_factor = 1
}

property_info.neighbour_bonus = {
  round = {
    min = 0,
    [2] = {
      modulus = 0.1
    }
  }
}

property_info.offshore_pumping_speed = {
  min = 10 / 60,
  round = {
    [2] = {
      modulus = 10 / 60
    }
  }
}

property_info.pollution_effect = {
  min = -1,
  round = {
    [2] = {
      modulus = 0.01
    }
  }
}

property_info.power = {
  min = 0.01,
  round = {
    [2] = {
      left_digits_to_keep = 3,
      modulus = 0.01
    }
  }
}

property_info.productivity_effect = {
  min = 0,
  round = {
    [2] = {
      modulus = 0.01
    }
  }
}

property_info.pump_pumping_speed = {
  min = 1 / 60,
  round = {
    [2] = {
      modulus = 10 / 60,
      left_digits_to_keep = 3
    }
  }
}

property_info.recipe_crafting_time = {
  min = 0.01,
  round = {
    [2] = {
      modulus = 0.1
    }
  }
}

property_info.repair_tool_speed = {
  min = 0.1,
  round = {
    [2] = {
      modulus = 0.1
    }
  }
}

property_info.researching_speed = {
  ["type"] = "proportional",
  slope = 10,
  round = {
    [2] = {
      modulus = 0.1
    }
  }
}

property_info.resistance_decrease = {
  round = {
    [2] = {
      modulus = 1
    }
  }
}

property_info.resistance_percent = {
  round = {
    [2] = {
      modulus = 1
    },
    [3] = {
      modulus = 10
    }
  }
}

property_info.roboport_radius = {
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

property_info.small_inventory = {
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

property_info.small_nonempty_inventory = {
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

property_info.speed_effect = {
  min = -1,
  round = {
    [2] = {
      modulus = 0.01
    }
  }
}

property_info.stack_size = {
  min = 1,
  min_factor = 2 / 5,
  round = {
    [1] = {
      modulus = 1
    },
    [2] = {
      modulus = 5
    }
  }
}

property_info.supply_area = {
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

property_info.tech_time = {
  min = 0.01,
  round = {
    [2] = {
      modulus = 1
    }
  }
}

property_info.temperature = {
  round = {
    [2] = {
      modulus = 1
    }
  }
}

property_info.tile_walking_speed_modifier = {
  min = 0.01,
  round = {
    [2] = {
      modulus = 0.01
    },
    [3] = {
      modulus = 0.1
    }
  }
}

property_info.tool_durability = {
  min = 1,
  round = {
    [2] = {
      modulus = 1
    }
  }
}

property_info.trigger_damage = {
  round = {
    [2] = {
      modulus = 0.1
    },
    [3] = {
      modulus = 1
    }
  }
}

property_info.underground_belt_length = {
  min = 2, -- TODO: Allow underground distance of 1 on extreme mode
  max = 255,
  round = {
    [1] = {
      modulus = 1
    },
    [2] = {
      modulus = 1
    }
  }
}

property_info.wire_distance = {
  min = 1.5,
  max = 64,
  round = {
    [3] = {
      modulus = 1
    }
  }
}

return property_info