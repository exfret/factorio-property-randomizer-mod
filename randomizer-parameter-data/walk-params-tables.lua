local walk_params = {}

walk_params.electric_pole_supply_area = {
  bias = 0.565
}

walk_params.magazine_size = {
  bias = 0.475 -- Make the bias towards smaller magazines to make up for the boost from having the minimum at 1
}

walk_params.stack_size = {
  bias = 0.525 -- It's better to give the player enormously large stack sizes than to have enormously small ones, so skew to larger ones
}

walk_params.underground_belt_length = {
  bias = 0.525, -- Make bias towards a little higher to fight against the offshoot to the left I was having
}

return walk_params