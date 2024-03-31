local inputs_table = {
    "build",
    --"clear-cursor",
    --"confirm-gui",
    --"confirm-message",
    "mine"
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