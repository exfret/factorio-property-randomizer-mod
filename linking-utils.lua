local crafting_machine_classes = {
  "assembling-machine",
  "rocket-silo",
  "furnace"
}

function find_same_crafting_category_groups ()
  local entity_linking_dict = {}

  for _, class_name1 in pairs(crafting_machine_classes) do
    for _, prototype1 in pairs(data.raw[class_name1]) do
      for _, class_name2 in pairs(crafting_machine_classes) do
        for _, prototype2 in pairs(data.raw[class_name2]) do
          if entity_linking_dict[prototype1.name] == nil then
            entity_linking_dict[prototype1.name] = {prototype1.name}
          end
          if entity_linking_dict[prototype2.name] == nil then
            entity_linking_dict[prototype2.name] = {prototype2.name}
          end

          if util.table.compare(prototype1.crafting_categories, prototype2.crafting_categories) then
            for _, prototype_in_table_1 in pairs(entity_linking_dict[prototype1.name]) do
              table.insert(entity_linking_dict[prototype2.name], prototype_in_table_1)
            end

            for _, prototype_in_table_2 in pairs(entity_linking_dict[prototype2.name]) do
              table.insert(entity_linking_dict[prototype1.name], prototype_in_table_2)
            end
          end
        end
      end
    end
  end

  local same_crafting_category_groups = {}
  local already_inserted = {}
  for prototype_name, table_to_insert in pairs(entity_linking_dict) do
    -- Check that we didn't already insert this table
    local table_was_already_inserted = false
    for _, prototype_already_inserted in pairs(already_inserted) do
      for _, table_already_inserted in pairs(entity_linking_dict[prototype_already_inserted]) do
        if util.table.compare(table_to_insert, table_already_inserted) then
          table_already_inserted = true
        end
      end
    end

    if not table_was_already_inserted then
      table.insert(same_crafting_category_groups, table_to_insert)
    end

    already_inserted[prototype_name] = true
  end

  return same_crafting_category_groups
end

-- This just uses next_upgrade to find entities of the same "type" right now
-- In the future I may need to check things like crafting categories, etc. depending on the class
-- TODO: Fix that this just checks things in the same class
function find_upgrade_groups (class_name)
  local entity_downgrades = {}

  for _, prototype in pairs(data.raw[class_name]) do
    if entity_downgrades[prototype.name] == nil then
      entity_downgrades[prototype.name] = {}
    end

    table.insert(entity_downgrades[prototype.name], prototype)

    if prototype.next_upgrade ~= nil then
      for other_class_name, _ in pairs(defines.prototypes["entity"]) do
        for entity_name, entity in pairs(data.raw[other_class_name]) do
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

function find_fast_replaceable_groups (class_name)
  local fast_replaceable_groups = {}

  for _, prototype in pairs(data.raw[class_name]) do
    if prototype.fast_replaceable_group then
      if fast_replaceable_groups[prototype.fast_replaceable_group] ~= nil then
        table.insert(fast_replaceable_groups[prototype.fast_replaceable_group], prototype)
      else
        fast_replaceable_groups[prototype.fast_replaceable_group] = {prototype}
      end
    else
      fast_replaceable_groups["aaa" .. prototype.name] = {prototype}
    end
  end

  return fast_replaceable_groups
end