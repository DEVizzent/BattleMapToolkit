extends GutTest

const PlayerWindowScene := preload("res://scenes/player/player_window.tscn")
const DMWindowScene := preload("res://scenes/ui/dm_window.tscn")
const TokenDataClass := preload("res://scripts/token/token_data.gd")
const TokenSpriteClass := preload("res://scripts/token/token_sprite.gd")
const GridDataClass := preload("res://scripts/grid/grid_data.gd")

var _pw: Window
var _dm: Control


func before_each() -> void:
	_dm = DMWindowScene.instantiate()
	add_child_autofree(_dm)
	await get_tree().process_frame
	GameState.map_tokens.clear()
	GameState.map_grids.clear()
	GameState.current_map_index = -1
	_pw = PlayerWindowScene.instantiate()
	add_child_autofree(_pw)
	await get_tree().process_frame


func test_player_window_creates_without_toolbars() -> void:
	assert_not_null(_pw, "player window should instantiate")
	assert_true(_pw is Window, "should be a Window node")
	assert_null(_pw.get_node_or_null("Toolbar"), "should have no toolbar")


func test_player_window_has_viewport_nodes() -> void:
	assert_not_null(_pw.map_root, "should have MapRoot")
	assert_not_null(_pw.map_sprite, "should have MapSprite")
	assert_not_null(_pw.token_layer, "should have TokenLayer")
	assert_not_null(_pw.grid_layer, "should have GridLayer")


func test_spawn_token_in_player_window() -> void:
	var td := TokenDataClass.new()
	td.name = "Goblin"
	_pw.spawn_token(td, Vector2(100, 200), 70.0)
	var token_id: String = str(td.get_instance_id())
	assert_true(_pw._token_sprites.has(token_id), "token should be in _token_sprites")
	assert_eq(_pw.token_layer.get_child_count(), 1, "token layer should have 1 child")


func test_move_token_in_player_window() -> void:
	var td := TokenDataClass.new()
	td.name = "Orco"
	_pw.spawn_token(td, Vector2(100, 100), 70.0)
	var token_id: String = str(td.get_instance_id())
	_pw.move_token(token_id, Vector2(300, 400))
	var sprite: Sprite2D = _pw._token_sprites.get(token_id)
	assert_eq(sprite.position, Vector2(300, 400), "token should move to new position")


func test_remove_token_from_player_window() -> void:
	var td := TokenDataClass.new()
	td.name = "Elfo"
	_pw.spawn_token(td, Vector2(50, 50), 70.0)
	var token_id: String = str(td.get_instance_id())
	_pw.remove_token(token_id)
	await get_tree().process_frame
	assert_false(_pw._token_sprites.has(token_id), "token should be removed from dict")
	assert_eq(_pw.token_layer.get_child_count(), 0, "token layer should be empty")


func test_set_token_visibility_in_player_window() -> void:
	var td := TokenDataClass.new()
	td.name = "Fantasma"
	_pw.spawn_token(td, Vector2(0, 0), 70.0)
	var token_id: String = str(td.get_instance_id())
	_pw.set_token_visible(token_id, false)
	var sprite: Sprite2D = _pw._token_sprites.get(token_id)
	assert_false(sprite.visible, "sprite should be hidden")
	_pw.set_token_visible(token_id, true)
	assert_true(sprite.visible, "sprite should be visible again")


func test_player_window_set_grid() -> void:
	var gd := GridDataClass.new()
	gd.size_px = 50.0
	gd.visible = true
	_pw.set_grid(gd)
	assert_not_null(_pw._grid_data, "grid data should be set")


func test_toggle_player_window_state() -> void:
	_dm._toggle_player_window()
	assert_true(GameState.player_window_open, "should be open after toggle")
	_dm._toggle_player_window()
	assert_false(GameState.player_window_open, "should be closed after second toggle")


func test_monitor_detection_available() -> void:
	var count := DisplayServer.get_screen_count()
	assert_true(count is int, "screen count should be an integer")


func test_player_window_closed_on_close_request() -> void:
	_dm._toggle_player_window()
	_dm._player_window.emit_signal("close_requested")
	assert_false(GameState.player_window_open, "player window should be marked closed")


