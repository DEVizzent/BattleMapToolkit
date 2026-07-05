extends GutTest

const TokenDataClass := preload("res://scripts/token/token_data.gd")


func test_default_values() -> void:
	var td := TokenDataClass.new()
	assert_eq(td.name, "")
	assert_eq(td.image_path, "")
	assert_eq(td.size_cells, 1.0)
	assert_eq(td.border_color, Color.YELLOW)
	assert_true(td.visible_to_players)
	assert_eq(td.vision_radius, 0)
	assert_eq(td.speed_ft, 30)
	assert_eq(td.conditions.size(), 0)


func test_to_dict() -> void:
	var td := TokenDataClass.new()
	td.name = "Goblin"
	td.image_path = "res://goblin.png"
	td.size_cells = 2.0
	td.border_color = Color.RED
	td.vision_radius = 6
	td.speed_ft = 30
	td.conditions = ["envenenado"]
	var d := td.to_dict()
	assert_eq(d["name"], "Goblin")
	assert_eq(d["image_path"], "res://goblin.png")
	assert_eq(d["size_cells"], 2.0)
	assert_eq(d["vision_radius"], 6)
	assert_eq(d["conditions"], ["envenenado"])


func test_from_dict_roundtrip() -> void:
	var td := TokenDataClass.new()
	td.name = "Orco"
	td.size_cells = 1.0
	td.border_color = Color.BLUE
	td.visible_to_players = false
	td.speed_ft = 25

	var d := td.to_dict()
	var restored := TokenDataClass.from_dict(d)
	assert_eq(restored.name, "Orco")
	assert_eq(restored.size_cells, 1.0)
	assert_false(restored.visible_to_players)
	assert_eq(restored.speed_ft, 25)
	assert_almost_eq(restored.border_color.r, 0.0, 0.001)
	assert_almost_eq(restored.border_color.b, 1.0, 0.001)


func test_size_cells_float_ok() -> void:
	var td := TokenDataClass.new()
	td.size_cells = 2.5
	assert_eq(td.size_cells, 2.5)


func test_conditions_default_empty() -> void:
	var td := TokenDataClass.new()
	assert_eq(td.conditions.size(), 0)
	td.conditions = ["envenenado", "paralizado"]
	assert_eq(td.conditions.size(), 2)
