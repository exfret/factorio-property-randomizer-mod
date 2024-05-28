local spec = require("spec")

seed_setting = settings.startup["propertyrandomizer-seed"].value

rounding_mode = -1
if settings.startup["propertyrandomizer-rounding-mode"].value == "murder the rightmost digits mercilessly" then
  rounding_mode = 3
elseif settings.startup["propertyrandomizer-rounding-mode"].value == "round-ish" then
  rounding_mode = 2
elseif settings.startup["propertyrandomizer-rounding-mode"].value == "leave 'em raw and unrounded" then
  rounding_mode = 1
end

sync_belt_tiers = settings.startup["propertyrandomizer-belt-sync"].value

local bias_string_to_num = {
  ["worst"] = 0.44,
  ["worse"] = 0.47,
  ["default"] = 0.5,
  ["better"] = 0.53,
  ["best"] = 0.56
}

bias = bias_string_to_num[settings.startup["propertyrandomizer-bias-dropdown"].value]

local chaos_string_to_num = {
  ["light"] = 0.25,
  ["less"] = 0.75,
  ["default"] = 1.5,
  ["more"] = 2.5,
  ["most"] = 4
}

chaos = chaos_string_to_num[settings.startup["propertyrandomizer-chaos-dropdown"].value]

local config = {}
config.properties = {}

local setting_values = {
  none = 0,
  less = 1,
  default = 2,
  more = 3,
  most = 4
}

-- First, follow settings
for _, randomization in pairs(spec) do
  if randomization.setting == "none" then
    config.properties[randomization.name] = false
  elseif type(randomization.setting) == "table" then
    if setting_values[settings.startup[randomization.setting.name].value] >= setting_values[randomization.setting.min_val] then
      config.properties[randomization.name] = true
    end
  elseif settings.startup[randomization.setting].value then
    config.properties[randomization.name] = true
  else
    config.properties[randomization.name] = false
  end
end

-- Now, follow overrides

-- TODO: Don't error on mistypings, but do give message in control phase
for override in string.gmatch(settings.startup["propertyrandomizer-custom-overrides"].value, "([^;]+)") do
  local new_val = true
  if string.sub(override, 1, 1) == "!" then
    new_val = false
    override = string.sub(override, 2, #override)
  end

  config.properties[override] = new_val

  -- Check that this is in the spec
  local is_in_spec = false
  for _, randomization in pairs(spec) do
    if randomization.name == override then
      is_in_spec = true
    end
  end
  if not is_in_spec then
    if info ~= nil then
      table.insert(info.warnings, "[exfret's Randomizer] [color=red]Error:[/color] Override randomization with ID \"[color=blue]" .. override .. "[/color]\" does not exist; this randomization was skipped.\nMake sure the overrides are spelled and formatted correctly without spaces and separated by semicolons ;")
    end
  end
end

return config