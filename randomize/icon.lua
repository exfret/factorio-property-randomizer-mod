local inertia_function = require("randomizer-parameter-data/inertia-function-tables")
local property_info = require("randomizer-parameter-data/property-info-tables")
local prototype_tables = require("randomizer-parameter-data/prototype-tables")
local walk_params = require("randomizer-parameter-data/walk-params-tables")

rand.swap_properties = function(prototype_1, prototype_2, properties)
    local temp_property_info = {}
    for _, property in pairs(properties) do
        temp_property_info[property] = prototype_1[property]
    end

    for _, property in pairs(properties) do
        prototype_1[property] = prototype_2[property]
    end

    for _, property in pairs(properties) do
        prototype_2[property] = temp_property_info[property]
    end
end

rand.permute = function(prototypes, properties, do_attack_parameters)
    for i = 1, #prototypes - 1 do
        local j = prg.range(prg.get_key(nil, "dummy"), i, #prototypes)
    
        rand.swap_properties(prototypes[i], prototypes[j], properties)

        -- Used for biter picture swapping, which is unused for now
        if do_attack_parameters == true then
            rand.swap_properties(prototypes[i].attack_parameters, prototypes[j].attack_parameters, {"sound", "animation", "cyclic_sound"})
        end
    end
end

rand.icons = function()
    local number_to_prototype = {}

    for item_class, _ in pairs(defines.prototypes.item) do
        for _, item_prototype in pairs(data.raw[item_class]) do
            table.insert(number_to_prototype, item_prototype)
        end
    end

    local icon_properties = {"icons", "icon", "icon_size", "icon_mipmaps", "dark_background_icons", "dark_background_icon"}
    rand.permute(number_to_prototype, icon_properties)
end

-- TODO: Reimplement other picture randomization