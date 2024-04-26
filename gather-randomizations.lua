local config = require("config")
local spec = require("spec")
require("analysis/karma")
require("globals")
require("linking-utils")

local blacklist = require("compatibility/blacklist")

-- TODO: Optimize runtime with a preconstructed table of what is in a group
local prototype_groups = {
    {
        property = "crafting_speed",
        list = {
            {"assembling-machine", "assembling-machine-1"},
            {"assembling-machine", "assembling-machine-2"},
            {"assembling-machine", "assembling-machine-3"}
        }
    }
}

-- TODO: Bullets
-- TODO: Armor with like, resistances
-- TODO: Smaller things that are just for modded
-- TODO: Pipe-to-grounds and distance
-- TOOD: Beacons
-- TODO: Equipment! Like batteries and roboports!
local class_to_upgrade_property = {
    ["assembling-machine"] = "crafting_speed",
    ["furnace"] = "crafting_speed",
    ["loader"] = "speed",
    ["loader-1x1"] = "speed",
    ["splitter"] = "speed",
    ["transport-belt"] = "speed",
    ["underground-belt"] = "speed",
    ["lab"] = "researching_speed",
    ["offshore-pump"] = "pumping_speed",
    ["solar-panel"] = {
        name = "production",
        format = "power"
    }
}

function gather_upgrade_lines()
    local upgrade_line_list = {}

    for class, property in pairs(class_to_upgrade_property) do
        local upgrade_groups = find_upgrade_groups(class)

        for _, upgrade_group in pairs(upgrade_groups) do
            local list = {}
            for _, upgrade in pairs(upgrade_group) do
                table.insert(list, {
                    upgrade.type,
                    upgrade.name
                })
            end

            table.insert(upgrade_line_list, {
                property = property,
                list = list
            })
        end
    end

    --[[for _, upgrade_group in pairs(upgrade_groups) do
        log("New group:")
        for _, upgrade in pairs(upgrade_group) do
            log(serpent.block(upgrade.name))
        end
    end]]

    return upgrade_line_list
end

