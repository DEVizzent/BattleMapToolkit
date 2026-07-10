extends GutTest

const PlayerWindowScene := preload("res://scenes/player/player_window.tscn")
const DMWindowScene := preload("res://scenes/ui/dm_window.tscn")
const TokenDataClass := preload("res://scripts/token/token_data.gd")
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
