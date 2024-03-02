local reformat = require("utilities/reformat")

local analyze_graph = {}

--[[
    Types of items...

    1. Science
    2. Complete intermediates
    3. Raw resources
    4. Buildables
    5. Misc. usable items
]]

-- Dictionary of items nodes to entity nodes and vice versa
analyze_graph.buildables = {}
analyze_graph.buildables.entity_to_item = {}
analyze_graph.buildables.item_to_entity = {}

function analyze_graph.find_buildables(dependency_graph)
    for entity_class, _ in pairs(defines.prototypes.entity) do
        for _, entity in pairs(data.raw[entity_class]) do
            if entity.placeable_by ~= nil then
                if entity.placeable_by.item ~= nil or #entity.placeable_by == 1 then
                    local item = entity.placeable_by.item or entity.placeable_by[1].item

                    dependency_graph[prg.get_key({type = "itemorfluid_node", name = item})].corresponding_entity = {type = entity.type, name = entity.name}
                    analyze_graph.buildables.entity_to_item[prg.get_key(entity)] = {name = item}
                    analyze_graph.buildables.item_to_entity[prg.get_key({type = "itemorfluidnode", name = item})] = {type = entity.type, name = entity.name}
                end
            end
        end
    end
end

analyze_graph.raw_resources = {}

function analyze_graph.find_raw_resources(dependency_graph)
    for _, resource in pairs(data.raw.resource) do
        if resource.minable ~= nil then
            if resource.minable.results ~= nil then
                for _, result in pairs(resource.minable.results) do
                    analyze_graph.raw_resources[result] = true
                end
            elseif resource.minable.result ~= nil then
                analyze_graph.raw_resources[resource.minable.result] = true
            end
        end
    end
end

return analyze_graph