local reformat = {}

-- TODO: double check vectors
-- TODO: Recheck for properties that could be strings or tables

--------------------------------------------------------------------------------
-- Table Types
--------------------------------------------------------------------------------

reformat.type = {}
reformat.prototype = {}
reformat.common = {}
reformat.test = {}

function reformat.type.ingredient_prototyte(ingredient)
    if ingredient[1] then
        ingredient.name = ingredient[1]
        ingredient[1] = nil
        ingredient.amount = ingredient[2]
        ingredient[2] = nil
    end
    if ingredient.type == nil then
        ingredient.type = "item"
    end
end

function reformat.type.product_prototyte(product)
    if product[1] then
        product.name = product[1]
        product[1] = nil
        product.amount = product[2]
        product[2] = nil
    end
    if product.type == nil then
        product.type = "item"
    end
end

function reformat.type.recipe_ingredients(recipe)
    if recipe.normal ~= nil then
        reformat.type.recipe_ingredients(recipe.normal)
    end
    if recipe.expensive ~= nil then
        reformat.type.recipe_ingredients(recipe.expensive)
    end
    if recipe.ingredients ~= nil then
        for _, ingredient in pairs(recipe.ingredients) do
            reformat.type.ingredient_prototyte(ingredient)
        end
    else
        recipe.ingredients = recipe.normal.ingredients
    end
end

function reformat.type.recipe_products(recipe)
    if recipe.normal ~= nil then
        reformat.type.recipe_products(recipe.normal)
    end
    if recipe.expensive ~= nil then
        reformat.type.recipe_products(recipe.expensive)
    end
    if recipe.result ~= nil then
        if recipe.result_count == nil then
            recipe.result_count = 1
        end
        recipe.results = {
            {name = recipe.result, amount = recipe.result_count}
        }
    end
    if recipe.results == nil then
        recipe.results = recipe.normal.results
    end
    if recipe.results ~= nil then
        recipe.result = nil
        recipe.result_count = nil

        for _, result in pairs(recipe.results) do
            reformat.type.product_prototyte(result)
        end
    end
end

function reformat.prototype.recipe(recipe)
    reformat.type.recipe_ingredients(recipe)
    reformat.type.recipe_products(recipe)

    if recipe.normal ~= nil then
        for name, value in pairs(recipe.normal) do
            recipe[name] = value
        end
        recipe.normal = nil
    end
    if recipe.expensive ~= nil then
        recipe.expensive = nil
    end
end

-- Don't allow normal versus expensive mode
function reformat.prototype.technology(technology)
    local tech_table = nil
    if technology.normal then
        tech_table = technology.normal
    elseif technology.expensive then
        tech_table = technology.expensive
    end

    if tech_table ~= nil then
        for k, v in pairs(tech_table) do
            technology[k] = v
        end
    end

    technology.normal = nil
    technology.expensive = nil

    if technology.effects == nil then
        technology.effects = {}
    end
end

--------------------------------------------------------------------------------
-- Common functionality
--------------------------------------------------------------------------------

function reformat.common.artillery(prototype)
    if prototype.disable_automatic_firing == nil then
        prototype.disable_automatic_firing = false
    end

    if prototype.cannon_base_pictures ~= nil then
        reformat.rotated_sprite(prototype.cannon_base_pictures)
    end

    if prototype.cannon_barrel_pictures ~= nil then
        reformat.rotated_sprite(prototype.cannon_barrel_pictures)
    end

    if prototype.rotating_sound ~= nil then
        reformat.interruptible_sound(prototype.rotating_sound)
    end

    if prototype.rotating_stopped_sound ~= nil then
        reformat.sound(prototype.rotating_stopped_sound)
    end

    if prototype.turn_after_shooting_cooldown == nil then
        prototype.turn_after_shooting_cooldown = 0
    end

    if prototype.cannon_parking_frame_count == nil then
        prototype.cannon_parking_frame_count = 0
    end

    if prototype.cannon_parking_speed == nil then
        prototype.cannon_parking_speed = 1
    end

    -- TODO: cannon_barrel_recoil_shiftings

    -- TODO: cannon_barrel_recoil_shiftings_load_correction_matrix

    -- TODO: cannon_barrel_light_direction
end

--------------------------------------------------------------------------------
-- Prototypes
--------------------------------------------------------------------------------

reformat.prototype["accumulator"] = function(prototype)
    reformat.type.energy_source(prototype.energy_source)
    
    if prototype.picture ~= nil then
        reformat.type.sprite(prototype.picture)
    end

    if prototype.charge_animation ~= nil then
        reformat.type.animation(prototype.charge_animation)
    else
        prototype.charge_light = nil
    end

    if prototype.charge_light ~= nil then
        reformat.type.light_definition(prototype.charge_light)
    end

    if prototype.discharge_animation ~= nil then
        reformat.type.animation(prototype.discharge_animation)
    else
        prototype.discharge_light = nil
    end

    if prototype.discharge_light ~= nil then
        reformat.type.light_definition(prototype.discharge_light)
    end

    if prototype.circuit_wire_connection_point ~= nil then
        reformat.type.wire_connection_point(prototype.circuit_wire_connection_point)
    end

    if prototype.circuit_wire_max_distance == nil then
        prototype.circuit_wire_max_distance = 0
    end

    if prototype.draw_copper_wires == nil then
        prototype.draw_copper_wires = true
    end

    if prototype.draw_circuit_wires == nil then
        prototype.draw_circuit_wires = true
    end

    if prototype.circuit_connector_sprites ~= nil then
        reformat.type.circuit_connector_sprites(prototype.circuit_connector_sprites)
    end

    -- TODO: I think this is just a string
    if prototype.default_output_signal ~= nil then
        reformat.type.signal_id_connector(prototype.default_output_signal)
    end

    reformat.prototype["entity-with-owner"](prototype)
end

reformat.prototype["achievement"] = function(prototype)
    reformat.common.prototype_with_icons(prototype)

    if prototype.allowed_without_fight == nil then
        prototype.allowed_without_fight = true
    end

    if prototype.hidden == nil then
        prototype.hidden = false
    end

    reformat.prototype["base"](prototype)
end

reformat.prototype["active-defense-equipment"] = function(prototype)
    reformat.type.attack_parameters(prototype.attack_parameters)

    reformat["equipment"](prototype)
end

reformat.prototype["ambient-sound"] = function (prototype)
    reformat.type.sound(prototype.sound)

    if prototype.weight == nil then
        prototype.weight = 1
    end
end

reformat.prototype["ammo-category"] = function(prototype)
    if prototype.bonus_gui_order == nil then
        prototype.bonus_gui_order = ""
    end

    reformat.prototype["base"](prototype)
end

reformat.prototype["ammo"] = function(prototype)
    -- ammo_type has special rules
    if prototype.ammo_type.category ~= nil then
        prototype.ammo_type = {
            prototype.ammo_type
        }
        prototype.ammo_type[1].source_type = "default"
    end
    for _, ammo_type in pairs(prototype.ammo_type) do
        reformat.type.ammo_type(ammo_type)
    end
    -- TODO: Reformat list to always be the three basic types in order

    if prototype.magazine_size == nil then
        prototype.magazine_size = 1
    end

    if prototype.reload_time == nil then
        prototype.reload_time = 0
    end

    reformat.prototype["item"](prototype)
end

reformat.prototype["ammo-turret"] = function(prototype)
    if prototype.entity_info_icon_shift == nil then
        prototype.entity_info_icon_shift = {x = 0, y = 0}
    end

    reformat.prototype["turret"](prototype)
end

reformat.prototype["animation"] = function (prototype)
    -- TODO
end

reformat.prototype["arithmetic-combinator"] = function (prototype)
    -- TODO

    reformat.prototype["combinator"](prototype)
end

reformat.prototype["armor"] = function(prototype)
    if prototype.resistances == nil then
        prototype.resistances = {}
    end
    reformat.type.resistances(prototype.resistances)

    if prototype.inventory_size_bonus == nil then
        prototype.inventory_size_bonus = 0
    end

    reformat.prototype["tool"](prototype)
end

reformat.prototype["arrow"] = function(prototype)
    reformat.type.sprite(prototype.arrow_picture)

    if prototype.circle_picture ~= nil then
        reformat.type.sprite(prototype.circle_picture)
    end

    if prototype.blinking == nil then
        prototype.blinking = false
    end

    -- Overrides

    if prototype.collision_mask == nil then
        prototype.collision_mask = {}
    end

    reformat.prototype["entity"](prototype)
end

reformat.prototype["artillery-flare"] = function(prototype)
    -- TODO

    reformat.prototype["entity"](prototype)
end

reformat.prototype["artillery-projectile"] = function(prototype)
    if prototype.picture ~= nil then
        reformat.type.sprite(prototype.picture)
    end

    if prototype.shadow ~= nil then
        reformat.type.sprite(prototype.shadow)
    end

    if prototype.chart_picture ~= nil then
        reformat.type.sprite(prototype.chart_picture)
    end

    if prototype.action ~= nil then
        reformat.type.trigger(prototype.action)
    end

    if prototype.final_action ~= nil then
        reformat.type.trigger(prototype.final_action)
    end

    if prototype.height_from_ground == nil then
        prototype.height_from_ground = 1
    end

    if prototype.rotatable == nil then
        prototype.rotatable = true
    end

    -- Overriddes

    if prototype.collision_mask == nil then
        prototype.collision_mask = {}
    end

    if prototype.collision_box == nil then
        prototype.collision_box = {{0,0},{0,0}}
    end

    reformat.prototype["entity"](prototype)
end

reformat.prototype["artillery-turret"] = function(prototype)
    if prototype.alert_when_attacking == nil then
        prototype.alert_when_attacking = true
    end

    if prototype.base_picture_secondary_draw_order == nil then
        prototype.base_picture_secondary_draw_order = 0
    end

    if prototype.base_shift == nil then
        prototype.base_shift = {x = 0, y = 0}
    end

    if prototype.base_picture ~= nil then
        reformat.type.animation_4_way(prototype.base_picture)
    end

    -- Overrides

    if prototype.is_military_target == nil then
        prototype.is_military_target = true
    end

    reformat.common.artillery(prototype)

    reformat.prototype["entity-with-owner"](prototype)
end

reformat.prototype["artillery-wagon-turret"] = function(prototype)
    -- TODO: cannon_base_shiftings

    reformat.common.artillery(prototype)

    reformat.prototype["rolling-stock"](prototype)
end

reformat.prototype["assembling-machine"] = function(prototype)
    if prototype.fixed_recipe == nil then
        prototype.fixed_recipe = ""
    end

    if prototype.gui_title_key == nil then
        prototype.gui_title_key = ""
    end

    if prototype.ingredient_count == nil then
        prototype.ingredient_count = 255
    end

    -- Overrides

    if prototype.entity_info_icon_shift == nil then
        prototype.entity_info_icon_shift = {x = 0, y = -0.3}
    else
        reformat.type.vector(prototype.entity_info_icon_shift)
    end

    reformat.prototype["crafting-machine"](prototype)
end

reformat.prototype["autoplace-control"] = function(prototype)
    if prototype.richness == nil then
        prototype.richness = false
    end

    if prototype.can_be_disabled == nil then
        prototype.can_be_disabled = true
    end

    reformat.prototype["base"](prototype)
end

reformat.prototype["battery-equipment"] = function(prototype)
    reformat.prototype["equipment"](prototype)
end

