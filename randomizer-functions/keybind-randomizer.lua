--[[function simulate_keybind_build_entity(event)
    local player = game.players[event.player_index]

    player.build_from_cursor(event.cursor_position)
end

script.on_event("randomizer-override-build", function(event)

end)

script.on_event("randomizer-override-mine", function(event)
    simulate_keybind_build_entity(event)
end)]]