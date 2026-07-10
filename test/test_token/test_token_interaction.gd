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


func test_clear_selection_hides_properties_panel() -> void:
	var td := _make_token("Elfo")
	var sprite := _spawn(td)
	_dm._select_token(sprite)
	assert_true(_dm.properties_content.visible, "properties should be visible after select")
	_dm._clear_selection()
	assert_false(_dm.properties_content.visible, "clear_selection must hide properties panel")


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
	_dm._selected_tokens = [sprite]
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
	_dm._selected_tokens = [sprite]
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
	assert_eq(snapped.x, 105.0, "size=1: 87 → cell 1 center = 35+70=105")
	assert_eq(snapped.y, 105.0, "size=1: 93 → cell 1 center = 35+70=105")


func test_snap_size_two_to_vertex() -> void:
	var grid := GameState.get_current_grid()
	grid.size_px = 70.0
	grid.origin = Vector2.ZERO
	var snapped: Vector2 = _dm._compute_snap_position(Vector2(87, 93), 2.0)
	assert_eq(snapped.x, 70.0, "size=2: 87 → round((87-0)/70)*70 = round(1.24)*70 = 70")
	assert_eq(snapped.y, 70.0, "size=2: 93 → round((93-0)/70)*70 = round(1.33)*70 = 70")


func test_snap_size_three_to_cell_center() -> void:
	var grid := GameState.get_current_grid()
	grid.size_px = 70.0
	grid.origin = Vector2.ZERO
	var snapped: Vector2 = _dm._compute_snap_position(Vector2(87, 93), 3.0)
	assert_eq(snapped.x, 105.0, "size=3 (odd): same as size 1, center of cell")
	assert_eq(snapped.y, 105.0, "size=3: cell 1 center")


func test_snap_size_four_to_vertex() -> void:
	var grid := GameState.get_current_grid()
	grid.size_px = 70.0
	grid.origin = Vector2.ZERO
	var snapped: Vector2 = _dm._compute_snap_position(Vector2(87, 93), 4.0)
	assert_eq(snapped.x, 70.0, "size=4 (even): snaps to nearest vertex")
	assert_eq(snapped.y, 70.0, "size=4: round(1.33)*70 = 70")


func test_snap_size_half_to_cell_center() -> void:
	var grid := GameState.get_current_grid()
	grid.size_px = 70.0
	grid.origin = Vector2.ZERO
	# ceil(0.5) = 1 → odd → cell-centered
	var snapped: Vector2 = _dm._compute_snap_position(Vector2(87, 93), 0.5)
	assert_eq(snapped.x, 105.0, "size=0.5: ceil(0.5)=1, odd → cell center")
	assert_eq(snapped.y, 105.0, "size=0.5: cell 1 center")


func test_snap_size_two_token_after_arrow_move() -> void:
	var grid := GameState.get_current_grid()
	grid.size_px = 70.0
	grid.origin = Vector2.ZERO
	var td := _make_token("Ogro", 2.0)
	var sprite := _spawn(td, Vector2(70, 70))
	_dm._select_token(sprite)
	var event: InputEventKey = InputEventKey.new()
	event.keycode = KEY_RIGHT
	event.pressed = true
	_dm._input(event)
	# size 2: move 70 right + snap to vertex → same position (already at intersection)
	assert_eq(sprite.position.x, 140.0, "size 2 moves 1 cell, snaps to vertex at 140")


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
	_dm._selected_tokens = [sprite]
	_dm._dragging_token = true
	_dm._drag_start_pos = Vector2(100, 100)
	_dm._stop_dragging()
	assert_false(_dm._dragging_token, "dragging should be false after stop")
	assert_false(_dm.token_layer._ghost_visible, "ghost line should be hidden after stop")
	assert_eq(_dm.token_layer._distance_text, "", "distance text should be cleared")


func test_arrow_key_moves_token_one_cell_right() -> void:
	var grid := GameState.get_current_grid()
	grid.size_px = 70.0
	grid.origin = Vector2.ZERO
	var sprite := _spawn(_make_token("Guerrero"), Vector2(105, 105))
	_dm._select_token(sprite)
	var event: InputEventKey = InputEventKey.new()
	event.keycode = KEY_RIGHT
	event.pressed = true
	_dm._input(event)
	assert_eq(sprite.position.x, 175.0, "right arrow: 105+70=175 (snapped to cell center)")
	assert_eq(sprite.position.y, 105.0, "Y should not change")


