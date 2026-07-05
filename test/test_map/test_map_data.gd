extends GutTest

const MapDataClass := preload("res://scripts/map/map_data.gd")


func test_default_values() -> void:
	var md := MapDataClass.new()
	assert_eq(md.name, "")
	assert_eq(md.image_path, "")


func test_to_dict() -> void:
	var md := MapDataClass.new()
	md.name = "Mazmorra"
	md.image_path = "res://map.png"
	var d := md.to_dict()
	assert_eq(d["name"], "Mazmorra")
	assert_eq(d["image_path"], "res://map.png")


func test_image_exists_true() -> void:
	var tmp := "user://test_map.png"
	var f := FileAccess.open(tmp, FileAccess.WRITE)
	f.close()

	var md := MapDataClass.new()
	md.image_path = tmp
	assert_true(md.image_exists())

	DirAccess.remove_absolute(tmp)


func test_image_exists_false() -> void:
	var md := MapDataClass.new()
	md.image_path = "user://no_existe.png"
	assert_false(md.image_exists())


func test_from_dict_roundtrip() -> void:
	var md := MapDataClass.new()
	md.name = "Test"
	md.image_path = "res://test.png"
	var d := md.to_dict()
	var restored := MapDataClass.from_dict(d)
	assert_eq(restored.name, "Test")
	assert_eq(restored.image_path, "res://test.png")
