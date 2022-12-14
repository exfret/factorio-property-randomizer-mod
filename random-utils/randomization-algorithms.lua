require("random")

require("globals")
local param_table_utils = require("param-table-utils")

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
      params.inertia_function = {
        ["type"] = "proportional",
        slope = DEFAULT_INERTIA_FUNCTION_SLOPE
      }
    end
  end

  if params.property_info == nil then
    params.property_info = {}
  end

  if params.property_info.round ~= nil then
    for i = 1,3 do
      if params.property_info.round[i] == nil then
        params.property_info.round[i] = {}
      end
    end

    if next(params.property_info.round[2]) == nil then
      params.property_info.round[2].modulus = 0.1
    end
    if params.property_info.round[3].modulus == nil then
      params.property_info.round[3].modulus = params.property_info.round[2].modulus
    end
    if params.property_info.round[3].left_digits_to_keep == nil then
      params.property_info.round[3].left_digits_to_keep = 2
    end
  end

  if params.walk_params == nil then
    params.walk_params = {}
  end
  
  local bias, num_steps
  if params.walk_params.bias ~= nil then
    bias = params.walk_params.bias
  else
    bias = 1/2
  end
  if params.walk_params.num_steps ~= nil then
    num_steps = params.walk_params.num_steps
  else
    num_steps = DEFAULT_WALK_PARAMS_NUM_STEPS
  end

  params.prototype = prototype
  params.tbl = tbl
  params.property = property
  params.prg_key = prg_key
  params.walk_params.bias = bias
  params.walk_params.num_steps = num_steps
end

function find_sign (roll, property_params)
  local lower_is_better = false
  if property_params.property_info ~= nil and property_params.property_info.lower_is_better then
    lower_is_better = true
  end

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

    tbl[property] = tbl[property] + sign * (1 / num_steps) * param_table_utils.find_inertia_function_value(inertia_function, tbl[property])
  end

  nudge_individual_property(params.tbl, params.property, find_sign(roll, params), params.walk_params.num_steps, params.inertia_function)
  for _, param_table in pairs(params.group_params) do
    nudge_individual_property(param_table.tbl, param_table.property, find_sign(roll, param_table), param_table.walk_params.num_steps, param_table.inertia_function)
  end
end

local function complete_final_randomization_fixes (params)
  local function fix_individual_property(tbl, property, property_info, old_value)
    if tbl[property] == nil then
      return
    end

    -- Rounding
    if property_info.round ~= nil then
      local left_digits_to_keep = property_info.round[rounding_mode].left_digits_to_keep
      if left_digits_to_keep ~= nil and left_digits_to_keep ~= 0 and tbl[property] ~= 0 then
        local digits_modulus = math.pow(10, math.floor(math.log(math.abs(tbl[property]), 10) - left_digits_to_keep + 1))
        tbl[property] = math.floor((tbl[property] + digits_modulus / 2) / digits_modulus) * digits_modulus
      end
      local modulus = property_info.round[rounding_mode].modulus
      if modulus ~= nil and modulus ~= 0 then
        tbl[property] = math.floor((tbl[property] + modulus / 2) / modulus) * modulus
      end
    end
  
    -- Min/max it
    if property_info.min ~= nil then
      tbl[property] = math.max(tbl[property], property_info.min)
    end
    if property_info.max ~= nil then
      tbl[property] = math.min(tbl[property], property_info.max)
    end
    if property_info.min_factor ~= nil then
      tbl[property] = math.max(tbl[property], property_info.min_factor * old_value)
    end
    if property_info.max_factor ~= nil then
      tbl[property] = math.min(tbl[property], property_info.max_factor * old_value)
    end
  end

  fix_individual_property(params.tbl, params.property, params.property_info, params.old_value)
  for _, param_table in pairs(params.group_params) do
    fix_individual_property(param_table.tbl, param_table.property, param_table.property_info, param_table.old_value)
  end
end

-- TODO: Finish moving min/max out of walk_params
-- params = {dummy = ?, prototype = ?, tbl = ?, property = ?, property_list = {?}, inertia function = {?}, property_info = {?}, group_params = {?}, prg_key = ?, walk_params = {?}}
-- property_list = list of property name strings
-- inertia_function = [See find_inertia_function_value()]
-- property_info = {lower_is_better = ?, min = ?, max = ?, round = {?}}
-- round = {rounding_params1, rounding_params2, rounding_params3}
-- rounding_params = {modulus = ?}
-- group_params = list of {dummy = ?, prototype = ?, tbl = ?, property = ?, inertia_function = {?}, property_info = {?}}
-- walk_params = {bias = ?, steps = ?}
-- ALSO: old_value, but this is written inside this function, don't pass it in
function randomize_numerical_property (passed_params)
  if passed_params == nil then
    passed_params = {}
  end
  if passed_params.group_params == nil then
    passed_params.group_params = {}
  end

  -- Only tbl or prototype should be "passed by reference"
  local params = util.table.deepcopy(passed_params)
  params.prototype = passed_params.prototype
  for i, _ in pairs(params.group_params) do
    params.group_params[i].prototype = passed_params.group_params[i].prototype
  end
  params.tbl = passed_params.tbl
  for i, _ in pairs(params.group_params) do
    params.group_params[i].tbl = passed_params.group_params[i].tbl
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
    -- Any walk_params set here are ignored
    set_randomization_param_values(param_table, {inertia_function = params.inertia_function})
  end

  params.old_value = params.tbl[params.property]

  local luckiness_of_this_randomization = 0
  for i = 1,params.walk_params.num_steps do
    if prg.value(params.prg_key) < params.walk_params.bias then -- "better" option
      nudge_properties(params, "make_property_better")
    else
      nudge_properties(params, "make_property_worse")
    end
  end

  complete_final_randomization_fixes(params)

  return params.tbl[params.property]
end

-- params = {points, dimension_information, prg_key, walk_params}
-- dimension_information = list of {inertia_function, property_info}
function randomize_points_in_space (params)
  if params.walk_params == nil then
    params.walk_params = {}
  end
  if params.walk_params.bias == nil then
    params.walk_params.bias = 1 / 2
  end
  if params.walk_params.num_steps == nil then
    params.walk_params.num_steps = DEFAULT_WALK_PARAMS_NUM_STEPS
  end

  -- TODO: Logic for deciding prg_key?

  for i = 1,params.walk_params.num_steps do
    local forces = param_table_utils.calculate_forces(params.dimension_information, params.points)

    for j, point in pairs(params.points) do
      for k=1,#point do
        local sign
        if prg.value(params.prg_key) < params.walk_params.bias then
          sign = 1
        else
          sign = -1
        end

        -- The arctan is to clamp large forces from causing huge changes
        point[k] = point[k] + math.atan(sign + FORCES_WEIGHT * forces[j][k]) * (1 / params.walk_params.num_steps) * param_table_utils.find_inertia_function_value(params.dimension_information[k].inertia_function, point[k])
      end
    end
  end
end