func test_arrow_key_moves_token_one_cell_up() -> void:
	var grid := GameState.get_current_grid()
	grid.size_px = 70.0
	grid.origin = Vector2.ZERO
	var sprite := _spawn(_make_token("Mago"), Vector2(175, 175))
	_dm._select_token(sprite)
	var event: InputEventKey = InputEventKey.new()
	event.keycode = KEY_UP
	event.pressed = true
	_dm._input(event)
	assert_eq(sprite.position.y, 105.0, "up arrow: 175-70=105")


func test_shift_arrow_fine_moves_one_pixel() -> void:
	var grid := GameState.get_current_grid()
	grid.size_px = 70.0
	grid.origin = Vector2.ZERO
	var sprite := _spawn(_make_token("Elfo"), Vector2(105, 105))
	_dm._select_token(sprite)
	var event: InputEventKey = InputEventKey.new()
	event.keycode = KEY_LEFT
	event.shift_pressed = true
	event.pressed = true
	_dm._input(event)
	assert_eq(sprite.position.x, 104.0, "shift+left: 105-1=104 (no snap)")


func test_non_arrow_key_ignored() -> void:
	var sprite := _spawn(_make_token("Orco"), Vector2(100, 100))
	_dm._select_token(sprite)
	var pos_before := sprite.position
	var event: InputEventKey = InputEventKey.new()
	event.keycode = KEY_A
	event.pressed = true
	_dm._input(event)
	assert_eq(sprite.position, pos_before, "non-arrow key should not move token")


func test_movement_trace_shown_on_drag_stop() -> void:
	var sprite := _spawn(_make_token("Orco"), Vector2(100, 100))
	_dm._selected_token = sprite
	_dm._selected_tokens = [sprite]
	_dm._dragging_token = true
	_dm._drag_start_pos = Vector2(100, 100)
	sprite.position = Vector2(300, 200)
	_dm._stop_dragging()
	assert_true(_dm.token_layer._trace_visible, "trace should be visible after dragging stops")


func test_movement_trace_shown_on_arrow_move() -> void:
	var grid := GameState.get_current_grid()
	grid.size_px = 70.0
	grid.origin = Vector2.ZERO
	var sprite := _spawn(_make_token("Mago"), Vector2(105, 105))
	_dm._select_token(sprite)
	var event: InputEventKey = InputEventKey.new()
	event.keycode = KEY_RIGHT
	event.pressed = true
	_dm._input(event)
	assert_true(_dm.token_layer._trace_visible, "trace should be visible after arrow move")
	assert_eq(_dm.token_layer._trace_from, Vector2(105, 105))
	assert_eq(_dm.token_layer._trace_to, Vector2(175, 105))


func test_speed_limit_marks_excess_red() -> void:
	var td := _make_token("Lento")
	td.speed_ft = 10
	var sprite := _spawn(td, Vector2(105, 105))
	_dm._selected_token = sprite
	_dm._selected_tokens = [sprite]
	_dm._dragging_token = true
	_dm._drag_offset = Vector2.ZERO
	_dm._drag_start_pos = Vector2(105, 105)
	_dm._update_drag_position()
	assert_gt(_dm.token_layer._speed_limit_px, 0, "speed limit should be set when token has speed_ft")
	# speed_ft=10, feet_per_cell=5 → max 2 cells, cell_px=70 → limit=140px


func test_no_speed_limit_when_speed_zero() -> void:
	var td := _make_token("Rapido")
	td.speed_ft = 0
	var sprite := _spawn(td, Vector2(105, 105))
	_dm._selected_token = sprite
	_dm._selected_tokens = [sprite]
	_dm._dragging_token = true
	_dm._drag_offset = Vector2.ZERO
	_dm._drag_start_pos = Vector2(105, 105)
	_dm._update_drag_position()
	assert_eq(_dm.token_layer._speed_limit_px, -1.0, "speed limit -1 when speed_ft=0")


