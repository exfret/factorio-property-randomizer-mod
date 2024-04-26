local inertia_function = require("randomizer-parameter-data/inertia-function-tables")
local property_info = require("randomizer-parameter-data/property-info-tables")
local prototype_tables = require("randomizer-parameter-data/prototype-tables")
local walk_params = require("randomizer-parameter-data/walk-params-tables")

local collision_mask_util = require("collision-mask-util")

-- TODO
rand.collision_masks = function()
    local toggles = {
        character_train_collision = {
            "character",
            "train-layer"
        },
        character_rail_collision = {
            "character",
            "rail-layer"
        },
        character_resource_collision = {
            "character",
            "resource-layer"
        },
        character_water_collision = {
            "character",
            "water-tile"
        }
    }
    -- Add player layers
    for entity_class, _ in pairs(defines.prototypes.entity) do
        local default_masks = collision_mask_util.get_default_mask(entity_class)

        local has_player_layer = false
        for _, layer in pairs(default_masks) do
            if layer == "player-layer" then
                has_player_layer = true
            end
        end

        if has_player_layer and entity_class ~= "character" then
            toggles["player_layer_" .. entity_class] = {
                entity_class,
                "player-layer"
            }
        end
    end

    -- If the collision mask is not the default, it probably is special and should stay that way
    local has_default_collision_layer = {}
    for entity_class, _ in pairs(defines.prototypes.entity) do
        for _, entity in pairs(data.raw[entity_class]) do
            if entity.collision_mask == nil or collision_mask_util.masks_are_same(entity.collision_mask, collision_mask_util.get_default_mask(entity.type)) then
                has_default_collision_layer[entity.name] = true
            end
        end
    end

    for toggle_id, toggle in pairs(toggles) do
        for _, entity in pairs(data.raw[toggle[1]]) do
            if has_default_collision_layer[entity.name] then
                local key = "collision-mask-randomization" .. toggle_id .. entity.name
                local random_value = prg.value(key)

                -- Turn the collision mask on with 30% chance, and off with 30% chance
                if random_value < 0.3 then
                    local new_collision_mask = collision_mask_util.get_mask(entity)
                    collision_mask_util.add_layer(new_collision_mask, toggle[2])
                    entity.collision_mask = new_collision_mask
                elseif random_value > 0.7 then
                    local new_collision_mask = collision_mask_util.get_mask(entity)
                    collision_mask_util.remove_layer(new_collision_mask, toggle[2])
                    entity.collision_mask = new_collision_mask
                end
            end
        end
    end

    -- Fix things from the same next_upgrade groups
    local entity_name_to_downgrades = {}
    for entity_class, _ in pairs(defines.prototypes.entity) do
        for _, prototype in pairs(data.raw[entity_class]) do
            if prototype.next_upgrade ~= nil and prototype.next_upgrade ~= prototype.name then
                if entity_name_to_downgrades[prototype.next_upgrade] == nil then
                    entity_name_to_downgrades[prototype.next_upgrade] = {prototype.name}
                else
                    table.insert(entity_name_to_downgrades[prototype.next_upgrade], prototype.name)
                end
            end
        end
    end

    local fixed_from_above = {}
    for entity_name, downgrades in pairs(entity_name_to_downgrades) do
        if not fixed_from_above[entity_name] then
            local collision_mask_to_apply
            for entity_class, _ in pairs(defines.prototypes.entity) do
                if data.raw[entity_class][entity_name] ~= nil then
                    collision_mask_to_apply = collision_mask_util.get_mask(data.raw[entity_class][entity_name])
                end
            end

            local entities_touched = {}
            local queue = {entity_name}
            local curr_ind = 1
            local last_ind = 2
            while queue[curr_ind] ~= nil do
                if (not entities_touched[queue[curr_ind]]) and entity_name_to_downgrades[queue[curr_ind]] ~= nil then
                    for _, other_entity_name in pairs(entity_name_to_downgrades[queue[curr_ind]]) do
                        for entity_class, _ in pairs(defines.prototypes.entity) do
                            if data.raw[entity_class][other_entity_name] ~= nil then
                                data.raw[entity_class][other_entity_name].collision_mask = collision_mask_to_apply
                            end
                        end
                        queue[last_ind] = other_entity_name
                        last_ind = last_ind + 1
                    end
                end

                entities_touched[queue[curr_ind]] = true
                fixed_from_above[queue[curr_ind]] = true

                queue[curr_ind] = nil
                curr_ind = curr_ind + 1
            end
        end
    end
end