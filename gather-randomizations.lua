blop.blop = nil -- So, reformat things, then have the functions gather the prototypes themselves

blop.blop = nil -- Make these files return things

local energy_randomizer = require("randomizer-functions/energy-randomizer")
local entity_randomizer = require("randomizer-functions/entity-randomizer")
local item_randomizer = require("randomizer-functions/item-randomizer")
local locale_randomizer = require("randomizer-functions/locale-randomizer") -- Currently TODO
local misc_randomizer = require("randomizer-functions/misc-randomizer")
local recipe_randomizer = require("randomizer-functions/recipe-randomizer")
local technology_randomizer = require("randomizer-functions/technology-randomizer")

local gather_randomizations = {}

blop.blop = nil -- Separate randomization functions more so these all make sense

blop.blop = nil -- Add tags for randomizations and names for configs

-- In the form {func = [function to do randomization], tags = [list of tags]}
local randomization_spec = {
    {
        func = energy_randomizer.randomize_energy_source_electric_buffer_capacity,
        tags = {"electric", "energy_source", "entity"}
    },
    {
        func = energy_randomizer.randomize_energy_source_electric_input_flow_limit
    },
    {
        func = energy_randomizer.randomize_energy_source_electric_output_flow_limit
    },
    {
        func = energy_randomizer.randomize_energy_source_burner_effectivity
    },
    {
        func = energy_randomizer.randomize_energy_source_fluid_effectivity
    },
    {
        func = energy_randomizer.randomize_energy_source_fluid_usage
    },
    {
        func = energy_randomizer.randomize_boiler_power_production
    },
    {
        func = energy_randomizer.randomize_boiler_target_temperature
    },
    {
        func = energy_randomizer.randomize_burner_generator_max_power_output
    },
    {
        func = energy_randomizer.randomizer_electric_energy_interface_
    },
    {
        func = energy_randomizer.randomize_energy_source_fluid_maximum_temperature
    },
    {
        func = energy_randomizer.randomize_heat_buffer_max_transfer,
        targets = {filter = "has-heat-buffer"}
    },
    {
        func = energy_randomizer.randomize_heat_buffer_specific_heat,
        targets = {filter = "has-heat-buffer"}
    },
    {
        func = energy_randomizer.randomize_heat_buffer_temperatures,
        targets = {filter = "has-heat-buffer"}
    },
    {
        func = item_randomizer.randomize_ammo_damage,
        targets = {filter = "has-ammo-type"}
    }
}

-- List of tables with signature {randomization = [function], blacklist = [table of protoype --> bool of whether blacklisted]}
gather_randomizations.list_to_randomize = {}



return gather_randomizations