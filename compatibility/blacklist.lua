local spec = require("spec")

local blacklist = {}

for _, randomization in pairs(spec) do
    blacklist[randomization.name] = {}
end

if mods["space-exploration"] then
    blacklist["inventory-sizes"]["se-rocket-landing-pad"] = true
    blacklist["inventory-sizes"]["se-cargo-rocket-cargo-pod"] = true
    blacklist["inventory-sizes"]["se-rocket-launch-pad"] = true

    blacklist["tank-capacity"]["se-rocket-launch-pad-tank"] = true
end

return blacklist