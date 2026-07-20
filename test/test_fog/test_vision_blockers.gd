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
	var gd := GameState.get_current_grid()
	gd.size_px = 70.0
	gd.origin = Vector2.ZERO

	var snapped: Vector2 = _dm._snap_to_half_grid(Vector2(30, 30), gd.size_px, gd.origin)
	assert_eq(snapped.x, 35.0)
	assert_eq(snapped.y, 35.0)

	var corner: Vector2 = _dm._snap_to_half_grid(Vector2(72, 72), gd.size_px, gd.origin)
	assert_eq(corner.x, 70.0)
	assert_eq(corner.y, 70.0)

	var center: Vector2 = _dm._snap_to_half_grid(Vector2(100, 100), gd.size_px, gd.origin)
	assert_eq(center.x, 105.0)
	assert_eq(center.y, 105.0)


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


func test_find_blocker_point_near_returns_index() -> void:
	var vb := VisionBlockerDataClass.new()
	vb.id = "vb_points"
	vb.points = [Vector2(0, 0), Vector2(50, 50), Vector2(100, 0)]
	GameState.current_map_index = 0
	GameState.get_current_vision_blockers().append(vb)

	assert_eq(_dm._find_blocker_point_near("vb_points", Vector2(3, 3), 10.0), 0)
	assert_eq(_dm._find_blocker_point_near("vb_points", Vector2(48, 48), 10.0), 1)
	assert_eq(_dm._find_blocker_point_near("vb_points", Vector2(200, 200), 10.0), -1)


func test_blocker_point_drag_updates_position() -> void:
	var vb := VisionBlockerDataClass.new()
	vb.id = "vb_drag"
	vb.points = [Vector2(0, 0), Vector2(100, 0)]
	GameState.current_map_index = 0
	GameState.get_current_vision_blockers().append(vb)

	_dm._on_blocker_pressed()
	_dm._select_blocker("vb_drag")
	_dm._start_dragging_blocker_point(0)

	var blockers: Array = GameState.get_current_vision_blockers()
	blockers[0].points[0] = Vector2(35, 35)
	_dm._refresh_blocker_display()
	_dm._finish_dragging_blocker_point()

	var updated: Array = GameState.get_current_vision_blockers()
	assert_eq(updated[0].points[0].x, 35.0)
	assert_eq(updated[0].points[0].y, 35.0)
	assert_false(_dm._dragging_blocker_point)


func test_blocker_point_drag_cancel_reverts_position() -> void:
	var vb := VisionBlockerDataClass.new()
	vb.id = "vb_revert"
	vb.points = [Vector2(0, 0), Vector2(100, 0)]
	GameState.current_map_index = 0
	GameState.get_current_vision_blockers().append(vb)

	_dm._on_blocker_pressed()
	_dm._select_blocker("vb_revert")
	_dm._start_dragging_blocker_point(1)

	var blockers: Array = GameState.get_current_vision_blockers()
	blockers[0].points[1] = Vector2(200, 200)
	_dm._cancel_dragging_blocker_point()

	var reverted: Array = GameState.get_current_vision_blockers()
	assert_eq(reverted[0].points[1].x, 100.0)
	assert_eq(reverted[0].points[1].y, 0.0)
	assert_false(_dm._dragging_blocker_point)


func test_blocker_toolbar_hidden_when_mode_off() -> void:
	assert_false(_dm.blocker_toolbar.visible)

	_dm._on_blocker_pressed()
	assert_true(_dm.blocker_toolbar.visible)

	_dm._on_blocker_pressed()
	assert_false(_dm.blocker_toolbar.visible)


func test_blocker_color_picker_exists() -> void:
	assert_not_null(_dm.blocker_color_picker)
	assert_almost_eq(_dm.blocker_color_picker.color.a, 0.7, 0.001)


# ─── Interaction flow ──────────────────────────────────────

func test_click_empty_starts_drawing_when_no_selection() -> void:
	_dm._on_blocker_pressed()
	_dm._current_blocker_points = []
	_dm._selected_blocker_id = ""

	assert_eq(_dm._current_blocker_points.size(), 0)
	_dm._add_blocker_point()
	assert_eq(_dm._current_blocker_points.size(), 1)


