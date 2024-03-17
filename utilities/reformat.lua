local reformat = {}

-- TODO: double check vectors
-- TODO: Recheck for properties that could be strings or tables

--------------------------------------------------------------------------------
-- Table Types
--------------------------------------------------------------------------------

reformat.type = {}

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
        recipe.type.ingredients = recipe.normal.ingredients
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

reformat.prototype = {}

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

    for property, default in pairs(spec.defaults) do -- TODO: Merge overrides with defaults
        if prototype[property] == nil then
            prototoype[property] = default
        end
    end

    for property, format in pairs(spec.properties) do
        prototype[property] = reformat.type[format](prototype[property])
    end

    if spec.inherits then
        reformat.prototype[prototype.name](prototype)
    end
end

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
                selection_mode = "blueprint,
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
            }
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
                animation = "animation",

            }
        }
    }
}

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