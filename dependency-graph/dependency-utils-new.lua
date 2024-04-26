require("random-utils.random")
require("globals")
require("simplex")

local prototype_tables = require("randomizer-parameter-data/prototype-tables")
local reformat = require("utilities/reformat")
local build_graph = require("dependency-graph/build-graph.lua")

local dependency_graph = build_graph.construct()

--log(serpent.block(dependency_graph))
