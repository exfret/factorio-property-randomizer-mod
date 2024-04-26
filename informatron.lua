function menu(player_index)
    return {
        luck_breakdown = {
            luck_logistics = {
                luck_inserters = 1,
                luck_belts = 1
            },
            luck_production = {
                luck_crafting_machine = 1
            }
        }
        --randomization_list = 1,
        --luckiness = 1
    }
end

function page_content(page_name, player_index, element)
    if page_name == "propertyrandomizer" then
        element.add({type = "label", name = "intro", caption = "This is the information page for exfret's randomizer."})
    end

    -- {element, main_type, sub_types, localised_type, properties_table}
    local function print_properties(params)
        for _, prototype in pairs(game[params.main_type]) do
            if params.sub_types[prototype.type] then
                params.element.add({type = "label", name = "intro_" .. prototype.name, caption = {"", "[entity=", prototype.name, "] [font=default-bold]", {params.localised_type .. "." .. prototype.name}, "[/font]"}})

                for _, property_names in pairs(params.properties_table[prototype.type]) do
                    local old_stats = global.old_data_raw[prg.get_key({type = prototype.type, name = prototype.name})]
                    local old_property_value = old_stats[property_names.prototype_name]
                    local new_property_value = prototype[property_names.control_phase]

                    local stats_change = math.floor(100 * new_property_value / old_property_value - 1)
                    local color
                    if stats_change >= 200 then
                        color = "green"
                    elseif stats_change >= 130 then
                        color = "blue"
                    elseif stats_change >= 70 then
                        color = "white"
                    elseif stats_change >= 40 then
                        color = "yellow"
                    else
                        color = "red"
                    end
                    local text_to_print = "        " .. property_names.localised .. ": [color=" .. color .. "]" .. stats_change .. "%[/color]"
                    -- Need to check for -1 in case of rounding errors
                    if stats_change == 0 or stats_change == -1 then
                        text_to_print = "        " .. property_names.localised .. ": [color=" .. color .. "]Normal[/color]"
                    end

                    params.element.add({type = "label", name = "property_" .. prototype.name .. property_names.control_phase, caption = text_to_print})
                end
            end
        end
    end

    if page_name == "luck_belts" then
        local speed_property = {
            control_phase = "belt_speed",
            localised = "Speed",
            prototype_name = "speed"
        }
        local belt_properties = {
            ["loader"] = {
                table.deepcopy(speed_property)
            },
            ["loader-1x1"] = {
                table.deepcopy(speed_property)
            },
            ["splitter"] = {
                table.deepcopy(speed_property)
            },
            ["transport-belt"] = {
                table.deepcopy(speed_property)
            },
            ["underground-belt"] = {
                table.deepcopy(speed_property),
                {
                    control_phase = "max_underground_distance",
                    localised = "Underground Length",
                    prototype_name = "max_distance"
                }
            }
        }

        local belt_prototypes = {
            ["loader"] = true,
            ["loader-1x1"] = true,
            ["splitter"] = true,
            ["transport-belt"] = true,
            ["underground-belt"] = true
        }

        print_properties({
            element = element,
            main_type = "entity_prototypes",
            sub_types = belt_prototypes,
            localised_type = "entity-name",
            properties_table = belt_properties
        })
    end

    if page_name == "luck_inserters" then
        local inserter_properties = {
            inserter_rotation_speed = "Speed"
        }

        for _, prototype in pairs(game.entity_prototypes) do
            if prototype.type == "inserter" then
                local inserter_name = prototype.name

                local inserter_stats = global.old_data_raw[prg.get_key({type = "inserter", name = inserter_name})]

                local speed_change = math.floor(100 * (game.entity_prototypes[inserter_name].inserter_rotation_speed / inserter_stats.rotation_speed - 1))
                local color
                if speed_change > 50 then
                    color = "green"
                elseif speed_change > 20 then
                    color = "blue"
                elseif speed_change > -20 then
                    color = "white"
                elseif speed_change > -50 then
                    color = "yellow"
                elseif speed_change <= -50 then
                    color = "red"
                end
                local text_to_print = "        Speed: [color=" .. color .. "]" .. speed_change .. "%[/color]"
                if math.abs(speed_change) <= 1 then
                    text_to_print = "        Speed: [color=" .. color .. "]Normal[/color]"
                end
                
                element.add({type = "label", name = "inserter_intro_" .. inserter_name, caption = {"", "[entity=", inserter_name, "] [font=default-bold]", {"entity-name." .. inserter_name}, "[/font]"}})
                element.add({type = "label", name = "inserter_speed_" .. inserter_name, caption = text_to_print})
                --element.add({type = "label", name = "line_break_inserter_" .. inserter_name, caption = "\n"})
            end
        end
    end

    -- TODO: energy_usage
    if page_name == "luck_crafting_machine" then
        local speed_property = {
            control_phase = "crafting_speed",
            localised = "Crafting Speed",
            prototype_name = "crafting_speed"
        }
        local properties_table = {
            ["assembling-machine"] = {
                table.deepcopy(speed_property)
            },
            ["furnace"] = {
                table.deepcopy(speed_property)
            }
        }

        local prototypes_table = {
            ["assembling-machine"] = true,
            ["furnace"] = true
        }

        print_properties({
            element = element,
            main_type = "entity_prototypes",
            sub_types = prototypes_table,
            localised_type = "entity-name",
            properties_table = properties_table
        })
    end

    if page_name == "randomization_list" then
        --[[element.add({type = "label", name = "text_1", caption = {"propertyrandomizer.page_randomization_list_text_1"}})
        element.add({type = "label", name = "character_values", caption = {"propertyrandomizer.page_randomization_list_character_values"}})
        element.add({type = "label", name = "crafting_times", caption = {"propertyrandomizer.page_randomization_list_crafting_times"}})
        element.add({type = "label", name = "entity_sizes", caption = {"propertyrandomizer.page_randomization_list_entity_sizes"}})
        element.add({type = "label", name = "inserter_positions", caption = {"propertyrandomizer.page_randomization_list_inserter_positions"}})
        element.add({type = "label", name = "logistics", caption = {"propertyrandomizer.page_randomization_list_logistics"}})
        element.add({type = "label", name = "military", caption = {"propertyrandomizer.page_randomization_list_military"}})]]
    end

    --[[if page_name == "luckiness" then
        element.add({type = "label", name = "text_1", caption = {"propertyrandomizer.page_luckiness_text_1"}})
    end]]

    --if page_name == "luckiness" then
    --    element.add({type = "label", name = "text_1", caption = {"propertyrandomizer.page_luckiness_text_1"}})
    --    element.add({type = "label", name = "inserter_positions", caption = {"propertyrandomizer.page_luckiness_inserter_positions", "Overall: " .. global.data.property_values[prg.get_key({type = "inserter", name = "inserter", property = "rotation_speed"})]}})
    --end

    --[[if page_name == "chaos_mode" then
        element.add({type = "label", name = "text_1", caption = {"propertyrandomizer.page_chaos_mode_text_1"}})
    end]]
end