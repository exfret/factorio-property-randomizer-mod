local config = require("config")
local spec = require("spec")
require("analysis/karma")
require("globals")

local blacklist = require("compatibility/blacklist")

-- TODO: Optimize runtime with a preconstructed table of what is in a group
local prototype_groups = {
    {
        {"assembling-machine", "assembling-machine-1"},
        {"assembling-machine", "assembling-machine-2"},
        {"assembling-machine", "assembling-machine-3"}
    }
}

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
                    -- TODO: Print message if player writes randomization name incorrectly

                    if config.properties[randomization.name] and (not blacklist[randomization.name][prototype.name]) and (not randomization.grouped) then
                        randomization.func(prototype)
                    end
                end
            end
        end
    end

    if false then
    for _, group in pairs(prototype_groups) do
        local randomized_in_order = false
        while not randomized_in_order do
            local prototypes_copy = {}
            for _, member in pairs(group) do
                table.insert(prototypes_copy, table.deepcopy(data.raw[member[1]][member[2]]))
            end

            --for _, prototype in pairs(
        end
    end
    end

    for _, randomization in pairs(spec) do
        if config.properties[randomization.name] and (not blacklist[randomization.name]["all"]) and randomization.grouped then
            -- TODO: Make spec randomizations indexed by name so we don't have to search for appropriate one
            randomization.func()
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