local inertia_function = require("randomizer-parameter-data/inertia-function-tables")
local property_info = require("randomizer-parameter-data/property-info-tables")
local prototype_tables = require("randomizer-parameter-data/prototype-tables")
local walk_params = require("randomizer-parameter-data/walk-params-tables")

rand.trigger_effect_item = function(prototype, tbl, target)
    -- TODO: Main body

    if tbl.type == "damage" and target == "randomize-damage" then
        randomize_numerical_property({
            prototype = prototype,
            tbl = tbl.damage,
            property = "amount",
            inertia_function = inertia_function.trigger_damage,
            walk_params = walk_params.trigger_damage,
            property_info = property_info.trigger_damage
        })
    end

    if tbl.type == "damage" and target == "randomize-damage-loose" then
        randomize_numerical_property({
            prototype = prototype,
            tbl = tbl.damage,
            property = "amount",
            property_info = property_info.trigger_damage_loose
        })
    end

    if tbl.type == "nested-result" then
        rand.trigger(prototype, tbl.action, target)
    end
end

rand.trigger_effect = function(prototype, tbl, target)
    if tbl == nil then
        return
    end

    if tbl.type ~= nil then
        rand.trigger_effect_item(prototype, tbl, target)
    else
        for _, val in pairs(tbl) do
            rand.trigger_effect_item(prototype, val, target)
        end
    end
end

rand.trigger_delivery = function(prototype, tbl, target)
    -- TODO: Main body

    rand.trigger_effect(prototype, tbl.source_effects, target)
    rand.trigger_effect(prototype, tbl.target_effects, target)
end

rand.trigger_item = function(prototype, tbl, target)
    -- TODO: Main body

    local delivery = tbl.action_delivery
    if delivery ~= nil then
        if delivery.type ~= nil then
            rand.trigger_delivery(prototype, delivery, target)
        else
            for _, val in pairs(delivery) do
                rand.trigger_delivery(prototype, val, target)
            end
        end
    end
end

rand.trigger = function(prototype, tbl, target)
    -- TODO: Add check that this is a specific effect radius rather than just any effect
    if tbl.type == "area" and target == "randomize-effect-radius" then
        randomize_numerical_property({
            prototype = prototype,
            tbl = tbl,
            property = "radius",
            property_info = property_info.limited_range
        })
    end

    if tbl.type ~= nil then
        rand.trigger_item(prototype, tbl, target)
    else
        for _, val in pairs(tbl) do
            rand.trigger_item(prototype, val, target)
        end
    end
end