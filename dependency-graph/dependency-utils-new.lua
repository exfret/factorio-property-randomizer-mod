require("random-utils.random")
require("globals")
require("simplex")

local prototype_tables = require("randomizer-parameter-data/prototype-tables")
local reformat = require("utilities/reformat")
local build_graph = require("dependency-graph/build-graph.lua")

dependency_graph = build_graph.construct() -- TODO: Make dependency graph initially a global as well

function find_reachable_nodes(removed_nodes)
    local function add_to_source(node, top_sort, nodes_left)
        if nodes_left[prg.get_key(node)] then
            table.insert(top_sort, table.deepcopy(node))
            nodes_left[prg.get_key(node)] = nil
        end
    end
    
    local top_sort = {}
    local nodes_left = table.deepcopy(dependency_graph)

    -- Remove blacklisted nodes
    for _, node in pairs(nodes_left) do
        if removed_nodes[prg.get_key(node)] then
            nodes_left[prg.get_key(node)] = nil
        end
    end

    -- Add source nodes
    for _, node in pairs(dependency_graph) do
        if build_graph.op[node.type] == "AND" and #node.prereqs == 0 then
            add_to_source(node, top_sort, nodes_left)
        end
    end

    local num_nodes = 0
    for _, _ in pairs(dependency_graph) do
        num_nodes = num_nodes + 1
    end

    for i = 1, num_nodes do
        -- Check that we still have nodes with possible dependents to check
        if #top_sort >= i then
            local curr_node = top_sort[i]

            for _, dependent in pairs(curr_node.dependents) do
                if build_graph.op[dependent.type] == "OR" and (not removed_nodes[prg.get_key(dependent)]) then
                    add_to_source(dependency_graph[prg.get_key(dependent)], top_sort, nodes_left)
                else
                    local satisfied = true
                    for _, prereq in pairs(dependency_graph[prg.get_key(dependent)].prereqs) do
                        if nodes_left[prg.get_key(prereq)] or removed_nodes[prg.get_key(prereq)] then
                            satisfied = false
                        end
                    end
                    if satisfied then
                        add_to_source(dependency_graph[prg.get_key(dependent)], top_sort, nodes_left)
                    end
                end
            end
        else
            break
        end
    end

    return top_sort
end

for _, node in pairs(find_reachable_nodes({})) do
    log(node.name)
end

function randomize_technologies()
    
end

--[[function randomize_technologies()

    
    local all_techs = {}
    for _, tech in pairs(data.raw.technology) do
      all_techs[prg.get_key({type = "technology_node", name = tech.name})] = true
    end
    local top_sort = find_reachable_tech_unlock_nodes_top(all_techs).top_sort
    
    for _, thing in pairs(top_sort) do
      --log(thing.name)
    end
    
    local tech_sort = {}
    for _, node in pairs(top_sort) do
      if node.type == "technology_node" then
        table.insert(tech_sort, table.deepcopy(node))
      end
    end
    
    --log(serpent.block(tech_sort))
    
    local color_tech_to_tech_inds = {}
    color_tech_to_tech_inds["space"] = {}
    color_tech_to_tech_inds["yp"] = {}
    color_tech_to_tech_inds["y"] = {}
    color_tech_to_tech_inds["p"] = {}
    color_tech_to_tech_inds["b"] = {}
    color_tech_to_tech_inds["g"] = {}
    color_tech_to_tech_inds["r"] = {}
    for ind, tech in pairs(tech_sort) do
      local technology = data.raw.technology[tech.name]
    
      local ing = {}
      for _, thing in pairs(technology.unit.ingredients) do
        ing[thing[1] or thing.name] = true
      end
    
      if ing["space-science-pack"] then
        table.insert(color_tech_to_tech_inds["space"], ind)
      elseif ing["utility-science-pack"] and ing["production-science-pack"] then
        table.insert(color_tech_to_tech_inds["yp"], ind)
      elseif ing["utility-science-pack"] then
        table.insert(color_tech_to_tech_inds["y"], ind)
      elseif ing["production-science-pack"] then
        table.insert(color_tech_to_tech_inds["p"], ind)
      elseif ing["chemical-science-pack"] then
        table.insert(color_tech_to_tech_inds["b"], ind)
      elseif ing["logistic-science-pack"] then
        table.insert(color_tech_to_tech_inds["g"], ind)
      elseif ing["automation-science-pack"] then
        table.insert(color_tech_to_tech_inds["r"], ind)
      else
        error()
      end
    end
    
    
    local tech_shuffle = table.deepcopy(tech_sort)
    
    local tech_table = {}
    for color, tech_inds in pairs(color_tech_to_tech_inds) do
      tech_table[color] = {}
    
      for _, ind in pairs(tech_inds) do
        table.insert(tech_table[color], tech_sort[ind])
      end
    
      prg.shuffle("pls_shuffle", tech_table[color])
    
      for i, ind in pairs(tech_inds) do
        tech_shuffle[ind] = tech_table[color][i]
      end
    end
    
    --prg.shuffle("pls_shuffle", tech_shuffle)
    
    
    local new_new_dependency_graph = table.deepcopy(dependency_graph)
    local added_techs = {}
    local stripped_nodes = {}
    for i=1,#tech_sort do
      local reachable_nodes = find_reachable_tech_unlock_nodes_top(added_techs).reachable
    
      -- move j's prereqs to i
      for j=1,#tech_shuffle do
        if (not stripped_nodes[prg.get_key(tech_shuffle[j])]) and reachable_nodes[prg.get_key(tech_shuffle[j])] then
          --log("boop  " .. i .. " : " .. j)
      
          local node_i = tech_sort[i]
          local node_j = tech_shuffle[j]
      
          new_new_dependency_graph[prg.get_key(node_i)].prereqs = node_j.prereqs
    
          added_techs[prg.get_key(node_i)] = true
          stripped_nodes[prg.get_key(node_j)] = true
    
          break
        end
      end
    end
    
    for _, node in pairs(new_new_dependency_graph) do
      if node.type == "technology_node" then
        data.raw.technology[node.name].prerequisites = {}
        for _, prereq in pairs(node.prereqs) do
          if prereq.type == "technology_node" then
            table.insert(data.raw.technology[node.name].prerequisites, prereq.name)
          end
        end
      end
    end

    for _, tech in pairs(data.raw.technology) do
        tech.upgrade = false
    end
end]]

--log(serpent.block(dependency_graph))
