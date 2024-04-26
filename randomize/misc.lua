local inertia_function = require("randomizer-parameter-data/inertia-function-tables")
local property_info = require("randomizer-parameter-data/property-info-tables")
local prototype_tables = require("randomizer-parameter-data/prototype-tables")
local walk_params = require("randomizer-parameter-data/walk-params-tables")

rand.achievements = function(prototype)
    -- TODO: Build incompatibility for mods that change/remove vanilla achievements altogether

    local is_vanilla_achievement = {
        ["computer-age-1"] = true,
        ["computer-age-2"] = true,
        ["computer-age-3"] = true,
        ["circuit-veteran-1"] = true,
        ["circuit-veteran-2"] = true,
        ["circuit-veteran-3"] = true,
        ["steam-all-the-way"] = true,
        ["automated-cleanup"] = true,
        ["automated-construction"] = true,
        ["you-are-doing-it-right"] = true,
        ["lazy-bastard"] = true,
        ["eco-unfriendly"] = true,
        ["tech-maniac"] = true,
        ["mass-production-1"] = true,
        ["mass-production-2"] = true,
        ["mass-production-3"] = true,
        ["getting-on-track"] = true,
        ["getting-on-track-like-a-pro"] = true,
        ["it-stinks-and-they-dont-like-it"] = true,
        ["raining-bullets"] = true,
        ["iron-throne-1"] = true,
        ["iron-throne-2"] = true,
        ["iron-throne-3"] = true,
        ["logistic-network-embargo"] = true,
        ["smoke-me-a-kipper-i-will-be-back-for-breakfast"] = true,
        ["no-time-for-chitchat"] = true,
        ["there-is-no-spoon"] = true,
        ["steamrolled"] = true,
        ["run-forrest-run"] = true,
        ["pyromaniac"] = true,
        ["so-long-and-thanks-for-all-the-fish"] = true,
        ["trans-factorio-express"] = true,
        ["you-have-got-a-package"] = true,
        ["delivery-service"] = true,
        ["golem"] = true,
        ["watch-your-step"] = true,
        ["solaris"] = true,
        ["minions"] = true
    }

    for _, prototype in pairs(data.raw["build-entity-achievement"]) do
        if prototype.amount ~= nil and prototype.amount > 1 then
            randomize_numerical_property({
                prototype = prototype,
                property = "amount",
                property_info = property_info.achievement_amount
            })

            if is_vanilla_achievement[prototype.name] then
                prototype.localised_description = {"achievement-description-propertyrandomizer." .. prototype.name, prototype.amount}
            end
        end

        if prototype.until_second ~= nil and prototype.until_second > 0 then
            randomize_numerical_property({
                prototype = prototype,
                property = "until_second",
                property_info = property_info.achievement_timed
            })

            if is_vanilla_achievement[prototype.name] then
                prototype.localised_description = {"achievement-description-propertyrandomizer." .. prototype.name, math.floor(10 * prototype.until_second / 60) / 10}
            end
        end
    end

    for _, prototype in pairs(data.raw["combat-robot-count"]) do
        if prototype.count ~= nil and prototype.count > 1 then
            randomize_numerical_property({
                prototype = prototype,
                property = "count",
                property_info = property_info.achievement_sensitive
            })

            if is_vanilla_achievement[prototype.name] then
                prototype.localised_description = {"achievement-description-propertyrandomizer." .. prototype.name, prototype.count}
            end
        end
    end

    for _, prototype in pairs(data.raw["construct-with-robots-achievement"]) do
        if prototype.amount ~= nil and prototype.amount > 1 then
            randomize_numerical_property({
                prototype = prototype,
                property = "amount",
                property_info = property_info.achievement_amount
            })

            if is_vanilla_achievement[prototype.name] then
                prototype.localised_description = {"achievement-description-propertyrandomizer." .. prototype.name, prototype.amount}
            end
        end
    end

    for _, prototype in pairs(data.raw["deconstruct-with-robots-achievement"]) do
        if prototype.amount ~= nil and prototype.amount > 1 then
            randomize_numerical_property({
                prototype = prototype,
                property = "amount",
                property_info = property_info.achievement_amount
            })

            if is_vanilla_achievement[prototype.name] then
                prototype.localised_description = {"achievement-description-propertyrandomizer." .. prototype.name, prototype.amount}
            end
        end
    end

    for _, prototype in pairs(data.raw["deliver-by-robots-achievement"]) do
            if prototype.amount > 1 then
            randomize_numerical_property({
                prototype = prototype,
                property = "amount",
                property_info = property_info.achievement_amount
            })

            if is_vanilla_achievement[prototype.name] then
                prototype.localised_description = {"achievement-description-propertyrandomizer." .. prototype.name, prototype.amount}
            end
        end
    end

    for _, prototype in pairs(data.raw["dont-build-entity-achievement"]) do
        if prototype.amount ~= nil and prototype.amount > 1 then
            randomize_numerical_property({
                prototype = prototype,
                property = "amount",
                property_info = property_info.achievement_sensitive
            })

            if is_vanilla_achievement[prototype.name] then
                prototype.localised_description = {"achievement-description-propertyrandomizer." .. prototype.name, prototype.amount}
            end
        end
    end

    for _, prototype in pairs(data.raw["dont-craft-manually-achievement"]) do
        if prototype.amount > 1 then
            randomize_numerical_property({
                prototype = prototype,
                property = "amount",
                property_info = property_info.achievement_lazy_bastard
            })

            if is_vanilla_achievement[prototype.name] then
                prototype.localised_description = {"achievement-description-propertyrandomizer." .. prototype.name, prototype.amount}
            end
        end
    end

    -- TODO: Transition to rand.energy function
    for _, prototype in pairs(data.raw["dont-use-entity-in-energy-production-achievement"]) do
        if prototype.minimum_energy_produced and util.parse_energy(prototype.minimum_energy_produced) > 0 then
            local energy_as_number = util.parse_energy(prototype.minimum_energy_produced)
            randomize_numerical_property({
                dummy = energy_as_number,
                prg_key = prg.get_key(prototype),
                property_info = property_info.achievement_amount
            })
            prototype.minimum_energy_produced = energy_as_number .. "J"

            if is_vanilla_achievement[prototype.name] then
                prototype.localised_description = {"achievement-description-propertyrandomizer." .. prototype.name, util.parse_energy(prototype.minimum_energy_produced) / 1000000000}
            end
        end
    end

    for _, prototype in pairs(data.raw["finish-the-game-achievement"]) do
        if prototype.until_second ~= nil and prototype.until_second > 1 then
            randomize_numerical_property({
                prototype = prototype,
                property = "until_second",
                property_info = property_info.achievement_timed
            })

            if is_vanilla_achievement[prototype.name] then
                prototype.localised_description = {"achievement-description-propertyrandomizer." .. prototype.name, math.floor(10 * prototype.until_second / 3600) / 10}
            end
        end
    end

    for _, prototype in pairs(data.raw["group-attack-achievement"]) do
        if prototype.amount ~= nil and prototype.amount > 1 then
            randomize_numerical_property({
                prototype = prototype,
                property = "amount",
                property_info = property_info.achievement_amount
            })

            if is_vanilla_achievement[prototype.name] then
                prototype.localised_description = {"achievement-description-propertyrandomizer." .. prototype.name, prototype.amount}
            end
        end
    end

    for _, prototype in pairs(data.raw["kill-achievement"]) do
        if prototype.amount ~= nil and prototype.amount > 1 then
            randomize_numerical_property({
                prototype = prototype,
                property = "amount",
                property_info = property_info.achievement_amount
            })

            if is_vanilla_achievement[prototype.name] then
                prototype.localised_description = {"achievement-description-propertyrandomizer." .. prototype.name, prototype.amount}
            end
        end
    end

    for _, prototype in pairs(data.raw["player-damaged-achievement"]) do
        randomize_numerical_property({
            prototype = prototype,
            property = "minimum_damage",
            property_info = property_info.achievement_sensitive
        })

        if is_vanilla_achievement[prototype.name] then
            prototype.localised_description = {"achievement-description-propertyrandomizer." .. prototype.name, prototype.minimum_damage}
        end
    end

    for _, prototype in pairs(data.raw["produce-achievement"]) do
        if prototype.amount > 1 then
            randomize_numerical_property({
                prototype = prototype,
                property = "amount",
                property_info = property_info.achievement_amount
            })

            if is_vanilla_achievement[prototype.name] then
                prototype.localised_description = {"achievement-description-propertyrandomizer." .. prototype.name, prototype.amount}
            end
        end
    end

    for _, prototype in pairs(data.raw["produce-per-hour-achievement"]) do
        if prototype.amount > 1 then
            randomize_numerical_property({
                prototype = prototype,
                property = "amount",
                property_info = property_info.achievement_amount
            })

            if is_vanilla_achievement[prototype.name] then
                prototype.localised_description = {"achievement-description-propertyrandomizer." .. prototype.name, prototype.amount}
            end
        end
    end

    -- research-achievement doesn't have numerical properties, so skip it

    for _, prototype in pairs(data.raw["train-path-achievement"]) do
        randomize_numerical_property({
            prototype = prototype,
            property = "minimum_distance",
            property_info = property_info.achievement_amount
        })

        if is_vanilla_achievement[prototype.name] then
            prototype.localised_description = {"achievement-description-propertyrandomizer." .. prototype.name, prototype.minimum_distance}
        end
    end
