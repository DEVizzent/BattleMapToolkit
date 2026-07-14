extends GutTest

const DMWindowScene := preload("res://scenes/ui/dm_window.tscn")
const VisionBlockerDataClass := preload("res://scripts/fog/vision_blocker_data.gd")
const GameStateClass := preload("res://scripts/core/game_state.gd")

var _dm: Control


func before_each() -> void:
	_dm = DMWindowScene.instantiate()
	add_child_autofree(_dm)
	await get_tree().process_frame
	GameState.map_vision_blockers.clear()
	GameState.current_map_index = -1
	await get_tree().process_frame


# ─── VisionBlockerData unit tests ─────────────────────────

func test_blocker_data_defaults() -> void:
	var vb := VisionBlockerDataClass.new()
	assert_eq(vb.id, "")
	assert_eq(vb.points.size(), 0)
	assert_true(vb.active)
	assert_ne(vb.color.a, 0.0)


func test_blocker_data_to_dict() -> void:
	var vb := VisionBlockerDataClass.new()
	vb.id = "vb_test"
	vb.points = [Vector2(10, 20), Vector2(30, 40)]
	vb.active = false
	vb.color = Color(1, 0, 0, 0.5)
	var d := vb.to_dict()
	assert_eq(d["id"], "vb_test")
	assert_eq(d["points"].size(), 2)
	assert_eq(d["points"][0]["x"], 10.0)
	assert_eq(d["points"][1]["y"], 40.0)
	assert_false(d["active"])
	assert_eq(d["color"]["r"], 1.0)


func test_blocker_data_from_dict_roundtrip() -> void:
	var vb := VisionBlockerDataClass.new()
	vb.id = "vb_roundtrip"
	vb.points = [Vector2(100, 200), Vector2(300, 400), Vector2(500, 600)]
	vb.active = false
	vb.color = Color(0.2, 0.8, 0.4, 0.9)
	var d := vb.to_dict()
	var vb2 := VisionBlockerDataClass.from_dict(d)
	assert_eq(vb2.id, "vb_roundtrip")
	assert_eq(vb2.points.size(), 3)
	assert_eq(vb2.points[1].x, 300.0)
	assert_false(vb2.active)
	assert_almost_eq(vb2.color.g, 0.8, 0.001)


func test_blocker_data_create_id() -> void:
	var id1: String = VisionBlockerDataClass.create_id()
	await get_tree().process_frame
	var id2: String = VisionBlockerDataClass.create_id()
	assert_string_contains(id1, "vb_")
	assert_ne(id1, id2)


# ─── GameState blocker helpers ────────────────────────────

func test_game_state_blockers_empty_by_default() -> void:
	var blockers := GameState.get_current_vision_blockers()
	assert_eq(blockers.size(), 0)


func test_game_state_blockers_per_map_isolation() -> void:
	GameState.current_map_index = 0
	var vb := VisionBlockerDataClass.new()
	vb.id = "vb_map0"
	GameState.get_current_vision_blockers().append(vb)
	assert_eq(GameState.get_current_vision_blockers().size(), 1)

	GameState.current_map_index = 1
	assert_eq(GameState.get_current_vision_blockers().size(), 0)

	GameState.current_map_index = 0
	assert_eq(GameState.get_current_vision_blockers().size(), 1)


func test_game_state_blockers_serialization() -> void:
	GameState.current_map_index = 0
	var vb := VisionBlockerDataClass.new()
	vb.id = "vb_serial"
	vb.points = [Vector2(50, 60), Vector2(70, 80)]
	vb.active = true
	GameState.get_current_vision_blockers().append(vb)

	var d := GameState.to_dict()
	assert_true(d.has("vision_blockers"))

	GameState._clear_all()
	assert_eq(GameState.get_current_vision_blockers().size(), 0)

	GameState.from_dict(d)
	GameState.current_map_index = 0
	var restored := GameState.get_current_vision_blockers()
	assert_eq(restored.size(), 1)
	assert_eq(restored[0].id, "vb_serial")
	assert_eq(restored[0].points.size(), 2)
	assert_true(restored[0].active)


# ─── Point-to-segment distance ────────────────────────────

func test_point_to_segment_on_segment() -> void:
	var p := Vector2(5, 5)
	var a := Vector2(0, 5)
	var b := Vector2(10, 5)
	var d: float = _dm._point_to_segment_distance(p, a, b)
	assert_lt(d, 0.01)


func test_point_to_segment_off_segment() -> void:
	var p := Vector2(5, 10)
	var a := Vector2(0, 0)
	var b := Vector2(10, 0)
	var d: float = _dm._point_to_segment_distance(p, a, b)
	assert_eq(d, 10.0)


func test_point_to_segment_beyond_endpoint() -> void:
	var p := Vector2(15, 0)
	var a := Vector2(0, 0)
	var b := Vector2(10, 0)
	var d: float = _dm._point_to_segment_distance(p, a, b)
	assert_eq(d, 5.0)


func test_point_to_segment_zero_length() -> void:
	var p := Vector2(3, 4)
	var a := Vector2(0, 0)
	var b := Vector2(0, 0)
	var d: float = _dm._point_to_segment_distance(p, a, b)
	assert_eq(d, 5.0)


# ─── DM Window blocker mode ───────────────────────────────

func test_blocker_btn_exists() -> void:
	assert_not_null(_dm.blocker_btn)
	assert_eq(_dm.blocker_btn.text, "Bloqueadores")


