extends GutTest

const SessionDataClass := preload("res://scripts/session/session_data.gd")

func test_default_values() -> void:
	var sd := SessionDataClass.new()
	assert_eq(sd.name, "")
	assert_eq(sd.maps_count, 0)
	assert_eq(sd.last_modified, "")
	assert_eq(sd.file_path, "")
	assert_false(sd.has_active_initiative)


func test_to_dict() -> void:
	var sd := SessionDataClass.new()
	sd.name = "Test"
	sd.maps_count = 3
	sd.last_modified = "2026-07-05"
	sd.file_path = "user://test.bmap"
	sd.has_active_initiative = true

	var d := sd.to_dict()
	assert_eq(d["name"], "Test")
	assert_eq(d["maps_count"], 3)
	assert_eq(d["last_modified"], "2026-07-05")
	assert_eq(d["file_path"], "user://test.bmap")
	assert_true(d["has_active_initiative"])


func test_file_exists_when_file_present() -> void:
	var tmp_path := "user://test_exists.bmap"
	var f := FileAccess.open(tmp_path, FileAccess.WRITE)
	f.close()

	var sd := SessionDataClass.new()
	sd.file_path = tmp_path
	assert_true(sd.file_exists(), "SessionData debe detectar archivo existente")

	DirAccess.remove_absolute(tmp_path)


func test_file_exists_when_file_missing() -> void:
	var sd := SessionDataClass.new()
	sd.file_path = "user://no_existe.bmap"
	assert_false(sd.file_exists(), "SessionData debe detectar archivo inexistente")


func test_display_string_singular() -> void:
	var sd := SessionDataClass.new()
	sd.name = "Test"
	sd.maps_count = 1
	sd.last_modified = "2026-01-01"
	var ds := sd.display_string()
	assert_string_contains(ds, "Test")
	assert_string_contains(ds, "1 mapa")
	assert_string_contains(ds, "2026-01-01")


func test_display_string_plural() -> void:
	var sd := SessionDataClass.new()
	sd.name = "Campaign"
	sd.maps_count = 5
	sd.last_modified = "2026-06-15"
	var ds := sd.display_string()
	assert_string_contains(ds, "5 mapas")


func test_display_string_with_initiative() -> void:
	var sd := SessionDataClass.new()
	sd.name = "Battle"
	sd.has_active_initiative = true
	var ds := sd.display_string()
	assert_string_contains(ds, "*")
