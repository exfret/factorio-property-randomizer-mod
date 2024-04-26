function simulate_pipette_tool(event)
    local player = game.players[event.player_index]
    
    if player.hand_location == nil then
        -- Nothing is in cursor, so pipette
        local pipette_entities = player.surface.find_entities_filtered({position = event.cursor_position, radius = 1})
        local entity = pipette_entities[1]

        if entity ~= nil then
            player.pipette_entity(entity)
        end
    else
        -- Something is in cursor, so clear cursor
        player.clear_cursor()
    end
end

script.on_event("randomizer-override-clear-cursor", function(event)
    local player = game.players[event.player_index]
end)

script.on_event("randomizer-override-move-up", function(event)
    local player = game.players[event.player_index]

    local last_movement = global.directions_time[event.player_index][1]
    last_movement = math.min(last_movement, global.directions_time[event.player_index][2])
    last_movement = math.min(last_movement, global.directions_time[event.player_index][3])
    last_movement = math.min(last_movement, global.directions_time[event.player_index][4])

    global.directions_time[event.player_index][1] = 0

    if global.directions[event.player_index][1] == 0 and global.directions[event.player_index][2] == 0 and global.directions[event.player_index][3] == 1 and global.directions[event.player_index][4] == 0 then
        global.directions[event.player_index] = {0, 0, 0, 0}
    elseif global.directions[event.player_index][1] == 1 or last_movement >= 35 then
        global.directions[event.player_index] = {1, 0, 0, 0}
    else
        global.directions[event.player_index][1] = 1
        global.directions[event.player_index][3] = 0
    end
end)

script.on_event("randomizer-override-move-right", function(event)
    local player = game.players[event.player_index]

    local last_movement = global.directions_time[event.player_index][1]
    last_movement = math.min(last_movement, global.directions_time[event.player_index][2])
    last_movement = math.min(last_movement, global.directions_time[event.player_index][3])
    last_movement = math.min(last_movement, global.directions_time[event.player_index][4])

    global.directions_time[event.player_index][2] = 0

    if global.directions[event.player_index][1] == 0 and global.directions[event.player_index][2] == 0 and global.directions[event.player_index][3] == 0 and global.directions[event.player_index][4] == 1 then
        global.directions[event.player_index] = {0, 0, 0, 0}
    elseif global.directions[event.player_index][2] == 1 or last_movement >= 35 then
        global.directions[event.player_index] = {0, 1, 0, 0}
    else
        global.directions[event.player_index][2] = 1
        global.directions[event.player_index][4] = 0
    end
end)

script.on_event("randomizer-override-move-down", function(event)
    local player = game.players[event.player_index]

    local last_movement = global.directions_time[event.player_index][1]
    last_movement = math.min(last_movement, global.directions_time[event.player_index][2])
    last_movement = math.min(last_movement, global.directions_time[event.player_index][3])
    last_movement = math.min(last_movement, global.directions_time[event.player_index][4])

    global.directions_time[event.player_index][3] = 0

    if global.directions[event.player_index][1] == 1 and global.directions[event.player_index][2] == 0 and global.directions[event.player_index][3] == 0 and global.directions[event.player_index][4] == 0 then
        global.directions[event.player_index] = {0, 0, 0, 0}
    elseif global.directions[event.player_index][3] == 1 or last_movement >= 35 then
        global.directions[event.player_index] = {0, 0, 1, 0}
    else
        global.directions[event.player_index][1] = 0
        global.directions[event.player_index][3] = 1
    end
end)

script.on_event("randomizer-override-move-left", function(event)
    local player = game.players[event.player_index]

    local last_movement = global.directions_time[event.player_index][1]
    last_movement = math.min(last_movement, global.directions_time[event.player_index][2])
    last_movement = math.min(last_movement, global.directions_time[event.player_index][3])
    last_movement = math.min(last_movement, global.directions_time[event.player_index][4])

    global.directions_time[event.player_index][4] = 0

    if global.directions[event.player_index][1] == 0 and global.directions[event.player_index][2] == 1 and global.directions[event.player_index][3] == 0 and global.directions[event.player_index][4] == 0 then
        global.directions[event.player_index] = {0, 0, 0, 0}
    elseif global.directions[event.player_index][4] == 1 or last_movement >= 35 then
        global.directions[event.player_index] = {0, 0, 0, 1}
    else
        global.directions[event.player_index][2] = 0
        global.directions[event.player_index][4] = 1
    end
end)


--[[function simulate_keybind_build_entity(event)
    local player = game.players[event.player_index]

    player.build_from_cursor(event.cursor_position)
end

script.on_event("randomizer-override-build", function(event)
    simulate_pipette_tool(event)
end)

--[[script.on_event("randomizer-override-mine", function(event)
    simulate_keybind_build_entity(event)
end)]]