end

rand.equipment_active_defense_cooldown = function(prototype)
    if prototype.type == "active-defense-equipment" then
        local attack_parameters = prototype.attack_parameters

        randomize_numerical_property({
            prototype = prototype,
            tbl = attack_parameters,
            property = "cooldown",
            property_info = property_info.attack_parameters_cooldown
        })
    end
end

-- Randomizes through damage modifier
rand.equipment_active_defense_damage = function(prototype)
    if prototype.type == "active-defense-equipment" then
        local attack_parameters = prototype.attack_parameters

        if attack_parameters.damage_modifier == nil then
            attack_parameters.damage_modifier = 1
        end

        randomize_numerical_property({
            prototype = prototype,
            tbl = attack_parameters,
            property = "damage_modifier",
            property_info = property_info.trigger_damage_loose -- Not a trigger damage, but close enough to the same things
        })
    end
end

rand.equipment_active_defense_radius = function(prototype)
    if prototype.type == "active-defense-equipment" then
        local attack_parameters = prototype.attack_parameters

        rand.trigger(prototype, attack_parameters, "randomize-effect-radius")
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

rand.inventory_widths = function()
    local utility_constants = data.raw["utility-constants"].default

    log("ran")

    -- Randomly decrement, increment or keep inventory width the same
    utility_constants.inventory_width = utility_constants.inventory_width + prg.range("utility-constants-inventory-width-randomization", -1, 1)
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
    if prototype.type == "projectile" then
        if prototype.action ~= nil then
            rand.trigger(prototype, prototype.action, "randomize-damage-loose")
        end
    end
end

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