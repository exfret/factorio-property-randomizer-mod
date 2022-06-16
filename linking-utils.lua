-- This just uses next_upgrade to find entities of the same "type" right now
-- In the future I may need to check things like crafting categories, etc. depending on the class
function find_upgrade_groups (class_name)
  local entity_downgrades = {}

  for _, prototype in pairs(data.raw[class_name]) do
    if entity_downgrades[prototype.name] == nil then
      entity_downgrades[prototype.name] = {}
    end

    table.insert(entity_downgrades[prototype.name], prototype)
    
    if prototype.next_upgrade ~= nil then
      for class_name, _ in pairs(defines.prototypes["entity"]) do
        for entity_name, entity in pairs(data.raw[class_name]) do
          if entity_name == prototype.next_upgrade then
            if entity_downgrades[entity_name] == nil then
              entity_downgrades[entity_name] = {}
            end

            for _, prototype_in_group in pairs(entity_downgrades[prototype.name]) do
              table.insert(entity_downgrades[entity_name], prototype_in_group)
            end
          end
        end
      end
    end
  end

  local upgrade_groups = {}
  for entity, entity_downgrade_list in pairs(entity_downgrades) do
    if data.raw[class_name][entity].next_upgrade == nil then
      table.insert(upgrade_groups, entity_downgrade_list)
    end
  end

  return upgrade_groups
end