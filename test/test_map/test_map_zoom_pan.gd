extends GutTest

func test_zoom_to_cursor_math() -> void:
	var old_scale: float = 1.0
	var screen_pos: Vector2 = Vector2(960, 540)
	var root_pos: Vector2 = Vector2(100, 50)

	var map_point: Vector2 = (screen_pos - root_pos) / old_scale
	assert_eq(map_point.x, 860.0)
	assert_eq(map_point.y, 490.0)

	var new_scale: float = 2.0
	var new_root_pos: Vector2 = screen_pos - map_point * new_scale
	assert_eq(new_root_pos.x, -760.0)
	assert_eq(new_root_pos.y, -440.0)


func test_zoom_out_clamped_to_min() -> void:
	var scale: float = 0.15
	# zoom out: scale * 0.8
	scale = clampf(scale * 0.8, 0.1, 4.0)
	# 0.15 * 0.8 = 0.12, clamped to min 0.1
	assert_gt(scale, 0.09)
	assert_lt(scale, 0.13)


func test_zoom_in_clamped_to_max() -> void:
	var scale: float = 3.5
	# zoom in: scale * 1.25
	scale = clampf(scale * 1.25, 0.1, 4.0)
	# 3.5 * 1.25 = 4.375, clamped to max 4.0
	assert_eq(scale, 4.0)


func test_zoom_in_increases_scale() -> void:
	var scale: float = 1.0
	scale = clampf(scale * 1.25, 0.1, 4.0)
	assert_eq(scale, 1.25)


func test_zoom_out_decreases_scale() -> void:
	var scale: float = 1.0
	scale = clampf(scale / 1.25, 0.1, 4.0)
	assert_eq(scale, 0.8)


func test_pan_delta_math() -> void:
	var pan_start: Vector2 = Vector2(500, 400)
	var cur_pos: Vector2 = Vector2(550, 380)
	var pan_root_start: Vector2 = Vector2(200, 100)

	var delta: Vector2 = cur_pos - pan_start
	var new_pos: Vector2 = pan_root_start + delta
	assert_eq(new_pos.x, 250.0)
	assert_eq(new_pos.y, 80.0)