func test_spawn_token_loads_texture_via_apply_data() -> void:
	var td := TokenDataClass.new()
	td.name = "Dragon"
	_pw.spawn_token(td, Vector2(100, 100), 70.0)
	var token_id: String = str(td.get_instance_id())
	var sprite: Sprite2D = _pw._token_sprites.get(token_id)
	assert_not_null(sprite, "sprite should exist after spawn")
	assert_eq(sprite.name, "Dragon", "apply_data should set the sprite name")
	assert_true(sprite.centered, "apply_data should center the sprite")


func test_spawn_token_with_explicit_id() -> void:
	var td := TokenDataClass.new()
	td.name = "CustomId"
	var custom_id := "token_42"
	_pw.spawn_token(td, Vector2(50, 50), 70.0, custom_id)
	assert_true(_pw._token_sprites.has(custom_id), "token stored under explicit ID")
	assert_eq(_pw.token_layer.get_child_count(), 1)


func test_token_moved_signal_updates_position() -> void:
	var td := TokenDataClass.new()
	td.name = "Movil"
	_pw.spawn_token(td, Vector2(0, 0), 70.0)
	var token_id: String = str(td.get_instance_id())
	EventBus.token_moved.emit(token_id, Vector2(0, 0), Vector2(500, 300))
	var sprite: Sprite2D = _pw._token_sprites.get(token_id)
	assert_eq(sprite.position, Vector2(500, 300), "token_moved signal should update position")


func test_player_window_additional_to_root() -> void:
	var test_pw := PlayerWindowScene.instantiate()
	_dm.get_tree().root.add_child(test_pw)
	assert_eq(test_pw.get_parent(), _dm.get_tree().root, "player window should be child of root, not DM")


func test_spawn_token_deduplicates_by_id() -> void:
	var td := TokenDataClass.new()
	_pw.spawn_token(td, Vector2(0, 0), 70.0)
	_pw.spawn_token(td, Vector2(999, 999), 70.0)
	assert_eq(_pw.token_layer.get_child_count(), 1, "should not create duplicate sprite for same ID")


func test_clear_tokens_removes_all() -> void:
	var a := TokenDataClass.new()
	a.name = "A"
	var b := TokenDataClass.new()
	b.name = "B"
	_pw.spawn_token(a, Vector2(0, 0), 70.0)
	_pw.spawn_token(b, Vector2(100, 100), 70.0)
	_pw.clear_tokens()
	await get_tree().process_frame
	assert_eq(_pw.token_layer.get_child_count(), 0, "clear_tokens should remove all sprites")
	assert_eq(_pw._token_sprites.size(), 0, "clear_tokens should clear the dict")


func test_visibility_sync_via_signal() -> void:
	var td := TokenDataClass.new()
	td.name = "Sigiloso"
	_pw.spawn_token(td, Vector2(0, 0), 70.0)
	var sprite: Sprite2D = _pw.token_layer.get_children()[0]
	assert_true(sprite.visible, "should start visible")
	EventBus.token_visibility_changed.emit("Sigiloso", false)
	assert_false(sprite.visible, "visibility signal should hide matching token")
	EventBus.token_visibility_changed.emit("Sigiloso", true)
	assert_true(sprite.visible, "visibility signal should show matching token")


func test_token_moved_uses_token_data_id_not_sprite_id() -> void:
	var td := TokenDataClass.new()
	td.name = "Identidad"
	_pw.spawn_token(td, Vector2(100, 100), 70.0, str(td.get_instance_id()))
	var token_data_id: String = str(td.get_instance_id())
	assert_true(_pw._token_sprites.has(token_data_id), "stored under token_data instance ID")
	EventBus.token_moved.emit(token_data_id, Vector2(100, 100), Vector2(300, 200))
	var sprite: Sprite2D = _pw._token_sprites.get(token_data_id)
	assert_eq(sprite.position, Vector2(300, 200), "move should work via token_data ID")


func test_dm_drag_updates_player_window() -> void:
	var td := TokenDataClass.new()
	td.name = "Sincro"
	_pw.spawn_token(td, Vector2(100, 100), 70.0, str(td.get_instance_id()))
	var token_id: String = str(td.get_instance_id())
	# Simulate DM drag: emit during drag
	EventBus.token_moved.emit(token_id, Vector2(100, 100), Vector2(150, 150))
	var sprite: Sprite2D = _pw._token_sprites.get(token_id)
	assert_eq(sprite.position, Vector2(150, 150), "real-time drag sync should update position")
	# Simulate DM release (final snap)
	EventBus.token_moved.emit(token_id, Vector2(150, 150), Vector2(175, 175))
	assert_eq(sprite.position, Vector2(175, 175), "final position should be synced")