func test_click_empty_deselects_when_blocker_selected() -> void:
	var vb := VisionBlockerDataClass.new()
	vb.id = "vb_deselect"
	vb.points = [Vector2(0, 0), Vector2(100, 100)]
	GameState.current_map_index = 0
	GameState.get_current_vision_blockers().append(vb)

	_dm._on_blocker_pressed()
	_dm._select_blocker("vb_deselect")
	assert_eq(_dm._selected_blocker_id, "vb_deselect")

	_dm._select_blocker("")
	assert_eq(_dm._selected_blocker_id, "")
	assert_true(_dm.blocker_delete_btn.disabled)


func test_switch_selection_between_blockers() -> void:
	var vb_a := VisionBlockerDataClass.new()
	vb_a.id = "vb_a"
	vb_a.points = [Vector2(0, 0), Vector2(50, 50)]
	var vb_b := VisionBlockerDataClass.new()
	vb_b.id = "vb_b"
	vb_b.points = [Vector2(100, 0), Vector2(150, 50)]
	GameState.current_map_index = 0
	var blockers: Array = GameState.get_current_vision_blockers()
	blockers.append(vb_a)
	blockers.append(vb_b)

	_dm._on_blocker_pressed()
	_dm._select_blocker("vb_a")
	assert_eq(_dm._selected_blocker_id, "vb_a")

	_dm._select_blocker("vb_b")
	assert_eq(_dm._selected_blocker_id, "vb_b")


func test_add_point_deselects_blocker() -> void:
	var vb := VisionBlockerDataClass.new()
	vb.id = "vb_draw_deselect"
	vb.points = [Vector2(0, 0), Vector2(100, 0)]
	GameState.current_map_index = 0
	GameState.get_current_vision_blockers().append(vb)

	_dm._on_blocker_pressed()
	_dm._select_blocker("vb_draw_deselect")
	assert_eq(_dm._selected_blocker_id, "vb_draw_deselect")

	_dm._current_blocker_points = [Vector2(200, 200)]
	_dm._add_blocker_point()
	assert_eq(_dm._selected_blocker_id, "")


# ─── Mode transitions and keyboard ─────────────────────────

func test_blocker_btn_while_drawing_finishes_first() -> void:
	_dm._on_blocker_pressed()
	_dm._current_blocker_points = [Vector2(100, 100), Vector2(200, 200)]
	assert_eq(GameState.get_current_vision_blockers().size(), 0)

	_dm._on_blocker_pressed()
	assert_eq(GameState.get_current_vision_blockers().size(), 1)
	assert_false(_dm._blocker_mode)


func test_esc_cancels_drawing() -> void:
	_dm._on_blocker_pressed()
	_dm._current_blocker_points = [Vector2(100, 100), Vector2(200, 200), Vector2(300, 300)]
	assert_eq(_dm._current_blocker_points.size(), 3)

	var event := InputEventKey.new()
	event.keycode = KEY_ESCAPE
	event.pressed = true
	_dm._input(event)

	assert_eq(_dm._current_blocker_points.size(), 0)


func test_esc_exits_blocker_mode() -> void:
	_dm._on_blocker_pressed()
	assert_true(_dm._blocker_mode)

	var event := InputEventKey.new()
	event.keycode = KEY_ESCAPE
	event.pressed = true
	_dm._input(event)

	assert_false(_dm._blocker_mode)


func test_delete_key_removes_selected_blocker() -> void:
	var vb := VisionBlockerDataClass.new()
	vb.id = "vb_del_key"
	vb.points = [Vector2(0, 0), Vector2(100, 100)]
	GameState.current_map_index = 0
	GameState.get_current_vision_blockers().append(vb)

	_dm._on_blocker_pressed()
	_dm._select_blocker("vb_del_key")
	assert_eq(GameState.get_current_vision_blockers().size(), 1)

	var event := InputEventKey.new()
	event.keycode = KEY_DELETE
	event.pressed = true
	_dm._input(event)

	assert_eq(GameState.get_current_vision_blockers().size(), 0)


