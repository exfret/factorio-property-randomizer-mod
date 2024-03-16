if compatibilities == nil then
  compatibilities = {}
end

-- Special inertia function and such values since we know we're in vanilla
compatibilities.vanilla = {
  -- Armor: just randomize it all at once (there aren't many mods that add side-grades to armor)
  -- Ammo: Randomize individual ammo groups

  -- TODO: Important intermediates

  ["custom_inertia-function-tables"] = { -- TODO: Add these to actual autoplace
    autoplace = {
      ["iron-ore"] = {
        type = "proportional",
        slope = DEFAULT_INERTIA_FUNCTION_SLOPE -- Iron ore is already changed enough NOTE: This probably should be lower even
      },
      ["copper-ore"] = {
        type = "proportional",
        slope = DEFAULT_INERTIA_FUNCTION_SLOPE -- Copper ore is already changed enough
      },
      ["stone"] = {
        type = "proportional",
        slope = 6 -- Stone can be changed a little more
      },
      ["coal"] = {
        type = "proportional",
        slope = 10 -- Coal can go crazy since there are other options, like solid fuel
      }
    }
  },
  ["upgrade-lines"] = { -- upgrade-lines = {list of {group_name, prototypes = list of prototypes, chains = list of chains}}
    {
      group_name = "assembling-machines",
      prototypes = {
        asm_1 = data.raw["assembling-machine"]["assembling-machine-1"],
        asm_2 = data.raw["assembling-machine"]["assembling-machine-2"],
        asm_3 = data.raw["assembling-machine"]["assembling-machine-3"]
      },
      chains = {
        {"asm_1", "asm_2", "asm_3"}
      }
    },
    {
      group_name = "transport-belts",
      prototypes = {
        belt_1 = data.raw["transport-belt"]["transport-belt"],
        belt_2 = data.raw["transport-belt"]["fast-transport-belt"],
        belt_3 = data.raw["transport-belt"]["express-transport-belt"]
      },
      chains = {
        {"belt_1", "belt_2", "belt_3"}
      }
    },
    {
      group_name = "underground-belts",
      prototypes = {
        belt_1 = data.raw["underground-belt"]["underground-belt"],
        belt_2 = data.raw["underground-belt"]["fast-underground-belt"],
        belt_3 = data.raw["underground-belt"]["express-underground-belt"]
      },
      chains = {
        {"belt_1", "belt_2", "belt_3"}
      }
    },
    {
      group_name = "splitters",
      prototypes = {
        belt_1 = data.raw["splitter"]["splitter"],
        belt_2 = data.raw["splitter"]["fast-splitter"],
        belt_3 = data.raw["splitter"]["express-splitter"]
      },
      chains = {
        {"belt_1", "belt_2", "belt_3"}
      }
    },
    {
      group_name = "electric-poles",
      prototypes = {
        small = data.raw["electric-pole"]["small-electric-pole"],
        med = data.raw["electric-pole"]["medium-electric-pole"],
        big = data.raw["electric-pole"]["big-electric-pole"],
        substation = data.raw["electric-pole"]["substation"]
      },
      chains = {
        {"small", "med"},
        {"small", "big"},
        {"med", "substation"},
        {"big", "substation"}
      }
    },
    {
      group_name = "boilers",
      prototypes = {
        boiler = data.raw["boiler"]["boiler"],
        heat_exchanger = data.raw["boiler"]["heat-exchanger"],
      },
      chains = {
        {"boiler", "heat-exchanger"}
      }
    },
    {
      group_name = "steam-generators",
      prototypes = {
        steam_engine = data.raw["generator"]["steam-engine"],
        steam_turbine = data.raw["generator"]["steam-turbine"]
      },
      chains = {
        {"steam_engine", "steam_turbine"}
      }
    },
    {
      group_name = "ammo",
      prototypes = {
        ammo = data.raw["ammo"]["firearm-magazine"],
        piercing = data.raw["ammo"]["piercing-rounds-magazine"]
        uranium = data.raw["ammo"]["uranium-rounds-magazine"],
        cannon = data.raw["ammo"]["cannon-shell"],
        explosive_cannon = data.raw["ammo"]["explosive-cannon-shell"],
        uranium_cannon = data.raw["ammo"]["uranium-cannon-shell"],
        rocket = data.raw["ammo"]["rocket"],
        explosive_rocket = data.raw["ammo"]["explosive-rocket"],
        shotgun = data.raw["ammo"]["shotgun-shell"],
        piercing_shotgun = data.raw["ammo"]["piercing-shotgun-shell"] -- Artillery shell, flamethrower ammo, and atomic bomb are different enough to not do
      },
      chains = {
        {"ammo", "piercing", "uranium"},
        {"piercing", "rocket", "explosive_rocket"},
        {"ammo", "shotgun", "piercing_shotgun"},
        {"piercing", "cannon", "explosive_cannon", "uranium_cannon"}
      }
    },
    {
      -- TODO
    }
  }
}