local reformat = require("utilities/reformat")

local prototype_tables = {}

prototype_tables.bot_classes = {
  "combat-robot",
  "construction-robot",
  "logistic-robot"
}

prototype_tables.bot_classes_as_keys = {
  ["combat-robot"] = true,
  ["construction-robot"] = true,
  ["logistic-robot"] = true
}

prototype_tables.bot_energy_keys = {
  ["construction-robot"] = {"energy_per_move", "energy_per_tick"},
  ["logistic-robot"] = {"energy_per_move", "energy_per_tick"}
  -- Don't include combat robots
}

prototype_tables.container_classes = {
  container = true,
  ["infinity-container"] = true,
  ["linked-container"] = true,
  ["logistic-container"] = true
}

prototype_tables.crafting_machine_classes = {
  "assembling-machine",
  "rocket-silo",
  "furnace"
}

prototype_tables.crafting_machine_classes_as_keys = {
  ["assembling-machine"] = true,
  ["rocket-silo"] = true,
  ["furnace"] = true
}

prototype_tables.energy_property_names = {
  fluid = {"heat_capacity", "fuel_value"},
  ["combat-robot"] = {"energy_per_move", "energy_per_tick"},
  ["construction-robot"] = {"energy_per_move", "energy_per_tick"},
  ["logistic-robot"] = {"energy_per_move", "energy_per_tick"},
  inserter = {"energy_per_movement", "energy_per_rotation"},
  lamp = {"energy_usage_per_tick"},
  ["programmable-speaker"] = {"energy_usage_per_tick"},
  ["energy-shield-equipment"] = {"energy_per_shield"}
}
-- Also anything extending Prototype/Item (fluid fuel values already randomized above)
for item, _ in pairs(defines.prototypes["item"]) do
  prototype_tables.energy_property_names[item] = {"fuel_value"}
end

prototype_tables.energy_source_names = {
  accumulator = {"energy_source"},
  beacon = {"energy_source"},
  boiler = {"energy_source"},
  ["burner-generator"] = {"burner", "energy_source"},
  car = {"burner", "energy_source"},
  ["arithmetic-combinator"] = {"energy_source"},
  ["decider-combinator"] = {"energy_source"},
  ["assembling-machine"] = {"energy_source"},
  ["rocket-silo"] = {"energy_source"},
  furnace = {"energy_source"},
  ["electric-energy-interface"] = {"energy_source"},
  ["electric-turret"] = {"energy_source"},
  generator = {"energy_source"},
  inserter = {"energy_source"},
  lab = {"energy_source"},
  lamp = {"energy_source"},
  locomotive = {"burner", "energy_source"},
  ["mining-drill"] = {"energy_source"},
  ["programmable-speaker"] = {"energy_source"},
  pump = {"energy_source"},
  radar = {"energy_source"},
  reactor = {"energy_source"},
  --roboport = {"energy_source"}, Don't randomize roboport energy due to possible conflicts with robot energy right now
  ["solar-panel"] = {"energy_source"},
  ["spider-vehicle"] = {"burner", "energy_source"},
  ["active-defense-equipment"] = {"energy_source"},
  ["battery-equipment"] = {"energy_source"},
  ["belt-immunity-equipment"] = {"energy_source"},
  ["energy-shield-equipment"] = {"energy_source"},
  ["generator-equipment"] = {"burner", "energy_source"},
  ["movement-bonus-equipment"] = {"energy_source"},
  ["night-vision-equipment"] = {"energy_source"},
  ["roboport-equipment"] = {"burner", "energy_source"},
  ["solar-panel-equipment"] = {"energy_source"}
}

