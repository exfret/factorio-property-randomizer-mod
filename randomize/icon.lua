local reformat = require("utilities/reformat")

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

rand.recipe_groups = function()
    local recipe_list = {}
    local subgroup_list = {}
    local order_list = {}
    for _, prototype in pairs(data.raw.recipe) do
        reformat.prototype.recipe(prototype)

        local subgroup = prototype.subgroup
        if subgroup == nil and #prototype.results == 1 then
            local item_name = prototype.results[1].name

            for class_name, _ in pairs(defines.prototypes.item) do
                if data.raw[class_name][item_name] ~= nil then
                    subgroup = data.raw[class_name][item_name].subgroup
                end
            end
        else
            local item_name = prototype.main_product

            for class_name, _ in pairs(defines.prototypes.item) do
                if data.raw[class_name][item_name] ~= nil then
                    subgroup = data.raw[class_name][item_name].subgroup
                end
            end
        end

        table.insert(recipe_list, prototype)
        table.insert(subgroup_list, subgroup)
        table.insert(order_list, prototype.order or "")
    end

    prg.shuffle("recipe-group-randomization-subgroup", subgroup_list)
    prg.shuffle("recipe-group-randomization-order", order_list)

    for i, prototype in pairs(recipe_list) do
        prototype.subgroup = subgroup_list[i]
        prototype.order = order_list[i]
    end
end

-- TODO: Reimplement other picture randomization