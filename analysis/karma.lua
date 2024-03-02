require("random-utils/random")

local karma = {}

karma.update_params = {
  prototype_update_step = 0.023,
  min_prototype_value = -0.2,
  max_prototype_value = 0.2,

  class_update_step = 0.015,
  min_class_value = -0.2,
  max_class_value = 0.2
}

karma.values = {}

karma.values.class_values = {}
karma.values.prototype_values = {}
karma.values.property_values = {}
karma.values.overall = {}

for class_name, class in pairs(data.raw) do
  for _, prototype in pairs(class) do
    karma.values.prototype_values[prg.get_key(prototype)] = {
      num_steps = 0,
      num_good_steps = 0
    }
  end
  karma.values.class_values[prg.get_key(class_name, "class")] = {
    num_steps = 0,
    num_good_steps = 0
  }
end
karma.values.overall[prg.get_key(nil, "dummy")] = {
  num_steps = 0,
  num_good_steps = 0
}

function karma.update_values(roll, prototype, property)
  if prototype == nil or property == nil then
    return
  end

  local goodness
  if roll == "make_property_better" then
    goodness = 1
  elseif roll == "make_property_worse" then
    goodness = 0
  end

  local property_key = prg.get_key({type = prototype.type, name = prototype.name, property = property}, "property")
  if karma.values.property_values[property_key] == nil then
    karma.values.property_values[property_key] = {
      num_steps = 0,
      num_good_steps = 0
    }
  end
  karma.values.property_values[property_key].num_steps = karma.values.property_values[property_key].num_steps + 1
  karma.values.property_values[property_key].num_good_steps = karma.values.property_values[property_key].num_good_steps + goodness
end

return karma