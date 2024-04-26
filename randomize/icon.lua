local reformat = require("utilities/reformat")

local inertia_function = require("randomizer-parameter-data/inertia-function-tables")
local property_info = require("randomizer-parameter-data/property-info-tables")
local prototype_tables = require("randomizer-parameter-data/prototype-tables")
local walk_params = require("randomizer-parameter-data/walk-params-tables")

-- TODO: Put these into a utilities file
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

rand.biter_images = function()
    local building_image_properties = { -- Next is entity-with-health
        "dying_explosion",
        "dying_trigger_effect",
        "damaged_trigger_effect",
        "attack_reaction",
        "repair_sound",
        "alert_when_damaged",
        "hide_resistances",
        "create_ghost_on_death",
        "random_corpse_variation",
        "integration_parch_render_layer",
        "corpse",
        "integration_patch", -- Next is entity
        "icons",
        "icon",
        "icon_size",
        "icon_mipmaps",
        "collision_box",
        "collision_mask",
        "map_generator_bounding_box",
        "selection_box",
        "drawing_box",
        "sticker_box",
        "hit_visualization_box",
        "trigger_target_mask",
        "build_grid_size",
        "remove_decoratives",
        "shooting_cursor_size",
        "created_smoke",
        "working_sound",
        "created_effect",
        "build_sound",
        "mined_sound",
        "mining_sound",
        "rotated_sound",
        "vehicle_impact_sound",
        "open_sound",
        "close_sound",
        "radius_visualization_specification",
        "alert_icon_shift",
        "alert_icon_scale",
        "fast_replaceable_group",
        "next_upgrade",
        "protected_from_tile_building",
        "remains_when_mined",
        "additional_pastable_entities",
        "tile_width",
        "tile_height",
        "water_reflection"
    }

    local unit_image_properties = {
        "run_animation",
        "alternative_attacking_frame_sequence",
        "dying_sound",
        "light",
        "render_layer",
        "running_sound_animation_positions",
        "walking_sound"
    }
    for _, property in pairs(building_image_properties) do
        table.insert(unit_image_properties, property)
    end
    
    number_to_prototype = {}
    for _, prototype in pairs(data.raw.unit) do
        table.insert(number_to_prototype, prototype)
    end
    
    rand.permute(number_to_prototype, unit_image_properties, true)
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