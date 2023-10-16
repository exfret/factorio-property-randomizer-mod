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

    --[[for i=1,#params.matrix do
        for j=1,#params.matrix[i] do
            if params.matrix[i][j] ~= 0 then
                local digit_scaling = math.pow(10, math.floor(math.log(math.abs(params.matrix[i][j]), 10) - 4))
                params.matrix[i][j] = params.matrix[i][j] / digit_scaling
                params.matrix[i][j] = round(params.matrix[i][j] * 12600) / (12600)
                params.matrix[i][j] = params.matrix[i][j] * digit_scaling
            end
        end
    end]]

    -- Deal with epsilons of error in the computer arithmetic (these can cascade later)
    --[[local e = 0.000001
    for i=1,#params.matrix do
        for j=1,#params.matrix[i] do
            if math.abs(params.matrix[i][j]) < e then
                params.matrix[i][j] = 0
            end
        end
    end]]
end

--[[test_pivot = {
    {1, 0, 0, 3, 2, 1},
    {0, 1, 0, 2, 3, 1},
    {0, 0, 1, 1, 2, 3}
}
pivot({matrix = test_pivot, row = 2, col = 5})
log(serpent.block(test_pivot))]]

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

--[[function reduce_cost_function (params)
    local scale_factor = params.matrix[1][params.row]

    for j=1,#params.matrix[1] do
        params.matrix[1][j] = params.matrix[1][j] - scale_factor * params.matrix[params.row][j]
    end
end]]

function solve_system (params)
    if params.permutation == nil then
        params.permutation = {}
        for i=1,#params.matrix[1] do
            params.permutation[i] = i
        end

        --[[local ind = 1

        params.permutation_matrix = {}
        for i = 1,#params.matrix do
            params.permutation_matrix[i] = {}
            for j = 1,#params.matrix[i] do
                if i == j then
                    params.permutation_matrix[i] = ind
                    ind = ind + 1
                end
            end
        end]]
    end

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

        local temp = params.permutation[params.row]
        params.permutation[params.row] = params.col
        params.permutation[params.col] = temp

        if params.row ~= params.col then
            --log("hahaha")
        end

        log("Pivoting...\n\t\tRow: " .. tostring(params.row) .. "\n" .. "\t\tCol: " .. tostring(params.col))

        pivot(params)

        --reduce_cost_function(params)
    end

    for i=2,math.min(#params.matrix[1]-1,#params.matrix) do
        local scale_factor = params.matrix[1][i]

        for j=1,#params.matrix[1] do
            params.matrix[1][j] = params.matrix[1][j] - scale_factor * params.matrix[i][j]
        end
    end

    --log(serpent.block(params.matrix))
    --log(serpent.block(params.permutation))

    return params.matrix[1][#params.matrix[1]]
end

random_matrix = {
    {1, 2, 2},
    {30, 10, 20}
}
random_score = {40, 100, 150}
random_constraint = {3, 75}
random_problem = {
    {1, 40, 100, 150, 0},
    {0, 1, 2, 2, 3},
    {0, 30, 10, 20, 75}
}

for i=1,#random_problem do
    for j=1,#random_problem[i] do
        if random_problem[i][j] ~= 0 then
            pivot({matrix = random_problem, row = i, col = j})
            break
        end
    end

    -- Find nonzero entry in i-th row
    --[[if #random_problem[i]-1 >= i then
        for j=i,#random_problem[i]-1 do
            if random_problem[i][j] ~= 0 then
                pivot({matrix = random_problem, row = i, col = j})
            end
        end
    end]]
end

--log(serpent.block(random_problem))

--log(solve_system({matrix = random_problem}))