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


func test_snap_respects_grid_origin() -> void:
	var grid := GameState.get_current_grid()
	grid.size_px = 50.0
	grid.origin = Vector2(10, 20)
	var sprite := _spawn(_make_token(), Vector2(87, 93))
	_dm._snap_token_position(sprite)
	assert_eq(sprite.position.x, 85.0, "snapped X should land on grid center shifted by origin.x")
	assert_eq(sprite.position.y, 95.0, "snapped Y should land on grid center shifted by origin.y")


func test_drag_ghost_visible_during_drag() -> void:
	var sprite := _spawn(_make_token("Orco"), Vector2(200, 200))
	_dm._selected_token = sprite
	_dm._dragging_token = true
	_dm._drag_offset = Vector2(50, 50)
	_dm._drag_start_pos = Vector2(200, 200)
	_dm._update_drag_position()
	assert_true(_dm.token_layer._ghost_visible, "ghost line should be visible during drag")
	assert_eq(_dm.token_layer._ghost_start, Vector2(200, 200), "ghost_start should match drag origin")
	assert_ne(_dm.token_layer._distance_text, "", "distance label should not be empty")


func test_drag_ghost_goes_to_snapped_position() -> void:
	var grid := GameState.get_current_grid()
	grid.size_px = 70.0
	grid.origin = Vector2.ZERO
	var sprite := _spawn(_make_token("Orco"), Vector2(200, 200))
	_dm._selected_token = sprite
	_dm._dragging_token = true
	_dm._drag_offset = Vector2(50, 50)
	_dm._drag_start_pos = Vector2(200, 200)
	_dm._update_drag_position()
	var snapped: Vector2 = _dm._compute_snap_position(sprite.position)
	assert_eq(_dm.token_layer._ghost_end, snapped, "ghost_end should be snapped position, not raw mouse")


func test_drag_distance_uses_diagonal_rule() -> void:
	GameState.diagonal_rule = true
	var cells: int = GameState.count_cells_grid(Vector2(0, 0), Vector2(140, 140), 70.0, Vector2.ZERO, true)
	assert_eq(cells, 3, "2 consecutive diagonals: 1+2=3 cells")
	cells = GameState.count_cells_grid(Vector2(0, 0), Vector2(210, 210), 70.0, Vector2.ZERO, true)
	assert_eq(cells, 4, "3 consecutive diagonals: 1+2+1=4 cells")


func test_drag_distance_without_diagonal_rule() -> void:
	var cells := GameState.count_cells_grid(Vector2(0, 0), Vector2(140, 140), 70.0, Vector2.ZERO, false)
	assert_eq(cells, 2, "2 diagonals without rule → max(2,2) = 2 cells")


func test_count_cells_grid_mixed_axes() -> void:
	var cells: int = GameState.count_cells_grid(Vector2(0, 0), Vector2(210, 70), 70.0, Vector2.ZERO, true)
	assert_eq(cells, 3, "3 right + 1 down: max=3, min=1, straight=2 → diags separated → 3 cells")


func test_diagonal_penalty_only_consecutive() -> void:
	GameState.diagonal_rule = true
	# 6 casillas derecha + 3 arriba: 6 straights separan las 3 diagonales → 6 casillas
	var cells: int = GameState.count_cells_grid(Vector2(0, 0), Vector2(420, 210), 70.0, Vector2.ZERO, true)
	assert_eq(cells, 6, "6R+3U: 3 diagonals separated by straights → max(6,3)=6, not penalized")
	# 5 casillas derecha + 3 arriba: 2 straights separan 3 diagonales → 5 casillas
	cells = GameState.count_cells_grid(Vector2(0, 0), Vector2(350, 210), 70.0, Vector2.ZERO, true)
	assert_eq(cells, 5, "5R+3U: 2 straights separate 3 diags → 5 cells (diag·straight·diag·straight·diag)")
	# 4 derecha + 4 arriba: 0 straights, 4 diags consecutivos → 6 casillas
	cells = GameState.count_cells_grid(Vector2(0, 0), Vector2(280, 280), 70.0, Vector2.ZERO, true)
	assert_eq(cells, 6, "4R+4U: all 4 diags consecutive → 1+2+1+2=6 cells")


func test_compute_snap_position_centers_on_cell() -> void:
	var grid := GameState.get_current_grid()
	grid.size_px = 70.0
	grid.origin = Vector2.ZERO
	var snapped: Vector2 = _dm._compute_snap_position(Vector2(87, 93))
	assert_eq(snapped.x, 105.0, "87 → cell 1 center = 35+70=105")
	assert_eq(snapped.y, 105.0, "93 → cell 1 center = 35+70=105")


func test_count_cells_grid_respects_origin() -> void:
	var cells: int = GameState.count_cells_grid(Vector2(110, 110), Vector2(180, 180), 70.0, Vector2(10, 10), true)
	var from_cx: int = int(floor((110.0 - 10.0) / 70.0))
	var to_cx: int = int(floor((180.0 - 10.0) / 70.0))
	var dx: int = abs(to_cx - from_cx)
	var dy: int = abs(to_cx - from_cx)
	var expected: int = dx + int(floor(float(min(dx, dy)) / 2.0))
	assert_eq(cells, expected, "should respect grid origin in cell calc")


func test_feet_per_cell_default_is_five() -> void:
	assert_eq(GameState.feet_per_cell, 5.0, "feet_per_cell default should be 5 pies DnD 5e")


func test_drag_ghost_hidden_on_stop() -> void:
	var sprite := _spawn(_make_token("Orco"), Vector2(100, 100))
	_dm._selected_token = sprite
	_dm._dragging_token = true
	_dm._drag_start_pos = Vector2(100, 100)
	_dm._stop_dragging()
	assert_false(_dm._dragging_token, "dragging should be false after stop")
	assert_false(_dm.token_layer._ghost_visible, "ghost line should be hidden after stop")
	assert_eq(_dm.token_layer._distance_text, "", "distance text should be cleared")
