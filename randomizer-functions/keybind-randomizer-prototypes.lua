-- Just do keyboard


-- TODO: Map, pipette, inventory, movement
local inputs_table = {
    --"build",
    --"confirm-gui",
    --"confirm-message",
    --"mine",
    "clear-cursor",
    "move-down",
    "move-left",
    "move-right",
    "move-up"
}

for _, input in pairs(inputs_table) do
    data:extend({
        {
            type = "custom-input",
            name = "randomizer-override-" .. input,
            key_sequence = "",
            linked_game_control = input,
            consuming = "game-only"
        }
    })
end