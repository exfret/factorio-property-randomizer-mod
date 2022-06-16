require("random")
-- TODO: function for simultaneous randomization?

-- inertia_function assumed to drop to zero between inputs and outputs
-- inertia_function must be sorted
function find_inertia_function_value (inertia_function, input)
  -- First check if min/max is specified and input is outside this
  if inertia_function.min and input <= inertia_function.min then
    return 0
  elseif inertia_function.max and input >= inertia_function.max then
    return 0
  end

  -- First check if the inertia function is given in a special form
  if inertia_function.type == "constant" then
    return inertia_function.value
  elseif inertia_function.type == "proportional" then
    return inertia_function.slope * input
  elseif inertia_function.type == "linear" then
    return inertia_function.slope * (input - inertia_function["x-intercept"])
  end

  if input <= inertia_function[1][1] then
    return 0
  elseif input >= inertia_function[#inertia_function][1] then
    return 0
  end

  for i = 1,#inertia_function do
    if input <= inertia_function[i][1] then
      local slope = (inertia_function[i][2] - inertia_function[i - 1][2]) / (inertia_function[i][1] - inertia_function[i - 1][1])

      return slope * (input - inertia_function[i - 1][1]) + inertia_function[i - 1][2]
    end
  end
end

-- defaults = {inertia_function = {?}}
local function set_randomization_param_values(params, defaults)
  if defaults == nil then
    defaults = {}
  end

  local prototype, tbl, property, prg_key
  tbl = {dummy = 1}
  property = "dummy"
  prg_key = "aaadummyprg"
  if params.prototype ~= nil then
    prototype = params.prototype
    tbl = params.prototype
    prg_key = prg.get_key(prototype)
  end
  if params.tbl ~= nil then
    tbl = params.tbl
  end
  if params.property ~= nil then
    property = params.property
  end
  if params.dummy ~= nil then
    tbl = {dummy = params.dummy}
    property = "dummy"
  end
  if params.prg_key ~= nil then
    prg_key = params.prg_key
  end

  if params.inertia_function == nil then
    if defaults.inertia_function ~= nil then
      params.inertia_function = defaults.inertia_function
    else
      params.inertia_function = {["type"] = "proportional", slope = 3}
    end
  end

  if params.randomization_params == nil then
    params.randomization_params = {}
  end
  
  local bias, num_steps
  if params.randomization_params.bias ~= nil then
    bias = params.randomization_params.bias
  else
    bias = 1/2
  end
  if params.randomization_params.num_steps ~= nil then
    num_steps = params.randomization_params.num_steps
  else
    num_steps = 75
  end

  params.prototype = prototype
  params.tbl = tbl
  params.property = property
  params.prg_key = prg_key
  params.randomization_params.bias = bias
  params.randomization_params.num_steps = num_steps
end

function find_sign (roll, lower_is_better)
  local sign

  if roll == "make_property_better" then
    sign = 1
  elseif roll == "make_property_worse" then
    sign = -1
  end

  if lower_is_better then
    sign = sign * -1
  end

  return sign
end

local function nudge_properties (params, roll)
  local function nudge_individual_property (tbl, property, sign, num_steps, inertia_function)
    if tbl[property] == nil then
      return
    end

    tbl[property] = tbl[property] + sign * (1 / num_steps) * find_inertia_function_value(inertia_function, tbl[property])
  end

  nudge_individual_property(params.tbl, params.property, find_sign(roll, params.lower_is_better), params.randomization_params.num_steps, params.inertia_function)
  for _, param_table in pairs(params.group_params) do
    nudge_individual_property(param_table.tbl, param_table.property, find_sign(roll, param_table.lower_is_better), param_table.randomization_params.num_steps, param_table.inertia_function)
  end
end

local function complete_final_randomization_fixes (params)
  local function fix_individual_property(tbl, property, min, max, round)
    if tbl[property] == nil then
      return
    end

    -- TODO: More complicated rounding logic based on rounding setting
    if round then
      tbl[property] = math.floor(tbl[property] + 0.5)
    end
  
    -- Min/max it
    if params.randomization_params.min then
      tbl[property] = math.max(tbl[property], params.randomization_params.min)
    end
    if params.randomization_params.max then
      tbl[property] = math.min(tbl[property], params.randomization_params.max)
    end
  end

  fix_individual_property(params.tbl, params.property, params.min, params.max, params.round)
  for _, param_table in pairs(params.group_params) do
    fix_individual_property(param_table.tbl, param_table.property, param_table.min, param_table.max, param_table.round)
  end
end

-- TODO: Finish moving min/max out of randomization_params
-- params = {dummy = ?, prototype = ?, tbl = ?, property = ?, lower_is_better = ?, min = ?, max = ?, round = ?, inertia function = {?}, prg_key = ?, group_params = {?}, randomization_params = {?}}
-- simultaneous_params = list of {dummy = ?, prototype = ?, tbl = ?, property = ?, lower_is_better = ?, min = ?, max = ?, round = ?, inertia_function = {?}}
-- inertia_function = [See find_inertia_function_value()]
-- randomization_params = {bias = ?, steps = ?}
function randomize_numerical_property (params)
  if params == nil then
    params = {}
  end
  if params.group_params == nil then
    params.group_params = {}
  end

  -- TODO: move this to set_randomization_params
  if params.dummy == nil and params.prototype == nil and params.tbl == nil and #params.group_params ~= 0 then
    local master_params = params.group_params[#params.group_params]
    for param_name, param_value in pairs(master_params) do
      params[param_name] = param_value
    end

    params.group_params[#params.group_params] = nil
  end

  set_randomization_param_values(params)
  for _, param_table in pairs(params.group_params) do
    -- Any randomization_params set here are ignored
    set_randomization_param_values(param_table, {inertia_function = params.inertia_function})
  end

  -- Account for karma
  --[[bias = bias + karma.prototype_values[prg_key]
  if params.prototype then
    bias = bias + karma.class_values[params.prototype.type]
  end
  local sign = 1
  if params.randomization_params.lower_is_better then
    sign = -1
  end]]

  local luckiness_of_this_randomization = 0
  for i = 1,params.randomization_params.num_steps do
    if prg.value(params.prg_key) < params.randomization_params.bias then -- "better" option
      nudge_properties(params, "make_property_better")
      
      --luckiness_of_this_randomization = luckiness_of_this_randomization + 1 / num_steps
    else
      nudge_properties(params, "make_property_worse")
      
      --luckiness_of_this_randomization = luckiness_of_this_randomization - 1 / num_steps
    end
  end

  complete_final_randomization_fixes(params)

  -- TODO: Update karma.values here

  return params.tbl[params.property]
end