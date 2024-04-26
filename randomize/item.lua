local reformat = require("utilities/reformat")

local inertia_function = require("randomizer-parameter-data/inertia-function-tables")
local property_info = require("randomizer-parameter-data/property-info-tables")
local prototype_tables = require("randomizer-parameter-data/prototype-tables")
local walk_params = require("randomizer-parameter-data/walk-params-tables")

rand.capsule_healing = function(prototype)
    if prototype.type == "capsule" then
        -- TODO
    end
end

rand.capsule_throw_range = function(prototype)
    if prototype.type == "capsule" then
        local capsule_action = prototype.capsule_action

        if capsule_action.type == "throw" then
            local attack_parameters = capsule_action.attack_parameters

            -- TODO: Modify radius visualization circle too (it's in the Entity prototype properties, not capsule)
            randomize_numerical_property({
                prototype = prototype,
                tbl = attack_parameters,
                property = "range",
                property_info = property_info.limited_range
            })
        end
    end
end

rand.ammo_damage = function(prototype)
    if prototype.type == "ammo" then
        if prototype.ammo_type.action ~= nil then
            rand.trigger(prototype, prototype.ammo_type.action, "randomize-damage")
        end
    end
end

rand.ammo_magazine_size = function(prototype)
    if prototype.type == "ammo" then
        -- Don't randomize magazine sizes of 1, they probably don't need to be randomized
        if prototype.magazine_size ~= nil and prototype.magazine_size ~= 1 then
            randomize_numerical_property{
                prototype = prototype,
                property = "magazine_size",
                property_info = property_info.magazine_size,
                walk_params = walk_params.magazine_size
            }
        end
    end
end

rand.gun_damage_modifier = function(prototype)
    if prototype.type == "gun" then
        if prototype.attack_parameters.damage_modifier == nil then
            prototype.attack_parameters.damage_modifier = 1
        end

        randomize_numerical_property({
            prototype = prototype,
            tbl = prototype.attack_parameters,
            property = "damage_modifier",
            walk_params = walk_params.gun_damage_modifier,
            property_info = property_info.gun_damage_modifier
        })
    end
end

rand.gun_movement_slowdown_factor = function(prototype)
    if prototype.type == "gun" then
        local attack_parameters = prototype.attack_parameters

        -- Don't randomize things that don't have a slowdown
        -- TODO: Is 0 the actual non-slowdown factor number? I'm confused how to interpret this number
        if attack_parameters.movement_slow_down_factor ~= nil and attack_parameters.movement_slow_down_factor ~= 1 then
            randomize_numerical_property({
                prototype = prototype,
                tbl = attack_parameters,
                property = "movement_slow_down_factor",
                property_info = property_info.limited_range_very_strict
            })
        end
    end
end

rand.gun_range = function(prototype)
    if prototype.type == "gun" then
        randomize_numerical_property({
            prototype = prototype,
            tbl = prototype.attack_parameters,
            property = "range",
            property_info = property_info.gun_shooting_range
        })
    end
end

rand.gun_speed = function(prototype)
    if prototype.type == "gun" then
        randomize_numerical_property({
            prototype = prototype,
            tbl = prototype.attack_parameters,
            property = "cooldown", -- I would round, but that requires taking the inverses into account
            property_info = property_info.gun_cooldown
        })
    end
end

rand.item_stack_sizes = function(prototype)
    if defines.prototypes.item[prototype.type] then
        -- Don't modify stack size if it's 1
        if prototype.stack_size ~= nil and prototype.stack_size ~= 1 then
            local property_info_to_use = property_info.stack_size
            -- Use sensitive stack size if it is a building or if it is used in making a building
            for _, recipe in pairs(data.raw.recipe) do
                reformat.prototype.recipe(recipe) -- TODO: Reformat beforehand and remove this

                for _, ingredient in pairs(recipe.ingredients) do
                    if ingredient.name == prototype.name then
                        for _, result in pairs(recipe.results) do
                            for item_class, _ in pairs(defines.prototypes.item) do
                                if item_class[result.name] ~= nil then
                                    if item_class[result.name].place_result ~= nil then
                                        property_info_to_use = property_info.stack_size_sensitive
                                    end
                                end
                            end
                        end
                    end
                end
            end
            if prototype.place_result ~= nil then
                property_info_to_use = property_info.stack_size_sensitive
            end

            randomize_numerical_property{
                prototype = prototype,
                property = "stack_size",
                inertia_function = inertia_function.stack_size,
                property_info = property_info_to_use,
                walk_params = walk_params.stack_size
            }
        end
    end
end

-- TODO: randomly add a very small amount of productivity
-- Productivity shouldn't be changed much
-- TODO: Make higher tier modules more likely to receive better effects, like productivity
--      (I'm given tier info so might as well use it)
-- TODO: Randomize whether to even add/remove effects, instead of just randomizing each effect into a slurry
-- TODO: Figure out a smarter way to deal with the OP productivity effect
-- TODO: Balance the modules/soft link or smth
-- TODO: Separate out based on effects
rand.module_effects = function(prototype)
    if prototype.type == "module" then
        -- Populate effects
        local effects = {
            consumption = true,
            speed = true,
            productivity = true,
            pollution = true
        }

        for effect, _ in pairs(effects) do
            if prototype.effect[effect] == nil then
                prototype.effect[effect] = {bonus = 0}
            end
            if prototype.effect[effect].bonus == nil then
                prototype.effect[effect] = {bonus = 0}
            end
        end

        randomize_numerical_property({
            prototype = prototype,
            tbl = prototype.effect.consumption,
            property = "bonus",
            inertia_function = inertia_function.consumption_effect,
            property_info = property_info.consumption_effect
        })

        randomize_numerical_property({
            prototype = prototype,
            tbl = prototype.effect.speed,
            property = "bonus",
            inertia_function = inertia_function.speed_effect,
            property_info = property_info.speed_effect
        })
  
        -- The way productivity's inertia function is defined, this won't introduce productivity where it didn't already exist
        randomize_numerical_property({
            prototype = prototype,
            tbl = prototype.effect.productivity,
            property = "bonus",
            inertia_function = inertia_function.productivity_effect,
            walk_params = walk_params.productivity_effect,
            property_info = property_info.productivity_effect
        })

        randomize_numerical_property({
            prototype = prototype,
            tbl = prototype.effect.pollution,
            property = "bonus",
            inertia_function = inertia_function.pollution_effect,
            property_info = property_info.pollution_effect
        })
    end
end

rand.repair_tool_speeds = function(prototype)
    if prototype.type == "repair-tool" then
        randomize_numerical_property({
            prototype = prototype,
            property = "speed",
            property_info = property_info.repair_tool_speed
        })
    end
end