func test_ctrl_click_adds_to_selection() -> void:
	var a := _spawn(_make_token("A"), Vector2(100, 100))
	var b := _spawn(_make_token("B"), Vector2(200, 200))
	_dm._select_token(a)
	assert_eq(_dm._selected_tokens.size(), 1)
	_dm._toggle_selection(b)
	assert_eq(_dm._selected_tokens.size(), 2, "Ctrl+click should add to multi-selection")
	assert_true(b.selected, "second token should show selection border")
	assert_true(a.selected, "first token should remain selected")


func test_ctrl_click_removes_from_selection() -> void:
	var a := _spawn(_make_token("A"), Vector2(100, 100))
	var b := _spawn(_make_token("B"), Vector2(200, 200))
	_dm._selected_tokens = [a, b]
	_dm._selected_token = a
	a.select()
	b.select()
	_dm._toggle_selection(b)
	assert_eq(_dm._selected_tokens.size(), 1, "Ctrl+click should remove from multi-selection")
	assert_false(b.selected, "removed token should not show border")
	assert_true(a.selected, "other token should remain selected")


func test_group_drag_moves_all_selected_tokens() -> void:
	var a := _spawn(_make_token("A"), Vector2(100, 100))
	var b := _spawn(_make_token("B"), Vector2(200, 200))
	_dm._selected_tokens = [a, b]
	_dm._selected_token = a
	_dm._dragging_token = true
	_dm._drag_offset = Vector2.ZERO
	_dm._drag_start_pos = a.position
	_dm._save_drag_start_positions()
	a.select()
	b.select()
	a.position = Vector2(170, 170)
	var delta := Vector2(70, 70)
	b.position += delta
	assert_eq(b.position, Vector2(270, 270), "non-primary selected token should move same delta")


func test_clear_selection_deselects_all() -> void:
	var a := _spawn(_make_token("A"), Vector2(100, 100))
	var b := _spawn(_make_token("B"), Vector2(200, 200))
	_dm._selected_tokens = [a, b]
	_dm._selected_token = a
	a.select()
	b.select()
	_dm._clear_selection()
	assert_eq(_dm._selected_tokens.size(), 0)
	assert_false(a.selected)
	assert_false(b.selected)
	assert_eq(_dm._selected_token, null)


func test_distance_preview_shows_on_ctrl_hover() -> void:
	var grid := GameState.get_current_grid()
	grid.size_px = 70.0
	grid.origin = Vector2.ZERO
	var sprite := _spawn(_make_token("Elfo"), Vector2(105, 105))
	_dm._selected_token = sprite
	_dm._selected_tokens = [sprite]
	_dm._update_distance_preview()
	assert_ne(_dm.token_layer._hover_text, "", "distance preview should show text")


func test_distance_preview_hidden_on_ctrl_release() -> void:
	_dm.token_layer.show_distance_preview(Vector2.ZERO, Vector2(100, 100), "5 pies")
	assert_ne(_dm.token_layer._hover_text, "")
	_dm.token_layer.hide_distance_preview()
	assert_eq(_dm.token_layer._hover_text, "", "hover text should clear on hide")


func test_distance_preview_no_token_no_text() -> void:
	_dm._selected_token = null
	_dm._selected_tokens.clear()
	_dm._update_distance_preview()
	assert_eq(_dm.token_layer._hover_text, "", "no preview when no token selected")


func test_distance_label_in_meters() -> void:
	GameState.current_units = GameState.Units.METERS
	var label: String = GameState.get_distance_label(2)
	assert_string_contains(label, "m")
	assert_string_contains(label, "2 casillas")
	GameState.current_units = GameState.Units.FEET


func test_distance_label_in_feet() -> void:
	GameState.current_units = GameState.Units.FEET
	var label: String = GameState.get_distance_label(2)
	assert_string_contains(label, "pies")
	assert_string_contains(label, "2 casillas")


func test_conditions_added_to_token_data() -> void:
	var td := _make_token()
	var sprite := _spawn(td)
	_dm._select_token(sprite)
	_dm._on_condition_toggled("envenenado", true)
	assert_true("envenenado" in td.conditions)


