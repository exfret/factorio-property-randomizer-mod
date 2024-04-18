local fixes = {}

fixes.magazine_size = {
    min = 2, -- Don't randomize magazine sizes of 1
    round = {
        modulus = 1,
        left_digits_to_keep = 
    }
}

fixes.none = {
    -- Not even rounding
}

return fixes