reformat.prototype["beacon"] = function(prototype)
    reformat.literal_type.energy(prototype, "energy_usage")

    -- We don't need to specify electric here because the possibility of it being void is already enough to force in the electric type key
    reformat.type.energy_source(prototype.energy_source)

    reformat.type.module_specification(prototype.module_specification)

    -- The following three todos have a load dependency (the last two load if and only if the first one doesn't)

    -- TODO: graphics_set

    -- TODO: animation

    -- TODO: base_picture

    if prototype.radius_visualisation_picture ~= nil then
        reformat.type.sprite(prototype.radius_visualisation_picture)
    end

    -- TODO: I think this could be a string
    if prototype.allowed_effects == nil then
        prototype.allowed_effets = {}
    else
        reformat.type.effect_type_limitation(prototype, "allowed_effects")
    end

    reformat.prototype["entity-with-owner"](prototype)
end

reformat.prototype["beam"] = function(prototype)
    reformat.type.animation(prototype.head)

    reformat.type.animation(protoype.tail)

    reformat.type.animation_variations(prototype.body)

    if prototype.action ~= nil then
        reforamt.type.action(prototype.action)
    end

    if prototype.target_offset == nil then
        prototype.target_offset = {x = 0, y = 0}
    else
        reformat.type.vector(prototype.target_offset)
    end

    if prototype.random_target_offset == nil then
        prototype.random_target_offset = false
    end

    if prototype.action_triggered_automatically == nil then
        prototype.action_triggered_automatically = false
    end

    if prototype.random_end_animation_rotation == nil then
        prototype.random_end_animation_rotation = false
    end
    
    if prototype.random_end_animation_rotation == nil then
        prototype.random_end_animation_rotation = true
    end

    if prototype.transparent_start_end_animations == nil then
        prototype.transparent_start_end_animations = true
    end

    if prototype.start ~= nil then
        reformat.type.animation(prototype.start)
    end

    if prototype.ending ~= nil then
        reformat.type.ending(prototype.ending)
    end

    if prototype.light_animations ~= nil then
        reformat.type.beam_animation_set(prototype.light_animations)
    end

    if prototype.ground_light_animations ~= nil then
        reformat.type.beam_animation_set(prototype.ground_light_animations)
    end

    if prototype.start_light ~= nil then
        reformat.type.animation(prototype.start_light)
    end

    if prototype.ending_light ~= nil then
        reformat.type.animation(prototype.ending_light)
    end

    if prototype.head_light ~= nil then
        reformat.type.animation(prototype.head_light)
    end

    if prototype.tail_light ~= nil then
        reformat.type.animation(prototype.tail_light)
    end

    if prototype.body_light ~= nil then
        reformat.type.animation_variations(prototype.body_light)
    end

    -- Overrides

    if prototype.collision_mask == nil then
        prototype.collision_mask = {}
    end

    reformat.prototype["entity"](prototype)
end

reformat.test.prototype = function(prototype)
    local spec = reformat.spec.prototype[prototype.name]

    if spec.defaults ~= nil then
        for property, default in pairs(spec.defaults) do -- TODO: Merge overrides with defaults
            if prototype[property] == nil then
                local copy = default
                if type(default) == "table" then
                    copy = table.deepcopy(default)
                end

                prototoype[property] = copy
            end
        end
    end

    -- TODO: Should I remove this?
    --[[if spec.common ~= nil then
        for _, format in pairs(spec.common) do
            reformat.common[format](prototype)
        end
    end]]

    if spec.properties ~= nil then
        for property, format in pairs(spec.properties) do
            if type(format) == "table" then
                -- TODO: This actually needs to call reformat.type[format.blop] for some value of blop, but it seems inconsistent
                prototype[property] = reformat.type[format](prototype[property], format)
            elseif type(format) == "string" then
                prototype[property] = reformat.type[format](prototype[property])
            end
        end
    end

    if spec.inherits ~= nil then
        reformat.prototype[spec.inherits](prototype)
    end
end

function reformat.verify_spec()
    for _, spec in pairs(reformat.spec.prototype) do
        if spec.properties == nil then
            -- defaults and allow_nil can be non-nil still for overrides
            -- Maybe check that they at least exist in the inherits?
        end
        for property, _ in pairs(spec.properties) do
            for default, _ in pairs(spec.defaults) do
                -- TODO: Check that all things in defaults are actually a property, also make sure nothing has an undefined property, and that every undefined property is an optional one
            end
        end

        local allowed_spec_properties = {
            properties = true,
            defaults = true,
            allow_nil = true,
            inherits = true
        }
        for spec_property_name, _ in pairs(spec) do
            if not allowed_spec_properties[spec_property_name] then
                -- TODO: Error
            end
        end
    end

    for class_name, class in pairs(data.raw) do
        local spec = reformat.spec.prototype[class_name]

        if spec == nil then
            -- TODO: Error
        end

        for _, prototype in pairs(class) do
            for property_name, property in pairs(prototype) do
                -- Check if property_name appears in spec or inherits
            end
        end
    end
end

--[[
    1) All properties must be defined in the properties table of a prototype's spec
    2) An optional property must be in the defaults or the "allow_nil" table
    ]]

