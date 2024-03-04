-- TODO: Make these ordered correctly in menu

data:extend({
  {
    setting_type = "startup",
    type = "bool-setting",
    name = "propertyrandomizer-chaos-mode",
    localised_name = "Chaos mode",
    localised_description = "Currently a WIP.",
    default_value = false,
    order = "aaa-chaos",
    hidden = true
  },
  {
    setting_type = "startup",
    type = "int-setting",
    name = "propertyrandomizer-seed",
    localised_name = "Random seed",
    localised_description = "Changing this will change how everything is randomized.",
    default_value = 528,
    order = "aab-seed"
  },
  {
    setting_type = "startup",
    type = "double-setting",
    name = "propertyrandomizer-bias",
    localised_name = "Bias [0.45 - 0.55] (0.45 means VERY bad)",
    localised_description = "Higher values mean more in your favor/easier.",
    default_value = 0.5,
    minimum_value = 0.45,
    maximum_value = 0.55,
    order = "ab-bias"
  },
  {
    setting_type = "startup",
    type = "double-setting",
    name = "propertyrandomizer-chaos",
    localised_name = "Chaos",
    localised_description = "Higher numbers result in more swinginess/chaos. Numbers past 2 not tested and may break the game.",
    default_value = 1,
    minimum_value = 0.1,
    maximum_value = 4,
    order = "ab-bias"
  },
  {
    setting_type = "startup",
    type = "string-setting",
    name = "propertyrandomizer-rounding-mode",
    localised_name = "Rounding mode",
    localised_description = "How round would you like your numbers?",
    default_value = "round-ish",
    allowed_values = {
      "round-est",
      "round-ish",
      "raw and unrounded"
    },
    order = "ac-rounding"
  },
  {
    setting_type = "startup",
    type = "bool-setting",
    name = "propertyrandomizer-belt-sync",
    localised_name = "Sync belt tiers",
    localised_description = "Make belts of the same tier (i.e.- yellow belt/underground/splitter) have the same speed.",
    default_value = "true",
    order = "ad-beltsync"
  },
  {
    setting_type = "startup",
    type = "bool-setting",
    name = "propertyrandomizer-character-values-midgame",
    localised_name = "Randomize character values",
    localised_description = "Randomize character crafting speed and walking speed every 30 minutes",
    default_value = true,
    order = "b-basic-character-values"
  },
  {
    setting_type = "startup",
    type = "bool-setting",
    name = "propertyrandomizer-crafting-times",
    localised_name = "Randomize recipe crafting times",
    localised_description = "Turn this off if you're using something else that randomizes recipes",
    default_value = true,
    order = "b-basic-crafting-times"
  },
  {
    setting_type = "startup",
    type = "bool-setting",
    name = "propertyrandomizer-logistic",
    localised_name = "Randomize logistics",
    localised_description = "Randomize speeds of belts/inserters, lengths of underground belts, supply area of electric poles, and other logistical things.",
    default_value = true,
    order = "b-basic-logistic"
  },
  {
    setting_type = "startup",
    type = "bool-setting",
    name = "propertyrandomizer-military",
    localised_name = "Randomize military",
    localised_description = "Randomize gun shooting speeds, bonus damage, armor, enemy health, etc. Turn this off if you're having troubles with biter difficulty.",
    default_value = true,
    order = "b-basic-military"
  },
  {
    setting_type = "startup",
    type = "bool-setting",
    name = "propertyrandomizer-production",
    localised_name = "Randomize production",
    localised_description = "Randomize production capabilities of machines, like speed and pollution.",
    default_value = true,
    order = "b-basic-production"
  },
  {
    setting_type = "startup",
    type = "bool-setting",
    name = "propertyrandomizer-storage",
    localised_name = "Randomize storage",
    localised_description = "Randomize properties that have to do with storage/inventories, such as inventory slots and stack sizes.",
    default_value = true,
    order = "b-basic-storage"
  },
  {
    setting_type = "startup",
    type = "bool-setting",
    name = "propertyrandomizer-tech-costs",
    localised_name = "Randomize technology costs",
    default_value = true,
    order = "b-basic-tech"
  },
  {
    setting_type = "startup",
    type = "bool-setting",
    name = "propertyrandomizer-entity-sizes",
    localised_name = "Randomize entity sizes",
    localised_description = "Currently only works on some entities.",
    default_value = false,
    order = "c-advanced-entity-sizes"
  },
  {
    setting_type = "startup",
    type = "bool-setting",
    name = "propertyrandomizer-icons",
    localised_name = "Advanced: Randomize icons",
    default_value = false,
    order = "c-advanced-icons"
  },
  {
    setting_type = "startup",
    type = "bool-setting",
    name = "propertyrandomizer-inserter-position",
    localised_name = "Advanced: Randomize inserter positions",
    localised_description = "Any given inserter has a small chance to become a long inserter, side inserter, or a variety of other cursed options.",
    default_value = false,
    order = "c-advanced-inserter-offsets"
  },
  {
    setting_type = "startup",
    type = "bool-setting",
    name = "propertyrandomizer-military-advanced",
    localised_name = "Advanced: Randomize military more",
    localised_description = "Makes some more questionable randomizations to the military side of the game that may wreck balance or are untested.",
    default_value = false,
    order = "c-advanced-military"
  },
  {
    setting_type = "startup",
    type = "bool-setting",
    name = "propertyrandomizer-mining-drill-productivity",
    localised_name = "Advanced: Randomize mining drill productivity",
    localised_description = "This also turns down the chance of a resource being successfully mined to balance the increased machine productivity.",
    default_value = false,
    order = "c-advanced-mining-drill-productivity"
  },
  {
    setting_type = "startup",
    type = "bool-setting",
    name = "propertyrandomizer-mining-offsets",
    localised_name = "Advanced: Randomize mining offsets",
    localised_description = "Randomize where the mining drills drop off their ore.",
    default_value = false,
    order = "c-advanced-mining-offsets"
  },
  {
    setting_type = "startup",
    type = "bool-setting",
    name = "propertyrandomizer-sounds",
    localised_name = "Advanced: Randomize all the sounds... Good luck",
    default_value = false,
    order = "c-advanced-sounds"
  },
  {
    setting_type = "startup",
    type = "bool-setting",
    name = "propertyrandomizer-misc-properties",
    localised_name = "(Almost) everything else",
    localised_description = "I see you got some extra properties to randomize there. Wanna fix that?",
    default_value = false,
    order = "y-the-rest"
  },
  {
    setting_type = "startup",
    type = "string-setting",
    name = "propertyrandomizer-custom-overrides",
    localised_name = "Custom override",
    localised_description = "You can get more specific with the randomizations you'd like here. See mod page for details.",
    default_value = "blop,foo",
    allow_blank = true,
    order = "z-custom-override",
    hidden = true
  }
  --[[TODO:
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