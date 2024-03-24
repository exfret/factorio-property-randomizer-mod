local pdf = {}

-- TODO: To be used for what was previously inertia functions

-- Still do walk-based?

pdf.get = function(passed_pdf_params)
    local pdf_params = table.deepcopy(passed_pdf_params)

    pdf.default = {
        -- Function that modifies the input before randomization to account for things like efficiency modules, which essentially have a min value of 0.8 rather than 0
        sanitizer = function(x) return x end
        -- Inverse of sanitizer
        desanitizer = function(x) return x end
        -- very_small = x1.25, small = x2, medium = x4, big = x10, very_big = x100, unlimited = no limits
        range = "medium",
        -- same, or a range value
        range_min = "same",
        range_max = "same",
        -- same = range, none = centered around mean, very_small = x1.15, small = x1.5, medium = x2, 
        split = "medium"
    }

    for key, value in pairs(pdf.default) do
        if pdf_params[key] == nil then
            pdf_params[key] = value
        end
    end
end

return pdf