reformat.spec = {
    prototype = {
        ["belt-immunity-equipment"] = {
            properties_literal = { -- TODO: No longer need to be separate
                energy_consumption = "energy"
            },
            inherits = "equipment"
        },
        ["blueprint-book"] = {
            overrides = {
                stack_size = 1,
                draw_label_for_cursor_render = true
            },
            inherits = "item-with-inventory"
        },
        ["blueprint"] = {
            overrides = {
                stack_size = 1,
                draw_label_for_cursor_render = true,
                selection_mode = "blueprint",
                alt_selection_mode = "blueprint",
                always_include_tiles = false
            },
            inherits = "selection-tool"
        },
        ["boiler"] = {
            properties = {
                energy_source = "energy_source",
                fluid_box = "fluid_box",
                output_fluid_box = "output_fluid_box",
                structure = "boiler_structure",
                fire = "type.boiler_fire",
                fire_glow = "boiler_fire_glow",
                patch = "boiler_patch"
            },
            properties_literal = { -- TODO: No longer need to be separate
                energy_consumption = "energy",
            },
            defaults = {
                fire_glow_flicker_enabled = false,
                fire_flicker_enabled = false,
                mode = "heat-water-inside"
            },
            inherits = "entity-with-owner"
        },
        ["build-entity-achievement"] = {
            defaults = {
                amount = 1,
                limited_to_one_game = false,
                until_second = 0
            },
            inherits = "achievement"
        },
        ["burner-generator"] = {
            properties = {
                energy_source = "electric_energy_source",
                burner = "burner_energy_source",
                animation = "animation_4_way",
                idle_animation = "animation_4_way"
            },
            properties_literal = { -- TODO: No longer need to be separate
                max_power_output = "max_power_output",
            },
            defaults = {
                min_perceived_performance = 0.25,
                performace_to_sound_speedup = 0.5
            },
            inherits = "entity-with-owner"
        },
        ["capsule"] = {
            properties = {
                capsule_action = "capsule_action",
                color = "color"
            },
            inherits = "item"
        },
        ["car"] = {
            properties = {
                animation = "rotated_animation",
                consumption = "energy",
                -- energy_source/burner is special and dealt with specially
                turret_animation = "rotated_animation",
                light_animation = "rotated_animation",
                light = "light_definition",
                sound_no_fuel = "sound",
                track_particle_triggers = "footstep_trigger_effect_list"
            },
            defaults = {
                render_layer = "object",
                tank_driving = false,
                has_belt_immunity = false,
                immune_to_tree_impacts = false,
                immune_to_rock_impacts = false,
                immune_to_cliff_impacts = true,
                turret_rotation_speed = 0.01,
                turret_return_timeout = 60,
                darkness_to_render_light_animation = 0.3,
                guns = {},
                collision_mask = {"player-layer", "train-layer", "consider-tile-transitions"}
            },
            inherits = "vehicle"
        },
        ["cargo-wagon"] = {
            inherits = "rolling-stock"
        },
        ["character-corpse"] = {
            common = {
                "prototype_with_pictures" -- Need special functionality to integrate picture into pictures if it exists
            },
            defaults = {
                render_layer = "object",
                collision_mask = {}
            }
            -- Confused about armor_picture_mapping, will leave it for now
        },
        ["character"] = {
            properties = {
                heartbeat = "sound",
                eat = "sound",
                damage_hit_tint = "color",
                animations = "character_armor_animation_list",
                light = "light_definition",
                footstep_particle_triggers = "footstep_trigger_effect_list",
                synced_footstep_particle_triggers = "footstep_trigger_effect_list",
                footprint_particles = "footprint_particle_list",
                left_footprint_offset = "vector",
                right_footprint_offset = "vector",
                tool_attack_result = "trigger"
            },
            defaults = {
                crafting_categories = {},
                mining_categories = {},
                enter_vehicle_distance = 3,
                tool_attack_distance = 1.5,
                respawn_time = 10,
                has_belt_immunity = false,
                is_military_target = true,
                collision_mask = {"player-layer", "train-layer", "consider-tile-transitions"}
            },
            inherits = "entity-with-owner"
        },
        ["cliff"] = {
            properties = {
                orientations = "oriented_cliff_prototype_set",
                grid_size = "vector",
                grid_offset = "vector"
            },
            defaults = {
                cliff_height = 4,
                collision_mask = {"item-layer", "object-layer", "player-layer", "water-tile", "not-colliding-with-itself"}
            },
            inherits = "entity"
        },
        ["combat-robot-count"] = {
            defaults = {
                count = 1
            },
            inherits = "achievement"
        },
        ["combat-robot"] = {
            properties = {
                attack_parameters = "attack_parameters",
                idle = "rotated_animation",
                shadow_idle = "rotated_animation",
                in_motion = "rotated_animation",
                shadow_in_motion = "rotated_animation",
                destroy_action = "trigger",
                light = "light_definition"
            },
            defaults = {
                range_from_player = 0,
                friction = 0,
                follows_player = false
            },
            inherits = "flying-robot"
        },
        ["combinator"] = {
            properties = {
                energy_source = "energy_source",
                active_energy_usage = "energy",
                sprites = "sprite_4_way",
                activity_led_sprites = "sprite_4_way",
                input_connection_bounding_box = "bounding_box",
                ouptut_connection_bounding_box = "bounding_box",
                activity_led_light_offsets = "4_vector",
                screen_led_light_offsets = "4_vector",
                input_connection_points = "4_wire_connection_point",
                output_connection_points = "4_wire_connection_point",
                activity_led_light = "light_definition",
                screen_light = "light_definition"
            },
            defaults = {
                activity_led_hold_time = 5,
                circuit_wire_max_distance = 0,
                draw_copper_wires = true,
                draw_circuit_wires = true
            },
            inherits = "entity-with-owner"
        },
        ["constant-combinator"] = {
            properties = {
                sprites = "sprite_4_way",
                activity_led_sprietss = "sprite_4_way",
                activity_led_light_offsets = "4_vector",
                circuit_wire_connection_points = "4_wire_connection_point",
                activity_led_light = "light_definition"
            },
            defaults = {
                circuit_wire_max_distance = 0,
                draw_copper_wires = true,
                draw_circuit_wires = true
            },
            inherits = "entity-with-owner"
        },
        ["construct-with-robots-achievement"] = {
            defaults = {
                amount = 0,
                more_than_manually = false
            }
        },
        ["construction-robot"] = {
            properties = {
                construction_vector = "vector",
                working = "rotated_animation",
                shadow_working = "rotated_animation",
                smoke = "animation",
                sparks = "animation_variations",
                repairing_sound = "sound",
                working_light = "light_definition"
            },
            defaults = {
                collision_box = {{0, 0} ,{0, 0}}
            },
            inherits = "robot-with-logistic-interface"
        },
        ["container"] = {
            properties = {
                picture = "sprite"
            },
            defaults = {
                inventory_type = "with_bar",
                enable_inventory_bar = true,
                scale_info_icons = false,
                circuit_wire_connection_point = "wire_connection_point",
                circuit_wire_max_distance = 0,
                draw_copper_wires = true,
                draw_circuit_wires = true,
                circuit_connector_sprites = "circuit_connector_sprites"
            },
            inherits = "entity-with-owner"
        },
        ["copy-paste-tool"] = {
            defaults = {
                cuts = false,
                stack_size = 1,
                always_include_tiles = false
            },
            inherits = "selection-tool"
        },
        ["corpse"] = { -- Dunno what to do about direction shuffle
            properties = {
                animation = "rotated_animation_variations",
                animation_overlay = "rotated_animation_variations",
                splash = "animation_variations",
                ground_patch = "animation_variations",
                ground_patch_higher = "animation_variations"
            },
            defaults = {
                dying_speed = 1,
                splash_speed = 1,
                time_before_shading_off = 60 * 15,
                time_before_removed = 60 * 120,
                remove_on_entity_placement = true,
                remove_on_tile_placement = true,
                final_render_layer = "corpse",
                ground_patch_render_layer = "ground-patch",
                animation_render_layer = "object",
                splash_render_layer = "object",
                animation_overlay_render_layer = "object",
                animation_overlay_final_render_layer = "corpse",
                shuffle_directions_at_frame = 1,
                use_tile_color_for_ground_patch_tint = false,
                ground_patch_fade_in_delay = 0,
                ground_patch_fade_in_speed = 0,
                ground_patch_fade_out_start = 0,
                ground_patch_fade_out_duration = 0,
                collision_mask = {}
            },
            inherits = "entity"
        },
        ["crafting-machine"] = {
            properties = {
                energy_usage = "energy",
                energy_source = "energy_source",
                fluid_boxes = "fluid_box_array_with_off_when_no_fluid_recipe", -- They can have an extra key in their fluid boxes I need to account for
                allowed_effects = "effect_type_limitation",
                animation = "animation_4_way",
                idle_animation = "animation_4_way",
                default_recipe_tint = "default_recipe_tint",
                shift_animation_waypoints = "shift_animation_waypoints",
                status_colors = "status_colors",
                entity_info_icon_shift = "vector",
                module_specification = "module_specification",
                working_visualisations = "working_visualization_array"
            },
            defaults = {
                fluid_boxes = {},
                allowed_effects = {},
                scale_entity_info_icon = false,
                show_recipe_icon = true,
                return_ingredients_on_change = true,
                always_raw_idle_animation = false,
                shift_animation_waypoint_stop_duration = 0,
                shift_animation_transition_duration = 0,
                draw_entity_info_icon_background = true,
                match_animation_speed_to_activity = true,
                show_recipe_icon_on_map = true,
                base_productivity = 0
            },
            implements = "entity-with-owner"
        },
        ["curved-rail"] = {
            defaults = {
                bending_type = "turn"
            },
            implements = "rail"
        },
        ["custom-input"] = { -- Has some special strings? Look back on this later
            defaults = {
                linked_game_control = "",
                consuming = "none",
                enabled = true,
                enabled_while_spectating = false,
                enabled_while_in_cutscene  = flase,
                include_selected_prototype = false,
                action = "lua"
            },
            implements = "base"
        },
        ["damage-type"] = {
            defaults = {
                hidden = false
            }
        },
        ["decider-combinator"] = {
            properties = {
                equal_symbol_sprites = "sprite_4_way",
                greater_symbol_sprites = "sprite_4_way",
                less_symbol_sprites = "sprite_4_way",
                not_equal_symbol_sprites = "sprite_4_way",
                greater_or_equal_symbol_sprites = "sprite_4_way",
                less_or_equal_symbol_sprites = "sprite_4_way"
            },
            implements = "combinator"
        },
        ["deconstruct-with-robots-achievement"] = {
            implements = "achievement"
        },
        ["deconstructible-tile-proxy"] = {
            implements = "entity"
        },
        ["deconstruction-item"] = {
            defaults = {
                entity_filter_count = 0,
                tile_filter_count = 0,
                stack_size = 1,
                selection_mode = "deconstruct",
                alt_selection_mode = "cancel-deconstruct",
                always_include_tiles = false
            },
            implements = "selection-tool"
        },
        ["optimized-decorative"] = { -- Just called DecorativePrototype in the list
            properties = {
                pictures = "sprite_variations",
                collision_box = "collision_box",
                walking_sound = "sound",
                trigger_effect = "trigger_effect",
                autoplace = "autoplace_specification"
            },
            defaults = {
                render_layer = "decorative",
                grows_through_rail_path = false,
                tile_layer = 0,
                decal_overdraw_priority = 0,
                collision_mask = {"doodad-layer"}
            },
            implements = "base"
        }, -- TODO: Reformat previous things for like entity-ids
        ["deliver-by-robots-achievement"] = {
            properties = {
                amount = "material_amount_type"
            },
            inherits = "achievement"
        },
        ["dont-build-entity-achievement"] = {
            properties = {
                -- Do dont_build manually so I can turn singleton entityId's into arrays
                amount = "uint32"
            },
            inherits = "achievement"
        },
        ["dont-craft-manually-achievement"] = {
            properties = {
                amount = "material_amount_type"
            },
            inherits = "achievement"
        },
        ["dont-use-entity-in-energy-production-achievement"] = {
            properties = {
                excluded = {
                    modifier = "array",
                    possibly_just_value = true,
                    format = "entity_id"
                },
                included = {
                    modifier = "array",
                    possibly_just_value = true,
                    format = "entity_id"
                },
                last_hour_only = "bool",
                minimum_energy_produced = "energy"
            },
            defaults = {
                last_hour_only = false,
                minimum_energy_produced = "0J"
            },
            inherits = "achievement"
        },
        ["editor-controller"] = {
            properties = {
                type = {
                    modifier = "union",
                    union_members = {
                        "editor-controller"
                    }
                },
                name = "string",
                inventory_size = "item_stack_index",
                gun_inventory_size = "item_stack_index",
                movement_speed = "double",
                item_pickup_distance = "double",
                loot_pickup_distance = "double",
                mining_speed = "double",
                enable_flash_light = "bool",
                adjust_speed_based_off_zoom = "bool",
                render_as_day = "bool",
                instant_blueprint_building = "bool",
                instant_deconstruction = "bool",
                instant_upgrading = "bool",
                instant_rail_planner = "bool",
                show_status_icons = "bool",
                show_hidden_entities = "bool",
                show_entity_tags = "bool",
                show_entity_health_bars = "bool",
                show_additional_entity_info_gui = "bool",
                generate_neighbor_chunks = "bool",
                fill_built_entity_energy_buffers = "bool",
                show_character_tab_in_controller_gui = "bool",
                show_infinity_filters_in_controller_gui = "bool",
                placed_corpses_never_expire = "bool"
            }
        },
        ["electric-energy-interface"] = {
            -- TODO: Special functionality for picture/pictures
            properties = {
                energy_source = "electric-energy-source",
                energy_production = "energy",
                energy_usage = "energy",
                gui_mode = {
                    modifier = "union",
                    union_members = {
                        "all",
                        "none",
                        "admins"
                    },
                    continuous_animation = "bool",
                    render_layer = "render_layer",
                    light = "light_definition",
                    picture = "sprite",
                    pictures = "sprite_4_way",
                    animation = "animation",
                    animations = "animation_4_way"
                }
            },
            defaults = {
                energy_production = "0J",
                energy_usage = "0J",
                gui_mode = "none",
                continuous_animation = false,
                render_layer = "object"
            },
            allow_nil = {
                light = true,
                picture = true,
                pictures = true,
                animation = true,
                animations = true
            },
            overrides = {
                allow_copy_paste = false
            },
            inherits = "entity-with-owner"
        },
        ["electric-pole"] = {
            properties = {
                pictures = "rotated-sprite",
                supply_area_distance = "double",
                connection_points = {
                    modifier = "array",
                    format = "wire_connection_point"
                },
                radius_visualisation_picture = "sprite",
                active_picture = "sprite",
                maximum_wire_distance = "double",
                draw_copper_wires = "bool",
                draw_circuit_wires = "bool",
                light = "light_definition",
                track_coverage_during_build_by_moving = "bool"
            },
            defaults = {
                maximum_wire_distance = 0,
                draw_copper_wires = true,
                draw_circuit_wires = true,
                track_coverage_during_build_by_moving = false
            },
            allow_nil = {
                radius_visualisation_picture = true,
                active_picture = true,
                light = true
            },
            inherits = "entity-with-owner"
        },
        ["electric-turret"] = {
            properties = {
                energy_source = "electric_or_void_energy_source" -- TODO: I don't know if there's a better way of doing this
            },
            inherits = "turret"
        },
        ["unit-spawner"] = {
            properties = {
                animations = "animation_variations",
                max_count_of_owned_units = "uint32",
                max_friends_around_to_spawn = "uint32",
                spawning_cooldown = {
                    modifier = "table",
                    format = {
                        [1] = "double",
                        [2] = "double"
                    }
                },
                spawning_radius = "double",
                spawning_spacing = "double",
                max_richness_for_spawn_shift = "double",
                max_spawn_shift = "double",
                pollution_absorption_absolute = "double",
                pollution_absorption_proportional = "double",
                call_for_help_radius = "double",
                result_units = {
                    modifier = "array",
                    format = "unit_spawn_definition"
                },
                dying_sound = "sound",
                integration = "sprite_variations",
                min_darkness_to_spawn = "float",
                max_darkness_to_spawn = "float",
                random_animation_offset = "bool",
                spawn_decorations_on_expansion = "bool",
                spawn_decoration = {
                    modifier = "array",
                    possibly_just_value = true,
                    format = "create_decoratives_trigger_effect_item"
                },
                defaults = {
                    min_darkness_to_spawn = 0,
                    max_darkness_to_spawn = 1,
                    random_animation_offset = true,
                    spawn_decorations_on_expansion = false,
                    spawn_decoration = {}
                },
                allow_nil = {
                    integration = true
                },
                overrides = {
                    is_military_target = true,
                    allow_run_time_change_of_is_military_target = false
                },
                inherits = "entity-with-owner"
            }
        },
        ["energy-shield-equipment"] = {
            properties = {
                max_shield_value = "float",
                energy_per_shield = "energy"
            },
            inherits = "equipment"
        },
        ["entity-ghost"] = {
            properties = {
                medium_build_sound = "sound",
                large_build_sound = "sound"
            },
            allow_nil = {
                medium_build_sound = true,
                large_build_sound = true
            },
            overrides = {
                collision_mask = {"ghost-layer"}
            },
            inherits = "entity"
        },
        ["particle"] = {
            overrides = {
                collision_mask = {}
            },
            inherits = "entity"
        },
        ["entity"] = {
            properties = {
                icons = {
                    modifier = "array",
                    format = "icon_data"
                },
                icon = "file_name",
                icon_size = "sprite_size_type",
                icon_mipmaps = "icon_mip_map_type",
                collision_box = "bounding_box",
                collision_mask = "collision_mask",
                map_generator_bounding_box = "bounding_box",
                selection_box = "bounding_box",
                drawing_box = "bounding_box",
                sticker_box = "bounding_box",
                hit_visualization_box = "bounding_box",
                trigger_target_mask = "trigger_target_mask",
                flags = "entity_prototype_flags",
                minable = "minable_properties",
                subgroup = "item_sub_group_id",
                allow_copy_paste = "bool",
                selectable_in_game = "bool",
                selection_priority = "uint8",
                build_grid_size = "uint8",
                remove_decoratives = {
                    modifier = "union",
                    union_members = {
                        "automatic",
                        "true",
                        "false"
                    }
                },
                emissions_per_second = "double",
                shooting_cursor_size = "float", -- TODO: This seems autogenerated from the collision box as default, but it's not documented how
                created_smoke = "create_trivial_smoke_effect_item",
                working_sound = "working_sound",
                created_effect = "trigger",
                build_sound = "sound",
                mined_sound = "sound",
                mining_sound = "sound",
                rotated_sound = "sound",
                vehicle_impact_sound = "sound",
                open_sound = "sound",
                close_sound = "sound",
                radius_visualisation_specification = "radius_visualisation_specification",
                build_base_evolution_requirement = "double",
                alert_icon_shift = "vector",
                alert_icon_scale = "float",
                fast_replaceable_group = "string",
                next_upgrade = "entity_id",
                protected_from_tile_building = "bool",
                placeable_by = {
                    modifier = "array",
                    possibly_just_value = true,
                    format = "item_to_place"
                },
                remains_when_mined = {
                    modifier = "array",
                    possibly_just_value = true,
                    format = "entity_id"
                },
                additional_pastable_entities = {
                    modifier = "array",
                    format = "entity_id"
                },
                tile_width = "uint32",
                autoplace = "autoplace_specification",
                map_color = "color",
                friendly_map_color = "color",
                enemy_map_color = "color",
                water_reflection = "water_reflection_definition" -- TODO: This can be seet inside graphics_set, so manage that
            },
            defaults = {
                icon_mipmaps = 0,
                collision_box = {{0, 0}, {0, 0}},
                collision_mask = {"item-layer", "object-layer", "player-layer", "water-tile"},
                selection_box = {{0, 0}, {0, 0}},
                hit_visualization_box = {{0, 0}, {0, 0}},
                flags = {},
                allow_copy_paste = true,
                selectable_in_game = true,
                selection_priority = 50,
                build_grid_size = 1,
                remove_decoratives = "automatic",
                emissions_per_second = 0,
                shooting_cursor_size = 0,
                build_base_evolution_requirement = 0,
                alert_icon_shift = {x = 0, y = 0},
                fast_replaceable_group = "",
                protected_from_tile_building = true,
                placeable_by = {},
                remains_when_mined = {},
                additional_pastable_entities = {}
            },
            allow_nil = { -- icons/icon/icon_size/icon_mipmaps is a bit of a complicated situation
                icons = true,
                icon = true,
                icon_size = true,
                map_generator_bounding_box = true, -- TODO: map_generator_bounding_box should be defaulted to collision_box
                drawing_box = true, -- TODO: Actually default to value of selection_box
                sticker_box = true, -- TODO: Actually default to collision_box
                trigger_target_mask = true, -- TODO: Defaults to UtilityConstants::default_trigger_target_mask_by_type
                minable = true,
                subgroup = true,
                created_smoke = true, -- TODO: Default to the "smoke-building" smoke whatever that is
                working_sound = true,
                created_effect = true,
                build_sound = true,
                mined_sound = true,
                mining_sound = true,
                rotated_sound = true,
                vehicle_impact_sound = true,
                open_sound = true,
                close_sound = true,
                radius_visualisation_specification = true,
                alert_icon_scale = true, -- I think this can just be defaulted to 1
                next_upgrade = true,
                tile_width = true, -- TODO: Actually calculated from the collision box width rounded up
                tile_height = true, -- TODO: See previous line
                autoplace = true,
                map_color = true,
                friendly_map_color = true,
                enemy_map_color = true,
                water_reflection = true,
                order = true -- This is technically an override, but it's overriden to be nil by default so we have to include it here
            },
            inherits = "base"
        },
        ["entity-with-health"] = {
            properties = {
                max_health = "float",
                healing_per_tick = "float",
                repair_speed_modifier = "float",
                dying_explosion = {
                    modifier = "array",
                    possibly_just_value = true,
                    format = "explosion_definition"
                },
                dying_trigger_effect = "trigge_effect",
                damaged_trigger_effect = "trigger_effect",
                loot = {
                    modifier = "array",
                    format = "loot-item"
                },
                resistances = {
                    modifier = "array",
                    format = "resistance"
                },
                attack_reaction = {
                    modifier = "array",
                    possibly_just_value = true,
                    format = "attack_reaction_item"
                },
                repair_sound = "sound",
                alert_when_damaged = "bool",
                hide_resistances = "bool",
                create_ghost_on_death = "bool",
                random_corpse_variation = "bool",
                integration_patch_render_layer = "render_layer",
                corpse = {
                    modifier = "array",
                    possibly_just_value = true,
                    format = "entity_id"
                },
                integration_patch = "sprite_4_way"
            },
            defaults = {
                max_health = 10,
                healing_per_tick = 0,
                repair_speed_modifier = 1,
                dying_explosion = {},
                loot = {},
                resistances = {},
                attack_reaction = {},
                alert_when_damaged = true,
                hide_resistances = true,
                create_ghost_on_death = true,
                random_corpse_on_death = false,
                integration_patch_render_layer = "lower-object",
                corpse = {}
            },
            allow_nil = {
                dying_trigger_effect = true,
                damaged_trigger_effect = true,
                repair_sound = true,
                integration_patch = true
            },
            inherits = "entity"
        },
        ["entity-with-owner"] = {
            properties = {
                is_military_target = "bool",
                allow_run_time_change_of_is_military_target = "bool"
            },
            defaults = {
                is_military_target = false,
                allow_run_time_change_of_is_military_target = false
            },
            inherits = "entity-with-health"
        },
        ["equipment-category"] = {
            -- No new properties
            inherits = "base"
        },
        ["equipment-grid"] = {
            properties = {
                equipment_categories = {
                    modifier = "array",
                    format = "equipment_category_id"
                },
                width = "uint32",
                height = "uint32",
                locked = "bool"
            },
            defaults = {
                locked = false
            },
            inherits = "base"
        },
        ["equipment"] = {
            properties = {
                sprite = "sprite",
                shape = "equipment_shape",
                categories = {
                    modifier = "array",
                    format = "equipment_category_id"
                },
                energy_source = "electric_energy_source",
                take_result = "item_id",
                background_color = "color",
                background_border_color = "color",
                grabbed_background_color = "color"
            },
            allow_nil = {
                take_result = true, -- TODO: Fill in with name of prototype as default
                background_color = true, -- TODO: Make a default color
                background_border_color = true,
                grabbed_background_color = true
            },
            inherits = "base"
        },
        ["explosion"] = {
            properties = {
                animations = "animation_variations",
                sound = "sound",
                smoke = "trivial_smoke_id",
                height = "float",
                smoke_slow_down_factor = "float",
                smoke_count = "uint16",
                rotate = "bool",
                beam = "bool",
                correct_rotation = "bool",
                scale_animation_speed = "bool",
                fade_in_duration = "uint8",
                fade_out_duration = "uint8",
                render_layer = "render_layer",
                scale_in_duration = "uint8",
                scale_out_duration = "uint8",
                scale_end = "float",
                scale_increment_per_tick = "float",
                light_intensity_factor_initial = "float",
                light_intensity_factor_final = "float",
                light_size_factor_initial = "float",
                light_size_factor_final = "float",
                light = "light_definition",
                light_intensity_peak_start_progress = "float",
                light_intensity_peak_end_progress = "float",
                light_size_peak_start_progress = "float",
                light_size_peak_end_progress = "float",
                scale_initial = "float",
                scale_initial_deviation = "float",
                scale = "float",
                scale_deviation = "float"
            },
            defaults = {
                height = 1,
                smoke_slow_down_factor = 0,
                smoke_count = 0,
                rotate = false,
                beam = false,
                correct_rotation = false,
                scale_animation_speed = false,
                fade_in_duration = 0,
                fade_out_duration = 0,
                render_layer = "explosion",
                scale_in_duration = 0,
                scale_out_duration = 0,
                scale_end = 1,
                scale_increment_per_tick = 0,
                light_intensity_factor_initial = 0,
                light_intensity_factor_final = 0,
                light_size_factor_initial = 0.05,
                light_size_factor_final = 0.1,
                light_size_peak_start_progress = 0,
                light_intensity_peak_end_progress = 0.9,
                light_size_peak_start_progress = 0.1,
                light_size_peak_end_progress = 0.5,
                scale_initial = 1,
                scale_initial_deviation = 0,
                scale = 1,
                scale_deviation = 0,
                collision_mask = {} -- Override
            },
            allow_nil = {
                sound = true,
                smoke = true,
                light = true
            },
            inherits = "entity"
        },
        ["finish-the-game-achievement"] = {
            properties = {
                until_second = "uint32"
            },
            defaults = {
                until_second = 0
            },
            inherits = "achievement"
        },
        ["fire"] = {
            properties = {
                damage_per_tick = "damage",
                spread_delay = "uint32",
                spread_delay_deviation = "uint32",
                render_layer = "render_layer",
                initial_render_layer = "render_layer",
                secondary_render_layer = "render_layer",
                small_tree_fire_pictures = "animation_variations",
                pictures = "animation_variations",
                smoke_source_pictures = "animation_variations",
                secondary_pictures = "animation_variations",
                burnt_patch_pictures = "sprite_variations",
                secondary_picture_fade_out_start = "uint32",
                secondary_picture_fade_out_duration = "uint32",
                spawn_entity = "entity_id",
                smoke = {
                    modifier = "array",
                    format = "smoke_source"
                },
                maximum_spread_count = "uint16",
                initial_flame_count = "uint8",
                uses_alternative_behavior = "bool",
                limit_overlapping_particles = "bool",
                tree_dying_factor = "float",
                fade_in_duration = "uint32",
                fade_out_duration = "uint32",
                initial_lifetime = "uint32",
                damage_multiplier_decrease_per_tick = "float",
                damage_multiplier_increase_per_added_fuel = "float",
                maximum_damage_multiplier = "float",
                lifetime_increase_by = "uint32",
                lifetime_increase_cooldown = "uint32",
                maximum_lifetime = "uint32",
                add_fuel_cooldown = "uint32",
                delay_between_initial_flames = "uint32",
                smoke_fade_in_duration = "uint32",
                smoke_fade_out_duration = "uint32",
                on_fuel_added_action = "trigger",
                on_damage_tick_effect = "trigger",
                light = "light",
                particle_alpha_blend_duration = "uint16",
                burnt_patch_lifetime = "uint32",
                burnt_patch_alpha_default = "float",
                particle_alpha = "float",
                particle_alpha_deviation = "float",
                flame_alpha = "float",
                flame_alpha_deviation = "float",
                burnt_patch_alpha_variations = {
                    modifier = "array",
                    format = "tile_and_alpha"
                }
            },
            defaults = {
                render_layer = "object",
                initial_render_layer = "object",
                secondary_render_layer = "object",
                secondary_picture_fade_out_start = 0,
                secondary_picture_fade_out_duration = 30,
                smoke = {},
                maximum_spread_count = 200,
                initial_flame_count = 0,
                uses_alternative_behavior = false,
                limit_overlapping_particles = false,
                tree_dying_factor = 0,
                fade_in_duration = 30,
                fade_out_duration = 30,
                initial_lifetime = 300,
                damage_multiplier_decrease_per_tick = 0,
                damage_multiplier_increase_per_added_fuel = 0,
                maximum_damage_multiplier = 1,
                lifetime_increase_by = 20,
                lifetime_increase_cooldown = 10,
                maximum_lifetime = math.pow(2,32)-1, -- Max UINT_32,
                add_fuel_cooldown = 10,
                delay_between_initial_flames = 10,
                smoke_fade_in_duration = 30,
                smoke_fade_out_duration = 30,
                particle_alpha_blend_duration = 0,
                burnt_patch_lifetime = 1800,
                burnt_patch_alpha_default = 1,
                particle_alpha = 1,
                particle_alpha_deviation = 0,
                flame_alpha = 1,
                flame_alpha_deviation = 0,
                collision_mask = {}
            },
            allow_nil = {
                small_tree_fire_pictures = true,
                pictures = true,
                smoke_source_pictures = true,
                secondary_pictures = true,
                burnt_patch_pictures = true,
                spawn_entity = true,
                on_fuel_added_action = true,
                on_damage_tick_effect = true,
                light = true,
                burnt_patch_alpha_variations = true -- TODO: Check if this could be empty array
            },
            inherits = "entity"
        },
        ["fish"] = {
            properties = {
                pictures = "sprite_variations"
            },
            inherits = "entity-with-health"
        },
        ["flame-thrower-explosion"] = {
            properties = {
                damage = "damage",
                slow_down_factor = "double"
            },
            inherits = "explosion"
        },
        ["fluid"] = {
            properties = {
                icons = {
                    modifier = array,
                    format = "icon_data"
                },
                icon = "file_name", -- TODO: format like prototype with icons
                icon_size = "sprite_size_type",
                icon_mipmaps = "icon_mip_map_type",
                default_temperature = "double",
                base_color = "color",
                flow_color = "color",
                max_temperature = "double",
                heat_capacity = "energy",
                fuel_value = "energy",
                emissions_multiplier = "double",
                subgroup = "item_sub_group_id",
                gas_temperature = "double",
                hidden = "bool",
                auto_barrel = "bool"
            },
            defaults = {
                icon_mipmaps = 0,
                heat_capacity = "1KJ",
                fule_value = "0J",
                emissions_multiplier = 1,
                subgroup = "fluid",
                hidden = false,
                auto_barrel = true
            },
            allow_nil = {
                icons = true,
                icon = true,
                icon_size = true,
                max_temperature = true, -- TODO: Default to default_temperature
                gas_temperature = true -- TODO: Set to max value of double
            },
            inherits = "base"
        },
        ["stream"] = {
            properties = {
                particle_spawn_interval = "uint16",
                particle_horizontal_speed = "float",
                particle_horizontal_speed_deviation = "float",
                particle_vertical_acceleration = "float",
                initial_action = "trigger",
                action = "trigger",
                special_neutral_target_damage = "damage",
                width = "float",
                particle_buffer_size = "uint32",
                particle_spawn_timeout = "uint16",
                particle_start_alpha = "float",
                particle_end_alpha = "float",
                particle_start_scale = "float",
                particle_alpha_per_part = "float",
                particle_scale_per_part = "float",
                particle_fade_out_threshold = "uint16",
                particle_vertical_acceleration = "float",
                particle_loop_exit_threshold = "float",
                particle_loop_frame_count = "uint16",
                spine_animation = "animation",
                particle = "animation",
                shadow = "animation",
                smoke_sources = {
                    modifier = "array",
                    format = "smoke_source"
                },
                progress_to_create_smoke = "float",
                stream_light = "light_definition",
                ground_light = "light_definition",
                target_position_deviation = "double",
                oriented_particle = "bool",
                shadow_scale_enabled = "bool"
            },
            defaults = {
                width = 0.5,
                particle_buffer_size = 20,
                particle_start_alpha = 1,
                particle_end_alpha = 1,
                particle_start_scale = 1,
                particle_alpha_per_part = 1,
                particle_scale_per_part = 1,
                particle_fade_out_threshold = 1,
                particle_loop_exit_threshold = 0,
                particle_loop_frame_count = 1,
                particle_fade_out_threshold = 65535,
                smoke_sources = {},
                progress_to_create_smoke = 0.5,
                target_position_deviation = 0,
                oriented_particle = false,
                shadow_scale_enabled = false,
                collision_mask = {} -- Override
            },
            allow_nil = {
                initial_action = true,
                action = true,
                special_neutral_target_damage = true,
                particle_spawn_timeout = true, -- TODO: Set to 4 * particle_spawn_interval
                spine_animation = true,
                particle = true,
                shadow = true,
                stream_light = true,
                ground_light = true
            },
            inherits = "entity"
        },
        ["fluid-turret"] = {
            properties = {
                fluid_buffer_size = "float",
                fluid_buffer_input_flow = "float",
                activation_buffer_ratio = "float",
                fluid_box = "fluid_box",
                muzzle_light = "light_definition",
                enough_fuel_indicator_light = "light_definition",
                not_enough_fuel_indicator_light = "light_definition",
                muzzle_animation = "animation",
                folded_muzzle_animation_shift = "animated_vector",
                preparing_muzzle_animation_shift = "animated_vector",
                prepared_muzzle_animation_shift = "animated_vector",
                starting_attack_muzzle_animation_shift = "animated_vector",
                attacking_muzzle_animation_shift = "animated_vector",
                ending_attack_muzzle_animation_shift = "animated_vector",
                folding_muzzle_animation_shift = "animated_vector",
                enough_fuel_indicator_picture = "sprite_4_way",
                not_enough_fuel_indicator_picture = "sprite_4_way",
                out_of_ammo_alert_icon = "sprite"
            },
            defaults = {
                turret_base_has_direction = true
            },
            allow_nil = {
                muzzle_light = true,
                enough_fuel_indicator_light = true,
                not_enough_fuel_indicator_light = true,
                muzzle_animation = true,
                folded_muzzle_animation_shift = true,
                preparing_muzzle_animation_shift = true,
                prepared_muzzle_animation_shift = true,
                starting_attack_muzzle_animation_shift = true,
                attacking_muzzle_animation_shift = true,
                ending_attack_muzzle_animation_shift = true,
                folding_muzzle_animation_shift = true,
                enough_fuel_indicator_picture = true,
                not_enough_fuel_indicator_picture = true,
                out_of_ammo_alert_icon = true
            },
            inherits = "turret"
        },
        ["fluid-wagon"] = {
            properties = {
                capacity = "double",
                tank_count = "uint8"
            },
            defaults = {
                tank_count = 3
            },
            inherits = "rolling-stock"
        },
        ["flying-robot"] = {
            properties = {
                speed = "double",
                max_speed = "double",
                max_energy = "energy",
                energy_per_move = "energy",
                energy_per_tick = "energy",
                min_to_charge = "float",
                max_to_charge = "float",
                speed_multiplier_when_out_of_energy = "float"
            },
            defaults = {
                max_energy = 0,
                energy_per_move = 0,
                energy_per_tick = 0,
                min_to_charge = 0.2,
                max_to_charge = 0.95,
                speed_multiplier_when_out_of_energy = 0,
                is_military_target = true, -- Override
                collision_mask = {} -- Override
            },
            allow_nil = {
                max_speed = true -- TODO: Is actually max double
            },
            inherits = "entity-with-owner"
        },
        ["flying-text"] = {
            properties = {
                speed = "float",
                time_to_live = "uint32",
                text_alignment = {
                    modifier = "union",
                    union_members = {
                        "left",
                        "center",
                        "right"
                    }
                }
            },
            defaults = {
                text_alignment = "left",
                collision_mask = {} -- Override
            },
            inherits = "entity"
        },
        ["font"] = {
            properties = {
                type = {
                    modifier = "fixed_value",
                    value = "font"
                },
                name = "string",
                size = "int32",
                from = "string",
                spacing = "float",
                border = "bool",
                filtered = "bool",
                border_color = "color"
            },
            defaults = {
                spacing = 0,
                border = false,
                filtered = false
            },
            allow_nil = {
                border_color = true
            }
        },
        ["fuel-category"] = { -- No new properties
            inherits = "base"
        },
        ["furnace"] = {
            properties = {
                result_inventory_size = "item_stack_index",
                source_inventory_size = "item_stack_index",
                cant_insert_at_source_message_key = "string"
            },
            defaults = {
                cant_insert_at_source_message_key = "inventory-restriction.cant-be-smelted",
                entity_info_icon_shift = {0, -0.1} -- Override
            },
            inherits = "crafting-machine"
        },
        ["gate"] = {
            properties = {
                vertical_animation = "animation",
                horizontal_animation = "animation",
                vertical_rail_animation_left = "animation",
                vertical_rail_animation_right = "animation",
                horizontal_rail_animation_left = "animation",
                horization_rail_animation_right = "animation",
                vertical_rail_base = "animation",
                horizontal_rail_base = "animation",
                wall_patch = "animation",
                opening_speed = "float",
                activation_distance = "double",
                timeout_to_close = "uint32",
                fadeout_interval = "uint32",
                opened_collision_mask = "collision_mask"
            },
            defaults = {
                fadeout_interval = 0,
                opened_collision_mask = {"object-layer", "item-layer", "floor-layer", "water-tile"},
                collision_mask = {"item-layer", "object-layer", "player-layer", "water-tile", "train-layer"} -- Override
            },
            inherits = "entity-with-owner"
        },
        ["generator-equipment"] = {
            properties = {
                power = "energy",
                burner = "burner_energy_source" -- TODO: Some way of specifying type?
            },
            allow_nil = {
                burner = true
            },
            inherits = "equipment"
        },
        ["generator"] = {
            properties = {
                energy_source = "electric_energy_source",
                fluid_box = "fluid_box",
                horizontal_animation = "animation",
                vertical_animation = "animation",
                effectivity = "double",
                fluid_usage_per_tick = "double",
                maximum_temperature = "double",
                smoke = {
                    modifier = "array",
                    format = "smoke_source"
                },
                burns_fluid = "bool",
                scale_fluid_usage = "bool",
                destroy_non_fuel_fluid = "bool",
                min_perceived_performance = "double",
                performance_to_sound_speedup = "double",
                max_power_output = "energy"
            },
            defaults = {
                effectivity = 1,
                smoke = {},
                burns_fluid = false,
                scale_fluid_usage = false,
                destroy_non_fuel_fluid = true,
                min_perceived_performance = 0.25,
                performance_to_sound_speedup = 0.5
            },
            allow_nil = {
                horizontal_animation = true,
                vertical_animation = true,
                max_power_output = true
            },
            inherits = "entity-with-owner"
        },
        ["god-controller"] = {
            properties = {
                type = {
                    modifier = "fixed_value",
                    value = "god-controller"
                },
                name = "string",
                inventory_size = "item_stack_index",
                movement_speed = "double",
                item_pickup_distance = "double",
                loot_pickup_distance = "double",
                mining_speed = "double",
                crafting_categories = {
                    modifier = "array",
                    format = "recipe-category-id"
                },
                mining_categories = {
                    modifier = "array",
                    format = "resource-category-id"
                }
            }
        },
        ["group-attack-achievement"] = {
            properties = {
                amount = "uint32"
            },
            defaults = {
                amount = "uint32"
            },
            inherits = "achievement"
        },
        ["gui-style"] = {
            properties = {
                default_tileset = "file_name",
                default_sprite_scale = "double",
                default_sprite_priority = "sprite-priority" -- Has custom properties as a string to StyleSpecification
            },
            defaults = {
                default_tileset = "",
                default_sprite_scale = 1,
                default_sprite_priority = "medium"
            },
            inherits = "base"
        },
        ["gun"] = {
            properties = {
                attack_parameters = "attack_parameters"
            },
            inherits = "item"
        },
        ["heat-interface"] = {
            properties = {
                heat_buffer = "heat_buffer",
                picture = "sprite",
                gui_mode = {
                    modifier = "union",
                    union_members = {
                        "all",
                        "none",
                        "admins"
                    }
                }
            },
            defaults = {
                gui_mode = "all"
            },
            allow_nil = {
                picture = true
            },
            inherits = "entity-with-owner"
        },
        ["heat-pipe"] = {
            properties = {
                connection_sprites = "connectable_entity_graphics",
                heat_glow_sprites = "connectable_entity_graphics",
                heat_buffer = "heat_buffer"
            },
            defaults = {
                collision_mask = {
                    "object-layer",
                    "floor-layer",
                    "water-tile"
                } -- Override
            },
            inherits = "entity-with-owner"
        },
        ["highlight-box"] = {
            -- No new properties
            defaults = {
                collision_mask = {} -- Override
            },
            inherits = "entity"
        },
        ["infinity-container"] = {
            properties = {
                erase_contents_when_mined = "bool",
                gui_mode = {
                    modifier = "union",
                    union_members = {
                        "all",
                        "none",
                        "admins"
                    }
                }
            },
            defaults = {
                gui_mode = "all",
                render_not_in_network_icon = false -- Override
            },
            allow_nil = {
                logistic_mode = true -- Override
            },
            inherits = "logistic-container"
        },
        ["infinity-pipe"] = {
            properties = {
                gui_mode = {
                    modifier = "union",
                    union_members = {
                        "all",
                        "none",
                        "admins"
                    }
                }
            },
            inherits = "pipe"
        },
        ["inserter"] = {
            properties = {
                extension_speed = "double",
                rotation_speed = "double",
                insert_position = "vector",
                pickup_position = "vector",
                platform_picture = "sprite_4_way",
                hand_base_picture = "sprite",
                hand_open_picture = "sprite",
                hand_closed_picture = "sprite",
                energy_source = "energy_source",
                energy_per_movement = "energy",
                energy_per_rotation = "energy",
                stack = "bool",
                allow_custom_vectors = "bool",
                allow_burner_leech = "bool",
                draw_held_item = "bool",
                use_easter_egg = "bool",
                filter_count = "uint8",
                hand_base_shadow = "sprite",
                hand_open_shadow = "sprite",
                hand_closed_hadow = "sprite",
                hand_size = "double",
                circuit_wire_max_distance = "double",
                draw_copper_wires = "bool",
                draw_circuit_wires = "bool",
                default_stack_control_input_signal = "signal_id_connector",
                draw_inserter_arrow = "bool",
                chases_belt_items = "bool",
                stack_size_bonus = "uint8",
                circuit_wire_connection_points = {
                    modifier = "array",
                    fixed_size = 4,
                    format = "wire_connection_point"
                },
                circuit_connector_sprites = {
                    modifier = "array",
                    fixed_size = 4,
                    format = "circuit_connector_sprites"
                }
            },
            defaults = {
                energy_per_movement = 0,
                energy_per_rotation = 0,
                stack = false,
                allow_custom_vectors = false,
                allow_burner_leech = false,
                draw_held_item = true,
                use_easter_egg = true,
                filter_count = 0,
                hand_size = 0.75,
                circuit_wire_max_distance = 0,
                draw_copper_wires = true,
                draw_circuit_wires = true,
                draw_inserter_arrow = true,
                chases_belt_items = true,
                stack_size_bonus = 0
            },
            allow_nil = {
                default_stack_control_input_signal = true,
                circuit_wire_connection_points = true,
                circuit_connector_sprites = true
            },
            inherits = "entity-with-owner"
        },
        ["item-entity"] = {
            -- No new properties
            defaults = {
                collision_mask = {"item-layer"}, -- Override
                collision_box = {{0, 0}, {0, 0}} -- Override
            },
            inherits = "entity"
        },
        ["item-group"] = { -- TODO: Give prototype with icons formatting
            properties = {
                icons = {
                    modifier = "array",
                    format = "icon_data"
                },
                icon = "file_name",
                icon_size = "sprite_size_type",
                icon_mipmaps = "icon_mip_map_type",
                order_in_recipe = "order"
            },
            allow_nil = {
                icons = true,
                icon = true,
                icon_size = true,
                icon_mipmaps = true,
                order_in_recipe = true -- TODO: Default is actuall order of this item group
            },
            inherits = "base"
        },
        ["item"] = {
            properties = { -- TODO: prototype with icons
                stack_size = "item_count_type",
                icons = {
                    modifier = "array",
                    format = "icon_data"
                },
                icon = "file_name",
                icon_size = "sprite_size_type",
                icon_mipmaps = "icon_mip_map_type",
                dark_background_icons = {
                    modifier = "array",
                    format = "icon_data"
                },
                dark_background_icon = "file_name",
                place_result = "entity_id",
                placed_as_equipment_result = "equipment_id",
                subgroup = "item_sub_group_id",
                fuel_category = "fuel_category_id",
                burnt_result = "item_id",
                place_as_tile = "place_as_tile",
                pictures = "sprite_variations",
                flags = "item_prototype_flags",
                default_request_amount = "item_count_type",
                wire_count = "item_count_type",
                fuel_value = "energy",
                fuel_acceleration_multiplier = "double",
                fuel_top_speed_multiplier = "double",
                fuel_emissions_multiplier = "double",
                fuel_glow_color = "color",
                open_sound = "sound",
                close_sound = "sound",
                rocket_launch_products = {
                    modifier = "array",
                    format = "item_product_prototype"
                },
                rocket_launch_product = "item_product_prototype" -- TODO: Refactor into rocket_launch_products
            },
            defaults = {
                icon_mipmaps = 0,
                place_result = "",
                placed_as_equipment = "",
                subgroup = "other",
                fuel_category = "",
                burnt_result = "",
                flags = {},
                wire_count = 0,
                fuel_value = "0J",
                fuel_acceleration_multiplier = 1,
                fuel_top_speed_multiplier = 1,
                fuel_emissions_multiplier = 1
            },
            allow_nil = {
                icons = true,
                icon = true,
                icon_size = true,
                dark_background_icons = true,
                dark_background_icon = true,
                place_as_tile = true,
                pictures = true,
                default_request_amount = true, -- TODO: Fill in with stack_size
                fuel_glow_color = true,
                open_sound = true,
                close_sound = true,
                rocket_launch_products = true,
                rocket_launch_product = true
            },
            inherits = "base"
        },
        ["item-request-proxy"] = {
            properties = {
                picture = "sprite",
                use_target_entity_alert_icon_shift = "bool"
            },
            defaults = {
                use_target_entity_alert_icon_shift = true,
                collision_mask = {} -- Override
            },
            inherits = "entity"
        },
        ["item-subgroup"] = {
            properties = {
                group = "item_group_id"
            },
            inherits = "base"
        },
        ["item-with-entity-data"] = {
            properties = {
                icon_tintable_masks = {
                    modifier = "array",
                    format = "icon_data"
                },
                icon_tintable_mask = "file_name",
                icon_tintables = {
                    modifier = "array",
                    format = "icon_data"
                },
                icon_tintable = "file_name" -- TODO: Put this and icon_tintable_mask into corresponding arrays
            },
            allow_nil = {
                icon_tintable_masks = true,
                icon_tintable_mask = true,
                icon_tintables = true,
                icon_tintable = true
            },
            inherits = "item"
        },
        ["item-with-inventory"] = {
            properties = {
                inventory_size = "item_stack_index",
                item_filter = {
                    modifier = "array",
                    format = "item_id"
                },
                item_group_filters = {
                    modifier = "array",
                    format = "item_group_id"
                },
                item_subgroup_filters = { -- TODO: Change other instances of sub_group to subgroup
                    modifier = "array",
                    format = "item_subgroup_id"
                },
                filter_mode = {
                    modifier = "union",
                    union_members = {
                        "blacklist",
                        "whitelist"
                    }
                },
                filter_message_key = "string",
                extends_inventory_by_default = "bool",
                insertion_priority_mode = {
                    modifier = "union",
                    union_members = {
                        "default",
                        "never",
                        "always",
                        "when-manually-filtered"
                    }
                }
            },
            defaults = {
                filter_mode = "whitelist",
                filter_message_key = "item-limitation.item-not-allowed-in-this-container-item",
                extends_inventory_by_default = false,
                insertion_priority_mode = "default",
                stack_size = 1 -- Override
            },
            allow_nil = {
                item_filters = true,
                item_group_filters = true,
                item_subgroup_filters = true
            },
            inherits = "item-with-label"
        },
        ["item-with-label"] = {
            properties = {
                default_label_color = "color",
                draw_label_for_cursor_render = "bool"
            },
            defaults = {
                draw_label_for_cursor_render = false
            },
            allow_nil = {
                default_label_color = true -- TODO: Is actually default item text color
            },
            inherits = "item"
        },
        ["item-with-tags"] = {
            -- No new properties
            inherits = "item-with-label"
        },
        ["kill-achievement"] = {
            properties = {
                to_kill = "entity_id",
                type_to_kill = "string",
                damage_type = "damage_type_id",
                amount = "uint32",
                in_vehicle = "bool",
                personally = "bool"
            },
            defaults = {
                amount = 1,
                in_vehicle = false,
                personally = false
            },
            allow_nil = {
                to_kill = true,
                type_to_kill = true,
                damage_type = true
            },
            inherits = "achievement"
        },
        ["lab"] = {
            properties = {
                energy_usage = "energy",
                energy_source = "energy_source",
                on_animation = "animation",
                off_animation = "animation",
                inputs = {
                    modifier = "array",
                    format = "item_id"
                },
                researching_speed = "double",
                allowed_effects = "effect_type_limitation", -- TODO: By default this allows all effects
                light = "light_definition",
                base_productivity = 0,
                entity_info_icon_shift = {0, 0},
                module_specification = "module_specification"
            },
            defaults = {
                researching_speed = 1,
                base_productivity = 0,
                entity_info_icon_shift = {0, 0}
            },
            allow_nil = {
                allowed_effects = true,
                light = true,
                module_specification = true
            },
            inherits = "entity-with-owner"
        },
        ["lamp"] = {
            properties = {
                picture_on = "sprite",
                picture_off = "sprite",
                energy_usage_per_tick = "energy",
                energy_source = "electric_or_void_energy_source", -- TODO: Deal with this case more elegantly
                light = "light_definition",
                light_when_colored = "light_definition",
                circuit_wire_connection_point = "wire_connection_point",
                circuit_wire_max_distance = "double",
                draw_copper_wires = "bool",
                draw_circuit_wires = "bool",
                circuit_connector_sprites = "circuit_connector_sprites",
                glow_size = "float",
                glow_color_intensity = "float",
                darkness_for_all_lamps_on = "float",
                darkness_for_all_lamps_off = "float",
                always_on = "bool",
                signal_to_color_mapping = {
                    modifier = "array",
                    format = "signal_color_mapping"
                },
                glow_render_mode = {
                    modifier = "union",
                    union_members = {
                        "additive",
                        "multiplicative"
                    }
                }
            },
            defaults = {
                circuit_wire_max_distance = 0,
                draw_copper_wires = true,
                draw_circuit_wires = true,
                glow_size = 0,
                glow_color_intensity = 0,
                darkness_for_all_lamps_on = 0.5,
                darkness_for_all_lamps_off = 0.3,
                always_on = false,
                glow_render_mode = "additive"
            },
            allow_nil = {
                light = true,
                light_when_colored = true,
                circuit_wire_connection_point = true,
                circuit_connector_sprites = true,
                signal_to_color_mapping = true
            },
            inherits = "entity-with-owner"
        },
        ["land-mine"] = {
            properties = {
                picture_safe = "sprite",
                picture_set = "sprite",
                trigger_radius = "double",
                picture_set_enemy = "sprite",
                timeout = "uint32",
                action = "trigger",
                ammo_category = "ammo_category_id",
                force_die_on_attack = "bool",
                trigger_force = "force_condition",
                trigger_collision_mask = "collision_mask"
            },
            defaults = {
                timeout = 120,
                force_die_on_attack = true,
                trigger_force = "enemy",
                trigger_collision_mask = {
                    "item-layer",
                    "object-layer",
                    "player-layer",
                    "water-layer"
                },
                is_military_target = true, -- Override
                collision_mask = { -- Override
                    "object-layer",
                    "water-layer",
                    "rail-layer"
                }
            },
            allow_nil = {
                picture_set_enemy = true,
                action = true,
                ammo_category = true, -- I'm suspicious that this is actually "" as default, but docs don't say that so it goes here for now
            },
            inherits = "entity-with-owner"
        },
        -- leaf-particle is deprecated so don't need it
        ["linked-belt"] = {
            properties = {
                structure = "linked_belt_structure",
                structure_render_layer = "render_layer",
                allow_clone_connection = "bool",
                allow_blueprint_connection = "bool",
                allow_side_loading = "bool"
            },
            defaults = {
                structure_render_layer = "object",
                allow_clone_connection = true,
                allow_blueprint_connection = true,
                allow_side_loading = false,
                collision_mask = { -- Override
                    "object-layer",
                    "item-layer",
                    "transport-belt-layer",
                    "water-tile"
                }
            },
            inherits = "transport-belt-connectable"
        },
        ["linked-container"] = {
            properties = {
                inventory_size = "item_stack_index",
                picture = "sprite",
                inventory_type = {
                    modifier = "union",
                    union_members = {
                        "with_bar",
                        "with_filters_and_bar"
                    }
                },
                gui_mode = {
                    modifier = "union",
                    union_members = {
                        "all",
                        "none",
                        "admins"
                    }
                },
                scale_info_icons = "bool",
                circuit_wire_connection_point = "wire_connection_point",
                circuit_wire_max_distance = "double",
                draw_copper_wires = "bool",
                draw_circuit_wires = "bool",
                circuit_connector_sprites = "circuit_connector_sprites"
            },
            defaults = {
                inventory_type = "with_bar",
                gui_mode = "all",
                scale_info_icons = false,
                circuit_wire_max_distance = 0,
                draw_copper_wires = true,
                draw_circuit_wires = true
            },
            allow_nil = {
                picture = true,
                circuit_wire_connection_point = true,
                circuit_connector_sprites = true
            },
            inherits = "entity-with-owner"
        },
        ["loader-1x1"] = {
            -- No new properties
            inherits = "loader"
        },
        ["loader-1x2"] = {
            -- No new properties
            inherits = "loader"
        },
        ["loader"] = {
            properties = {
                structure = "loader_structure",
                filter_count = "uint8",
                structure_render_layer = "render_layer",
                container_distance = "double",
                allow_rail_interaction = "bool",
                allow_container_interaction = "bool",
                belt_length = "double",
                energy_source = "energy_source", -- Listed as one of the four energy sources separately; not sure why
                energy_per_item = "energy"
            },
            defaults = {
                structure_render_layer = "object",
                container_distance = 1.5,
                allow_rail_interation = true,
                allow_container_interaction = true,
                belt_length = 0.5,
                energy_per_item = 0,
                collision_mask = { -- Override
                    "object-layer",
                    "item-layer",
                    "transport-belt-layer",
                    "water-tile"
                }
            },
            allow_nil = {
                energy_source = true -- TODO: Maybe default to void energy source?
            },
            inherits = "transport_belt_connectable"
        },
        ["locomotive"] = {
            properties = {
                max_power = "energy",
                reversing_power_modifier = "double",
                energy_source = "burner_or_void_energy_source",
                burner = "burner_energy_source", -- TODO: Must have only energy_source OR burner, check for this when formatting
                front_light = "light_definition",
                front_light_pictures = "rotated_sprite",
                darkness_to_render_light_animation = "float",
                max_snap_to_train_stop_distance = "float"
            },
            defaults = {
                darkness_to_render_light_animation = 0.3,
                max_snap_to_train_stop_distance = 3
            },
            allow_nil = {
                energy_source = true,
                burner = true,
                front_light = true,
                front_light_pictures = true
            },
            inherits = "rolling-stock"
        },
        ["logistic-container"] = {
            properties = {
                logistic_mode = {
                    modifier = "union",
                    union_members = {
                        "active-provider",
                        "passive-provider",
                        "requester",
                        "storage",
                        "buffer"
                    },
                },
                render_not_in_network_icon = "bool",
                opened_duration = "uint8",
                animation = "animation",
                landing_location_offset = "vector",
                use_exact_mode = "bool",
                animation_sound = "sound"
            },
            defaults = {
                render_not_in_network_icon = true,
                opened_duration = 0,
                landing_location_offset = {0, 0},
                use_exact_mode = false
            },
            allow_nil = {
                max_logistic_slots = true, -- Does not list default, but it's just a uint16
                animation = true,
                animation_sound = true,
                picture = true -- Override
            },
            implements = "container"
        },
        ["logistic-robot"] = {
            properties = {
                idle_with_cargo = "rotated_animation",
                in_motion_with_cargo = "rotated_animation",
                shadow_idle_with_cargo = "rotated_animation",
                shadow_in_motion_with_cargo = "rotated_animation"
            },
            defaults = {
                collision_box = {{0, 0}, {0, 0}} -- Override
            },
            allow_nil = {
                idle_with_cargo = true,
                in_motion_with_cargo = true,
                shadow_idle_with_cargo = true,
                shadow_in_motion_with_cargo = true
            },
            implements = "robot-with-logistic-interface"
        },
        ["map-gen-presets"] = {
            properties = {
                type = {
                    modifier = "fixed_value",
                    value = "map-gen-presets"
                },
                name = "string"
                -- TODO: Custom string to map-gen-preset properties
            }
        },
        ["map-settings"] = {
            properties = {
                type = {
                    modifier = "fixed_value",
                    value = "map-settings"
                },
                name = "string",
                pollution = "pollution_settings",
                steering = "steering_settings",
                enemy_evolution = "enemy_evolution_settings",
                enemy_expansion = "enemy_expansion_settings",
                unit_group = "unit_group_settings",
                path_finder = "path_finder_settings",
                max_failed_behavior_count = "uint32",
                difficulty_settings = "difficulty_settings"
            }
        },
        ["market"] = {
            properties = {
                picture = "sprite",
                allow_access_to_all_forces = "bool"
            },
            defaults = {
                allow_access_to_all_forces = true
            },
            inherits = "entity-with-owner"
        },
        ["mining-drill"] = {
            properties = {
                vector_to_place_result = "vector",
                resource_searching_radius = "double",
                energy_usage = "energy", -- TODO: rename properties that use power to power
                mining_speed = "double",
                energy_source = "energy_source",
                resource_categories = {
                    modifier = "array",
                    format = "resource_category_id"
                },
                output_fluid_box = "fluid_box",
                input_fluid_box = "fluid_box",
                animations = "animation_4_way",
                graphics_set = "mining_drill_graphics_set",
                wet_mining_graphics_set = "mining_drill_graphics_set",
                base_picture = "sprite_4_way",
                allowed_effects = "effect_type_limitation",
                radius_visualisation_picture = "sprite",
                circuit_wire_max_distance = "double",
                draw_copper_wires = "bool",
                draw_circuit_wires = "bool",
                base_render_layer = "render_layer",
                base_productivity = "float",
                monitor_visualization_tint = "color",
                circuit_wire_connection_points = {
                    modifier = "array",
                    fixed_size = 4,
                    format = "wire_connection_point"
                },
                circuit_connector_sprites = {
                    modifier = "array",
                    fixed_size = 4,
                    format = "circuit_connector_sprites"
                },
                module_specification = "module_specification"
            },
            defaults = {
                circuit_wire_max_distance = 0,
                draw_copper_wires = true,
                draw_circuit_wires = true,
                base_render_layer = "lower-object",
                base_productivity = 0,
            },
            allow_nil = {
                output_fluid_box = true,
                input_fluid_box = true,
                animations = true,
                graphics_set = true,
                wet_mining_graphics_set = true,
                base_picture = true,
                allowed_effects = true, -- TODO: This by default allows all effects
                radius_visualisation_picture = true,
                monitor_visualization_tint = true,
                circuit_wire_connection_points = true,
                circuit_connector_sprites = true,
                module_specification = true
            },
            inherits = "entity-with-owner"
        },
        -- mining-tool is deprecated, so skip
        ["module-category"] = {
            -- No new properties
            inherits = "base"
        },
        ["module"] = {
            properties = {
                category = "module_category_id",
                tier = "uint32",
                effect = "effect",
                requires_beacon_alt_mode = "bool",
                limitation = {
                    modifier = "array",
                    format = "recipe_id"
                },
                limitation_blacklist = {
                    modifier = "array",
                    format = "recipe_id"
                },
                limitation_message_key = "string",
                art_style = "string",
                beacon_tint = "beacon_visulation_tints"
            },
            defaults = {
                requires_beacon_alt_mode = true,
                art_style = "vanilla"
            },
            allow_nil = {
                limitation = true,
                limitation_blacklist = true,
                limitation_message_key = true,
                beacon_visulation_tints = true
            },
            inherits = "item"
        },
        ["mouse-cursor"] = {
            properties = {
                type = {
                    modifier = "fixed_value",
                    value = "mouse-cursor"
                },
                name = "string",
                system_cursor = {
                    modifier = "union",
                    union_members = {
                        "arrow",
                        "i-beam",
                        "crosshair",
                        "wait-arrow",
                        "size-all",
                        "no",
                        "hand"
                    }
                },
                filename = "file_name",
                hot_pixel_x = "int16",
                hot_pixel_y = "int16"
            },
            allow_nil = {
                system_cursor = true,
                filename = true,
                hot_pixel_x = true,
                hot_pixel_y = true
            }
        },
        ["movement-bonus-equipment"] = {
            properties = {
                energy_consumption = "power", -- TODO: Should be labeling with power from here on
                movement_bonus = "double"
            },
            inherits = "equipment"
        },
        ["noise-expression"] = {
            properties = {
                expression = "noise_expression",
                intended_property = "string"
            },
            allow_nil = {
                intended_property = true -- There's a lot of text to read for this, I'm not sure what it's for
            },
            inherits = "base"
        },
        ["night-vision-equipment"] = {
            properties = {
                energy_input = "power",
                color_lookup = "daytime_color_lookup_table",
                darkness_to_turn_on = "float",
                activate_sound = "sound",
                deactivate_sound = "sound"
            },
            defaults = {
                darkness_to_turn_on = 0.5
            },
            allow_nil = {
                activate_sound = true,
                deactivate_sound = true
            },
            inherits = "equipment"
        },
        ["noise-layer"] = {
            -- No new properties
            inherits = "base"
        },
        ["offshore-pump"] = {
            properties = {
                fluid_box = "fluid_box",
                pumping_speed = "float",
                fluid = "fluid_id",
                graphics_set = "offshore_pump_graphics_set",
                picture = "animation_4_way",
                min_perceived_performance = "float",
                fluid_box_tile_collision_test = "collision_mask",
                adjacent_tile_collision_test = "collision_mask",
                adjacent_tile_collision_mask = "collision_mask",
                center_collision_mask = "collision_mask",
                adjacent_tile_collision_box = "bounding_box",
                placeable_position_visualization = "sprite",
                remove_on_tile_collision = "bool",
                always_draw_fluid = "bool",
                check_bounding_box_collides_with_tiles = "bool",
                circuit_wire_max_distance = "double",
                draw_copper_wires = "bool",
                draw_circuit_wires = "bool",
                circuit_wire_connection_points = {
                    modifier = "array",
                    fixed_size = 4,
                    format = "wire_connection_points"
                },
                circuit_connector_sprites = {
                    modifier = "array",
                    fixed_size = 4,
                    format = "circuit_connector_sprites"
                },
            },
            defaults = {
                min_perceived_performance = 0.25,
                fluid_box_tile_collision_test = "ground-tile",
                adjacent_tile_collision_test = "water-tile",
                adjacent_tile_collision_box = {{-0.05, -0.8}, {0.05, -0.7}},
                remove_on_tile_collision = false,
                always_draw_fluid = true,
                circuit_wire_max_distance = 0,
                draw_copper_wires = true,
                draw_circuit_wires = true
            },
            allow_nil = {
                graphics_set = true,
                picture = true,
                adjacent_tile_collision_mask = true, -- Lists "none" as default, which I assume is nil
                center_collision_mask = true, -- Lists "none" as default, which I assume is nil
                placeable_position_visualization = true,
                check_bounding_box_collides_with_tiles = true, -- TODO: Some complicated rules if not set... look into those
                circuit_wire_connection_points = true,
                circuit_connector_sprites = true
            },
            inherits = "entity-with-owner"
        },
        ["optimized-particle"] = {
            properties = {
                pictures = "animation_variations",
                life_time = "uint16",
                shadows = "animation_variations",
                draw_shadow_when_on_ground = "bool",
                regular_trigger_effect = "trigger_effect",
                ended_in_water_trigger_effect = "trigger_effect",
                ended_on_ground_trigger_effect = "trigger_effect",
                render_layer = "render_layer",
                render_layer_when_on_ground = "render_layer",
                regular_trigger_effect_frequency = "uint32",
                movement_modifier_when_on_ground = "float",
                movement_modifier = "float",
                vertical_acceleration = "float",
                mining_particle_frame_speed = "float",
                fade_away_duration = "uint16"
            },
            defaults = {
                draw_shadow_when_on_ground = true,
                render_layer = "object",
                render_layer_when_on_ground = "lower-object",
                regular_trigger_effect_frequency = 0, 
                movement_modifier_when_on_ground = 0.8,
                movement_modifier = 1,
                vertical_acceleration = -0.004,
                mining_particle_frame_speed = 0
            },
            allow_nil = {
                shadows = true,
                regular_trigger_effect = true,
                ended_in_water_trigger_effect = true,
                ended_on_ground_trigger_effect = true,
                fade_away_duration = true -- TODO: Defaults to a formula based on life_time, implement this
            },
            implements = "base"
        },
        ["particle-source"] = {
            properties = {
                time_to_live = "float",
                time_before_start = "float",
                height = "float",
                vertical_speed = "float",
                horizontal_speed = "float",
                particle = "particle_id",
                smoke = {
                    modifier = "array",
                    format = "smoke_source"
                },
                time_to_live_deviation = "float",
                time_before_start_deviation = "float",
                height_deviation = "float",
                vertical_speed_deviation = "float",
                horizontal_speed_deviation = "float"
            },
            defaults = {
                time_to_live_deviation = 0,
                time_before_start_deviation = 0,
                height_deviation = 0,
                vertical_speed_deviation = 0,
                horizontal_speed_deviation = 0,
                collision_mask = {} -- Override
            },
            allow_nil = {
                particle = true,
                smoke = true
            },
            inherits = "entity"
        },
        ["pipe"] = {
            properties = {
                fluid_box = "fluid_box",
                horizontal_window_bounding_box = "bounding_box",
                vertical_window_bounding_box = "bounding_box",
                pictures = "pipe_pictures"
            },
            inherits = "entity-with-owner"
        },
        ["pipe-to-ground"] = {
            properties = {
                fluid_box = "fluid_box",
                pictures = "pipe_to_ground_pictures",
                draw_fluid_icon_override = "bool"
            },
            defaults = {
                draw_fluid_icon_override = false
            },
            inherits = "entity-with-owner"
        },
        ["player-damaged-achievement"] = {
            properties = {
                minimum_damage = "float",
                should_survive = "bool",
                type_of_dealer = "string"
            },
            defaults = {
                type_of_dealer = ""
            },
            inherits = "achievement"
        },
        ["player-port"] = {
            properties = {
                animation = "animation"
            },
            inherits = "entity-with-owner"
        },
        ["power-switch"] = {
            properties = {
                power_on_animation = "animation",
                overlay_start = "animation",
                overlay_loop = "animation",
                led_on = "sprite",
                led_off = "sprite",
                overlay_start_delay = "uint8",
                circuit_wire_connection_point = "wire_connection_point",
                left_wire_connection_point = "wire_connection_point",
                right_wire_connection_point = "wire_connection_point",
                wire_max_distance = "double",
                draw_copper_wires = "bool",
                draw_circuit_wires = "bool"
            },
            defaults = {
                wire_max_distance = 0,
                draw_copper_wires = true,
                draw_circuit_wires = true
            },
            inherits = "power-switch"
        },
        ["produce-achievement"] = {
            properties = {
                amount = "material_amount_type",
                limited_to_one_game = "bool",
                item_product = "item_id",
                fluid_product = "fluid_id"
            },
            allow_nil = {
                item_product = true,
                fluid_product = true
            },
            inherits = "achievement"
        },
        ["produce-per-hour-achievement"] = {
            properties = {
                amount = "material_amount_type",
                item_product = "item_id",
                fluid_product = "fluid_id"
            },
            allow_nil = {
                item_product = "item_id",
                fluid_product = "fluid_id"
            },
            inherits = "achievement"
        },
        ["programmable-speaker"] = {
            properties = {
                energy_source = "electric_or_void_energy_source",
                energy_usage_per_tick = "power",
                sprite = "sprite",
                maximum_polyphony = "uint32",
                instuments = {
                    modifier = "array",
                    format = "programmable_speaker_instrument"
                },
                audible_distance_modifier = "float",
                circuit_wire_connection_point = "wire_connection_point",
                circuit_wire_max_distance = "double",
                draw_copper_wires = "bool",
                draw_copper_wires = "bool",
                circuit_connector_sprites = "circuit_connector_sprites"
            },
            defaults = {
                audible_distance_modifier = 1,
                circuit_wire_max_distance = 0,
                draw_copper_wires = true,
                draw_circuit_wires = true
            },
            allow_nil = {
                circuit_wire_connection_point = true,
                circuit_connector_sprites = true
            },
            inherits = "entity-with-owner"
        },
        ["projectile"] = {
            properties = {
                acceleration = "double",
                animation = "animation",
                rotatable = "bool",
                enable_drawing_with_mask = "bool",
                direction_only = "bool",
                hit_at_collision_position = "bool",
                force_condition = "force_condition",
                piercing_damage = "float",
                max_speed = "double",
                turn_speed = "float",
                speed_modifier = "vector",
                height = "double",
                action = "trigger",
                final_action = "trigger",
                light = "light_definition",
                smoke = {
                    modifier = "array",
                    format = "smoke_source"
                },
                hit_collision_mask = "collision_mask",
                turning_speed_increases_exponentially_with_projectile_speed = "bool",
                shadow = "animation_variations"
            },
            defaults = {
                rotatable = true,
                enable_drawing_with_mask = true,
                direction_only = false,
                hit_at_collision_position = false,
                force_condition = "all",
                piercing_damage = 0,
                turn_speed = 1,
                speed_modifier = {1, 1},
                height = 1,
                hit_collision_mask = {
                    "player-layer",
                    "train-layer"
                },
                turning_speed_increases_exponentially_with_projectile_speed = false,
                collision_mask = {} -- Override
            },
            allow_nil = {
                animation = true,
                max_speed = true, -- TODO: Actually max double
                action = true,
                final_action = true,
                light = true,
                smoke = true
            },
            inherits = "entity"
        },
        ["base"] = {
            properties = {
                type = "string",
                name = "string",
                order = "order",
                localised_name = "localised_string",
                localised_description = "localised_string"
            },
            defaults = {
                order = ""
            },
            allow_nil = {
                localised_name = true,
                localised_description = true
            }
        },
        ["pump"] = {
            properties = {
                fluid_box = "fluid-box",
                energy_source = "energy_source",
                energy_usage = "power",
                pumping_speed = "double",
                animations = "animation_4_way",
                fluid_wagon_connector_speed = "double",
                fluid_wagon_connector_alignment_tolerance = "double",
                fluid_wagon_connector_frame_count = "uint8",
                fluid_animation = "animation_4_way",
                glass_pictures = "sprite_4_way",
                circuit_wire_max_distance = "double",
                draw_copper_wires = "bool",
                draw_circuit_wires = "bool",
                circuit_wire_connection_points = {
                    modifier = "array",
                    fixed_size = 4,
                    format = "wire_connection_point"
                },
                circuit_connector_sprites = {
                    modifier = "array",
                    fixed_size = 4,
                    format = "circuit_connector_sprites"
                },
                fluid_wagon_connector_graphics = "fluid_wagon_connector_graphics"
            },
            defaults = {
                fluid_wagon_connector_speed = 1 / 64,
                fluid_wagon_connector_alignment_tolerance = 1 /16,
                fluid_wagon_connector_frame_count = 1,
                circuit_wire_max_distance = 0,
                draw_copper_wires = true,
                draw_circuit_wires = true
            },
            allow_nil = {
                fluid_animation = true,
                glass_pictures = true,
                circuit_wire_connection_points = true,
                circuit_connector_sprites = true,
                fluid_wagon_connector_graphics = true
            },
            inherits = "entity-with-owner"
        },
        ["radar"] = {
            properties = {
                energy_usage = "power",
                energy_per_sector = "energy",
                energy_per_nearby_scan = "energy",
                energy_source = "energy_source",
                pictures = "rotated_sprite",
                max_distance_of_sector_revealed = "uint32",
                max_distance_of_nearby_sector_revealed = "uint32",
                radius_minimap_visualisation_color = "color",
                rotation_speed = "double"
            },
            defaults = {
                rotation_speed = 0.01,
                is_military_target = true -- Override
            },
            allow_nil = {
                radius_minimap_visualisation_color = true
            },
            inherits = "entity-with-owner"
        },
        ["rail-chain-signal"] = {
            properties = {
                selection_box_offsets = {
                    modifier = "array",
                    format = "vector"
                },
                blue_light = "light_definition",
                default_blue_output_signal = "signal_id_connector"
            },
            allow_nil = {
                blue_light = true,
                default_blue_output_signal = true
            },
            inherits = "rail-signal-base"
        },
        ["rail-planner"] = {
            properties = {
                straight_rail = "entity_id",
                curved_rail = "entity_id"
            },
            inherits = "item"
        },
        ["rail"] = {
            properties = {
                pictures = "rail_picture_set",
                walking_sound = "sound"
            },
            allow_nil = {
                walking_sound = true
            },
            inherits = "entity-with-owner"
        },
        ["rail-remnants"] = {
            properties = {
                bending_type = {
                    modifier = "union",
                    union_members = {
                        "straight",
                        "turn"
                    }
                },
                pictures = "rail_picture_set"
            },
            inherits = "corpse"
        },
        ["rail-signal-base"] = {
            properties = {
                animation = "rotated_animation",
                rail_piece = "animation",
                green_light = "light_definition",
                orange_light = "light_definition",
                red_light = "light_definition",
                default_red_output_signal = "signal_id_connector",
                defuault_orange_output_signal = "signal_id_connector",
                default_green_output_signal = "signal_id_connector",
                circuit_wire_max_distance = "double",
                draw_copper_wires = "bool",
                draw_circuit_wires = "bool",
                circuit_wire_connection_points = {
                    modifier = "array",
                    format = "wire_connection_point"
                },
                circuit_connector_sprites = {
                    modifier = "array",
                    format = "circuit_connector_sprites"
                }
            },
            defaults = {
                circuit_wire_max_distance = 0,
                draw_copper_wires = true,
                draw_circuit_wires = true,
                collision_mask = { -- Override
                    "floor-layer",
                    "rail-layer",
                    "item-layer"
                },
                collision_box = {{-0.2, -0.2}, {0.2, 0.2}} -- Override
            },
            allow_nil = {
                rail_piece = true,
                green_light = true,
                orange_light = true,
                red_light = true,
                default_red_output_signal = true,
                defuault_orange_output_signal = true,
                default_green_output_signal = true,
                circuit_wire_connection_points = true,
                circuit_connector_sprites = true
            },
            inherits = "entity-with-owner"
        },
        ["rail-signal"] = {
            -- No new properties
            inherits = "rail-signal-base"
        },
        ["reactor"] = {
            properties = {
                working_light_picture = "sprite",
                heat_buffer = "heat_buffer",
                energy_source = "energy_source",
                consumption = "power",
                connection_patches_connected = "sprite_variations",
                connection_patches_disconnected = "sprite_variations",
                heat_connection_patches_connected = "sprite_variations",
                heat_connection_patches_disconnected = "sprite_variations",
                lower_layer_picture = "sprite",
                heat_lower_layer_picture = "sprite",
                picture = "sprite",
                light = "light_definition",
                meltdown_action = "trigger",
                neighbour_bonus = "double",
                scale_energy_usage = "bool",
                use_fuel_glow_color = "bool",
                default_fuel_glow_color = "color"
            },
            defaults = {
                neighbour_bonus = 1,
                scale_energy_usage = false,
                use_fuel_glow_color = false,
                default_fuel_glow_color = {1, 1, 1, 1}
            },
            allow_nil = {
                connection_patches_connected = true,
                connection_patches_disconnected = true,
                heat_connection_patches_connected = true,
                heat_connection_patches_disconnected = true,
                lower_layer_picture = true,
                heat_lower_layer_picture = true,
                picture = true,
                light = true,
                meltdown_action = true
            },
            inherits = "entity-with-owner"
        },
        ["recipe-category"] = {
            -- No new properties
            inherits = "base"
        },
        ["recipe"] = {
            properties = {
                category = "recipe_category_id",
                subgroup = "item_subgroup_id",
                crafting_machine_tint = "crafting_machine_tint",
                icons = {
                    modifier = "array",
                    format = "icon_data"
                },
                icon = "file_name",
                icon_size = "sprite_size_type",
                icon_mipmaps = "icon_mipmap_type",
                normal = "recipe_data", -- TODO: Special formatting to remove expensive mode?
                expensive = "recipe_data",
                ingredients = {
                    modifier = "array",
                    format = "ingredient_prototype"
                },
                results = {
                    modifier = "array",
                    format = "product_prototype"
                },
                result = "item_id",
                result_count = "uint16",
                main_product = "string", -- TODO: Should this technically be fluid/item id?
                energy_required = "double",
                emissions_multiplier = "double",
                requester_paste_multiplier = "uint32",
                overload_multiplier = "uint32",
                allow_inserter_overload = "bool",
                enabled = "bool",
                hidden = "bool",
                hide_from_stats = "bool",
                hide_from_player_crafting = "bool",
                allow_decomposition = "bool",
                allow_as_intermediate = "bool",
                allow_intermediates = "bool",
                always_show_made_in = "bool",
                show_amount_in_title = "bool",
                always_show_products = "bool",
                unlock_results = "bool"
            },
            defaults = {
                category = "crafting",
                icon_mipmaps = 0,
                result_count = 1,
                energy_required = 0.5,
                emissions_multiplier = 1,
                requester_paste_multiplier = 30,
                overload_multiplier = 0,
                allow_inserter_overload = true,
                enabled = true,
                hidden = false,
                hide_from_stats = false,
                hide_from_player_crafting = false,
                allow_decomposition = true,
                allow_as_intermediate = true,
                allow_intermediates = true,
                always_show_made_in = false,
                show_amount_in_title = true,
                always_show_products = false,
                unlock_results = true
            },
            allow_nil = {
                subgroup = true, -- TODO: Complicated rules for subgroup defaults
                crafting_machine_tint = true,
                icons = true,
                icon = true,
                icon_size = true,
                normal = true,
                expensive = true,
                ingredients = true,
                results = true,
                result = true,
                main_product = true -- TODO: Complicated rules for how to fill in
            },
            inherits = "base"
        },
        ["repair-tool"] = {
            properties = {
                speed = "float",
                repair_result = "trigger" -- Does nothing
            },
            allow_nil = {
                repair_result = true
            },
            inherits = "tool"
        },
        ["research-achievement"] = {
            properties = {
                technology = "technology_id",
                research_all = "bool"
            },
            defaults = {
                research_all = false
            },
            allow_nil = {
                technology = true
            },
            inherits = "achievement"
        },
        ["resource-category"] = {
            -- No new properties
            inherits = "base"
        },
        ["resource"] = {
            properties = {
                stages = "animation_variations",
                stage_counts = {
                    modifier = "array",
                    format = "uint32"
                },
                infinite = "bool",
                highlight = "bool",
                randomize_visual_position = "bool",
                map_grid = "bool",
                minimum = "uint32",
                normal = "uint32",
                infinite_depletion_amount = "uint32",
                resource_patch_search_radius = "uint32",
                category = "resource_category_id",
                walking_sound = "sound",
                stages_effect = "animation_variations",
                effect_animation_period = "float",
                effect_animation_period_deviation = "float",
                effect_darkness_multiplier = "float",
                min_effect_alpha = "float",
                max_effect_alpha = "float",
                tree_removal_probability = "double",
                cliff_removal_probability = "double",
                tree_removal_max_distance = "double",
                mining_visualisation_tint = "color"
            },
            defaults = {
                infinite = false,
                randomize_visual_position = true,
                map_grid = true,
                minimum = 0,
                normal = 1,
                infinite_depletion_amount = 1,
                resource_patch_search_radius = 3,
                category = "basic-solid",
                effect_animation_period = 0,
                effect_animation_period_deviation = 0,
                effect_darkness_multiplier = 1,
                min_effect_alpha = 0,
                max_effect_alpha = 1,
                tree_removal_probability = 0,
                cliff_removal_probability = 1,
                tree_removal_max_distance = 0,
                collision_mask = {"resource-layer"} -- Override
            },
            allow_nil = {
                walking_sound = true,
                stages_effect = true,
                mining_visualisation_tint = true
            },
            inherits = "entity"
        },
        ["roboport-equipment"] = {
            properties = {
                recharging_animation = "animation",
                spawn_and_station_height = "float",
                charge_approach_distance = "float",
                construction_radius = "float",
                charging_energy = "power",
                spawn_and_station_shadow_height_offset = "float",
                draw_logistic_radius_visualization = "bool",
                draw_construction_radius_visualization = "bool",
                recharging_light = "light_definition",
                charging_station_count = "uint32",
                charging_distance = "float",
                charging_station_shift = "vector",
                charging_threshold_distance = "float",
                robot_vertical_acceleration = "float",
                stationing_offset = "vector",
                robot_limit = "item_count_type",
                robots_shrink_when_entering_and_exiting = "bool",
                charging_offsets = {
                    modifier = "array",
                    format = "vector"
                },
                spawn_minimum = "energy",
                burner = "buner_energy_source",
                power = "power"
            },
            defaults = {
                spawn_and_station_shadow_height_offset = 0,
                draw_logistic_radius_visualization = true,
                draw_construction_radius_visualization = true,
                charging_station_count = 0,
                charging_distance = 0,
                charging_threshold_distance = 1,
                robot_vertical_acceleration = 0.01,
                robots_shrink_when_entering_and_exiting = false
            },
            allow_nil = {
                recharging_light = true,
                charging_station_shift = true, -- I think since this is a shift it actually is "defaulted" to {0,0}
                stationing_offset = true,
                robot_limit = true, -- Actually defaulted to max uint
                charging_offsets = true,
                spawn_minimum = true, -- TODO: Actually default to 0.2*energy_source.buffer_capacity
                burner = true,
                power = true
            },
            inherits = "equipment"
        },
        ["roboport"] = {
            properties = {
                energy_source = "electric_or_void_energy_source",
                energy_usage = "power",
                recharge_minimum = "energy",
                robot_slots_count = "item_stack_index",
                material_slots_count = "item_stack_index",
                base = "sprite",
                base_patch = "sprite",
                base_animation = "animation",
                door_animation_up = "animation",
                door_animation_down = "animation",
                request_to_open_door_timeout = "uint32",
                recharging_animation = "animation",
                spawn_and_station_height = "float",
                charge_approach_distance = "float",
                logistics_radius = "float",
                construction_radius = "float",
                charging_energy = "power",
                open_door_trigger_effect = "trigger_effect",
                close_door_trigger_effect = "trigger_effect",
                default_available_logistic_output_signal = "signal_id_connector",
                default_total_logistic_output_signal = "signal_id_connector",
                default_available_construction_output_signal = "signal_id_connector",
                default_total_construction_output_signal = "signal_id_connector",
                circuit_wire_connection_point = "wire_connection_point",
                circuit_wire_max_distance = "double",
                draw_copper_wires = "bool",
                draw_circuit_wires = "bool",
                circuit_connector_sprites = "circuit_connector_sprites",
                spawn_and_station_shadow_height_offset = "float",
                draw_logistic_radius_visualization = "bool",
                draw_construction_radius_visualization = "bool",
                recharging_light = "light_definition",
                charging_station_count = "uint32",
                charging_distance = "float",
                charging_station_shift = "vector",
                charging_threshold_distance = "float", -- Unused
                robot_vertical_acceleration = "float",
                stationing_offset = "vector",
                robot_limit = "item_count_type", -- Unused
                robots_shrink_when_entering_and_exiting = "bool",
                charging_offsets = {
                    modifier = "array",
                    format = "vector"
                },
                logistics_connection_distance = "float"
            },
            defaults = {
                circuit_wire_max_distance = 0,
                draw_copper_wires = true,
                draw_circuit_wires = true,
                spawn_and_station_shadow_height_offset = 0,
                draw_logistic_radius_visualization = true,
                draw_construction_radius_visualization = true,
                charging_station_count = 0,
                charging_distance = 0,
                charging_threshold_distance = 1, -- Unused
                robot_vertical_acceleration = 0.01,
                robots_shrink_when_entering_and_exiting = false
            },
            allow_nil = {
                open_door_trigger_effect = true,
                close_door_trigger_effect = true,
                default_available_logistic_output_signal = true,
                default_total_logistic_output_signal = true,
                default_available_construction_output_signal = true,
                default_total_construction_output_signal = true,
                circuit_wire_connection_point = true,
                circuit_connector_sprites = true,
                recharging_light = true,
                charging_station_shift = true, -- Since this is a shift, we might be able to get away with setting it to {0, 0} as default
                stationing_offset = true,
                robot_limit = true, -- Actually max uint, but also unused
                charging_offsets = true,
                logistics_connection_distance = true -- TODO: Actually defaults to logistics_radius
            },
            inherits = "entity-with-owner"
        },
        ["robot-with-logistic-interface"] = {
            properties = {
                max_payload_size = "item_count_type",
                cargo_centered = "vector",
                idle = "rotated_animation",
                in_motion = "rotated_animation",
                shadow_idle = "rotated_animation",
                destroy_action = "trigger",
                draw_cargo = "bool"
            },
            defaults = {
                draw_cargo = true
            },
            allow_nil = {
                idle = true,
                in_motion = true,
                shadow_idle = true,
                shadow_in_motion = true,
                destroy_action = true
            },
            inherits = "flying-robot"
        },
        ["rocket-silo"] = {
            properties = {
                active_energy_usage = "power",
                lamp_energy_usage = "power",
                rocket_entity = "entity_id",
                arm_02_right_animation = "animation",
                arm_01_back_animation = "animation",
                arm_03_front_animation = "animation",
                shadow_sprite = "sprite",
                hole_sprite = "sprite",
                hole_light_sprite = "sprite",
                rocket_shadow_overlay_sprite = "sprite",
                rocket_glow_overlay_sprite = "sprite",
                door_back_sprite = "sprite",
                door_front_sprite = "sprite",
                base_day_sprite = "sprite",
                base_front_sprite = "sprite",
                red_lights_back_sprites = "sprite",
                red_lights_front_sprites = "sprite",
                hole_clipping_box = "bounding_box",
                door_back_open_offset = "vector",
                door_front_open_offset = "vector",
                silo_fade_out_start_distance = "double",
                silo_fade_out_end_distance = "double",
                times_to_blink = "uint8",
                light_blinking_speed = "double",
                door_opening_speed = "double",
                rocket_parts_required = "uint32",
                satellite_animation = "animation",
                satellite_shadow_animation = "aniimation",
                base_night_sprite = "sprite",
                base_light = "light_definition",
                base_engine_light = "light_definition",
                rocket_rising_delay = "uint8",
                launch_wait_time = "uint8",
                alarm_trigger = "trigger_effect",
                clamps_on_trigger = "trigger_effect",
                clamps_off_trigger = "trigger_effect",
                doors_trigger = "trigger_effect",
                raise_rocket_trigger = "trigger_effect",
                alarm_sound = "sound",
                clamps_on_sound = "sound",
                clamps_off_sound = "sound",
                doors_sound = "sound",
                raise_rocket_sound = "sound",
                flying_sound = "sound",
                rocket_result_inventory_size = "item_stack_index"
            },
            defaults = {
                rocket_rising_delay = 30,
                launch_wait_time = 120,
                rocket_result_inventory_size = 0
            },
            allow_nil = {
                satellite_animation = true,
                satellite_shadow_animation = true,
                base_night_sprite = true,
                base_light = true,
                base_engine_light = true,
                alarm_trigger = true,
                clamps_on_trigger = true,
                clamps_off_trigger = true,
                doors_trigger = true,
                raise_rocket_trigger = true,
                alarm_sound = true,
                clamps_on_sound = true,
                clamps_off_sound = true,
                doors_sound = true,
                raise_rocket_sound = true,
                flying_sound = true
            },
            inherits = "assembling-machine"
        },
        ["rocket-silo-rocket"] = {
            properties = {
                rocket_sprite = "sprite",
                rocket_shadow_sprite = "sprite",
                rocket_glare_overlay_sprite = "sprite",
                rocket_smoke_bottom1_animation = "animation",
                rocket_smoke_bottom2_animation = "animation",
                rocket_smoke_top1_animation = "animation",
                rocket_smoke_top2_animation = "animation",
                rocket_smoke_top3_animation = "animation",
                rocket_flame_animation = "animation",
                rocket_flame_left_animation = "animation",
                rocket_flame_right_animation = "animation",
                rocket_rise_offset = "vector",
                rocket_flame_left_rotation = "float",
                rocket_flame_right_rotation = "float",
                rocket_render_layer_switch_distance = "double",
                full_render_layer_switch_distance = "double",
                rocket_launch_offset = "vector",
                effects_fade_in_start_distance = "double",
                effects_fade_in_end_distance = "double",
                shadow_fade_out_start_ratio = "double",
                shadow_fade_out_end_ratio = "double",
                rocket_visible_distance_from_center = "float",
                rising_speed = "double",
                engine_starting_speed = "double",
                flying_speed = "double",
                flying_acceleration = "double",
                inventory_size = "item_stack_index",
                shadow_slave_entity = "entity_id",
                dying_explosion = "entity_id",
                glow_light = "light_definition",
                rocket_initial_offset = "vector",
                rocket_above_wires_slice_offset_from_center = "float",
                rocket_air_object_slice_offset_from_center = "float",
                flying_trigger = "trigger_effect"
            },
            defaults = {
                rocket_above_wires_slice_offset_from_center = -3,
                rocket_air_object_slice_offset_from_center = -5.5
            },
            allow_nil = {
                shadow_slave_entity = true,
                dying_explosion = true,
                glow_light = true,
                rocket_initial_offset = true, -- TODO: This is an offset, so maybe default is {0, 0}
                flying_trigger = "trigger_effect"
            },
            inherits = "entity"
        }
    }
}

-- Special formatting: Make car "burner" property into energy_source
-- There's also a special property in artillery I think?

reformat["equipment"] = function(prototype)
    reformat.type.sprite(prototype.sprite)

    reformat.type.equipment_shape(prototype.shape)

    reformat.type.electric_energy_source(prototype.energy_source)

    -- TODO: color properties

    reformat.prototype["base"](prototype)
end

function reformat.prototypes()
    -- The formatted data
    local fdat = table.deepcopy(data.raw)

    for _, class in pairs(fdat) do
        class.format = "class"

        for _, prototype in pairs(class) do
            prototype.format = "prototype"

            reformat.prototype[prototype.type](prototype)
        end
    end
end

return reformat