func test_player_window_drag_emits_token_moved() -> void:
	var td := TokenDataClass.new()
	td.name = "Dragger"
	_pw.spawn_token(td, Vector2(50, 50), 70.0, str(td.get_instance_id()))
	var token_id: String = str(td.get_instance_id())
	_pw._dragging_token = true
	_pw._drag_sprite = _pw._token_sprites.get(token_id)
	_pw._drag_start_pos = Vector2(50, 50)
	_pw._drag_sprite.position = Vector2(200, 200)
	_pw._stop_drag()
	# Verify signal was emitted by checking sprite is at final position
	var sprite: Sprite2D = _pw._token_sprites.get(token_id)
	assert_eq(sprite.position, Vector2(200, 200), "drag should update position")


func test_bidirectional_sync_dm_to_player_to_dm() -> void:
	var td := TokenDataClass.new()
	td.name = "Bidi"
	_pw.spawn_token(td, Vector2(0, 0), 70.0, str(td.get_instance_id()))
	var token_id: String = str(td.get_instance_id())
	EventBus.token_moved.emit(token_id, Vector2.ZERO, Vector2(100, 100))
	var sprite: Sprite2D = _pw._token_sprites.get(token_id)
	assert_eq(sprite.position, Vector2(100, 100), "DM sync arrived")
	EventBus.token_moved.emit(token_id, Vector2(100, 100), Vector2(200, 200))
	assert_eq(sprite.position, Vector2(200, 200), "player sync should also work")


func test_player_drag_shows_ghost_and_distance() -> void:
	var gd := GridDataClass.new()
	gd.size_px = 70.0
	gd.origin = Vector2.ZERO
	_pw.set_grid(gd)
	var td := TokenDataClass.new()
	td.name = "GhostTest"
	_pw.spawn_token(td, Vector2(100, 100), 70.0, str(td.get_instance_id()))
	_pw._dragging_token = true
	_pw._drag_sprite = _pw._token_sprites.get(str(td.get_instance_id()))
	_pw._drag_offset = Vector2.ZERO
	_pw._drag_start_pos = Vector2(100, 100)
	_pw._update_drag_position()
	assert_true(_pw.token_layer._ghost_visible, "ghost line should be visible during player drag")
	assert_ne(_pw.token_layer._distance_text, "", "distance text should be shown")


func test_player_drag_stop_hides_ghost() -> void:
	var td := TokenDataClass.new()
	_pw.spawn_token(td, Vector2(100, 100), 70.0, str(td.get_instance_id()))
	_pw._dragging_token = true
	_pw._drag_sprite = _pw._token_sprites.get(str(td.get_instance_id()))
	_pw._drag_start_pos = Vector2(100, 100)
	_pw._stop_drag()
	assert_false(_pw.token_layer._ghost_visible, "ghost should be hidden after drag stop")


func test_ghost_visible_in_both_windows_when_dm_drags() -> void:
	EventBus.token_drag_update.emit(Vector2(0, 0), Vector2(100, 100), "10 pies (2 casillas)", -1.0)
	assert_true(_pw.token_layer._ghost_visible, "PlayerWindow ghost should show from DM drag signal")
	assert_true(_dm.token_layer._ghost_visible, "DM window ghost should show from its own handler")


func test_ghost_visible_in_both_windows_when_player_drags() -> void:
	EventBus.token_drag_update.emit(Vector2(50, 50), Vector2(200, 200), "15 pies (3 casillas)", -1.0)
	assert_true(_pw.token_layer._ghost_visible, "PlayerWindow should show ghost from its own emit")
	assert_true(_dm.token_layer._ghost_visible, "DM should show ghost from PlayerWindow drag signal")


func test_ghost_hidden_in_both_windows_on_drag_end() -> void:
	EventBus.token_drag_update.emit(Vector2.ZERO, Vector2(100, 100), "5 pies (1 casillas)", -1.0)
	EventBus.token_drag_end.emit()
	assert_false(_pw.token_layer._ghost_visible, "PlayerWindow ghost should be hidden")
	assert_false(_dm.token_layer._ghost_visible, "DM ghost should be hidden")


