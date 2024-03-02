require("config")

require("random-utils/random")
require("random-utils/randomization-algorithms")

prg.seed(seed_setting)

local preset_controls = {}

for _, autoplace_control in pairs(data.raw["autoplace-control"]) do
  local curr_control = {}
  if autoplace_control.richness ~= nil then
    curr_control.richness = randomize_numerical_property({prg_key = prg.get_key(autoplace_control)})
  end
  curr_control.size = randomize_numerical_property({prg_key = prg.get_key(autoplace_control)})
  curr_control.frequency = randomize_numerical_property({prg_key = prg.get_key(autoplace_control)})

  preset_controls[autoplace_control.name] = curr_control
end

local pollution_settings = data.raw["map-settings"]["map-settings"].pollution
local evolution_settings = data.raw["map-settings"]["map-settings"].enemy_evolution
local expansion_settings = data.raw["map-settings"]["map-settings"].enemy_expansion
local difficulty_settings = data.raw["map-settings"]["map-settings"].difficulty_settings

-- TODO: PRG keys?
local key_table = {class = "map-gen-presets", name = "default"}
data.raw["map-gen-presets"].default["random"] = {
  order = "b",
  basic_settings = {
    terrain_segmentation = randomize_numerical_property(),
    water = randomize_numerical_property(),
    autoplace_controls = preset_controls,
    starting_area = randomize_numerical_property()
    -- TODO: Cliffs
  },
  advanced_settings = {
    pollution = {
      diffusion_ratio = math.min(0.25, randomize_numerical_property() * pollution_settings.diffusion_ratio),
      ageing = math.max(0.1, randomize_numerical_property() * pollution_settings.ageing),
      min_pollution_to_damage_trees = randomize_numerical_property() * pollution_settings.min_pollution_to_damage_trees,
      pollution_restored_per_tree_damage = randomize_numerical_property() * pollution_settings.pollution_restored_per_tree_damage,
      enemy_attack_pollution_consumption_modifier = math.max(0.1, pollution_settings.enemy_attack_pollution_consumption_modifier)
    },
    enemy_evolution = {
      time_factor = randomize_numerical_property() * evolution_settings.time_factor,
      destroy_factor = randomize_numerical_property() * evolution_settings.destroy_factor,
      pollution_factor = randomize_numerical_property() * evolution_settings.pollution_factor
    },
    enemy_expansion = {
      max_expansion_distance = randomize_numerical_property() * expansion_settings.max_expansion_distance,
      settler_group_min_size = randomize_numerical_property() * expansion_settings.settler_group_min_size,
      settler_group_max_size = randomize_numerical_property() * expansion_settings.settler_group_max_size,
      min_expansion_cooldown = randomize_numerical_property() * expansion_settings.min_expansion_cooldown,
      max_expansion_cooldown = randomize_numerical_property() * expansion_settings.max_expansion_cooldown
    },
    difficulty_settings = {
      technology_price_multiplier = randomize_numerical_property() * difficulty_settings.technology_price_multiplier
    }
  }
}