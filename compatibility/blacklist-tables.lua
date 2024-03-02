local blacklist = {
    ["randomize_inventory_sizes"] = {},
    ["randomize_storage_tank_capacity"] = {}
}

if mods["space-exploration"] then
    blacklist["randomize_inventory_sizes"]["se-rocket-landing-pad"] = true
    blacklist["randomize_inventory_sizes"]["se-cargo-rocket-cargo-pod"] = true
    blacklist["randomize_inventory_sizes"]["se-rocket-launch-pad"] = true

    blacklist["randomize_storage_tank_capacity"]["se-rocket-launch-pad-tank"] = true
end

return blacklist