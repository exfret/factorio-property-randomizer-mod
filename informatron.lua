function menu(player_index)
    return {
        luck_breakdown = {
            luck_logistics = {
                luck_inserters = 1,
                luck_belts = 1,
                luck_bots = 1
            },
            luck_military = {
            },
            luck_production = {
                luck_beacon = 1,
                luck_crafting_machine = 1,
                luck_power = 1
            }
        }
        --randomization_list = 1,
        --luckiness = 1
    }
end

-- More info to show...
-- TODO: Ammo damage
-- TODO: Boiler power

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

                    local stats_change = math.floor(100 * (new_property_value / old_property_value - 1))
                    local color
                    if stats_change >= 100 then
                        color = "green"
                    elseif stats_change >= 30 then
                        color = "blue"
                    elseif stats_change >= -30 then
                        color = "white"
                    elseif stats_change >= -60 then
                        color = "yellow"
                    else
                        color = "red"
                    end
                    local sign_symbol = ""
                    if stats_change > 0 then
                        sign_symbol = "+"
                    end
                    local text_to_print = "        " .. property_names.localised .. ": [color=" .. color .. "]" .. sign_symbol .. stats_change .. "%[/color]"
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

    if page_name == "luck_bots" then
        local speed_property = {
            control_phase = "speed",
            localised = "Speed",
            prototype_name = "speed"
        }
        local bot_properties = {
            ["construction-robot"] = {
                table.deepcopy(speed_property)
            },
            ["logistic-robot"] = {
                table.deepcopy(speed_property)
            }
        }
        local bot_prototypes = {
            ["construction-robot"] = true,
            ["logistic-robot"] = true
        }

        print_properties({
            element = element,
            main_type = "entity_prototypes",
            sub_types = bot_prototypes,
            localised_type = "entity-name",
            properties_table = bot_properties
        })
    end

    if page_name == "luck_inserters" then
        local speed_property = {
            control_phase = "inserter_rotation_speed",
            localised = "Speed",
            prototype_name = "rotation_speed"
        }
        local inserter_properties = {
            ["inserter"] = {
                table.deepcopy(speed_property)
            }
        }

        local prototypes_table = {
            ["inserter"] = true
        }

        print_properties({
            element = element,
            main_type = "entity_prototypes",
            sub_types = prototypes_table,
            localised_type = "entity-name",
            properties_table = inserter_properties
        })
    end

    if page_name == "luck_beacon" then
        local effectivity_property = {
            control_phase = "distribution_effectivity",
            localised = "Effectivity",
            prototype_name = "distribution_effectivity"
        }
        local supply_area_property = {
            control_phase = "supply_area_distance",
            localised = "Supply Area",
            prototype_name = "supply_area_distance"
        }
        local properties_table = {
            ["beacon"] = {
                table.deepcopy(effectivity_property),
                table.deepcopy(supply_area_property)
            }
        }
        local prototypes_table = {
            ["beacon"] = true
        }

        print_properties({
            element = element,
            main_type = "entity_prototypes",
            sub_types = prototypes_table,
            localised_type = "entity-name",
            properties_table = properties_table
        })
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

    if page_name == "luck_power" then
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