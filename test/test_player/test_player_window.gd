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
