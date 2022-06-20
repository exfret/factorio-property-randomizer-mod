-- TODO: Make these ordered correctly in menu

data:extend({
  {
    setting_type = "startup",
    type = "int-setting",
    name = "propertyrandomizer-seed",
    localised_name = "Random seed",
    localised_description = "Changing this will change how everything is randomized",
    default_value = 1,
    order = "aa"
  },
  {
    setting_type = "startup",
    type = "string-setting",
    name = "propertyrandomizer-rounding-mode",
    localised_name = "Rounding mode",
    localised_description = "How round would you like your numbers?",
    default_value = "round-ish",
    allowed_values = {
      "murder the rightmost digits mercilessly",
      "round-ish",
      "leave 'em raw and unrounded"
    },
    order = "ab"
  },
  {
    setting_type = "startup",
    type = "bool-setting",
    name = "propertyrandomizer-ammo",
    localised_name = "Randomize ammo",
    default_value = true
  },
  {
    setting_type = "startup",
    type = "bool-setting",
    name = "propertyrandomizer-armor-and-equipment",
    localised_name = "Randomize armor and equipment",
    default_value = true
  },
  {
    setting_type = "startup",
    type = "bool-setting",
    name = "propertyrandomizer-beacons",
    localised_name = "Randomize beacons",
    default_value = true
  },
  {
    setting_type = "startup",
    type = "bool-setting",
    name = "propertyrandomizer-bots",
    localised_name = "Randomize bots",
    default_value = true
  },
  {
    setting_type = "startup",
    type = "bool-setting",
    name = "propertyrandomizer-capsules",
    localised_name = "Randomize capsules",
    localised_description = "Capsules are pretty much anything that you 'use' by clicking, for example grenades, fish, defender capsules, etc.",
    default_value = true
  },
  {
    setting_type = "startup",
    type = "bool-setting",
    name = "propertyrandomizer-crafting-times",
    localised_name = "Randomize crafting times",
    default_value = true
  },
  {
    setting_type = "startup",
    type = "bool-setting",
    name = "propertyrandomizer-electric-pole",
    localised_name = "Randomize electric poles",
    default_value = true
  },
  {
    setting_type = "startup",
    type = "bool-setting",
    name = "propertyrandomizer-energy-value",
    localised_name = "Randomize energy/power values",
    localised_description = "Randomize anything to do with energy or power values (power production, fuel values, etc.)",
    default_value = true
  },
  {
    setting_type = "startup",
    type = "bool-setting",
    name = "propertyrandomizer-health-properties",
    localised_name = "Randomize health properties",
    default_value = true
  },
  {
    setting_type = "startup",
    type = "bool-setting",
    name = "propertyrandomizer-inventory-properties",
    localised_name = "Randomize inventory properties",
    localised_description = "Randomize properties that have to do with inventories, such as inventory slots and stack sizes.",
    default_value = true
  },
  {
    setting_type = "startup",
    type = "bool-setting",
    name = "propertyrandomizer-logistic-speed",
    localised_name = "Randomize logistic building speed",
    localised_description = "Randomize how fast most logistical buildings are, like belt speed and inserter rotation speed.",
    default_value = true
  },
  {
    setting_type = "startup",
    type = "bool-setting",
    name = "propertyrandomizer-machine-pollution",
    localised_name = "Randomize machine pollution",
    localised_description = "Randomize how much pollution is produced by machines.",
    default_value = true
  },
  { -- TODO: Add localised names and descriptions to these
    setting_type = "startup",
    type = "bool-setting",
    name = "propertyrandomizer-machine-speed",
    localised_name = "Randomize machine speed",
    localised_description = "Randomize how fast machines work, such as the crafting speed of a chemical plant.",
    default_value = true
  },
  {
    setting_type = "startup",
    type = "bool-setting",
    name = "propertyrandomizer-module-effects",
    localised_name = "Randomize module effects",
    default_value = true
  },
  {
    setting_type = "startup",
    type = "bool-setting",
    name = "propertyrandomizer-module-slots",
    localised_name = "Randomize number of module slots",
    default_value = true
  },
  {
    setting_type = "startup",
    type = "bool-setting",
    name = "propertyrandomizer-underground-distance",
    localised_name = "Randomize underground distance",
    localised_description = "Randomize underground belt AND pipe distance.",
    default_value = true
  },
  {
    setting_type = "startup",
    type = "bool-setting",
    name = "propertyrandomizer-vehicles",
    localised_name = "Randomize vehicles",
    default_value = true
  },
  {
    setting_type = "startup",
    type = "bool-setting",
    name = "propertyrandomizer-character-values-midgame",
    localise_name = "Randomize character values midgame",
    localised_description = "Randomize character crafting speed and walking speed every 10 minutes",
    default_value = false
  },
  {
    setting_type = "startup",
    type = "bool-setting",
    name = "propertyrandomizer-enemy-spawning",
    localised_name = "Randomize enemy spawning",
    default_value = false
  },
  {
    setting_type = "startup",
    type = "bool-setting",
    name = "propertyrandomizer-entity-interaction-speed",
    localised_name = "Randomize interaction speeds",
    default_value = false
  },
  {
    setting_type = "startup",
    type = "bool-setting",
    name = "propertyrandomizer-inserter-position",
    localised_name = "Randomize inserter positions",
    default_value = false
  },
  {
    setting_type = "startup",
    type = "bool-setting",
    name = "propertyrandomizer-mining-drill-productivity",
    localised_name = "Randomize mining drill productivity",
    localised_description = "This also turns down the chance of a resource being successfully mined to balance the increased machine productivity.",
    default_value = false
  },
  {
    setting_type = "startup",
    type = "bool-setting",
    name = "propertyrandomizer-misc-properties",
    localised_name = "(Almost) everything else",
    localised_description = "Yo dawg, I see you got some extra properties to randomize there. Wanna fix that?",
    default_value = false
  }--[[, TODO
  {
    setting_type = "startup",
    type = "bool-setting",
    name = "propertyrandomizer-switch-projectiles",
    localised_name = "Switch projectiles",
    default_value = false
  }]]
})