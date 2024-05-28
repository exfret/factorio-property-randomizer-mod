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
            for _, randomization in pairs(spec) do
                if config.properties[randomization.name] and (not blacklist[randomization.name][prototype.name]) and (not randomization.grouped) and randomization.func ~= "control" then
                    randomization.func(prototype)
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
end