prototype_tables.entities_to_modify_mining_speed = {
  "character-corpse",
  "accumulator",
  "artillery-turret",
  "beacon",
  "boiler",
  "burner-generator",
  -- Not character
  "arithmetic-combinator",
  "decider-combinator",
  "constant-combinator",
  "container",
  "logistic-container",
  "infinity-container",
  "assembling-machine",
  "rocket-silo",
  "furnace",
  -- Not electric-energy-interface
  "electric-pole",
  "unit-spawner",
  "combat-robot",
  "construction-robot",
  "logistic-robot",
  "gate",
  "generator",
  -- Not heat-interface
  "heat-pipe",
  "inserter",
  "lab",
  "lamp",
  "land-mine",
  "linked-container",
  "market",
  "mining-drill",
  "offshore-pump",
  "pipe",
  "infinity-pipe",
  "pipe-to-ground",
  "player-port",
  "power-switch",
  "programmable-speaker",
  "pump",
  "radar",
  "curved-rail",
  "straight-rail",
  "rail-chain-signal",
  "rail-signal",
  "reactor",
  "roboport",
  -- Not simple-entity-with-owner or simple-entity-with-force (I don't know what they are really used for)
  "solar-panel",
  "storage-tank",
  "train-stop",
  "linked-belt",
  "loader-1x1",
  "loader",
  "splitter",
  "transport-belt",
  "underground-belt",
  "turret",
  "ammo-turret",
  "electric-turret",
  "fluid-turret",
  "unit",
  "car",
  "artillery-wagon",
  "cargo-wagon",
  "fluid-wagon",
  "locomotive",
  "spider-vehicle",
  "wall",
  "fish",
  "simple-entity",
  "tree",
  "item-entity",
  -- Not resource (that's too sensitive, must be randomized separately)
  "tile-ghost"
}

prototype_tables.entities_to_modify_mining_speed_as_keys = {}
for _, val in pairs(prototype_tables.entities_to_modify_mining_speed) do
  prototype_tables.entities_to_modify_mining_speed_as_keys[val] = true
end

-- TODO: Find a more general way to make tools for dealing with entity classes
prototype_tables.entities_with_health = {
  "accumulator",
  "artillery-turret",
  "beacon",
  "boiler",
  "burner-generator",
  "character",
  "arithmetic-combinator",
  "decider-combinator",
  "constant-combinator",
  "container",
  "logistic-container",
  "infinity-container",
  "assembling-machine",
  "rocket-silo",
  "furnace",
  "electric-energy-interface",
  "electric-pole",
  "unit-spawner",
  "combat-robot",
  "construction-robot",
  "logistic-robot",
  "gate",
  "generator",
  "heat-interface",
  "heat-pipe",
  "inserter",
  "lab",
  "lamp",
  "land-mine",
  "linked-container",
  "market",
  "mining-drill",
  "offshore-pump",
  "pipe",
  "infinity-pipe",
  "pipe-to-ground",
  "player-port",
  "power-switch",
  "programmable-speaker",
  "pump",
  "radar",
  "curved-rail",
  "straight-rail",
  "rail-chain-signal",
  "rail-signal",
  "reactor",
  "roboport",
  "simple-entity-with-owner",
  "simple-entity-with-force",
  "solar-panel",
  "storage-tank",
  "train-stop",
  "linked-belt",
  "loader-1x1",
  "loader",
  "splitter",
  "transport-belt",
  "underground-belt",
  "turret",
  "ammo-turret",
  "electric-turret",
  "fluid-turret",
  "unit",
  "car",
  "artillery-wagon",
  "cargo-wagon",
  "fluid-wagon",
  "locomotive",
  "spider-vehicle",
  "wall",
  "fish",
  "simple-entity",
  "spider-leg",
  "tree"
}

prototype_tables.entities_with_health_as_keys = {}
for _, val in pairs(prototype_tables.entities_with_health) do
  prototype_tables.entities_with_health_as_keys[val] = true
end

-- Entities blacklisted from randomizing their health
prototype_tables.entities_with_health_blacklist = {
  character = true,
  ["spider-leg"] = true
}

-- Modify with health slope 1
prototype_tables.entities_with_health_sensitive = {
  ["unit-spawner"] = true,
  turret = true, -- For worms
  unit = true,
  wall = true
}

prototype_tables.entities_with_health_non_sensitive_as_keys = prototype_tables.entities_with_health_as_keys
for val, _ in pairs(prototype_tables.entities_with_health_blacklist) do
  prototype_tables.entities_with_health_non_sensitive_as_keys[val] = nil
end
for val, _ in pairs(prototype_tables.entities_with_health_sensitive) do
  prototype_tables.entities_with_health_non_sensitive_as_keys[val] = nil
end

prototype_tables.equipment_energy_properties = {
  ["energy-shield-equipment"] = {"energy_per_shield"}
}

prototype_tables.equipment_power_properties = {
  ["belt-immunity-equipment"] = {"energy_consumption"},
  ["movement-bonus-equipment"] = {"energy_consumption"},
  ["night-vision-equipment"] = {"energy_input"}
}

prototype_tables.has_heat_buffer = {
  ["heat-interface"] = true,
  ["heat-pipe"] = true,
  reactor = true
}

prototype_tables.inserter_energy_keys = {
  inserter = {"energy_per_movement", "energy_per_rotation"}
}

-- Furnace inventory sizes and rocket_result_inventory_size are cursed properties... don't randomize
-- Don't randomize trash inventory sizes
prototype_tables.inventory_names = {
  ["artillery-turret"] = {"inventory_size"},
  container = {"inventory_size"},
  ["logistic-container"] = {"inventory_size"},
  ["infinity-container"] = {"inventory_size"},
  ["linked-container"] = {"inventory_size"},
  ["ammo-turret"] = {"inventory_size"},
  car = {"inventory_size"},
  ["artillery-wagon"] = {"inventory_size"},
  ["cargo-wagon"] = {"inventory_size"},
  ["spider-vehicle"] = {"inventory_size"}
}

prototype_tables.item_classes_to_randomize_stack_size = {
  "item",
  "ammo",
  "capsule",
  "gun",
  "module",
  "tool",
  --"armor", Note: this can technically have a >1 stack size, but only if there is no equipment grid
  "repair-tool"
}

prototype_tables.machine_classes = {
  "assembling-machine",
  "rocket-silo",
  "furnace",
  "lab",
  "mining-drill",
  "offshore-pump"
}

prototype_tables.machine_energy_keys = {
  lamp = {"energy_usage_per_tick"},
  ["programmable-speaker"] = {"energy_usage_per_tick"}
}

prototype_tables.machine_power_keys = {
  beacon = {"energy_usage"},
  ["arithmetic-combinator"] = {"active_energy_usage"},
  ["decider-combinator"] = {"active_energy_usage"},
  ["assembling-machine"] = {"energy_usage"},
  ["rocket-silo"] = {"energy_usage"},
  furnace = {"energy_usage"},
  lab = {"energy_usage"},
  ["mining-drill"] = {"energy_usage"},
  pump = {"energy_usage"},
  radar = {"energy_usage"}
}

prototype_tables.machines_with_module_slots = {
  "beacon",
  "assembling-machine",
  "rocket-silo",
  "furnace",
  "lab",
  "mining-drill"
}
prototype_tables.machines_with_module_slots_as_keys = {}
for _, val in pairs(prototype_tables.machines_with_module_slots) do
  prototype_tables.machines_with_module_slots_as_keys[val] = true
end

prototype_tables.machines_with_module_slots_as_keys = {}
for _, val in pairs(prototype_tables.machines_with_module_slots) do
  prototype_tables.machines_with_module_slots_as_keys[val] = true
end

-- Note: not everything that has an EnergySource property actually supports pollution
prototype_tables.polluting_machine_classes = {
  boiler = {"energy_source"},
  ["burner-generator"] = {"burner"}, -- Emissions on energy_source are ignored, they must be put on burner
  ["assembling-machine"] = {"energy_source"},
  ["rocket-silo"] = {"energy_source"},
  furnace = {"energy_source"},
  generator = {"energy_source"},
  ["mining-drill"] = {"energy_source"},
  reactor = {"energy_source"}
}

prototype_tables.power_property_names = {
  beacon = {"energy_usage"},
  ["arithmetic-combinator"] = {"active_energy_usage"},
  ["decider-combinator"] = {"active_energy_usage"},
  ["assembling-machine"] = {"energy_usage"},
  ["rocket-silo"] = {"energy_usage"},
  furnace = {"energy_usage"},
  lab = {"energy_usage"},
  ["mining-drill"] = {"energy_usage"},
  pump = {"energy_usage"},
  --roboport = {"energy_usage"}, Don't randomize roboport energy properties now due to possible conflicts with bot charging
  --                                Note: I seem to randomize them still, just in the entity randomizer, maybe still do this but with checks about bot charging
  --car = {"consumption"}, I think this just increases the car power
  ["belt-immunity-equipment"] = {"energy_consumption"},
  ["movement-bonus-equipment"] = {"energy_consumption"},
  ["night-vision-equipment"] = {"energy_input"},
  radar = {"energy_usage"}
}

prototype_tables.sound_file_extensions = {
  [".ogg"] = true,
  [".wav"] = true,
  [".voc"] = true
}

prototype_tables.tool_classes = {
  "tool",
  "repair-tool"
}

prototype_tables.turret_classes = {
  "ammo-turret",
  "electric-turret",
  "fluid-turret",
  "turret"
}

prototype_tables.transport_belt_classes = {
  "transport-belt",
  "underground-belt",
  "splitter",
  "linked-belt",
  "loader-1x1",
  "loader"
}

prototype_tables.vehicle_classes = {
  "car",
  "artillery-wagon",
  "cargo-wagon",
  "fluid-wagon",
  "locomotive",
  "spider-vehicle"
}

prototype_tables.vehicle_classes_as_keys = {}
for _, val in pairs(prototype_tables.vehicle_classes) do
  prototype_tables.vehicle_classes_as_keys[val] = true
end

prototype_tables.vehicle_speed_keys = {
  car = "consumption",
  ["spider-vehicle"] = "movement_energy_consumption",
  locomotive = "max_power"
}

-- More complex tables
prototype_tables.intermediate_item_names = {}

for _, recipe in pairs(data.raw.recipe) do
  reformat.prototype.recipe(recipe)

  for _, ingredient in pairs(recipe.ingredients) do
    prototype_tables.intermediate_item_names[ingredient.name] = true
  end
end

return prototype_tables