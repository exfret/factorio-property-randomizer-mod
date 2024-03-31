local pdf = {}

-- TODO: To be used for what was previously inertia functions

-- Still do walk-based?

-- Increment formula: roll based on bias, increment/decrement value by value * step_amount
--      also add force away from range min's/max's

pdf.get = function(passed_pdf_params)
    local pdf_params = table.deepcopy(passed_pdf_params)

    pdf.default = {
        -- Function that modifies the input before randomization to account for things like module speed effects, which essentially have a min value of -1 rather than 0
        sanitizer = function(x) return x end
        -- Inverse of sanitizer
        desanitizer = function(x) return x end
        -- very_small = x1.25, small = x2, medium = x4, big = x10, very_big = x100, unlimited = no limits
        range = "medium",
        -- same, or a range value
        range_min = "same",
        range_max = "same",
        -- none, standard = 0.04
        split_force = "standard",
        -- absolute min/max values allowed, written values are before sanitization
        min = 0,
        max = REALLY_BIG_FLOAT_NUM
    }

    for key, value in pairs(pdf.default) do
        if pdf_params[key] == nil then
            pdf_params[key] = value
        end
    end


end

return pdf