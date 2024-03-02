if compatibilities == nil then
  compatibilities = {}
end

-- Special inertia function and such values since we know we're in vanilla
compatibilities.vanilla = {
  -- Armor: just randomize it all at once (there aren't many mods that add side-grades to armor)
  -- Ammo: Randomize individual ammo groups

  -- TODO: Important intermediates

  ["inertia-function-tables"] = {
    autoplace = {
      ["iron-ore"] = {
        type = "proportional",
        slope = DEFAULT_INERTIA_FUNCTION_SLOPE -- Iron ore is already changed enough
      },
      ["copper-ore"] = {
        type = "proportional",
        slope = DEFAULT_INERTIA_FUNCTION_SLOPE -- Copper ore is already changed enough
      },
      ["stone"] = {
        type = "proportional",
        slope = 6 -- Stone can be changed a little more
      },
      ["coal"] = {
        type = "proportional",
        slope = 10 -- Coal can go crazy since there are other options, like solid fuel
      }
    }
  }
}