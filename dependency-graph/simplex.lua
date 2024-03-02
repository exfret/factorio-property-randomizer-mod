function round (number)
    if number - math.floor(number) < 0.5 then
        return math.floor(number)
    else
        return math.ceil(number)
    end
end

-- Has been sorta tested and I think it works
function pivot (params)
    -- Rescale row
    local scale_factor = 1 / params.matrix[params.row][params.col]
    for j=1,#params.matrix[params.row] do
        params.matrix[params.row][j] = scale_factor * params.matrix[params.row][j]
    end
    for j=1,#params.row_weights[params.row] do
        params.row_weights[params.row][j] = scale_factor * params.row_weights[params.row][j]
    end

    -- Pivot ops to other rows
    for i=1,#params.matrix do
        if i ~= params.row then
            --log(scale_factor)

            local scale_factor = params.matrix[i][params.col]
            
            for j=1,#params.matrix[i] do
                --log(params.matrix[i][j])
                --log(params.matrix[params.row][j])
                --log(#params.matrix[i])
                --log(#params.matrix[params.row])
                --log(i)
                --log(#params.matrix)
                --log(params.row)

                params.matrix[i][j] = params.matrix[i][j] - scale_factor * params.matrix[params.row][j]
            end
            for j=1,#params.row_weights[i] do
                params.row_weights[i][j] = params.row_weights[i][j] - scale_factor * params.row_weights[params.row][j]
            end
        end
    end

    -- Switch cols params.col with params.row
    local left_col = {}
    local right_col = {}
    for i=1,#params.matrix do
        left_col[i] = params.matrix[i][math.min(params.row,#params.matrix[i])]
        right_col[i] = params.matrix[i][params.col]
    end
    for i=1,#params.matrix do
        params.matrix[i][math.min(params.row,#params.matrix[i])] = right_col[i]
        params.matrix[i][params.col] = left_col[i]
    end
    local temp_num = params.permutation[params.row]
    params.permutation[params.row] = params.permutation[params.col]
    params.permutation[params.col] = temp_num
end

function find_entering_var (params)
    for i=#params.matrix,#params.matrix[1]-1 do
        if params.matrix[1][i] < 0 then
            params.col = i
            return true
        end
    end

    return false
end

function find_leaving_var (params)
    local min = 0
    local min_ind = 0

    for i=2,#params.matrix do
        local row = params.matrix[i]

        if row[params.col] > 0.0001 and -row[#params.matrix[i]] / row[params.col] < min then
            min = row[#row] / row[params.col]
            min_ind = i
        end
    end

    params.row = min_ind
end

function solve_system (params)
    while true do
        local found_var = find_entering_var(params)
        if not found_var then
            log("Break 1")
            break
        end

        find_leaving_var(params)

        if params.row == 0 then
            log("Break 2")
            break
        end

        log("Pivoting...\n\t\tRow: " .. tostring(params.row) .. "\n" .. "\t\tCol: " .. tostring(params.col))

        pivot(params)
    end

    for i=2,math.min(#params.matrix[1]-1,#params.matrix) do
        local scale_factor = params.matrix[1][i]

        for j=1,#params.matrix[1] do
            params.matrix[1][j] = params.matrix[1][j] - scale_factor * params.matrix[i][j]
        end
    end

    return params.matrix[1][#params.matrix[1]]
end