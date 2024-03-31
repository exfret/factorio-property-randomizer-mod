require("random-utils/random")

require("analysis/karma")
require("globals")
local param_table_utils = require("param-table-utils")

local function initialize_param_tbl_property_values(params)
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

  params.prototype = prototype
  params.tbl = tbl
  params.property = property
  params.prg_key = prg_key
end

local function initialize_param_inertia_function_values(params, defaults)
  if defaults == nil then
    defaults = {}
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
end

local function initialize_param_property_info_values(params)
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
end

local function initialize_param_walk_params_values(params)
  if params.walk_params == nil then
    params.walk_params = {}
  end
  
  local bias = settings.startup["propertyrandomizer-bias"].value
  if params.walk_params.bias ~= nil then
    bias = bias + (params.walk_params.bias - 0.5)
  end

  local num_steps
  if params.walk_params.num_steps ~= nil then
    num_steps = params.walk_params.num_steps
  else
    num_steps = DEFAULT_WALK_PARAMS_NUM_STEPS
  end
  
  params.walk_params.bias = bias
  params.walk_params.num_steps = num_steps
end

-- defaults = {inertia_function = {?}}
local function set_randomization_param_values(params, defaults)
  initialize_param_tbl_property_values(params)
  initialize_param_inertia_function_values(params, defaults)
  initialize_param_property_info_values(params)
  initialize_param_walk_params_values(params)
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

    local nudge = sign * settings.startup["propertyrandomizer-chaos"].value * (1 / num_steps) * param_table_utils.find_inertia_function_value(inertia_function, tbl[property])
    if math.abs(nudge / math.sqrt(1 + tbl[property] * tbl[property]) * num_steps) >= 150 then
      nudge = sign * 150 * math.sqrt(1 + tbl[property] * tbl[property]) / num_steps
    elseif inertia_function.type == "proportional" and settings.startup["propertyrandomizer-chaos"].value * inertia_function.slope >= 20 then
      -- Also limit so that proportional inertia functions don't cause things to go below zero
      nudge = sign / num_steps * 10 * tbl[property]
    end
    tbl[property] = tbl[property] + nudge
  end

  nudge_individual_property(params.tbl, params.property, find_sign(roll, params), params.walk_params.num_steps, params.inertia_function)
  for _, param_table in pairs(params.group_params) do
    nudge_individual_property(param_table.tbl, param_table.property, find_sign(roll, param_table), param_table.walk_params.num_steps, param_table.inertia_function)
  end
end

local function apply_property_info_changes(tbl, property, property_info, old_value)
  if tbl[property] == nil then
    return
  end

  -- Rounding
  if property_info.round ~= nil then
    -- If rounding down causes it to go to zero, instead take ceiling, this is to help with some rounding issues without rewriting huge chunks of code
    -- It should also be relatively non-invasive
    local left_digits_to_keep = property_info.round[rounding_mode].left_digits_to_keep
    if left_digits_to_keep ~= nil and left_digits_to_keep ~= 0 and tbl[property] ~= 0 then
      local digits_modulus = math.pow(10, math.floor(math.log(math.abs(tbl[property]), 10) - left_digits_to_keep + 1))

      local new_value = math.floor((tbl[property] + digits_modulus / 2) / digits_modulus) * digits_modulus
      local positive_new_value = math.ceil(tbl[property] / digits_modulus) * digits_modulus
      if new_value == 0 then
        tbl[property] = positive_new_value
      else
        tbl[property] = new_value
      end
    end
    local modulus = property_info.round[rounding_mode].modulus
    if modulus ~= nil and modulus ~= 0 then
      local new_value = math.floor((tbl[property] + modulus / 2) / modulus) * modulus
      local positive_new_value = math.ceil(tbl[property] / modulus) * modulus
      if new_value == 0 then
        tbl[property] = positive_new_value
      else
        tbl[property] = new_value
      end
    end
  end

  -- Min/max it
  if property_info.min ~= nil then
    if old_value <= property_info.min then
      tbl[property] = old_value
    else
      tbl[property] = math.max(tbl[property], property_info.min)
    end
  end
  if property_info.max ~= nil then
    if tbl[property] >= property_info.max then
      tbl[property] = old_value
    else
      tbl[property] = math.min(tbl[property], property_info.max)
    end
  end
  if property_info.min_factor ~= nil then -- TODO: Make this respect modulus
    tbl[property] = math.max(tbl[property], property_info.min_factor * old_value)
  end
  if property_info.max_factor ~= nil then
    tbl[property] = math.min(tbl[property], property_info.max_factor * old_value)
  end
