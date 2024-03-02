-- Usage: equipment_variations[num_points][variation_index]["points"][array of 2D points]
local equipment_variations = {
    [1] = {
        [1] = {
            width = 1,
            height = 1,
            points = {
                {0,0}
            }
        }
    },
    [2] = {
        [1] = {
            width = 2,
            height = 1,
            points = {
                {0,0},{1,0}
            }
        },
        [2] = {
            width = 1,
            height = 2,
            points = {
                {0,0},
                {0,1}
            }
        },
        [3] = {
            width = 2,
            height = 2,
            points = {
                {0,0},
                      {1,1}
            }
        },
        [4] = {
            width = 2,
            height = 2,
            points = {
                     {1,0},
                {0,1}
            }
        },
        [5] = {
            width = 3,
            height = 1,
            points = {
                {0,0},      {2,0}
            }
        },
        [6] = {
            width = 1,
            height = 3,
            points = {
                {0,0},

                {0,2}
            }
        }
    },
    [3] = {
        [1] = {
            width = 3,
            height = 1,
            points = {
                {0,0},{1,0},{2,0}
            }
        },
        [2] = {
            width = 1,
            height = 3,
            points = {
                {0,0},
                {0,1},
                {0,2}
            }
        },
        [3] = {
            width = 2,
            height = 2,
            points = {
                {0,0},{1,0},
                {0,1}
            }
        },
        [4] = {
            width = 2,
            height = 2,
            points = {
                {0,0},{1,0},
                      {1,1}
            }
        },
        [5] = {
            width = 2,
            height = 2,
            points = {
                {0,0},
                {0,1},{1,1}
            }
        },
        [6] = {
            width = 2,
            height = 2,
            points = {
                      {1,0},
                {0,1},{1,1}
            }
        },
        [7] = {
            width = 2,
            height = 2,
            points = {
                      {1,0},
                {0,1},{1,1}
            }
        } -- TODO: finish
    }
}

return equipment_variations