func test_delete_key_cancels_drawing_when_no_selection() -> void:
	_dm._on_blocker_pressed()
	_dm._current_blocker_points = [Vector2(100, 100), Vector2(200, 200)]

	var event := InputEventKey.new()
	event.keycode = KEY_DELETE
	event.pressed = true
	_dm._input(event)

	assert_eq(_dm._current_blocker_points.size(), 0)


# ─── Toggle and delete guards ──────────────────────────────

func test_toggle_active_ignored_without_selection() -> void:
	_dm._on_blocker_pressed()
	_dm._selected_blocker_id = ""
	_dm._on_blocker_toggle_active()
	assert_eq(_dm._selected_blocker_id, "")


func test_toggle_updates_button_text() -> void:
	var vb := VisionBlockerDataClass.new()
	vb.id = "vb_toggle_text"
	vb.points = [Vector2(0, 0), Vector2(100, 100)]
	vb.active = true
	GameState.current_map_index = 0
	GameState.get_current_vision_blockers().append(vb)

	_dm._on_blocker_pressed()
	_dm._select_blocker("vb_toggle_text")
	assert_string_contains(_dm.blocker_toggle_active_btn.text, "esactivar")

	_dm._on_blocker_toggle_active()
	assert_string_contains(_dm.blocker_toggle_active_btn.text, "ctivar")


func test_delete_guard_no_selection() -> void:
	_dm._on_blocker_pressed()
	_dm._selected_blocker_id = ""
	var count: int = GameState.get_current_vision_blockers().size()
	_dm._delete_selected_blocker()
	assert_eq(GameState.get_current_vision_blockers().size(), count)


func test_delete_button_press_integration() -> void:
	var vb := VisionBlockerDataClass.new()
	vb.id = "vb_btn_delete"
	vb.points = [Vector2(0, 0), Vector2(100, 100)]
	GameState.current_map_index = 0
	GameState.get_current_vision_blockers().append(vb)

	_dm._on_blocker_pressed()
	_dm._select_blocker("vb_btn_delete")
	assert_eq(GameState.get_current_vision_blockers().size(), 1)

	_dm._on_blocker_delete_selected()
	assert_eq(GameState.get_current_vision_blockers().size(), 0)


# ─── _make_blocker_data ────────────────────────────────────

func test_make_blocker_data_creates_valid_resource() -> void:
	var points: Array = [Vector2(10, 20), Vector2(30, 40)]
	var vb: Resource = _dm._make_blocker_data(points)
	assert_string_contains(vb.id, "vb_")
	assert_eq(vb.points.size(), 2)
	assert_eq(vb.points[0].x, 10.0)
	assert_true(vb.active)
	assert_eq(vb.color, _dm._blocker_color)


# ─── Signals emitted ───────────────────────────────────────

func test_vision_blocker_added_signal_on_finish() -> void:
	_dm._on_blocker_pressed()
	_dm._current_blocker_points = [Vector2(100, 100), Vector2(200, 200)]
	var captured: Dictionary = {}
	EventBus.vision_blocker_added.connect(func(id): captured["id"] = id)
	_dm._finish_current_blocker()
	assert_ne(captured.get("id", ""), "")


func test_vision_blocker_removed_signal_on_delete() -> void:
	var vb := VisionBlockerDataClass.new()
	vb.id = "vb_signal_rm"
	vb.points = [Vector2(0, 0), Vector2(100, 100)]
	GameState.current_map_index = 0
	GameState.get_current_vision_blockers().append(vb)

	_dm._on_blocker_pressed()
	_dm._select_blocker("vb_signal_rm")
	var captured: Dictionary = {}
	EventBus.vision_blocker_removed.connect(func(id): captured["id"] = id)
	_dm._delete_selected_blocker()
	assert_eq(captured.get("id", ""), "vb_signal_rm")


func test_vision_blocker_toggled_signal() -> void:
	var vb := VisionBlockerDataClass.new()
	vb.id = "vb_signal_tg"
	vb.points = [Vector2(0, 0), Vector2(100, 100)]
	vb.active = true
	GameState.current_map_index = 0
	GameState.get_current_vision_blockers().append(vb)

	_dm._on_blocker_pressed()
	_dm._select_blocker("vb_signal_tg")
	var captured: Dictionary = {}
	EventBus.vision_blocker_toggled.connect(func(id, active):
		captured["id"] = id
		captured["active"] = active
	)
	_dm._on_blocker_toggle_active()
	assert_eq(captured.get("id", ""), "vb_signal_tg")
	assert_false(captured.get("active", true))


