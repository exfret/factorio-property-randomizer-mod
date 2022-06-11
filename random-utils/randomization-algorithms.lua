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

-- params = {dummy = ?, tbl = ?, prototype = ?, property = ?, prg_key = ?, inertia function = {?}, randomization_params = {?}}
-- randomization_params = {bias = ?, steps = ?, min = ?, max = ?, round = ?}
-- randomization_params consists of: bias, steps, min, max (bias is towards positive direction)
function randomize_numerical_property (params)
  if params == nil then
    params = {}
  end

  local tbl, property, prg_key
  property = params.property
  if params.prototype == nil and params.table == nil then
    if params.dummy == nil then
      params.dummy = 1
    end
    tbl = {dummy = params.dummy}
    property = "dummy"
    prg_key = "aaadummyprg"
  elseif params.tbl ~= nil then
    tbl = params.tbl
    prg_key = params.prototype.type .. "aaa" .. params.prototype.name
  elseif params.prototype ~= nil then
    tbl = params.prototype
    prg_key = params.prototype.type .. "aaa" .. params.prototype.name
  end

  if params.prg_key ~= nil then
    prg_key = params.prg_key
  end

  if tbl[property] == nil then
    return
  end

  if params.inertia_function == nil then
    params.inertia_function = {["type"] = "proportional", slope = 3}
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

  -- Account for karma
  bias = bias + karma.values[prg_key]
  local sign = 1
  if params.randomization_params.lower_is_better then
    sign = -1
  end

  local luckiness_of_this_randomization = 0
  for i = 1,num_steps do
    if prg.value(prg_key) < bias then -- "better" option
      tbl[property] = tbl[property] + sign * (1 / num_steps) * find_inertia_function_value(params.inertia_function, tbl[property])
      luckiness_of_this_randomization = luckiness_of_this_randomization + 1 / num_steps
    else
      tbl[property] = tbl[property] - sign * (1 / num_steps) * find_inertia_function_value(params.inertia_function, tbl[property])
      luckiness_of_this_randomization = luckiness_of_this_randomization - 1 / num_steps
    end
  end

  -- TODO: Update karma.values here

  if params.randomization_params.round then
    tbl[property] = math.floor(tbl[property] + 0.5)
  end

  -- Min/max it
  if params.randomization_params.min then
    tbl[property] = math.max(tbl[property], params.randomization_params.min)
  end
  if params.randomization_params.max then
    tbl[property] = math.min(tbl[property], params.randomization_params.max)
  end

  return tbl[property]
end