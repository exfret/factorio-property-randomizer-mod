is_control_phase = true

--require("config")
require("informatron")

require("random-utils/random")

local config = require("config")

--require("randomizer-functions/keybind-randomizer")

local util = require("util")

-- TODO: Modify all forces, not just player force
script.on_init(function()
  new_seed = settings.startup["propertyrandomizer-seed"].value - 2

  global.X1 = (new_seed * 2 + 11111) % D20
  global.X2 = (new_seed * 4 + 1) % D20

  for i = 1,3 do
    prg.value(nil, global)
  end

  --[[global.key_bind_map = {
    ["clear-cursor"] = "clear-cursor",
    ["move-down"] = "move-down",
    ["move-left"] = "move-left",
    ["move-right"] = "move-right",
    ["move-up"] = "move-up"
  }
  global.directions = {}
  global.directions_time = {}
  global.diagonal_time = {}]]

  global.force_modifications = {}
  local force_modifications = global.force_modifications

  force_modifications.running_speed = 0
  --force_modifications.reach = 0
  --TODO: force_modifications.health = 0
  force_modifications.manual_crafting_speed = 0
  -- TODO: Make labs less productive and then increase productivity here so that you have to choose when to use your science packs
  --force_modifications.lab_speed = 0
  --force_modifications.lab_productivity = 0

  --ok, global.data = serpent.load(bigunpack("propertyrandomizer_karma"))

  global.stats = {}
  global.stats.list = {}
  global.stats.prototype_values = {}
  for load_value, key in pairs(game.item_prototypes["prototype-data"].entity_type_filters) do
    local _, load_table = serpent.load(load_value)

    table.insert(global.stats.list, load_table)

    if load_table.value_type == "prototype" then
      global.stats.prototype_values[prg.get_key({type = load_table.class, name = load_table.prototype})] = load_table
    end
  end

  for key, val in pairs(global.stats.prototype_values) do
    --log(key)
  end
  --log(serpent.block(global.stats.prototype_values))
  --log(serpent.block(global.stats.list))

  global.old_data_raw = {}
  for load_value, key in pairs(game.item_prototypes["propertyrandomizer-old-prototype-data"].entity_type_filters) do
    local _, load_table = serpent.load(load_value)

    global.old_data_raw[prg.get_key({type = load_table.type, name = load_table.name})] = load_table.prototype
  end

  remote.add_interface("propertyrandomizer", {
    informatron_menu = function(data)
      return menu(data.player_index)
    end,
    informatron_page_content = function(data)
      return page_content(data.page_name, data.player_index, data.element)
    end
  })

  --[[for _, value in pairs(new_table) do
    local _, load_value = serpent.load(value)
    log(serpent.block(load_value))
  end]]

  -- For possible movement modification
  global.dir = {
    north = "north",
    northeast = "northeast",
    east = "east",
    southeast = "southeast",
    south = "south",
    southwest = "southwest",
    west = "west",
    northwest = "northwest"
  }
end)

script.on_load(function(event)
  remote.add_interface("propertyrandomizer", {
    informatron_menu = function(data)
      return menu(data.player_index)
    end,
    informatron_page_content = function(data)
      return page_content(data.page_name, data.player_index, data.element)
    end
  })
end)

script.on_event(defines.events.on_player_created, function(event)
  --[[
  global.directions[event.player_index] = {0, 0, 0, 0} -- NESW
  global.directions_time[event.player_index] = {0, 0, 0, 0}
  global.diagonal_time[event.player_index] = {1000, 1000, 1000, 1000}]]
end)