func test_blocker_mode_toggles_on_off() -> void:
	assert_false(_dm._blocker_mode)
	_dm.blocker_btn.button_pressed = true
	_dm._on_blocker_pressed()
	assert_true(_dm._blocker_mode)
	assert_true(_dm.blocker_btn.button_pressed)

	_dm._on_blocker_pressed()
	assert_false(_dm._blocker_mode)


func test_blocker_add_point_snaps_to_grid() -> void:
	GameState.current_map_index = 0
	var gd := GameState.get_current_grid()
	gd.size_px = 70.0
	gd.origin = Vector2.ZERO

	_dm._on_blocker_pressed()
	_dm.map_sprite.texture = null
	_dm.map_root.scale = Vector2.ONE
	_dm.map_root.position = Vector2.ZERO

	var point := Vector2(85, 85)
	var snapped: Vector2 = _dm._snap_to_grid(point, gd.size_px, gd.origin, 1)
	var expected_x: float = floor(85.0 / 70.0) * 70.0 + 35.0
	assert_eq(snapped.x, expected_x)
	assert_eq(snapped.y, expected_x)


func test_blocker_finish_with_1_point_does_nothing() -> void:
	_dm._on_blocker_pressed()
	_dm._current_blocker_points.append(Vector2(100, 100))
	_dm._finish_current_blocker()
	assert_eq(GameState.get_current_vision_blockers().size(), 0)
	assert_eq(_dm._current_blocker_points.size(), 1)


func test_blocker_finish_with_2_points_creates_blocker() -> void:
	_dm._on_blocker_pressed()
	_dm._current_blocker_points = [Vector2(100, 100), Vector2(200, 200)]
	_dm._finish_current_blocker()
	assert_eq(GameState.get_current_vision_blockers().size(), 1)
	assert_eq(GameState.get_current_vision_blockers()[0].points.size(), 2)
	assert_eq(_dm._current_blocker_points.size(), 0)


func test_blocker_cancel_clears_points() -> void:
	_dm._on_blocker_pressed()
	_dm._current_blocker_points = [Vector2(100, 100), Vector2(200, 200), Vector2(300, 300)]
	_dm._cancel_blocker_drawing()
	assert_eq(_dm._current_blocker_points.size(), 0)


func test_blocker_select_sets_id() -> void:
	var vb := VisionBlockerDataClass.new()
	vb.id = "vb_select_test"
	vb.points = [Vector2(0, 0), Vector2(100, 100)]
	GameState.current_map_index = 0
	GameState.get_current_vision_blockers().append(vb)

	_dm._on_blocker_pressed()
	_dm._select_blocker("vb_select_test")
	assert_eq(_dm._selected_blocker_id, "vb_select_test")
	assert_false(_dm.blocker_delete_btn.disabled)


func test_blocker_deselect_clears_id() -> void:
	_dm._on_blocker_pressed()
	_dm._select_blocker("something")
	_dm._select_blocker("")
	assert_eq(_dm._selected_blocker_id, "")
	assert_true(_dm.blocker_delete_btn.disabled)


func test_blocker_delete_removes_from_game_state() -> void:
	var vb := VisionBlockerDataClass.new()
	vb.id = "vb_delete_me"
	vb.points = [Vector2(0, 0), Vector2(100, 100)]
	GameState.current_map_index = 0
	GameState.get_current_vision_blockers().append(vb)

	_dm._on_blocker_pressed()
	_dm._select_blocker("vb_delete_me")
	_dm._delete_selected_blocker()
	assert_eq(GameState.get_current_vision_blockers().size(), 0)
	assert_eq(_dm._selected_blocker_id, "")


func test_blocker_toggle_active() -> void:
	var vb := VisionBlockerDataClass.new()
	vb.id = "vb_toggle_me"
	vb.points = [Vector2(0, 0), Vector2(100, 100)]
	vb.active = true
	GameState.current_map_index = 0
	GameState.get_current_vision_blockers().append(vb)

	_dm._on_blocker_pressed()
	_dm._select_blocker("vb_toggle_me")
	_dm._on_blocker_toggle_active()
	assert_false(GameState.get_current_vision_blockers()[0].active)

	_dm._on_blocker_toggle_active()
	assert_true(GameState.get_current_vision_blockers()[0].active)


func test_find_blocker_near_returns_id() -> void:
	var vb := VisionBlockerDataClass.new()
	vb.id = "vb_near"
	vb.points = [Vector2(0, 0), Vector2(100, 100)]
	GameState.current_map_index = 0
	GameState.get_current_vision_blockers().append(vb)

	var mid := Vector2(50, 50)
	var found: String = _dm._find_blocker_near(mid, 10.0)
	assert_eq(found, "vb_near")


func test_find_blocker_near_far_away_returns_empty() -> void:
	var vb := VisionBlockerDataClass.new()
	vb.id = "vb_far"
	vb.points = [Vector2(0, 0), Vector2(100, 0)]
	GameState.current_map_index = 0
	GameState.get_current_vision_blockers().append(vb)

	var far := Vector2(500, 500)
	var found: String = _dm._find_blocker_near(far, 10.0)
	assert_eq(found, "")


func test_blocker_toolbar_hidden_when_mode_off() -> void:
	assert_false(_dm.blocker_toolbar.visible)

	_dm._on_blocker_pressed()
	assert_true(_dm.blocker_toolbar.visible)

	_dm._on_blocker_pressed()
	assert_false(_dm.blocker_toolbar.visible)


func test_blocker_color_picker_exists() -> void:
	assert_not_null(_dm.blocker_color_picker)
	assert_almost_eq(_dm.blocker_color_picker.color.a, 0.7, 0.001)
