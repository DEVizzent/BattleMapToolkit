extends Node

## Settings — ajustes de la aplicación persistentes en user://settings.json

const SETTINGS_FILE := "user://settings.json"

var default_session_dir: String = "user://sessions"
var units: String = "feet"       # "feet" o "meters"
var language: String = "auto"    # "auto", "es", "en"
var locale: String = "es"
var theme_mode: String = "dark"  # "dark" o "light"
var player_monitor: int = 1
var default_view_mode: String = "synced"  # "synced", "independent", "follow_turn"
var touch_enabled_for_players: bool = true
var autosave_interval_minutes: int = 5


func _ready() -> void:
	_load()


func _load() -> void:
	if not FileAccess.file_exists(SETTINGS_FILE):
		return
	var file := FileAccess.open(SETTINGS_FILE, FileAccess.READ)
	if not file:
		return
	var text := file.get_as_text()
	file.close()
	var json := JSON.new()
	var err := json.parse(text)
	if err != OK:
		return
	var d: Dictionary = json.data
	default_session_dir = d.get("default_session_dir", default_session_dir)
	units = d.get("units", units)
	language = d.get("language", language)
	locale = d.get("locale", locale)
	theme_mode = d.get("theme_mode", theme_mode)
	player_monitor = d.get("player_monitor", player_monitor)
	default_view_mode = d.get("default_view_mode", default_view_mode)
	touch_enabled_for_players = d.get("touch_enabled_for_players", touch_enabled_for_players)
	autosave_interval_minutes = d.get("autosave_interval_minutes", autosave_interval_minutes)


func save() -> void:
	var d := {
		"default_session_dir": default_session_dir,
		"units": units,
		"language": language,
		"locale": locale,
		"theme_mode": theme_mode,
		"player_monitor": player_monitor,
		"default_view_mode": default_view_mode,
		"touch_enabled_for_players": touch_enabled_for_players,
		"autosave_interval_minutes": autosave_interval_minutes,
	}
	var file := FileAccess.open(SETTINGS_FILE, FileAccess.WRITE)
	if not file:
		return
	file.store_string(JSON.stringify(d, "\t"))
	file.close()