script.on_event(defines.events.on_tick, function(event)
  --[[for player_index, dir in pairs(global.directions) do
    local vertical = dir[1] - dir[3]
    local horizontal = dir[2] - dir[4]

    walking = true
    direction = defines.direction.north
    if vertical == -1 and horizontal == -1 then
      direction = defines.direction.southwest
    elseif vertical == -1 and horizontal == 0 then
      direction = defines.direction.south
    elseif vertical == -1 and horizontal == 1 then
      direction = defines.direction.southeast
    elseif vertical == 0 and horizontal == 1 then
      direction = defines.direction.east
    elseif vertical == 1 and horizontal == 1 then
      direction = defines.direction.northeast
    elseif vertical == 1 and horizontal == 0 then
      direction = defines.direction.north
    elseif vertical == 1 and horizontal == -1 then
      direction = defines.direction.northwest
    elseif vertical == 0 and horizontal == -1 then
      direction = defines.direction.west
    elseif vertical == 0 and horizontal == 0 then
      walking = false
    end

    local player = game.players[player_index]
    player.walking_state = {walking = walking, direction = direction}

    for ind, _ in pairs(global.directions_time[player_index]) do
      global.directions_time[player_index][ind] = global.directions_time[player_index][ind] + 1
    end

    if dir[1] == 1 and dir[2] == 1 then -- Northeast
      global.diagonal_time[player_index][1] = 0
      if global.diagonal_time[player_index][3] <= 20 then
        player.walking_state = {walking = false, direction = direction}
      end
    end
    if dir[1] == -1 and dir[2] == 1 then -- Southeast
      global.diagonal_time[player_index][2] = 0
      if global.diagonal_time[player_index][4] <= 20 then
        player.walking_state = {walking = false, direction = direction}
      end
    end
    if dir[1] == -1 and dir[2] == -1 then -- Southwest
      global.diagonal_time[player_index][3] = 0
      if global.diagonal_time[player_index][1] <= 20 then
        player.walking_state = {walking = false, direction = direction}
      end
    end
    if dir[1] == 1 and dir[2] == -1 then -- Northwest
      log("blop")

      global.diagonal_time[player_index][4] = 0
      if global.diagonal_time[player_index][2] <= 20 then
        player.walking_state = {walking = false, direction = direction}
      end
    end

    for key, _ in pairs(global.diagonal_time[player_index]) do
      global.diagonal_time[player_index][key] = global.diagonal_time[player_index][key] + 1
    end
  end]]

  if event.tick == 10 and settings.startup["propertyrandomizer-seed"].value == 528 then
    game.print("[exfret's Randomizer] [color=yellow]Warning:[/color] You are on the default seed. If you want things randomized differently for a new experience, change the \"seed\" setting under mod settings in the menu.")
  end

  if event.tick == 10 then
    --game.print("[exfret's Randomizer] [color=blue]Info:[/color] Future versions of the randomizer (not this one) will require the informatron mod. You might need to install and enable it manually for these future versions to work.")

    local table_to_load
    for load_value, _ in pairs(game.item_prototypes["propertyrandomizer-warnings"].entity_type_filters) do
      table_to_load = load_value
    end
    local _, warnings = serpent.load(table_to_load)
    for _, warning in pairs(warnings) do
      game.print(warning)
    end
  end

  -- Permute directions
  --[=[ Doesn't work atm
  if config.properties["movement"] then
    if event.tick % 4 ~= 0 then
      for _, player in pairs(game.players) do
        if player.walking_state.walking then
          local player_direction = player.walking_state.direction
          local new_direction
          local directions = {"north", "northeast", "east", "southeast", "south", "southwest", "west", "northwest"}
          for _, dir in pairs(directions) do
            if player_direction == defines.direction[dir] then
              new_direction = defines.direction[global.dir[dir]]
            end
          end

          player.walking_state = {walking = true, direction = new_direction}
        end
      end
    else
      for _, player in pairs(game.players) do
        player.walking_state = {walking = false, direction = defines.direction.north}
      end
    end

    if event.tick % (60 * 60) == 45 * 60 then
      local random_value = prg.int(nil, 8, global)
      if random_value == 1 then
        -- Id
        global.dir = {
          north = "north",
          northeast = "northeast",
          east = "east",
          southeast = "southeast",
          south = "south",
          southwest = "southwest",
          west = "west",
          northwest = "northwest"
        }
      elseif random_value == 2 then
        -- Rotation 90 degrees
        global.dir = {
          north = "west",
          northeast = "northwest",
          east = "north",
          southeast = "northeast",
          south = "east",
          southwest = "southeast",
          west = "south",
          northwest = "southwest"
        }
      elseif random_value == 3 then
        -- Rotation 180 degrees
        global.dir = {
          north = "south",
          northeast = "southwest",
          east = "west",
          southeast = "norhtwest",
          south = "north",
          southwest = "northeast",
          west = "east",
          northwest = "southeast"
        }
      elseif random_value == 4 then
        -- Rotation 270 degrees
        global.dir = {
          north = "east",
          northeast = "southeast",
          east = "south",
          southeast = "southwest",
          south = "west",
          southwest = "northwest",
          west = "north",
          northwest = "northeast"
        }
      elseif random_value == 5 then
        -- Horizontal flip
        global.dir = {
          north = "south",
          northeast = "southeast",
          east = "east",
          southeast = "northeast",
          south = "north",
          southwest = "northwest",
          west = "west",
          northwest = "southwest"
        }
      elseif random_value == 6 then
        -- Vertical flip
        global.dir = {
          north = "north",
          northeast = "northwest",
          east = "west",
          southeast = "southwest",
          south = "south",
          southwest = "southeast",
          west = "east",
          northwest = "northeast"
        }
      elseif random_value == 7 then
        -- Diagonal flip 1
        -- South to east, west to north
        global.dir = {
          north = "west",
          northeast = "southwest",
          east = "south",
          southeast = "southeast",
          south = "east",
          southwest = "northeast",
          west = "north",
          northwest = "northwest"
        }
      elseif random_value == 8 then
        -- Diagonal flip 2
        -- South to west, east to north
        global.dir = {
          north = "east",
          northeast = "northeast",
          east = "north",
          southeast = "northwest",
          south = "west",
          southwest = "southwest",
          west = "south",
          northwest = "southeast"
        }
      end
    end
  end --]=]

  if event.tick % (2 * 60 * 60 * 60) == 15 * 60 * 60 and config.properties["daytime-cycle"] then
    for surface_name, surface in pairs(game.surfaces) do
      -- Minimum daytime is 60 seconds
      local multiplier = prg.value(nil, global)
      surface.ticks_per_day = 60 * 60 / (multiplier * multiplier * multiplier)

      local daytime_lengths = {prg.value(nil, global), prg.value(nil, global), prg.value(nil, global), prg.value(nil, global)}
      table.sort(daytime_lengths)

      -- We can't assign these at once and factorio immediately throws an error if they're in the wrong order, so we need to do this in a hacky way
      -- TODO: Actually check if there's a way to set these all at once
      surface.dawn = 1
      surface.morning = 0.99
      surface.evening = 0.98
      surface.dusk = 0.97

      surface.dusk = math.min(0.97, daytime_lengths[1])
      surface.evening = math.min(0.98, daytime_lengths[2])
      surface.morning = math.min(0.99, daytime_lengths[3])
      surface.dawn = daytime_lengths[4]

      local dusk_length = math.floor(100 * (surface.evening - surface.dusk))
      local evening_length = math.floor(100 * (surface.morning - surface.evening))
      local morning_length = math.floor(100 * (surface.dawn - surface.morning))
      local dawn_length = 100 - dusk_length - evening_length - morning_length

      if surface_name == "nauvis" then
        game.print("Nauvis day length is now " .. math.floor(surface.ticks_per_day / (60 * 60)) .. " minutes and " .. math.floor(((surface.ticks_per_day / 60) % 60)) .. " seconds. Reroll will be in 2 hours.")
        game.print("Morning/Daytime/Evening/Night breakdowns are " .. morning_length .. "% / " .. dawn_length .. "% / " .. dusk_length .. "% / " .. evening_length .. "%")
      end
    end
  end

  if event.tick % (30 * 60 * 60) == 0 and config.properties["character-values"] then
    -- TODO: Limit from below by like 30% so that it doesn't interact badly with other mods
    -- OR... even just make this a multiplier

    --[[local old_force_modifications = util.table.deepcopy(global.force_modifications)

    local new_force_modifications = global.force_modifications
    new_force_modifications.running_speed = prg.value(nil, global) - 1 / 3
    --new_force_modifications.health = prg.value(nil, global) - 1 / 2
    new_force_modifications.manual_crafting_speed = prg.value(nil, global) - 2 / 5

    player_force = game.forces.player
    player_force.character_running_speed_modifier = -1 + (1 + player_force.character_running_speed_modifier) * math.pow(4, new_force_modifications.running_speed - old_force_modifications.running_speed)
    -- TODO: Dynamically sense base max health
    --player_force.character_health_bonus = -250 + (250 + player_force.character_health_bonus) * math.pow(9, new_force_modifications.health - old_force_modifications.health)
    player_force.manual_crafting_speed_modifier = -1 + (1 + player_force.manual_crafting_speed_modifier) * math.pow(13, new_force_modifications.manual_crafting_speed - old_force_modifications.manual_crafting_speed)]]

    local old_force_modifications = util.table.deepcopy(global.force_modifications)
    local new_force_modifications = global.force_modifications
    new_force_modifications.running_speed = 3 / 2 * (prg.value(nil, global) - 1 / 3)
    new_force_modifications.manual_crafting_speed = -1 + math.pow(prg.value(nil, global) + 2 / 3, 3)

    player_force = game.forces.player -- TODO: Different forces compatibility
    player_force.character_running_speed_modifier = -1 + (1 + player_force.character_running_speed_modifier) / (1 + old_force_modifications.running_speed) * (1 + new_force_modifications.running_speed)
    player_force.manual_crafting_speed_modifier = -1 + (1 + player_force.manual_crafting_speed_modifier) / (1 + old_force_modifications.manual_crafting_speed) * (1 + new_force_modifications.manual_crafting_speed)

    game.print("[exfret's Randomizer] [color=blue]Info:[/color] Running speed is now " .. math.ceil(100 * (1 + player_force.character_running_speed_modifier)) .. "%")
    game.print("[exfret's Randomizer] [color=blue]Info:[/color] Crafting speed is now " .. math.ceil(100 * (1 + player_force.manual_crafting_speed_modifier)) .. "%")
    --game.forces.player.character_running_speed_modifier = 
    -- TODO: Print new values when they come
  end
end)

script.on_configuration_changed(function()
  game.print("[exfret's Randomizer] [color=red]Warning:[/color] Mod configuration was changed... if you just updated exfret's randomizer, keep in mind that things may break in pre-existing runs.\nTo change back, you can select the version via a drop-down in the in-game mod portal or download old versions from the factorio mod website.\nIf you need any help, message exfret on discord or on the factorio mod website (mods.factorio.com/mod/propertyrandomizer).")
end)