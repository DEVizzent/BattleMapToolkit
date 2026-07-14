extends GutTest

const PlayerWindowScene := preload("res://scenes/player/player_window.tscn")
const DMWindowScene := preload("res://scenes/ui/dm_window.tscn")
const TokenDataClass := preload("res://scripts/token/token_data.gd")
const TokenSpriteClass := preload("res://scripts/token/token_sprite.gd")
const GridDataClass := preload("res://scripts/grid/grid_data.gd")

var _dm: Control
var _pw: Window

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


func _make_token(px: float = 70.0) -> Sprite2D:
	var td := TokenDataClass.new()
	td.size_cells = 1.0
	var sprite := TokenSpriteClass.new()
	sprite.apply_data(td, px)
	return sprite


# ─── DM: 1-finger tap on token selects it ─────────────────

func test_dm_touch_tap_on_token_selects() -> void:
	var sprite := _make_token()
	sprite.position = Vector2(100, 100)
	_dm.token_layer.add_child(sprite)
	_dm.map_root.scale = Vector2(1.0, 1.0)
	_dm.map_root.position = Vector2.ZERO
	var touch := InputEventScreenTouch.new()
	touch.index = 0
	touch.pressed = true
	touch.position = _dm.map_viewport.global_position + Vector2(100, 100)
	_dm._handle_touch(touch)
	assert_not_null(_dm._selected_token, "selected_token should be set after touching token")
	assert_true(_dm._touch_on_token, "_touch_on_token should be true")


func test_dm_touch_tap_on_empty_deselects() -> void:
	var sprite := _make_token()
	sprite.position = Vector2(100, 100)
	_dm.token_layer.add_child(sprite)
	_dm._select_token(sprite)
	_dm.map_root.scale = Vector2(1.0, 1.0)
	_dm.map_root.position = Vector2.ZERO
	var touch := InputEventScreenTouch.new()
	touch.index = 0
	touch.pressed = true
	touch.position = _dm.map_viewport.global_position + Vector2(500, 500)
	_dm._handle_touch(touch)
	assert_false(_dm._touch_on_token, "_touch_on_token should be false after touching empty space")


# ─── DM: 1-finger drag moves token ───────────────────────

func test_dm_touch_drag_moves_token() -> void:
	_dm.size = Vector2(800, 600)
	var sprite := _make_token()
	sprite.position = Vector2(100, 100)
	_dm.token_layer.add_child(sprite)
	_dm.map_root.scale = Vector2(1.0, 1.0)
	_dm.map_root.position = Vector2.ZERO
	var touch_down := InputEventScreenTouch.new()
	touch_down.index = 0
	touch_down.pressed = true
	touch_down.position = _dm.map_viewport.global_position + Vector2(100, 100)
	_dm._handle_touch(touch_down)
	# First drag initializes, second actually moves
	var drag1 := InputEventScreenDrag.new()
	drag1.index = 0
	drag1.position = _dm.map_viewport.global_position + Vector2(200, 200)
	_dm._handle_drag(drag1)
	var drag2 := InputEventScreenDrag.new()
	drag2.index = 0
	drag2.position = _dm.map_viewport.global_position + Vector2(250, 250)
	_dm._handle_drag(drag2)
	assert_ne(sprite.position, Vector2(100, 100), "token should have moved")


# ─── DM: 2-finger pinch zoom ─────────────────────────────

func test_dm_pinch_zoom_changes_scale() -> void:
	_dm.size = Vector2(800, 600)
	_dm.map_root.scale = Vector2(1.0, 1.0)
	_dm._touch_pinch_dist = 100.0
	_dm._touch_pinch_scale = 1.0
	_dm._touch_pinch_center = Vector2(250, 200)
	_dm._touch1_idx = 0
	_dm._touch2_idx = 1
	_dm._touch1_pos = Vector2(200, 200)
	_dm._touch2_pos = Vector2(300, 200)
	var drag := InputEventScreenDrag.new()
	drag.index = 1
	drag.position = _dm.map_viewport.global_position + Vector2(360, 200)
	_dm._handle_drag(drag)
	assert_gt(_dm.map_root.scale.x, 1.0, "zoom should increase on pinch spread")


# ─── DM: 2-finger parallel pan ───────────────────────────