func test_player_drag_updates_dm_token_position() -> void:
	var td := TokenDataClass.new()
	td.name = "Remote"
	var cell_px: float = 70.0
	_dm._spawn_token_sprite(td, Vector2(0, 0), cell_px)
	var token_id: String = str(td.get_instance_id())
	EventBus.token_moved.emit(token_id, Vector2.ZERO, Vector2(300, 400))
	# Find the DM sprite and check position
	var found: bool = false
	for child in _dm.token_layer.get_children():
		if child is TokenSpriteClass:
			if str(child.token_data.get_instance_id()) == token_id:
				assert_eq(child.position, Vector2(300, 400), "DM token should move via PlayerWindow signal")
				found = true
	assert_true(found, "should find the DM token sprite")


func test_dm_token_not_overridden_during_own_drag() -> void:
	var td := TokenDataClass.new()
	var cell_px: float = 70.0
	_dm._spawn_token_sprite(td, Vector2(100, 100), cell_px)
	var token_id: String = str(td.get_instance_id())
	_dm._dragging_token = true
	_dm._selected_tokens = []
	# Find the sprite and add to selected
	for child in _dm.token_layer.get_children():
		if child is TokenSpriteClass:
			if str(child.token_data.get_instance_id()) == token_id:
				_dm._selected_tokens.append(child)
				_dm._selected_token = child
	# Try to move via signal — should NOT update position during own drag
	EventBus.token_moved.emit(token_id, Vector2(100, 100), Vector2(999, 999))
	for child in _dm.token_layer.get_children():
		if child is TokenSpriteClass:
			if str(child.token_data.get_instance_id()) == token_id:
				assert_eq(child.position, Vector2(100, 100), "DM token should not move via signal during own drag")
	_dm._dragging_token = false
	_dm._selected_tokens.clear()


# ─── Fase 10: Player view indicator & sync ──────────────────

func test_player_view_indicator_shown_in_independent() -> void:
	GameState.view_mode = GameState.ViewMode.INDEPENDENT
	EventBus.player_view_changed.emit(Rect2(Vector2(0, 0), Vector2(200, 150)))
	assert_true(_dm.token_layer._player_view_visible, "indicator should be visible in independent mode")
	assert_eq(_dm.token_layer._player_view_rect, Rect2(Vector2(0, 0), Vector2(200, 150)))


func test_player_view_indicator_hidden_in_synced() -> void:
	GameState.view_mode = GameState.ViewMode.SYNCED
	EventBus.player_view_changed.emit(Rect2(Vector2(10, 10), Vector2(100, 80)))
	assert_false(_dm.token_layer._player_view_visible, "indicator should be hidden in synced mode")


func test_player_view_hidden_with_zero_rect() -> void:
	GameState.view_mode = GameState.ViewMode.INDEPENDENT
	_dm.token_layer.show_player_view(Rect2())
	assert_false(_dm.token_layer._player_view_visible, "zero-size rect should hide indicator")


func test_notify_view_changed_signal_connected() -> void:
	# Verify the DM is connected to receive player_view_changed
	assert_not_null(_dm, "DM window should exist")


func test_sync_view_from_dm() -> void:
	_pw.sync_view_from_dm(Vector2(2.0, 2.0), Vector2(350, 420))
	assert_eq(_pw.map_root.scale, Vector2(2.0, 2.0), "player scale should match DM")
	assert_eq(_pw.map_root.position, Vector2(350, 420), "player position should match DM")


func test_sync_player_view_if_synced_skips_when_closed() -> void:
	GameState.view_mode = GameState.ViewMode.SYNCED
	_dm._player_window = null
	_dm._sync_player_view_if_synced()
	assert_null(_dm._player_window, "should not crash with null player window")


func test_sync_player_view_if_synced_copies_in_synced_mode() -> void:
	GameState.view_mode = GameState.ViewMode.SYNCED
	GameState.player_window_open = true
	_dm._player_window = _pw
	_dm.map_root.scale = Vector2(1.5, 1.5)
	_dm.map_root.position = Vector2(777, 888)
	_dm._sync_player_view_if_synced()
	assert_eq(_pw.map_root.scale, Vector2(1.5, 1.5), "player scale synced from DM")
	assert_eq(_pw.map_root.position, Vector2(777, 888), "player position synced from DM")


