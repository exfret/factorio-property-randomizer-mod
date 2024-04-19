-- TODO: Can I uncomment this right now? I think 
--require("config")

seed_setting = settings.startup["propertyrandomizer-seed"].value

require("random-utils/random")

--require("dependency-graph/dependency-utils")

prg.seed(seed_setting)

-- Does nothing... for now