func test_dm_two_finger_pan_moves_map() -> void:
	_dm.size = Vector2(800, 600)
	_dm._touch_pinch_dist = 100.0
	_dm._touch_pinch_scale = 1.0
	_dm._touch1_idx = 0
	_dm._touch2_idx = 1
	var start_pos: Vector2 = _dm.map_root.position
	_dm._touch1_pos = Vector2(100, 100)
	_dm._touch2_pos = Vector2(200, 100)
	var drag := InputEventScreenDrag.new()
	drag.index = 0
	drag.position = _dm.map_viewport.global_position + Vector2(110, 100)
	_dm._handle_drag(drag)
	var drag2 := InputEventScreenDrag.new()
	drag2.index = 1
	drag2.position = _dm.map_viewport.global_position + Vector2(210, 100)
	_dm._handle_drag(drag2)
	assert_ne(_dm.map_root.position, start_pos, "map should have moved on parallel pan")


# ─── Player: 1-finger touch on token starts drag ────────

func test_pw_touch_on_token_starts_drag() -> void:
	_pw.size = Vector2(800, 600)
	var sprite := _make_token()
	sprite.position = Vector2(50, 50)
	_pw.token_layer.add_child(sprite)
	_pw.map_root.scale = Vector2(1.0, 1.0)
	_pw.map_root.position = Vector2.ZERO
	var touch := InputEventScreenTouch.new()
	touch.index = 0
	touch.pressed = true
	touch.position = Vector2(50, 50)
	_pw._handle_touch(touch)
	assert_true(_pw._touch_on_token, "player _touch_on_token should be true")
	assert_not_null(_pw._drag_sprite, "player _drag_sprite should be set")


# ─── Player: 1-finger drag moves token ──────────────────

func test_pw_touch_drag_moves_token() -> void:
	_pw.size = Vector2(800, 600)
	var sprite := _make_token()
	sprite.position = Vector2(50, 50)
	_pw.token_layer.add_child(sprite)
	_pw.map_root.scale = Vector2(1.0, 1.0)
	_pw.map_root.position = Vector2.ZERO
	_pw._grid_data = GridDataClass.new()
	_pw._grid_data.size_px = 70.0
	var touch_down := InputEventScreenTouch.new()
	touch_down.index = 0
	touch_down.pressed = true
	touch_down.position = Vector2(50, 50)
	_pw._handle_touch(touch_down)
	_pw._touch_on_token = true
	_pw._dragging_token = true
	_pw._drag_offset = Vector2.ZERO
	_pw._drag_start_pos = sprite.position
	var drag := InputEventScreenDrag.new()
	drag.index = 0
	drag.position = Vector2(200, 200)
	_pw._handle_drag(drag)
	assert_ne(sprite.position, Vector2(50, 50), "player token should have moved")


# ─── Player: token snap on touch drag ───────────────────

func test_pw_touch_drag_snaps_token() -> void:
	_pw.size = Vector2(800, 600)
	var sprite := _make_token()
	sprite.position = Vector2(70, 70)
	_pw.token_layer.add_child(sprite)
	_pw.map_root.scale = Vector2(1.0, 1.0)
	_pw.map_root.position = Vector2.ZERO
	_pw._grid_data = GridDataClass.new()
	_pw._grid_data.size_px = 70.0
	_pw._grid_data.origin = Vector2.ZERO
	_pw._touch1_index = 0
	_pw._touch2_index = -1
	_pw._touch_on_token = true
	_pw._dragging_token = true
	_pw._drag_sprite = sprite
	_pw._drag_offset = Vector2.ZERO
	_pw._drag_start_pos = sprite.position
	var drag := InputEventScreenDrag.new()
	drag.index = 0
	drag.position = Vector2(85, 85)
	_pw._handle_drag(drag)
	assert_eq(sprite.position.x, 105.0, "token should snap to cell center")
	assert_eq(sprite.position.y, 105.0)


# ─── Player: 2-finger pinch zoom ────────────────────────

func test_pw_pinch_zoom_changes_scale() -> void:
	_pw.size = Vector2(800, 600)
	_pw.map_root.scale = Vector2(1.0, 1.0)
	_pw._pinch_start_dist = 100.0
	_pw._pinch_start_scale = 1.0
	_pw._pinch_center = Vector2(250, 200)
	_pw._touch1_index = 0
	_pw._touch2_index = 1
	_pw._touch1_pos = Vector2(200, 200)
	_pw._touch2_pos = Vector2(300, 200)
	var drag := InputEventScreenDrag.new()
	drag.index = 1
	drag.position = Vector2(360, 200)
	_pw._handle_drag(drag)
	assert_gt(_pw.map_root.scale.x, 1.0, "player zoom should increase on pinch spread")


# ─── Player: 2-finger parallel pan ──────────────────────