# ─── GameState.mark_dirty on changes ───────────────────────

func test_mark_dirty_on_blocker_create() -> void:
	GameState.mark_clean()
	assert_false(GameState.session_dirty)
	_dm._on_blocker_pressed()
	_dm._current_blocker_points = [Vector2(100, 100), Vector2(200, 200)]
	_dm._finish_current_blocker()
	assert_true(GameState.session_dirty)


func test_mark_dirty_on_blocker_delete() -> void:
	var vb := VisionBlockerDataClass.new()
	vb.id = "vb_md"
	vb.points = [Vector2(0, 0), Vector2(100, 100)]
	GameState.current_map_index = 0
	GameState.get_current_vision_blockers().append(vb)
	GameState.mark_clean()

	_dm._on_blocker_pressed()
	_dm._select_blocker("vb_md")
	_dm._delete_selected_blocker()
	assert_true(GameState.session_dirty)


func test_mark_dirty_on_blocker_toggle() -> void:
	var vb := VisionBlockerDataClass.new()
	vb.id = "vb_md2"
	vb.points = [Vector2(0, 0), Vector2(100, 100)]
	GameState.current_map_index = 0
	GameState.get_current_vision_blockers().append(vb)
	GameState.mark_clean()

	_dm._on_blocker_pressed()
	_dm._select_blocker("vb_md2")
	_dm._on_blocker_toggle_active()
	assert_true(GameState.session_dirty)


# ─── Touch ignored in blocker mode ─────────────────────────

func test_touch_ignored_in_blocker_mode() -> void:
	_dm._on_blocker_pressed()
	var touch := InputEventScreenTouch.new()
	touch.pressed = true
	_dm._handle_touch(touch)
	assert_true(_dm._blocker_mode)


func test_drag_ignored_in_blocker_mode() -> void:
	_dm._on_blocker_pressed()
	var drag := InputEventScreenDrag.new()
	_dm._handle_drag(drag)
	assert_true(_dm._blocker_mode)


# ─── Snap edge cases ───────────────────────────────────────

func test_snap_to_half_grid_zero_cell_px() -> void:
	var pos: Vector2 = _dm._snap_to_half_grid(Vector2(85, 85), 0.0, Vector2.ZERO)
	assert_eq(pos, Vector2(85, 85))


# ─── DM fog preview (11.6) ──────────────────────────────────

func test_dm_fog_renderer_created_on_ready() -> void:
	assert_not_null(_dm._dm_fog_renderer, "FogRenderer should be created in _ready")


func test_dm_fog_preview_disabled_by_default() -> void:
	assert_false(_dm._dm_fog_preview_enabled, "DM fog preview should be disabled by default")


func test_toggle_dm_fog_preview_enables_and_disables() -> void:
	_dm._toggle_dm_fog_preview()
	assert_true(_dm._dm_fog_preview_enabled, "first toggle should enable")
	assert_true(_dm._dm_fog_renderer._enabled, "renderer should be enabled")

	_dm._toggle_dm_fog_preview()
	assert_false(_dm._dm_fog_preview_enabled, "second toggle should disable")
	assert_false(_dm._dm_fog_renderer._enabled, "renderer should be disabled")


func test_update_dm_fog_runs_when_preview_enabled() -> void:
	_dm._toggle_dm_fog_preview()
	var gd := GameState.get_current_grid()
	gd.size_px = 70.0
	gd.origin = Vector2.ZERO
	_dm._update_dm_fog()
	# Should not crash — just verify the method runs without errors
	assert_true(_dm._dm_fog_renderer._enabled)


func test_update_dm_fog_skipped_when_preview_disabled() -> void:
	_dm._update_dm_fog()
	assert_false(_dm._dm_fog_renderer._enabled,
		"fog renderer should stay disabled when preview is off")