func test_conditions_removed_from_token_data() -> void:
	var td := _make_token()
	var sprite := _spawn(td)
	_dm._select_token(sprite)
	_dm._on_condition_toggled("envenenado", true)
	_dm._on_condition_toggled("envenenado", false)
	assert_false("envenenado" in td.conditions)


func test_multiple_conditions() -> void:
	var td := _make_token()
	var sprite := _spawn(td)
	_dm._select_token(sprite)
	_dm._on_condition_toggled("envenenado", true)
	_dm._on_condition_toggled("paralizado", true)
	assert_eq(td.conditions.size(), 2)


func test_conditions_panel_has_buttons() -> void:
	var td := _make_token()
	var sprite := _spawn(td)
	_dm._select_token(sprite)
	var count := 0
	for child in _dm.prop_conditions_flow.get_children():
		if child is CheckButton:
			count += 1
	assert_gt(count, 0, "conditions flow should have check buttons")


func test_conditions_no_token_no_crash() -> void:
	_dm._on_condition_toggled("envenenado", true)
	assert_false(_dm.properties_content.visible, "no crash, properties hidden")


func test_context_menu_has_correct_items() -> void:
	var td := _make_token()
	var sprite := _spawn(td)
	_dm._show_token_context_menu(sprite)
	await get_tree().process_frame
	var popup: PopupMenu = null
	for child in get_tree().root.get_children():
		if child is PopupMenu:
			popup = child
			break
	assert_not_null(popup, "context menu should be created")
	assert_eq(popup.item_count, 4, "should have 4 items (3 actions + 1 separator)")
	assert_string_contains(popup.get_item_text(0), "Duplicar")
	assert_string_contains(popup.get_item_text(1), "Guardar en biblioteca")
	assert_true(popup.is_item_separator(2), "item 2 should be a separator")
	assert_string_contains(popup.get_item_text(3), "Eliminar")
	popup.queue_free()


func test_save_token_to_library_creates_file() -> void:
	var img := Image.create(16, 16, false, Image.FORMAT_RGBA8)
	img.fill(Color(1, 1, 1, 0.5))
	var test_path: String = "user://_test_token.png"
	img.save_png(test_path)
	var abs_test: String = ProjectSettings.globalize_path(test_path)
	var td := _make_token("TestLib")
	td.image_path = abs_test
	var sprite := _spawn(td)
	_dm._save_token_to_library(sprite)
	var dest_dir: String = ProjectSettings.globalize_path("res://library/tokens")
	var expected: String = dest_dir.path_join("TestLib.png")
	assert_true(FileAccess.file_exists(expected), "token PNG should be saved to library")
	DirAccess.remove_absolute(expected)
	DirAccess.remove_absolute(abs_test)


func test_save_token_to_library_refreshes_list() -> void:
	var img := Image.create(16, 16, false, Image.FORMAT_RGBA8)
	img.fill(Color(1, 1, 1, 0.5))
	var test_path: String = "user://_test_token2.png"
	img.save_png(test_path)
	var abs_test: String = ProjectSettings.globalize_path(test_path)
	var td := _make_token("TestLib2")
	td.image_path = abs_test
	var sprite := _spawn(td)
	_dm._save_token_to_library(sprite)
	assert_gt(_dm.token_library.item_count, 0, "library should have items after save")
	var dest_dir: String = ProjectSettings.globalize_path("res://library/tokens")
	var expected: String = dest_dir.path_join("TestLib2.png")
	DirAccess.remove_absolute(expected)
	DirAccess.remove_absolute(abs_test)


func test_context_menu_no_crash_on_invalid() -> void:
	var td := _make_token()
	td.image_path = ""
	var sprite := _spawn(td)
	_dm._show_token_context_menu(sprite)
	await get_tree().process_frame
	assert_true(true, "context menu should not crash with empty image path")


func test_marquee_click_preserves_multi_selection() -> void:
	var a := _spawn(_make_token("A"), Vector2(100, 100))
	var b := _spawn(_make_token("B"), Vector2(200, 100))
	_dm._selected_tokens = [a, b]
	_dm._selected_token = a
	a.select()
	b.select()
	assert_eq(_dm._selected_tokens.size(), 2)
	_dm._clear_selection()
	assert_eq(_dm._selected_tokens.size(), 0)
	# Re-set: simula click sobre 'a' estando ya en la seleccion
	_dm._selected_tokens = [a, b]
	_dm._selected_token = a
	_dm._dragging_token = true
	_dm._drag_offset = Vector2.ZERO
	_dm._drag_start_pos = a.position
	_dm._save_drag_start_positions()
	assert_eq(_dm._selected_tokens.size(), 2, "selection should not be cleared for already-selected token")
	assert_true(_dm._selected_tokens.has(b), "both tokens should remain selected")