function randomize()
    for _, class in pairs(data.raw) do
        for _, prototype in pairs(class) do
            --[[local is_in_prototype_group = false
            for _, group in pairs(prototype_groups) do
                for _, member in pairs(group) do
                    if member[1] == prototype.type and member[2] == prototype.name then
                        is_in_prototype_group = true
                    end
                end
            end]]

            if not is_in_prototype_group then
                for _, randomization in pairs(spec) do
                    if config.properties[randomization.name] and (not blacklist[randomization.name][prototype.name]) and (not randomization.grouped) then
                        randomization.func(prototype)
                    end
                end
            end
        end
    end

    for _, randomization in pairs(spec) do
        if config.properties[randomization.name] and (not blacklist[randomization.name]["all"]) and randomization.grouped then
            -- TODO: Make spec randomizations indexed by name so we don't have to search for appropriate one
            randomization.func()
        end
    end

    if settings.startup["propertyrandomizer-upgrade-line-preservation"].value then
        -- TODO: Filter on only "sensible" groups
        -- Sensible groups should also have a linear ordering
        -- TODO: Also make sure that things are a decent distance apart later
        -- TODO: Finish and reimplement
        local upgrade_lines = gather_upgrade_lines()
        
        for _, group in pairs(upgrade_lines) do
            local current_property_order = {}
            for _, mem in pairs(group.list) do
                if type(group.property) == "table" then
                    if group.property.format == "power" then
                        table.insert(current_property_order, 60 * util.parse_energy(data.raw[mem[1]][mem[2]][group.property.name]))
                    end
                else
                    table.insert(current_property_order, data.raw[mem[1]][mem[2]][group.property])
                end
            end

            local property_sorted = table.deepcopy(current_property_order)
            table.sort(property_sorted)

            for ind, mem in pairs(group.list) do
                if type(group.property) == "table" then
                    if group.property.format == "power" then
                        data.raw[mem[1]][mem[2]][group.property.name] = property_sorted[ind] .. "W"
                    end
                else
                    data.raw[mem[1]][mem[2]][group.property] = property_sorted[ind]
                end
            end
        end

        -- Modules
        for _, module_category in pairs(data.raw["module-category"]) do
            local upgrade_list_with_num_keys = {}

            for _, module in pairs(data.raw.module) do
                if module.category == module_category.name then
                    if upgrade_list_with_num_keys[module.tier] == nil then
                        upgrade_list_with_num_keys[module.tier] = {}
                    end
                    table.insert(upgrade_list_with_num_keys[module.tier], module)
                end
            end

            local upgrade_list = {}
            for _, list_of_modules in pairs(upgrade_list_with_num_keys) do
                for _, module in pairs(list_of_modules) do
                    table.insert(upgrade_list, module)
                end
            end

            -- Determine effect priority via first entry
            -- TODO: Figure out what the type of module is BEFORE randomization!
            local effect_property = "productivity"
            if upgrade_list[1].effect.productivity == nil or upgrade_list[1].effect.productivity.bonus == nil or upgrade_list[1].effect.productivity.bonus == 0 then
                effect_property = "speed"
            end
            if effect_property == "speed" and (upgrade_list[1].effect.speed == nil or upgrade_list[1].effect.speed.bonus == nil or upgrade_list[1].effect.speed.bonus == 0) then
                effect_property = "consumption"
            end
            if effect_property == "consumption" and (upgrade_list[1].effect.consumption == nil or upgrade_list[1].effect.consumption.bonus == nil or upgrade_list[1].effect.consumption.bonus == 0) then
                effect_property = "pollution"
            end
            if effect_property == "pollution" and (upgrade_list[1].effect.pollution == nil or upgrade_list[1].effect.pollution.bonus == nil or upgrade_list[1].effect.pollution.bonus == 0) then
                effect_property = "invalid" -- This means the first module has no effects, so there's no way to see what the property upgrade line is
            end

            -- TODO: Remove hotfix
            if module_category.name == "effectivity" then
                effect_property = "consumption"
            end

            if effect_property ~= "invalid" then
                local current_property_order = {}
                for _, mem in pairs(upgrade_list) do
                    local multiplier = 1
                    if effect_property == "consumption" or effect_property == "pollution" then
                        multiplier = -1
                    end
                    if mem.effect[effect_property] ~= nil and mem.effect[effect_property].bonus ~= nil then
                        table.insert(current_property_order, multiplier * mem.effect[effect_property].bonus)
                    else
                        table.insert(current_property_order, 0)
                    end
                end

                local property_sorted = table.deepcopy(current_property_order)
                table.sort(property_sorted)

                for ind, mem in pairs(upgrade_list) do
                    local multiplier = 1
                    if effect_property == "consumption" or effect_property == "pollution" then
                        multiplier = -1
                    end

                    mem.effect[effect_property].bonus = multiplier * property_sorted[ind]
                end
            end
        end
    end

    if false then
    -- This is so hacky...
    DEFAULT_WALK_PARAMS_NUM_STEPS = 1
    NUDGE_MODIFIER = 1 / 75
    -- Group fixes
    for _, group in pairs(prototype_groups) do
        local karma_values = {}
        local total_steps = {}
        for _, member in pairs(group) do
            table.insert(karma_values, karma.util.get_goodness(karma.values.prototype_values[prg.get_key(data.raw[member[1]][member[2]])]))
            table.insert(total_steps, karma.values.prototype_values[prg.get_key(data.raw[member[1]][member[2]])].num_steps)
        end

        local karma_values_sorted = table.deepcopy(karma_values)
        table.sort(karma_values_sorted)

        -- Now need to adjust property values
        for ind, _ in pairs(group) do
            local prototype = data.raw[group[ind][1]][group[ind][2]]

            --log(karma.util.get_goodness(karma.values.prototype_values[prg.get_key(prototype)]))

            -- Bring prototype closer to karma_values_sorted value
            local amount_remaining = math.abs(karma.util.get_goodness(karma.values.prototype_values[prg.get_key(prototype)]) - karma_values_sorted[ind])
            while amount_remaining > 0.001 do
                local sign
                if karma.util.get_goodness(karma.values.prototype_values[prg.get_key(prototype)]) > karma_values_sorted[ind] then
                    sign = "make_worse"
                else
                    sign = "make_better"
                end

                -- Just do a random property for now since we have no way of telling if a property applies up front
                local randomization = spec[prg.int(prg.get_key(prototype), #spec)]
                if not randomization.grouped then
                    local old_karma = table.deepcopy(karma.values.prototype_values[prg.get_key(prototype)])
                    local old_prototype = table.deepcopy(prototype)

                    randomization.func(prototype)
                    
                    -- TODO: Still preserve property_info fixes
                    -- Check that the randomization actually moved things in the correct direction
                    if (sign == "make_worse" and karma.util.get_goodness(karma.values.prototype_values[prg.get_key(prototype)]) > karma.util.get_goodness(old_karma)) or (sign == "make_better" and karma.util.get_goodness(karma.values.prototype_values[prg.get_key(prototype)]) < karma.util.get_goodness(old_karma)) then
                        -- TODO: Also fix class and property values!
                        karma.values.prototype_values[prg.get_key(prototype)] = old_karma
                        prototype = old_prototype
                    elseif karma.values.prototype_values[prg.get_key(prototype)].num_steps > old_karma.num_steps then -- Check num steps to make sure a randomization was performed
                        -- TODO: This is so god awfully bad of a way to do this, please fix
                        log(group[ind][2])
                        log(karma.update_params.prototype_update_step * math.abs(2 * (karma.values.prototype_values[prg.get_key(prototype)].num_good_steps - old_karma.num_good_steps) - DEFAULT_WALK_PARAMS_NUM_STEPS) / 75)
                        log(amount_remaining)
                        amount_remaining = amount_remaining - karma.update_params.prototype_update_step * math.abs(2 * (karma.values.prototype_values[prg.get_key(prototype)].num_good_steps - old_karma.num_good_steps) - DEFAULT_WALK_PARAMS_NUM_STEPS) / 75 / 10 -- Idk why 10 but it feels good
                    end
                end
            end
        end
    end
    end
end