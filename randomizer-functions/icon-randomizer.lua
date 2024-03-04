local prototype_tables = require("randomizer-parameter-data.prototype-tables")

local icon_randomizer = {}

function icon_randomizer.swap_properties(prototype_1, prototype_2, properties)
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

function icon_randomizer.permute(prototypes, properties, do_attack_parameters)
    for i=1,#prototypes-1 do
        local j = prg.range(prg.get_key(nil, "dummy"), i, #prototypes)
    
        icon_randomizer.swap_properties(prototypes[i], prototypes[j], properties)

        if do_attack_parameters == true then
            icon_randomizer.swap_properties(prototypes[i].attack_parameters, prototypes[j].attack_parameters, {"sound", "animation", "cyclic_sound"})
        end
    end
end

local number_to_prototype = {}

for item_class, _ in pairs(defines.prototypes.item) do
    for _, item_prototype in pairs(data.raw[item_class]) do
        table.insert(number_to_prototype, item_prototype)
    end
end

local icon_properties = {"icons", "icon", "icon_size", "icon_mipmaps", "dark_background_icons", "dark_background_icon"}
icon_randomizer.permute(number_to_prototype, icon_properties)

local building_image_properties = {
    --[["fluid_boxes",
    "scale_entity_info_icon",
    "show_recipe_icon",
    "animation",
    "always_draw_idle_animation",
    "default_recipe_tint",
    "shift_animation_waypoints",
    "shift_animation_waypoint_stop_duration",
    "shift_animation_transition_duration",
    "status_colors",
    "entity_info_icon_shift",
    "draw_entity_info_icon_background",
    "match_animation_speed_to_activity",
    "show_recipe_icon_on_map",
    "working_visulations",]] -- Next is entity-with-health
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

--[[local car_image_properties = {
    "crash_trigger",
    "minimap_representation",
    "selected_minimap_representation",
    "stop_trigger"
}
for _, property in pairs(building_image_properties) do
    table.insert(car_image_properties, property)
end

number_to_prototype = {}]]
-- Crafting machines are too complex with their fluid boxes
--[[for _, crafting_machine_class in pairs(prototype_tables.crafting_machine_classes) do
    for _, crafting_prototype in pairs(data.raw[crafting_machine_class]) do
        table.insert(number_to_prototype, crafting_prototype)

        -- Quick easy fix for restrictions on fast replaceable group
        crafting_prototype.fast_replaceable_group = nil
        crafting_prototype.next_upgrade = nil
    end
end]]

--[[for _, car in pairs(data.raw.car) do
    table.insert(number_to_prototype, car)
end
icon_randomizer.swap_properties(data.raw.car.car, data.raw.car.tank, car_image_properties)]]

local electric_pole_image_properties = {
    "connection_points",
    "pictures",
    "active_picture",
    "draw_circuit_wires",
    "draw_copper_wires",
    "light",
    "radius_visualization_picture",
    "track_coverage_during_build_by_moving"
}
for _, property in pairs(building_image_properties) do
    table.insert(electric_pole_image_properties, property)
end

number_to_prototype = {}
for _, prototype in pairs(data.raw["electric-pole"]) do
    table.insert(number_to_prototype, prototype)
end

--icon_randomizer.permute(number_to_prototype, electric_pole_image_properties)

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

--icon_randomizer.permute(number_to_prototype, unit_image_properties, true)

local container_image_properties = {
    "picture",
    "scale_info_icons",
    "circuit_wire_connection_point",
    "draw_copper_wires",
    "draw_circuit_wires",
    "circuit_connector_sprites"
}
for _, property in pairs(building_image_properties) do
    table.insert(container_image_properties, property)
end

number_to_prototype = {}
for _, prototype in pairs(data.raw.container) do
    table.insert(number_to_prototype, prototype)
end

--icon_randomizer.permute(number_to_prototype, container_image_properties)