end

local function complete_final_randomization_fixes (params)
  apply_property_info_changes(params.tbl, params.property, params.property_info, params.old_value)
  for _, param_table in pairs(params.group_params) do
    apply_property_info_changes(param_table.tbl, param_table.property, param_table.property_info, param_table.old_value)
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

  -- Randomly increase or decrease bias to make a distribution that's less likely to sample from the middle (i.e.- make it so things change more often than not)
  if prg.int(params.prg_key, 2) == 1 then
    params.walk_params.bias = params.walk_params.bias - SPLIT_BIAS_MODIFIER - 0.1 * settings.startup["propertyrandomizer-chaos"].value -- TODO: Isn't 0.1 a lot lol
  else
    params.walk_params.bias = params.walk_params.bias + SPLIT_BIAS_MODIFIER + 0.1 * settings.startup["propertyrandomizer-chaos"].value
  end

  if params.walk_params.bias >= 0.5 + MAX_BIAS_CHANGE then
    params.walk_params.bias = 0.5 + MAX_BIAS_CHANGE
  end
  if params.walk_params.bias <= 0.5 - MAX_BIAS_CHANGE then
    params.walk_params.bias = 0.5 - MAX_BIAS_CHANGE
  end

  params.old_value = params.tbl[params.property]
  for i, _ in pairs(params.group_params) do
    params.group_params[i].old_value = params.group_params[i].tbl[params.group_params[i].property]
  end

  local luckiness_of_this_randomization = 0
  for i = 1,params.walk_params.num_steps do
    if prg.value(params.prg_key) < params.walk_params.bias then -- "better" option
      nudge_properties(params, "make_property_better")
      karma.update_values("make_property_better", params.prototype, params.property)
    else
      nudge_properties(params, "make_property_worse")
      karma.update_values("make_property_worse", params.prototype, params.property)
    end
  end

  complete_final_randomization_fixes(params)

  return params.tbl[params.property]
end

-- params = {points, dimension_information, prg_key, walk_params}
-- dimension_information = list of {inertia_function, property_info}
function randomize_points_in_space (passed_params)
  local params = table.deepcopy(passed_params)
  params.points = passed_params.points

  params.old_values = table.deepcopy(params.points)

  for _, dimension_info in pairs(params.dimension_information) do
    initialize_param_inertia_function_values(dimension_info)
    initialize_param_property_info_values(dimension_info)
  end

  initialize_param_walk_params_values(params)

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

  -- Apply property_info fixes
  for point_index, point in pairs(params.points) do
    for k=1,#point do
      apply_property_info_changes(point, k, params.dimension_information[k].property_info, params.points[point_index][k])
    end
  end
end

