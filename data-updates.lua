require("config")

require("random-utils/random")
require("random-utils/randomization-algorithms")

prg.seed(seed_setting)

local tree_pollution_modifier = randomize_numerical_property()
local expansion_modifier = randomize_numerical_property()

-- TODO: work on modded ores, or just autoplace controls of any type
-- TODO: Add correct prg_keys
--[[data.raw["map-gen-presets"]["default"]["random"] = {
  order = "b",
  basic_settings = {
    terrain_segmentation = randomize_numerical_property(),
    water = randomize_numerical_property(),
    autoplace_controls = {
      ["iron-ore"] = { richness = randomize_numerical_property(), size = randomize_numerical_property(), frequency = randomize_numerical_property() },
      ["copper-ore"] = { richness = randomize_numerical_property(), size = randomize_numerical_property(), frequency = randomize_numerical_property() },
      ["coal"] = { richness = randomize_numerical_property(), size = randomize_numerical_property(), frequency = randomize_numerical_property() },
      ["crude-oil"] = { richness = randomize_numerical_property(), size = randomize_numerical_property(), frequency = randomize_numerical_property() },
      ["enemy-base"] = { size = randomize_numerical_property(), frequency = randomize_numerical_property() },
      ["stone"] = { richness = randomize_numerical_property(), size = randomize_numerical_property(), frequency = randomize_numerical_property() },
      ["trees"] = { size = randomize_numerical_property(), frequency = randomize_numerical_property() },
      ["uranium-ore"] = { richness = randomize_numerical_property(), size = randomize_numerical_property(), frequency = randomize_numerical_property() }
    },
    cliff_settings = {
      cliff_elevation_interval = 40 / randomize_numerical_property(),
      richness = 0.5 * randomize_numerical_property()
    },
    property_expression_names = {
      ["control-setting:aux:frequency:multiplier"] = 0.5 * randomize_numerical_property(),
      ["control-setting:moisture:bias"] = -0.5 + 0.5 * randomize_numerical_property(),
      ["control-setting:moisture:frequency:multiplier"] = 0.5 * randomize_numerical_property(),
      ["control-setting:aux:bias"] = -0.5 + 0.5 * randomize_numerical_property()
    }
  },
  advanced_settings = {
    pollution = {
      diffusion_ratio = 0.02 * randomize_numerical_property(),
      enemy_attack_pollution_consumption_modifier = randomize_numerical_property(),
      min_pollution_to_damage_trees = 60 * randomize_numerical_property(),
      pollution_restored_per_tree_damage = 10 * randomize_numerical_property()
    },
    enemy_evolution = {
      time_factor = 0.000004 * randomize_numerical_property(),
      destroy_factor = 0.002 * randomize_numerical_property(),
      pollution_factor = 0.0000009 * randomize_numerical_property()
    },
    enemy_expansion = {
      max_expansion_distance = 7 * randomize_numerical_property(),
      settler_group_min_size = 5 * randomize_numerical_property(),
      settler_group_max_size = 20 * randomize_numerical_property(),
      min_expansion_cooldown = 14400 * randomize_numerical_property(),
      max_expansion_cooldown = 216000 * randomize_numerical_property()
    },
    difficulty_settings = {
      technology_price_multiplier = randomize_numerical_property(),
      research_queue_setting = "always"
    }
  }
}

--[[ data:extend({
  {
    type = "map-gen-presets",
    name = "default",
    default = {
      default = true,
      order = "a"
    },
    randomized = {
      order = "b",
      basic_settings = {
        terrain_segmentation = randomize_numerical_property(),
        water = randomize_numerical_property(),
        autoplace_controls = {
          ["iron-ore"] = { richness = randomize_numerical_property(), size = randomize_numerical_property(), frequency = randomize_numerical_property() },
          ["copper-ore"] = { richness = randomize_numerical_property(), size = randomize_numerical_property(), frequency = randomize_numerical_property() },
          ["coal"] = { richness = randomize_numerical_property(), size = randomize_numerical_property(), frequency = randomize_numerical_property() },
          ["crude-oil"] = { richness = randomize_numerical_property(), size = randomize_numerical_property(), frequency = randomize_numerical_property() },
          ["enemy-base"] = { size = randomize_numerical_property(), frequency = randomize_numerical_property() },
          ["stone"] = { size = randomize_numerical_property(), frequency = randomize_numerical_property() },
          ["trees"] = { size = randomize_numerical_property(), frequency = randomize_numerical_property() },
          ["uranium-ore"] = { richness = randomize_numerical_property(), size = randomize_numerical_property(), frequency = randomize_numerical_property() }
        }
      }
    }
  },
  {
    type = "map-settings",
    name = "map-settings",
    max_failed_behavior_count = 3,
    difficulty_settings = {
      research_queue = "always",
      recipe_difficulty = defines.difficulty_settings.recipe_difficulty.normal,
      technology_difficulty = defines.difficulty_settings.technology_difficulty.normal,
      technology_price_multiplier = randomize_numerical_property()
    },
    pollution = {
      ageing = randomize_numerical_property(),
      diffusion_ratio = 0.02 * randomize_numerical_property(),
      enabled = true,
      enemy_attack_pollution_consumption_modifier = randomize_numerical_property(),
      expected_max_per_chunk = 150,
      max_pollution_to_restore_trees = 20 * tree_pollution_modifier,
      min_pollution_to_damage_trees = 60 * tree_pollution_modifier,
      min_to_diffuse = 15 * randomize_numerical_property(),
      min_to_show_per_chunk = 50,
      pollution_per_tree_damage = 50 * tree_pollution_modifier,
      pollution_restored_per_tree_damage = 10 * tree_pollution_modifier,
      pollution_with_max_forest_damage = 150 * tree_pollution_modifier
    },
    steering = {
      default = {
        force_unit_fuzzy_goto_behavior = false,
        radius = 1.2,
        separation_factor = 1.2,
        separation_force = 0.005
      },
      moving = {
        force_unit_fuzzy_goto_behavior = false,
        radius = 3,
        separation_factor = 3,
        separation_force = 0.01
      }
    },
    unit_group = {
      max_gathering_unit_groups = 30,
      max_group_gathering_time = 36000,
      max_group_member_fallback_factor = 3,
      max_group_radius = 30,
      max_group_slowdown_factor = 0.3,
      max_member_slowdown_when_ahead = 0.6,
      max_member_speedup_when_behind = 1.3999999999999999,
      max_unit_group_size = 200,
      max_wait_time_for_late_members = 7200,
      member_disown_distance = 10,
      min_group_gathering_time = 3600,
      min_group_radius = 5,
      tick_tolerance_when_member_arrives = 60
    },
    enemy_evolution = {
      destroy_factor = 0.002 * randomize_numerical_property(),
      enabled = true,
      pollution_factor = 9e-07 * randomize_numerical_property(),
      time_factor = 4e-06 * randomize_numerical_property()
    },
    enemy_expansion = {
      building_coefficient = 0.1,
      enabled = true,
      enemy_building_influence_radius = 2,
      friendly_base_influence_radius = 2,
      max_colliding_tiles_coefficient = 0.9,
      max_expansion_cooldown = math.floor(216000 * expansion_modifier),
      max_expansion_distance = math.floor(8 * expansion_modifier),
      min_expansion_cooldown = math.floor(14400 * expansion_modifier),
      neighbouring_base_chunk_coefficient = 0.4 * expansion_modifier,
      neighbouring_chunk_coefficient = 0.5 * expansion_modifier,
      other_base_coefficient = 2 * expansion_modifier,
      settler_group_max_size = math.floor(20 * expansion_modifier),
      settler_group_min_size = math.floor(5 * expansion_modifier)
    },
    path_finder = {
      cache_accept_path_end_distance_ratio = 0.15,
      cache_accept_path_start_distance_ratio = 0.2,
      cache_max_connect_to_cache_steps_multiplier = 100,
      cache_path_end_distance_rating_multiplier = 20,
      cache_path_start_distance_rating_multiplier = 10,
      direct_distance_to_consider_short_request = 100,
      enemy_with_different_destination_collision_penalty = 30,
      extended_collision_penalty = 3,
      fwd2bwd_ratio = 5,
      general_entity_collision_penalty = 10,
      general_entity_subsequent_collision_penalty = 3,
      goal_pressure_ratio = 2,
      ignore_moving_enemy_collision_distance = 5,
      long_cache_min_cacheable_distance = 30,
      long_cache_size = 25,
      max_clients_to_accept_any_new_request = 10,
      max_clients_to_accept_short_new_request = 100,
      max_steps_worked_per_tick = 1000,
      max_work_done_per_tick = 8000,
      min_steps_to_check_path_find_termination = 2000,
      negative_cache_accept_path_end_distance_ratio = 0.3,
      negative_cache_accept_path_start_distance_ratio = 0.3,
      negative_path_cache_delay_interval = 20,
      overload_levels = {
        0,
        100,
        500
      },
      overload_multipliers = {
        2,
        3,
        4
      },
      short_cache_min_algo_steps_to_cache = 50,
      short_cache_min_cacheable_distance = 10,
      short_cache_size = 5,
      short_request_max_steps = 1000,
      short_request_ratio = 0.5,
      stale_enemy_with_same_destination_collision_penalty = 30,
      start_to_goal_cost_multiplier_to_terminate_path_find = 2000,
      use_path_cache = true
    }
  }
})
]]--



























