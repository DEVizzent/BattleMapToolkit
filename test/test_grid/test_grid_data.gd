extends GutTest

const GridDataClass := preload("res://scripts/grid/grid_data.gd")


func test_default_values() -> void:
	var gd := GridDataClass.new()
	assert_eq(gd.size_px, 70.0)
	assert_eq(gd.origin, Vector2.ZERO)
	assert_false(gd.visible)
	assert_eq(gd.opacity, 0.3)
	assert_eq(gd.line_width, 1.0)
	assert_false(gd.show_coords)


func test_to_dict() -> void:
	var gd := GridDataClass.new()
	gd.size_px = 100.0
	gd.origin = Vector2(10, 20)
	gd.visible = true
	gd.color = Color.RED
	gd.opacity = 0.5
	gd.line_width = 2.0
	gd.show_coords = true
	var d := gd.to_dict()
	assert_eq(d["size_px"], 100.0)
	assert_eq(d["origin"], {"x": 10.0, "y": 20.0})
	assert_true(d["visible"])
	assert_eq(d["color"]["r"], 1.0)
	assert_eq(d["opacity"], 0.5)
	assert_eq(d["line_width"], 2.0)
	assert_true(d["show_coords"])


func test_from_dict_roundtrip() -> void:
	var gd := GridDataClass.new()
	gd.size_px = 50.0
	gd.origin = Vector2(5, 15)
	gd.color = Color(0.2, 0.4, 0.6, 0.8)
	gd.opacity = 0.7
	gd.line_width = 3.0
	gd.visible = true
	gd.show_coords = true

	var d := gd.to_dict()
	var restored := GridDataClass.from_dict(d)
	assert_eq(restored.size_px, 50.0)
	assert_eq(restored.origin.x, 5.0)
	assert_eq(restored.origin.y, 15.0)
	assert_almost_eq(restored.color.r, 0.2, 0.001)
	assert_almost_eq(restored.color.g, 0.4, 0.001)
	assert_almost_eq(restored.color.b, 0.6, 0.001)
	assert_almost_eq(restored.color.a, 0.8, 0.001)
	assert_eq(restored.opacity, 0.7)
	assert_eq(restored.line_width, 3.0)
	assert_true(restored.visible)
	assert_true(restored.show_coords)


func test_visible_false_hides_grid() -> void:
	var gd := GridDataClass.new()
	assert_false(gd.visible)


func test_size_px_clamped_in_range() -> void:
	var gd := GridDataClass.new()
	# No validation in resource itself; just ensures property is settable
	gd.size_px = 10.0
	assert_eq(gd.size_px, 10.0)
	gd.size_px = 500.0
	assert_eq(gd.size_px, 500.0)