func test_pw_two_finger_pan_moves_map() -> void:
	_pw.size = Vector2(800, 600)
	_pw._pinch_start_dist = 100.0
	_pw._pinch_start_scale = 1.0
	_pw._touch1_index = 0
	_pw._touch2_index = 1
	var start_pos: Vector2 = _pw.map_root.position
	_pw._touch1_pos = Vector2(100, 100)
	_pw._touch2_pos = Vector2(200, 100)
	var drag := InputEventScreenDrag.new()
	drag.index = 0
	drag.position = Vector2(110, 100)
	_pw._handle_drag(drag)
	var drag2 := InputEventScreenDrag.new()
	drag2.index = 1
	drag2.position = Vector2(210, 100)
	_pw._handle_drag(drag2)
	assert_ne(_pw.map_root.position, start_pos, "player map should move on parallel pan")


# ─── Viewport bounds checks ─────────────────────────────

func test_dm_touch_outside_viewport_ignored() -> void:
	var touch := InputEventScreenTouch.new()
	touch.index = 0
	touch.pressed = true
	touch.position = Vector2(-100, -100)
	var result: bool = _dm._is_touch_over_viewport(touch)
	assert_false(result, "touch outside viewport should not be detected")


func test_pw_touch_outside_viewport_ignored() -> void:
	var result: bool = _pw._touch_in_viewport(Vector2(-50, -50))
	assert_false(result, "touch outside player viewport should be ignored")
	var result2: bool = _pw._touch_in_viewport(Vector2(100, 100))
	assert_true(result2, "touch inside player viewport should be accepted")


# ─── DM: 1-finger release stops drag ─────────────────────

func test_dm_touch_release_stops_drag() -> void:
	var sprite := _make_token()
	sprite.position = Vector2(100, 100)
	_dm.token_layer.add_child(sprite)
	_dm.map_root.scale = Vector2(1.0, 1.0)
	_dm.map_root.position = Vector2.ZERO
	_dm._touch1_idx = 0
	_dm._touch2_idx = -1
	_dm._touch_on_token = true
	_dm._touch_drag_initialized = true
	_dm._selected_token = sprite
	_dm._selected_tokens = [sprite]
	_dm._dragging_token = true
	_dm._drag_start_pos = sprite.position
	_dm._save_drag_start_positions()
	var touch_up := InputEventScreenTouch.new()
	touch_up.index = 0
	touch_up.pressed = false
	touch_up.position = Vector2(100, 100)
	_dm._handle_touch(touch_up)
	assert_false(_dm._dragging_token, "should stop dragging on release")


# ─── 2-finger zoom keeps same center ────────────────────

func test_dm_pinch_zoom_preserves_center() -> void:
	_dm.size = Vector2(800, 600)
	_dm.map_root.scale = Vector2(1.0, 1.0)
	_dm.map_root.position = Vector2.ZERO
	_dm._touch_pinch_dist = 100.0
	_dm._touch_pinch_scale = 1.0
	_dm._touch_pinch_center = Vector2(300, 200)
	_dm._touch1_idx = 0
	_dm._touch2_idx = 1
	_dm._touch1_pos = Vector2(250, 200)
	_dm._touch2_pos = Vector2(350, 200)
	var world_before: Vector2 = (_dm._touch_pinch_center - _dm.map_root.position) / _dm.map_root.scale.x
	var drag := InputEventScreenDrag.new()
	drag.index = 1
	drag.position = _dm.map_viewport.global_position + Vector2(450, 200)
	_dm._handle_drag(drag)
	var world_after: Vector2 = (_dm._touch_pinch_center - _dm.map_root.position) / _dm.map_root.scale.x
	assert_almost_eq(world_after.x, world_before.x, 0.01, "zoom should keep center fixed")


# ─── Reset state after 2-finger sequence ends ───────────

func test_dm_second_finger_lift_resets_state() -> void:
	_dm._touch1_idx = 0
	_dm._touch2_idx = 1
	_dm._touch1_pos = Vector2(100, 100)
	_dm._touch2_pos = Vector2(200, 200)
	_dm._touch_pinch_dist = 141.0
	var touch_up := InputEventScreenTouch.new()
	touch_up.index = 1
	touch_up.pressed = false
	_dm._handle_touch(touch_up)
	assert_eq(_dm._touch2_idx, -1, "touch2 should be cleared after second finger lifts")
	assert_eq(_dm._touch_pinch_dist, 0.0, "pinch dist reset after second finger lifts")
	assert_false(_dm._touch_two_pan, "two pan reset after second finger lifts")