func test_group_drag_moves_all_after_marquee_click() -> void:
	var a := _spawn(_make_token("A"), Vector2(100, 100))
	var b := _spawn(_make_token("B"), Vector2(200, 100))
	_dm._selected_tokens = [a, b]
	_dm._selected_token = a
	_dm._dragging_token = true
	_dm._drag_offset = Vector2.ZERO
	_dm._drag_start_pos = a.position
	_dm._save_drag_start_positions()
	a.select()
	b.select()
	var orig_b: Vector2 = b.position
	a.position = Vector2(150, 150)
	var delta: Vector2 = a.position - _dm._drag_start_pos
	b.position += delta
	assert_eq(b.position, orig_b + delta, "both tokens should move same delta")


func test_stacking_respects_grid_origin() -> void:
	var gd := GameState.get_current_grid()
	gd.origin = Vector2(30, 20)
	gd.size_px = 70.0
	var cell_px: float = gd.size_px
	var snapped_pos := Vector2(100, 100)
	var adjusted: Vector2 = snapped_pos - gd.origin
	var expected_snap: Vector2 = (adjusted / cell_px).round() * cell_px + gd.origin
	var a := _spawn(_make_token("A"), expected_snap)
	var b := _spawn(_make_token("B"), expected_snap + Vector2(5, 3))
	_dm._rearrange_stacked_tokens()
	var dist: float = a.position.distance_squared_to(b.position)
	assert_gt(dist, 10.0, "stacked tokens should be fanned out with origin offset")
	gd.origin = Vector2.ZERO


func test_stacking_same_cell_with_origin() -> void:
	var gd := GameState.get_current_grid()
	gd.origin = Vector2(50, 50)
	gd.size_px = 70.0
	var cell_px: float = gd.size_px
	var snapped_pos := Vector2(200, 200)
	var adjusted: Vector2 = snapped_pos - gd.origin
	var expected_snap: Vector2 = (adjusted / cell_px).round() * cell_px + gd.origin
	var a := _spawn(_make_token("A"), expected_snap)
	var b := _spawn(_make_token("B"), expected_snap)
	_dm._rearrange_stacked_tokens()
	assert_ne(a.position.round(), b.position.round(), "stacked tokens should have different positions")
	gd.origin = Vector2.ZERO


func test_measure_toggle_activates() -> void:
	assert_false(_dm._measuring)
	_dm._on_measure_pressed()
	assert_true(_dm._measuring)
	assert_true(_dm.measure_btn.button_pressed)
	_dm._on_measure_pressed()
	assert_false(_dm._measuring)
	assert_false(_dm.measure_btn.button_pressed)


func test_measure_add_waypoint() -> void:
	_dm._on_measure_pressed()
	_dm._add_measure_waypoint()
	assert_eq(_dm._measure_points.size(), 1, "should have one waypoint")


func test_measure_escape_cancels() -> void:
	_dm._on_measure_pressed()
	_dm._add_measure_waypoint()
	_dm._add_measure_waypoint()
	assert_eq(_dm._measure_points.size(), 2)
	_dm._cancel_measurement()
	assert_eq(_dm._measure_points.size(), 0, "escape should clear all waypoints")


func test_measure_multiple_waypoints() -> void:
	_dm._on_measure_pressed()
	_dm._add_measure_waypoint()
	_dm._add_measure_waypoint()
	_dm._add_measure_waypoint()
	assert_eq(_dm._measure_points.size(), 3, "should have three waypoints")


func test_measure_deactivate_clears() -> void:
	_dm._on_measure_pressed()
	_dm._add_measure_waypoint()
	_dm._on_measure_pressed()
	assert_eq(_dm._measure_points.size(), 0, "deactivating should clear waypoints")
	assert_false(_dm._measuring)
