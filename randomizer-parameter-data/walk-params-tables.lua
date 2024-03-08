-- Offshore pump, lab, and burner biases are modified in machine_speed function in entity_randomizer

local walk_params = {}

walk_params.autoplace_control = {
  bias = 0.53
}

walk_params.electric_pole_supply_area = {
  bias = 0.565
}

-- Make equipment grid sizes err towards positive so that poking holes is not as bad
walk_params.equipement_grid_size = {
  bias = 0.6
}

-- Make equipment sizes err towards smaller so that poking holes doesn't increase size as much
walk_params.equipment_size = {
  bias = 0.6 -- TODO: Check that equipment size has larger_is_better
}

walk_params.gun_damage_modifier = {
  bias = 0.53
}

walk_params.offshore_pumping_speed = {
  bias = 0.47
}

walk_params.productivity_effect = {
  bias = 0.53 -- I think higher productivity is funnier and compensates for some of the other BS you have to put up with
}

walk_params.projectile_damage = {
  bias = 0.54
}

walk_params.recipe_crafting_time = {
  bias = 0.47
}

walk_params.stack_size = {
  bias = 0.56 -- It's better to give the player enormously large stack sizes than to have enormously small ones, so skew to larger ones
}

walk_params.temperature = { -- Since temperatures are often determined by the worst one in the chain, make bias higher to account for that
  bias = 0.55
}

walk_params.tile_walking_speed_modifier = {
  bias = 0.54
}

walk_params.trigger_damage = {
  bias = 0.53
}

walk_params.underground_belt_length = {
  bias = 0.525, -- Make bias towards a little higher to fight against the offshoot to the left I was having
}

walk_params.vehicle_speed = {
  bias = 0.53
}

return walk_params