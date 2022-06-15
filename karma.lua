require("randomization-algorithms/random")

karma.update_params = {
  prototype_update_step = 0.023,
  min_prototype_value = -0.2,
  max_prototype_value = 0.2,

  class_update_step = 0.015,
  min_class_value = -0.2,
  max_class_value = 0.2
}

karma = {}

function karma.init()
  karma.class_values = {}
  karma.prototype_values = {}

  for _, class in pairs(data.raw) do
    for _, prototype in pairs(class) do
      karma.prototype_values[prg.get_key(prototype)] = 0
    end
    karma.class_values[class.name] = 0
  end
  karma.prototype_values["aaadummyprg"] = 0
end

function karma.update_prototype_value(key, luckiness)
  
end

function karma.update_class_value(key, luckiness)
end