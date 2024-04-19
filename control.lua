--require("config")
require("informatron")

require("random-utils/random")

local util = require("util")

-- TODO: Modify all forces, not just player force
script.on_init(function ()
  new_seed = settings.startup["propertyrandomizer-seed"].value - 2

  global.X1 = (new_seed * 2 + 11111) % D20
  global.X2 = (new_seed * 4 + 1) % D20

  for i = 1,3 do
    prg.value(nil, global)
  end

  global.key_bind_map = {
    ["build"] = "build",
    ["clear-cursor"] = "clear-cursor",
    ["confirm-gui"] = "confirm-gui",
    ["confirm-message"] = "confirm-message",
    ["mine"] = "mine"
  }

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

  --[[remote.add_interface("propertyrandomizer", {
    informatron_menu = function(data)
      return menu(data.player_index)
    end,
    informatron_page_content = function(data)
      return page_content(data.page_name, data.player_index, data.element)
    end
  })]]

  --[[local new_table = {}
  for load_value, key in pairs(game.item_prototypes["prototype-data"].entity_type_filters) do
    table.insert(new_table, load_value)
  end

  --[[for _, value in pairs(new_table) do
    local _, load_value = serpent.load(value)
    log(serpent.block(load_value))
  end]]
end)

script.on_event(defines.events.on_tick, function(event)
  if event.tick == 10 and settings.startup["propertyrandomizer-seed"].value == 528 then
    game.print("[exfret's Randomizer] [color=yellow]Warning:[/color] You are on the default seed. If you want things randomized differently for a new experience, change the \"seed\" setting under mod settings in the menu.")
  end

  if event.tick == 10 then
    game.print("[exfret's Randomizer] [color=blue]Info:[/color] Future versions of the randomizer (not this one) will require the informatron mod. You might need to install and enable it manually for these future versions to work.")

    local table_to_load
    for load_value, _ in pairs(game.item_prototypes["propertyrandomizer-warnings"].entity_type_filters) do
      table_to_load = load_value
    end
    local _, warnings = serpent.load(table_to_load)
    for _, warning in pairs(warnings) do
      game.print(warning)
    end
  end

  if event.tick % (30 * 60 * 60) == 0 and settings.startup["propertyrandomizer-character-values-midgame"].value then
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
    new_force_modifications.running_speed = 3 / 2 * (prg.value(nil, global) - 1 / 4)
    new_force_modifications.manual_crafting_speed = -1 + math.pow(prg.value(nil, global) + 2 / 3, 3)

    player_force = game.forces.player -- TODO: Different forces compatibility
    player_force.character_running_speed_modifier = player_force.character_running_speed_modifier - old_force_modifications.running_speed + new_force_modifications.running_speed
    player_force.manual_crafting_speed_modifier = player_force.manual_crafting_speed_modifier - old_force_modifications.manual_crafting_speed + new_force_modifications.manual_crafting_speed

    game.print("[exfret's Randomizer] [color=blue]Info:[/color] Running speed is now " .. math.ceil(100 * (1 + player_force.character_running_speed_modifier)) .. "%")
    game.print("[exfret's Randomizer] [color=blue]Info:[/color] Crafting speed is now " .. math.ceil(100 * (1 + player_force.manual_crafting_speed_modifier)) .. "%")
    --game.forces.player.character_running_speed_modifier = 
    -- TODO: Print new values when they come
  end
end)

script.on_configuration_changed(function()
  game.print("[exfret's Randomizer] [color=red]Warning:[/color] Mod configuration was changed... if you just updated exfret's randomizer, keep in mind that things may break in pre-existing runs.\nTo change back, you can select the version via a drop-down in the in-game mod portal or download old versions from the factorio mod website.\nIf you need any help, message exfret on discord or on the factorio mod website (mods.factorio.com/mod/propertyrandomizer).")
end)