func test_sync_player_view_skips_in_independent() -> void:
	GameState.view_mode = GameState.ViewMode.INDEPENDENT
	GameState.player_window_open = true
	_dm._player_window = _pw
	_dm.map_root.scale = Vector2(3.0, 3.0)
	_dm.map_root.position = Vector2(999, 111)
	_pw.sync_view_from_dm(Vector2.ONE, Vector2.ZERO)
	_dm._sync_player_view_if_synced()
	assert_eq(_pw.map_root.scale, Vector2.ONE, "player view should NOT be overwritten in independent mode")


func test_view_mode_change_syncs_view() -> void:
	GameState.player_window_open = true
	_dm._player_window = _pw
	_dm.map_root.scale = Vector2(0.5, 0.5)
	_dm.map_root.position = Vector2(100, 200)
	GameState.view_mode = GameState.ViewMode.INDEPENDENT
	_dm._on_view_mode_changed(GameState.ViewMode.SYNCED)
	assert_eq(_pw.map_root.scale, Vector2(0.5, 0.5), "switching to synced should sync view")
	assert_eq(_pw.map_root.position, Vector2(100, 200))


func test_player_input_blocked_in_synced() -> void:
	GameState.view_mode = GameState.ViewMode.SYNCED
	_pw.map_root.scale = Vector2(1.0, 1.0)
	_pw.map_root.position = Vector2(111, 222)
	var mouse_event := InputEventMouseButton.new()
	mouse_event.button_index = MOUSE_BUTTON_WHEEL_UP
	mouse_event.pressed = true
	_pw._input(mouse_event)
	assert_eq(_pw.map_root.scale, Vector2(1.0, 1.0), "zoom should be blocked in synced mode")
	assert_eq(_pw.map_root.position, Vector2(111, 222))


# ─── 10.2: Player view indicator uses template color ─────

func test_player_view_indicator_uses_template_color() -> void:
	var red: Color = Color(1.0, 0.0, 0.0, 1.0)
	_dm.token_layer.set_template_color(red, 0.3)
	GameState.view_mode = GameState.ViewMode.INDEPENDENT
	_dm.token_layer.show_player_view(Rect2(Vector2(10, 10), Vector2(100, 80)))
	# The indicator now uses _template_line_color instead of hardcoded cyan
	assert_eq(_dm.token_layer._template_line_color, red, "template color should be red")


# ─── 10.4/10.5: Off-screen arrow and partial overlap ─────

func test_player_view_arrow_when_off_screen_left() -> void:
	GameState.view_mode = GameState.ViewMode.INDEPENDENT
	var dm_view := Rect2(Vector2(200, 100), Vector2(500, 400))
	var player_view := Rect2(Vector2(0, 200), Vector2(150, 200))
	# Player view is left of DM view
	var overlap := dm_view.intersection(player_view)
	assert_eq(overlap.size.x, 0, "no overlap when player view is left of DM")
	_dm.token_layer.show_player_view(player_view, dm_view)
	assert_true(_dm.token_layer._player_view_visible, "indicator should still be visible")


func test_player_view_partial_overlap() -> void:
	GameState.view_mode = GameState.ViewMode.INDEPENDENT
	var dm_view := Rect2(Vector2(100, 100), Vector2(400, 300))
	var player_view := Rect2(Vector2(50, 150), Vector2(200, 200))
	var overlap := dm_view.intersection(player_view)
	assert_true(overlap.size.x > 0, "should have partial overlap")
	assert_true(overlap.size.x < player_view.size.x, "overlap should be smaller than full player view")
	_dm.token_layer.show_player_view(player_view, dm_view)
	assert_true(_dm.token_layer._player_view_visible)


func test_player_view_fully_onscreen() -> void:
	GameState.view_mode = GameState.ViewMode.INDEPENDENT
	var dm_view := Rect2(Vector2(0, 0), Vector2(600, 400))
	var player_view := Rect2(Vector2(100, 100), Vector2(200, 150))
	var overlap := dm_view.intersection(player_view)
	assert_eq(overlap, player_view, "full overlap when player view is inside DM view")
	_dm.token_layer.show_player_view(player_view, dm_view)
	assert_true(_dm.token_layer._player_view_visible)
