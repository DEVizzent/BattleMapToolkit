extends GutTest

const DMWindowScene := preload("res://scenes/ui/dm_window.tscn")
const TokenDataClass := preload("res://scripts/token/token_data.gd")
const TokenSpriteClass := preload("res://scripts/token/token_sprite.gd")

var _dm: Control


func before_each() -> void:
	_dm = DMWindowScene.instantiate()
	add_child_autofree(_dm)
	await get_tree().process_frame
	GameState.map_tokens.clear()
	GameState.current_map_index = -1
	_dm._clear_token_sprites()
	await get_tree().process_frame


func _make_token(td_name: String = "Goblin", cells: float = 1.0) -> Resource:
	var td := TokenDataClass.new()
	td.name = td_name
	td.size_cells = cells
	return td


func _spawn(td: Resource, pos: Vector2 = Vector2(100, 100)) -> Sprite2D:
	_dm._spawn_token_sprite(td, pos, _dm._get_cell_px())
	return _dm.token_layer.get_children().back() as Sprite2D


func test_select_token_shows_border() -> void:
	var td := _make_token()
	var sprite := _spawn(td)
	_dm._select_token(sprite)
	assert_true(sprite.selected)


func test_deselect_hides_border() -> void:
	var td := _make_token()
	var sprite := _spawn(td)
	_dm._select_token(sprite)
	_dm._select_token(null)
	assert_false(sprite.selected)


func test_select_new_deselects_old() -> void:
	var a := _spawn(_make_token("A"), Vector2(100, 100))
	var b := _spawn(_make_token("B"), Vector2(200, 200))
	_dm._select_token(a)
	_dm._select_token(b)
	assert_false(a.selected)
	assert_true(b.selected)


func test_properties_panel_shows_on_select() -> void:
	var td := _make_token("Heroe", 2.0)
	var sprite := _spawn(td)
	_dm._select_token(sprite)

	assert_true(_dm.properties_content.visible)
	assert_eq(_dm.prop_name_edit.text, "Heroe")
	assert_eq(_dm.prop_size_spin.value, 2.0)
	assert_true(_dm.prop_visible_check.button_pressed)


func test_properties_panel_hides_on_deselect() -> void:
	var td := _make_token()
	var sprite := _spawn(td)
	_dm._select_token(sprite)
	_dm._select_token(null)
	assert_false(_dm.properties_content.visible)


func test_rename_token_updates_sprite() -> void:
	var td := _make_token("Orco")
	var sprite := _spawn(td)
	_dm._select_token(sprite)

	_dm._on_token_name_changed("Orco Jefe")
	assert_eq(td.name, "Orco Jefe")
	assert_eq(sprite.name, "Orco Jefe")


func test_resize_token_updates_data() -> void:
	var td := _make_token("Dragon", 1.0)
	var sprite := _spawn(td)
	_dm._select_token(sprite)

	_dm._on_token_size_changed(3.0)
	assert_eq(td.size_cells, 3.0)


func test_visibility_toggle() -> void:
	var td := _make_token()
	var sprite := _spawn(td)
	_dm._select_token(sprite)

	_dm._on_token_visibility_toggled(false)
	assert_false(td.visible_to_players)

	_dm._on_token_visibility_toggled(true)
	assert_true(td.visible_to_players)


func test_delete_selected_token_removes_sprite() -> void:
	var sprite := _spawn(_make_token("Bicho"))
	_dm._select_token(sprite)
	var children_before: int = _dm.token_layer.get_child_count()

	_dm._delete_selected_token()
	await get_tree().process_frame

	assert_eq(_dm.token_layer.get_child_count(), children_before - 1)
	assert_false(_dm.properties_content.visible)


func test_duplicate_token_creates_copy() -> void:
	var td := _make_token("Guerrero")
	GameState.add_token_for_current_map(td)
	var sprite := _spawn(td)
	_dm._select_token(sprite)
	var count_before: int = _dm.token_layer.get_child_count()

	_dm._duplicate_token(sprite)

	var tokens_arr := GameState.get_current_tokens()
	assert_eq(tokens_arr.size(), 2)
	assert_eq(_dm.token_layer.get_child_count(), count_before + 1)
	assert_string_contains(tokens_arr[1].name, "copia")


func test_delete_token_sprite_updates_list() -> void:
	var td := _make_token("Fantasma")
	GameState.add_token_for_current_map(td)
	var sprite := _spawn(td)
	assert_eq(GameState.get_current_tokens().size(), 1)

	_dm._delete_token_sprite(sprite)
	await get_tree().process_frame

	assert_eq(GameState.get_current_tokens().size(), 0)
	_dm._refresh_token_list()
	assert_eq(_dm.token_list.item_count, 0)


func test_get_cell_px_returns_grid_size() -> void:
	var grid := GameState.get_current_grid()
	grid.size_px = 50.0
	assert_eq(_dm._get_cell_px(), 50.0)
	grid.size_px = 100.0
	assert_eq(_dm._get_cell_px(), 100.0)


func test_token_layer_mouse_pos_converts_coordinates() -> void:
	_dm.map_root.position = Vector2(0, 0)
	_dm.map_root.scale = Vector2(1, 1)
	var pos: Vector2 = _dm._get_token_layer_mouse_pos()
	assert_eq(typeof(pos), TYPE_VECTOR2)


func test_border_color_changes_token_data() -> void:
	var td := _make_token()
	var sprite := _spawn(td)
	_dm._select_token(sprite)

	_dm._on_token_border_color_changed(Color.RED)
	assert_eq(td.border_color, Color.RED)


func test_vision_radius_changes_token_data() -> void:
	var td := _make_token()
	var sprite := _spawn(td)
	_dm._select_token(sprite)

	_dm._on_token_vision_changed(6.0)
	assert_eq(td.vision_radius, 6)
	assert_string_contains(_dm.prop_vision_label.text, "Vision: 6")


func test_speed_changes_token_data() -> void:
	var td := _make_token()
	var sprite := _spawn(td)
	_dm._select_token(sprite)

	_dm._on_token_speed_changed(25.0)
	assert_eq(td.speed_ft, 25)


func test_properties_reflect_token_data_on_select() -> void:
	var td := _make_token("Elfo")
	td.border_color = Color.BLUE
	td.vision_radius = 12
	td.speed_ft = 35
	var sprite := _spawn(td)
	_dm._select_token(sprite)

	assert_eq(_dm.prop_border_color.color, Color.BLUE)
	assert_eq(_dm.prop_vision_slider.value, 12.0)
	assert_eq(_dm.prop_speed_spin.value, 35.0)


func test_border_color_roundtrip_sprite_to_data() -> void:
	var td := _make_token("Heroe")
	td.border_color = Color.GREEN
	var sprite := _spawn(td)
	_dm._select_token(sprite)

	# Simulate user picking RED in ColorPickerButton: button updates its color + emits signal
	_dm.prop_border_color.color = Color.RED
	_dm._on_token_border_color_changed(Color.RED)

	assert_eq(td.border_color, Color.RED)
	assert_eq(sprite.token_data.border_color, Color.RED)
	assert_eq(_dm.prop_border_color.color, Color.RED)
	assert_true(sprite.selected)


func test_border_color_default_is_yellow() -> void:
	var td := _make_token()
	var sprite := _spawn(td)
	_dm._select_token(sprite)

	assert_eq(_dm.prop_border_color.color, Color.YELLOW)
	assert_eq(sprite.token_data.border_color, Color.YELLOW)
