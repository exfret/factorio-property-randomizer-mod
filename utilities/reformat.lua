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

function reformat.test.prototype(prototype)
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
                }
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