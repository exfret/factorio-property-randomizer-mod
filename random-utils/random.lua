local CRC32 = require("hash")

-- Make a prg for each prototype
prg_table = {}

prg = {}

A1 = 727595
A2 = 798405
D20 = 1048576
D40 = 1099511627776

-- Seed the generator
function prg.seed(key)
  local using = {}

  local new_seed = seed_setting + (CRC32.Hash(key) % D20)

  using["X1"] = (new_seed * 2 + 11111) % D20
  using["X2"] = (new_seed * 4 + 1) % D20

  prg_table[key] = using

  prg.value(key)
  prg.value(key)
  prg.value(key)

  --[[

  for class_name, class in pairs(data.raw) do
    for _, prototype in pairs(class) do
      -- aaa should separate the class from the name since this doesn't occur in any class names
      local key = prototype.type .. "aaa" .. prototype.name

      local using = {}

      local new_seed = seed + (CRC32.Hash(key) % D20) -- Mod by D20 to make sure it's small enough

      using["X1"] = (new_seed * 2 + 11111) % D20
      using["X2"] = (new_seed * 4 + 1) % D20

      prg_table[key] = using

      prg.value(key)
      prg.value(key)
      prg.value(key)
    end

    local key = class_name .. "bbb"

    local using = {}

    local new_seed = seed + D20 + (CRC32.Hash(key) % D20)

    using["X1"] = (new_seed * 2 + 11111) % D20
    using["X2"] = (new_seed * 4 + 1) % D20

    prg_table[key] = using

    prg.value(key)
    prg.value(key)
    prg.value(key)]
  end

  local using = {}

  local new_seed = seed - 1
  
  using["X1"] = (new_seed * 2 + 11111) % D20
  using["X2"] = (new_seed * 4 + 1) % D20

  prg_table["aaadummyprg"] = using

  prg.value("aaadummyprg")
  prg.value("aaadummyprg")
  prg.value("aaadummyprg")]]
end

-- TODO: Make this cleaner while still having this file for both data and control stage
-- Get a decimal value between [0, 1]
function prg.value(key, XTable)
  if XTable ~= nil then
    local U = XTable.X2 * A2
    local V = (XTable.X1 * A2 + XTable.X2 * A1) % D20
    V = (V * D20 + U) % D40
    XTable.X1 = math.floor(V / D20)
    XTable.X2 = V - XTable.X1 * D20
    return V / D40
  end

  if prg_table[key] == nil then
    prg.seed(key)
  end

  local using = prg_table[key]

  local U = using["X2"] * A2
  local V = (using["X1"] * A2 + using["X2"] * A1) % D20
  V = (V * D20 + U) % D40
  using["X1"] = math.floor(V / D20)
  using["X2"] = V - using["X1"] * D20
  return V / D40
end

-- get an integer value between [1, max]
function prg.int(key, max)
  return math.floor(prg.value(key) * max) + 1
end

-- get an integer value between [min, max]
function prg.range(key, min, max)
  return min + prg.int(key, max - min + 1) - 1
end

function prg.float_range(key, min, max)
  return min + prg.value(key) * (max - min)
end

-- shuffle a table
function prg.shuffle(key, tbl)
  for i = #tbl, 2, -1 do
    local j = prg.int(key, i)
    tbl[i], tbl[j] = tbl[j], tbl[i]
  end
end

-- TODO: Move this to a general utils file
-- If object is class, assume we're passing the key, not the actual class
function prg.get_key (object, type_of_key)
  if type_of_key == "class" then
    return object .. "bbb"
  elseif type_of_key == "dummy" then
    return "aaadummyprg"
  end

  return object.type .. "aaa" .. object.name
end