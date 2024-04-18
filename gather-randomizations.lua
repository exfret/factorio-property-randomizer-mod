local config = require("config")
local spec = require("spec")

local blacklist = require("compatibility/blacklist")

function randomize()
    for _, class in pairs(data.raw) do
        for _, prototype in pairs(class) do
            for _, randomization in pairs(spec) do
                -- TODO: Print message if player writes randomization name incorrectly

                if config.properties[randomization.name] and (not blacklist[randomization.name][prototype.name]) and (not randomization.grouped) then
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
end