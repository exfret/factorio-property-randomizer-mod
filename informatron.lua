function menu(player_index)
    return {
        randomization_list = 1,
        luckiness = 1,
        chaos_mode = 1
    }
end

function page_content(page_name, player_index, element)
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