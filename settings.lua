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
    localised_name = "Chaos [0.1 - 4]",
    localised_description = "Higher numbers result in more swinginess/chaos. Numbers past 2 not tested for balance.",
    default_value = 1,
    minimum_value = 0.1,
    maximum_value = 4,
    order = "ab-chaos"
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
    order = "ac-rounding",
    hidden = true -- TODO: FIX
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
    name = "propertyrandomizer-upgrade-line-preservation",
    localised_name = "Preserve upgrade lines",
    localised_description = "Generally attempt to make better things actually better. For example, assembling machine 2's will be guaranteed higher crafting speeds than assembling machine 1's.",
    default_value = "true",
    order = "ae-upgrade-line-preservation"
  },
  {
    setting_type = "startup",
    type = "bool-setting",
    name = "propertyrandomizer-character-values-midgame",
    localised_name = "Randomize character values",
    localised_description = "Randomize character crafting speed and walking speed every 30 minutes.",
    default_value = true,
    order = "b-basic-character-values"
  },
  {
    setting_type = "startup",
    type = "bool-setting",
    name = "propertyrandomizer-crafting-times",
    localised_name = "Randomize recipe crafting times",
    localised_description = "Turn this off if you're using something else that randomizes recipes.",
    default_value = true,
    order = "b-basic-crafting-times"
  },
  --[[{
    setting_type = "startup",
    type = "bool-setting",
    name = "propertyrandomizer-extra",
    localised_name = "Randomize extras",
    localised_description = "Misc. things that are on by default, like achievement requirements.",
    default_value = true,
    order = "b-basic-extra"
  },]] -- TODO: Decide whether I want this
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
    localised_description = "Randomize gun shooting speeds, bonus damage, etc. Turn this off if you're having troubles with biter difficulty.",
    default_value = true,
    order = "b-basic-military"
  },
  {
    setting_type = "startup",
    type = "bool-setting",
    name = "propertyrandomizer-production",
    localised_name = "Randomize production",
    localised_description = "Randomize production capabilities of machines, like speed and module slots.",
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
  --[[{
    setting_type = "startup",
    type = "bool-setting",
    name = "propertyrandomizer-cliff-sizes",
    localised_name = "Advanced: Randomize cliff sizes",
    localised_description = "Different cliffs will have different sizes.",
    default_value = false,
    order = "c-advanced-cliff-sizes"
  },]] -- Going to be override only
  --[[{
    setting_type = "startup",
    type = "bool-setting",
    name = "propertyrandomizer-icons",
    localised_name = "Advanced: Randomize icons",
    default_value = false,
    order = "c-advanced-icons"
  },]] -- Icons is going to be override only from now on
  {
    setting_type = "startup",
    type = "bool-setting",
    name = "propertyrandomizer-inserter-position",
    localised_name = "Advanced: Randomize inserter positions",
    localised_description = "Any given inserter has a chance to become a long inserter, side inserter, or a variety of other cursed options.",
    default_value = false,
    order = "c-advanced-inserter-offsets"
  },
  {
    setting_type = "startup",
    type = "bool-setting",
    name = "propertyrandomizer-military-advanced",
    localised_name = "Advanced: Randomize military more",
    localised_description = "Makes some more questionable randomizations to the military side of the game, like biter speed and more.",
    default_value = false,
    order = "c-advanced-military"
  },
  {
    setting_type = "startup",
    type = "bool-setting",
    name = "propertyrandomizer-production-advanced",
    localised_name = "Advanced: Randomize production more",
    localised_description = "Randomize more production-based features. Especially impacts power generation/consumption.",
    default_value = false,
    order = "c-advanced-production"
  },
  --[[{
    setting_type = "startup",
    type = "bool-setting",
    name = "propertyrandomizer-mining-drill-productivity",
    localised_name = "Advanced: Randomize mining drill productivity",
    localised_description = "This also turns down the chance of a resource being successfully mined to balance the increased machine productivity.",
    default_value = false,
    order = "c-advanced-mining-drill-productivity",
    hidden = true -- TODO: Make just an override
  },]]
  --[[{
    setting_type = "startup",
    type = "bool-setting",
    name = "propertyrandomizer-mining-offsets",
    localised_name = "Advanced: Randomize mining offsets",
    localised_description = "Randomize where the mining drills drop off their ore.",
    default_value = false,
    order = "c-advanced-mining-offsets"
  },]]
  --[[{
    setting_type = "startup",
    type = "bool-setting",
    name = "propertyrandomizer-sounds",
    localised_name = "Advanced: Randomize all the sounds... Good luck",
    default_value = false,
    order = "c-advanced-sounds"
  },]] -- Override only
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
    localised_name = "Custom overrides [See Tooltip]",
    localised_description = "For extra fancy customization. See override document on the mod page for details: mods.factorio.com/mod/propertyrandomizer",
    default_value = "",
    allow_blank = true,
    order = "z-custom-override",
    hidden = false
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