-- prototype must be defined
function randnum(passed_params)
  local params = table.deepcopy(passed_params)

  params.key = prg.get_key({type = passed_params.prototype.type, name = passed_params.prototype.name, property = passed_params.property}, "property")
  params.tbl = passed_params.tbl or passed_params.prototype
  
  -- TODO: Move these to constants or globals
  local num_rolls = 25
  local steps_per_roll = 20
  local split_bias = 0.2

  -- Note that prototoype, tbl, property, and key don't have defaults
  local defaults = {
    -- See str_to_cap for soft and hard caps
    range = "medium",
    -- Can be "same" or a range value
    range_min = "same",
    range_max = "same",
    step_size = 5,
    -- Extra bias to add/subtract
    bias = 0,
    -- 1 or -1, defines whether the property is good (1) or bad (-1) to have
    dir = 1
  }

  for key, value in pairs(defaults) do
    if params[key] == nil then
      params[key] = value
    end
  end
  
  local tbl, property, key, step_size, bias, dir = params.tbl, params.property, params.key, params.step_size, params.bias, params.dir
  local val = tbl[property]
  local old_val = val

  local soft_min, soft_max, hard_min, hard_max
  local str_to_cap = {
    very_small = {1.1, 1.3},
    small = {2, 3},
    medium = {4, 6},
    big = {10, 20},
    very_big = {25, 50},
    none = {0, REALLY_BIG_FLOAT_NUM}
  }
  local cap_keys = {"range_min", "range_max"}
  for _, cap_key in pairs(cap_keys) do
    local cap_str
    if params[cap_key] == "same" then
      cap_str = params.range
    else
      cap_str = params[cap_key]
    end

    local soft_factor = str_to_cap[cap_str][1]
    local hard_factor = str_to_cap[cap_str][2]
    soft_min, soft_max = 1 / soft_factor * old_val, soft_factor * old_val
    hard_min, hard_max = 1 / hard_factor * old_val, hard_factor * old_val
  end

  local real_split_bias = 0.2 * (2 * prg.range(key, 0, 1) - 1)
  local real_bias = 0.5 + bias + real_split_bias

  for i = 1, num_rolls do
    local sign = dir
    if prg.value(key) >= real_bias then
      sign = -1 * sign
    end

    for j = 1, steps_per_roll do
      local forces = 0

      if val < soft_min then
        forces = 1 - (val - hard_min) / (soft_min - hard_min)
      end
      if val > soft_max then
        forces = -1 + (hard_max - val) / (hard_max - hard_min)
      end

      val = val + val * (step_size / (num_rolls * steps_per_roll)) * (sign + forces)
    end
  end

  -- Update table value
  tbl[property] = val
end

function test_new_randomize_numerical(passed_params)
  local params = table.deepcopy(passed_params)
  params.tbl = passed_params.tbl or passed_params.prototype

  local num_rolls = 25
  local steps_per_roll = 4
  -- This should always be at most, say, a fifth of the num_steps * num_step_inc which is 100, so at most 20
  -- Modify this by chaos_factor, which is at most 4, so never get step_size above 5
  local step_size = 5

  local tbl, property = params.tbl, params.property
  local val = tbl[property]
  local old_val = val

  -- Either 0.2 or -0.2
  local split_bias = 0.2 * (2 * prg.range("dummy_test", 0, 1) - 1)

  local soft_min = 1 / 2 * old_val
  local soft_max = 2 * old_val
  local hard_min = 1 / 4 * old_val
  local hard_max = 4 * old_val

  log("name: " .. tbl.name)
  local roll_diff = 0
  for i = 1, num_rolls do
    local sign
    if prg.value("dummy_test2") < 0.5 + split_bias then
      sign = 1
      log("positive")
    else
      sign = -1
      log("negative")
    end

    for j = 1, steps_per_roll do
      local forces = 0
      -- Force upwards
      if val < soft_min then
        -- val = hard_min means force of 1, val = soft_min means force of 0
        --forces = 1 - (val - hard_min) / (soft_min - hard_min)
      end
      if val > soft_max then
        -- val = hard_min means force of 1, val = soft_min means force of 0
        --forces = -1 + (hard_max - val) / (hard_max - hard_min)
      end
      -- Force of 1 should never decrement (ditto for force of -1 and increment)

      val = val + val * (step_size / (num_rolls * steps_per_roll)) * (sign + forces)
    end
  end
  log("end rolling")

  tbl[property] = val
end