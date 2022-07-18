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
    name = "propertyrandomizer-belt-sync",
    localised_name = "Sync belt tiers",
    localised_description = "Make belts of the same tier (i.e.- yellow belt/underground/splitter) have the same speed.",
    default_value = "true",
    order = "ac"
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
    default_value = false,
    hidden = true
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
    name = "propertyrandomizer-belt-speeds",
    localised_name = "Randomize belt speeds",
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
    name = "propertyrandomizer-crafting-machine-speed",
    localised_name = "Randomize crafting machine speeds",
    localised_description = "Randomize the speed of anything that crafts stuff, including furnaces, chemical plants, the rocket silo, etc.",
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
    name = "propertyrandomizer-gun-damage-modifier",
    localised_name = "Randomize personal gun damage modifier",
    localised_description = "Add a random modifier that can either be a penalty or bonus to the attack damage of guns",
    default_value = true
  },
  {
    setting_type = "startup",
    type = "bool-setting",
    name = "propertyrandomizer-gun-range",
    localised_name = "Randomize personal gun shooting range",
    localised_description = "This only randomizes personal guns (or vehicle guns), not turrets.",
    default_value = true
  },
  {
    setting_type = "startup",
    type = "bool-setting",
    name = "propertyrandomizer-gun-speed",
    localised_name = "Randomize personal gun shooting speed",
    localised_description = "This only randomizes personal guns (or vehicle guns), not turrets.",
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
    name = "propertyrandomizer-inserter-speed",
    localised_name = "Randomize inserter rotation speed",
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
    name = "propertyrandomizer-lab-research-speed",
    localised_name = "Randomize lab research speed",
    default_value = false
  },
  {
    setting_type = "startup",
    type = "bool-setting",
    name = "propertyrandomizer-machine-pollution",
    localised_name = "Randomize machine pollution",
    localised_description = "Randomize how much pollution is produced by machines.",
    default_value = true
  },
  {
    setting_type = "startup",
    type = "bool-setting",
    name = "propertyrandomizer-mining-speeds",
    localised_name = "Randomize mining speeds",
    localised_description = "Randomize the speed of mining drills, pumpjacks, and any other entities that mine resources.",
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
    name = "propertyrandomizer-offshore-pump-speed",
    localised_name = "Randomize offshore pumping speed",
    default_value = true
  },
  {
    setting_type = "startup",
    type = "bool-setting",
    name = "propertyrandomizer-pump-pumping-speed",
    localised_name = "Randomize the pump's speed",
    default_value = true
  },
  {
    setting_type = "startup",
    type = "bool-setting",
    name = "propertyrandomizer-tech-costs",
    localised_name = "Randomize technology costs",
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
    localised_name = "Randomize character values midgame",
    localised_description = "Randomize character crafting speed and walking speed every 10 minutes",
    default_value = false
  },
  {
    setting_type = "startup",
    type = "bool-setting",
    name = "propertyrandomizer-crafting-times",
    localised_name = "Randomize crafting times",
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
    name = "propertyrandomizer-fuel-inventory-slots",
    localised_name = "Randomize fuel inventory slots",
    localised_description = "Randomize the amount of inventory slots for fuel. For example, burner mining drills may now be able to hold two stacks of coal instead of just one.",
    default_value = false
  },
  {
    setting_type = "startup",
    type = "bool-setting",
    name = "propertyrandomizer-inserter-position",
    localised_name = "Randomize inserter positions",
    localised_description = "Any given inserter has a small chance to become a long inserter, side inserter, or a variety of other cursed options.",
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
    name = "propertyrandomizer-mining-drill-dropoff",
    localised_name = "Randomize mining drill dropoff location",
    localised_description = "Randomize where mining drills place the items they mine... be ready to completely change your mining layouts. Note: May not be compatible with some mods that add new miners in a nonstandard way.",
    default_value = false
  },
  {
    setting_type = "startup",
    type = "bool-setting",
    name = "propertyrandomizer-misc-properties",
    localised_name = "(Almost) everything else",
    localised_description = "Yo dawg, I see you got some extra properties to randomize there. Wanna fix that?",
    default_value = false
  }
  --[[, TODO
  {
    setting_type = "startup",
    type = "bool-setting",
    name = "propertyrandomizer-switch-projectiles",
    localised_name = "Switch projectiles",
    default_value = false
  }]]
  --[[{
    setting_type = "startup",
    type = "bool-setting",
    name = "propertyrandomizer-enemy-spawning",
    localised_name = "Randomize enemy spawning",
    default_value = false
  },]]
})