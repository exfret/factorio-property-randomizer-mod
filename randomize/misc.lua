local inertia_function = require("randomizer-parameter-data/inertia-function-tables")
local property_info = require("randomizer-parameter-data/property-info-tables")
local prototype_tables = require("randomizer-parameter-data/prototype-tables")
local walk_params = require("randomizer-parameter-data/walk-params-tables")

local function is_sound_file(file)
    return file and string.len(file) >= 4 and prototype_tables.sound_file_extensions[string.sub(file, -4)]
end

local function is_sound_property(property)
    if type(property) ~= "table" then
        return false
    end
  
    if is_sound_file(property.filename) then
        return true
    end
    if property[1] and type(property[1]) == "table" and is_sound_file(property[1].filename) then
        return true
    end
    if property.variations and is_sound_file(property.variations.filename) then
        return true
    end
    if property.variations and property.variations[1] and is_sound_file(property.variations[1].filename) then
        return true
    end
  
    return false
end

rand.sounds = function()
    local sounds = {}

    -- Gather up all the sounds
    for _, class in pairs(data.raw) do
        for _, prototype in pairs(class) do
            for _, property in pairs(prototype) do
                if is_sound_property(property) then
                    table.insert(sounds, property)
                end
            end
        end
    end

    log(#sounds)
  
    -- Now mix them all together
    for _, class in pairs(data.raw) do
        for _, prototype in pairs(class) do
            for property_key, property in pairs(prototype) do
                if is_sound_property(property) then
                    local new_sound_index = prg.range("sound-prg-key", 1, #sounds)
                    log(new_sound_index)

                    -- TODO: Do a permuation rather than just a random function
                    prototype[property_key] = sounds[new_sound_index] -- TODO: Use another distinct key for this
                end
            end
        end
    end
end

rand.equipment_grids = function(prototype)
    if prototype.type == "equipment-grid" then
        randomize_numerical_property({
            prototype = prototype,
            property = "height",
            property_info = property_info.equipment_grid
        })
        randomize_numerical_property({
            prototype = prototype,
            property = "width",
            property_info = property_info.equipment_grid
        })
    end
end

rand.fluid_emissions_multiplier = function(prototype)
    if prototype.type == "fluid" then
        if prototype.emissions_multiplier == nil then
            prototype.emissions_multiplier = 1
        end

        randomize_numerical_property({
            prototype = prototype,
            property = "emissions_multiplier",
            property_info = property_info.fluid_emissions_multiplier
        })
    end
end

rand.map_colors = function()
    for entity_class, _ in pairs(defines.prototypes.entity) do
        for _, entity in pairs(data.raw[entity_class]) do
            -- TODO: Fill in defaults, or just ignore them; right now this does nothing for entities with default colors
            if entity.map_color ~= nil then
                entity.map_color = {r = prg.float_range(prg.get_key(entity), 0, 1), g = prg.float_range(prg.get_key(entity), 0, 1), b = prg.float_range(prg.get_key(entity), 0, 1)}
            end
            if entity.friendly_map_color ~= nil then
                entity.friendly_map_color = {r = prg.float_range(prg.get_key(entity), 0, 1), g = prg.float_range(prg.get_key(entity), 0, 1), b = prg.float_range(prg.get_key(entity), 0, 1)}
            end
            if entity.enemy_map_color ~= nil then
                entity.enemy_map_color = {r = prg.float_range(prg.get_key(entity), 0, 1), g = prg.float_range(prg.get_key(entity), 0, 1), b = prg.float_range(prg.get_key(entity), 0, 1)}
            end
        end
    end
end

rand.projectile_damage = function(prototype)
    local function randomize_action(action)
        local function randomize_action_delivery_damage(action_delivery)
            local function randomize_target_effects_damage(target_effect)
                if target_effect.type == "damage" then
                    randomize_numerical_property({
                        tbl = target_effect.damage,
                        property = "amount",
                        inertia_function = inertia_function.projectile_damage,
                        walk_params = walk_params.projectile_damage,
                        property_info = property_info.projectile_damage
                    })
                end
            end

            if action_delivery.target_effects ~= nil then
                local target_effects_table = action_delivery.target_effects

                if target_effects_table.type ~= nil then
                    randomize_target_effects_damage(target_effects_table)
                else
                    for _, target_effect in pairs(target_effects_table) do
                        randomize_target_effects_damage(target_effect)
                    end
                end
            end
        end

        if action ~= nil then
            local action_delivery_table = action.action_delivery
    
            if action_delivery_table ~= nil then
                if action_delivery_table.type ~= nil then
                    randomize_action_delivery_damage(action_delivery_table)
                else
                    for _, action_delivery in pairs(action_delivery_table) do
                        randomize_action_delivery_damage(action_delivery)
                    end
                end
            end
        end
    end

    if prototype.type == "projectile" and prototype.action ~= nil then
        local action_table = prototype.action
  
        if action_table ~= nil then
            if action_table.type ~= nil then
                randomize_action(action_table)
            else
                for _, action in pairs(action_table) do
                    randomize_action(action)
                end
            end
        end
    end
end

-- Due to complications from tile directions (mainly hazard concrete), do this over all tiles at once for now
rand.tile_walking_speed_modifier = function()
    local tile_sets = {}

    local tiles_to_evaluate = {}
    for _, prototype in pairs(data.raw.tile) do
        tiles_to_evaluate[prototype.name] = true
    end

    for _, prototype in pairs(data.raw.tile) do
        if tiles_to_evaluate[prototype.name] then
            local curr_tile = prototype
            local curr_tile_set = {}
            table.insert(curr_tile_set, curr_tile)
            tiles_to_evaluate[curr_tile.name] = false

            while (curr_tile.next_direction and curr_tile.next_direction ~= prototype.name) do
                curr_tile = data.raw.tile[curr_tile.next_direction]
                table.insert(curr_tile_set, curr_tile)
                tiles_to_evaluate[prototype.name] = false
            end

            table.insert(tile_sets, curr_tile_set)
        end
    end

    for _, tile_set in pairs(tile_sets) do
        local group_params = {}

        for _, tile in pairs(tile_set) do
            if tile.walking_speed_modifier == nil then
                tile.walking_speed_modifier = 1
            end

            local inertia_function_to_use = inertia_function.tile_walking_speed_modifier
            if tile.walking_speed_modifier == 1 then
                inertia_function_to_use = inertia_function.tile_walking_speed_modifier_nonstandard
            end

            table.insert(group_params, {
                prototype = tile,
                property = "walking_speed_modifier",
                inertia_function = inertia_function_to_use,
                property_info = property_info.tile_walking_speed_modifier
            })
        end

        randomize_numerical_property({
            group_params = group_params,
            walk_params = walk_params.tile_walking_speed_modifier
        })
    end
end