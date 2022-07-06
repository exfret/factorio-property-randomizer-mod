local param_table_utils = {}

local INFINITE_DISTANCE_NUMBER = 1000000000

-- inertia_function assumed to drop to zero between inputs and outputs
-- inertia_function must be sorted
function param_table_utils.find_inertia_function_value (inertia_function, input)
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

function param_table_utils.add_inertia_function_multiplier (multiplier, inertia_function)
  local new_inertia_function = util.table.deepcopy(inertia_function)

  if new_inertia_function.slope ~= nil then
    new_inertia_function.slope = multiplier * new_inertia_function.slope
  elseif new_inertia_function.value ~= nil then
    new_inertia_function.value = multiplier * new_inertia_function.value
  else
    for i = 1,#new_inertia_function do
      new_inertia_function[i][2] = multiplier * new_inertia_function[i][2]
    end
  end

  return new_inertia_function
end

function param_table_utils.find_inertia_function_distance (inertia_function, x1, x2)
  local function find_linear_distance (slope, x1, x2)
    if x1 * x2 < 0 then
      return INFINITE_DISTANCE_NUMBER
    else
      return math.abs((1 / slope) * (math.log(math.abs(x1), math.exp(1)) - math.log(math.abs(x2), math.exp(1))))
    end
  end

  if inertia_function.type == "constant" then
    return math.abs((1 / inertia_function.value) * (x2 - x1))
  elseif inertia_function.type == "proportional" then
    return find_linear_distance(inertia_function.slope, x1, x2)
  elseif inertia_function.type == "linear" then
    x1 = x1 - inertia_function["x-intercept"]
    x2 = x2 - inertia_function["x-intercept"]
    
    -- Now it's the same as proportional
    return find_linear_distance(inertia_function.slope, x1, x2)
  end

  -- First make x1 the smaller one
  local smaller_x = math.min(x1, x2)
  local larger_x = math.max(x1, x2)
  x1 = smaller_x
  x2 = larger_x

  local dist_acc = 0
  for i = 1,#inertia_function do
    if x1 < inertia_function[i][1] and inertia_function[i][1] < x2 then
      local value_at_x1 = find_inertia_function_value(inertia_function, x1)
      local slope = (inertia_function[i][2] - value_at_x1) / (inertia_function[i][1] - x1)
      if slope == 0 then
        dist_acc = dist_acc + (1 / value_at_x1) * (inertia_function[i][1] - x1)
        x1 = inertia_function[i][1]
      else
        local x_intercept = x1 - value_at_x1 / slope
        local shifted_x1 = x1 - x_intercept
        local shifted_right_point = inertia_function[i][1] - x_intercept

        dist_acc = dist_acc + find_linear_distance(slope, shifted_x1, shifted_right_point)
        x1 = inertia_function[i][1]
      end
    elseif x1 <= inertia_function[i][1] and x2 <= inertia_function[i][1] and x1 ~= x2 then
      local value_at_x1 = find_inertia_function_value(inertia_function, x1)
      local value_at_x2 = find_inertia_function_value(inertia_function, x2)
      local slope = (value_at_x2 - value_at_x1) / (x2 - x1)
      if slope == 0 then
        dist_acc = dist_acc + (1 / value_at_x1) * (x2 - x1)
        x1 = x2
      else
        local x_intercept = x1 - value_at_x1 / slope
        local shifted_x1 = x1 - x_intercept
        local shifted_x2 = x2 - x_intercept

        dist_acc = dist_acc + find_linear_distance(slope, shifted_x1, shifted_x2)
        x1 = x2
      end
    end
  end

  return dist_acc
end

return param_table_utils