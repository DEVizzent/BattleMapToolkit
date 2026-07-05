extends GutTest

func before_all() -> void:
	# Limpiar settings antes de testear
	if FileAccess.file_exists("user://settings.json"):
		DirAccess.remove_absolute("user://settings.json")


func after_all() -> void:
	if FileAccess.file_exists("user://settings.json"):
		DirAccess.remove_absolute("user://settings.json")


func test_default_values() -> void:
	assert_eq(Settings.units, "feet")
	assert_eq(Settings.language, "auto")
	assert_eq(Settings.locale, "es")
	assert_eq(Settings.theme_mode, "dark")
	assert_eq(Settings.player_monitor, 1)
	assert_eq(Settings.default_view_mode, "synced")
	assert_true(Settings.touch_enabled_for_players)
	assert_eq(Settings.autosave_interval_minutes, 5)


func test_save_and_load_roundtrip() -> void:
	Settings.units = "meters"
	Settings.language = "en"
	Settings.theme_mode = "light"
	Settings.save()

	# Recargar
	Settings._load()

	assert_eq(Settings.units, "meters", "units debe persistir")
	assert_eq(Settings.language, "en", "language debe persistir")
	assert_eq(Settings.theme_mode, "light", "theme debe persistir")


func test_settings_file_created_after_save() -> void:
	Settings.save()
	assert_true(FileAccess.file_exists("user://settings.json"), "settings.json debe existir tras save()")


func test_load_with_missing_file_keeps_defaults() -> void:
	DirAccess.remove_absolute("user://settings.json")
	var old_units := Settings.units
	Settings._load()
	assert_eq(Settings.units, old_units, "Los defaults no deben cambiar si no hay archivo")
