extends Control

## Launcher — pantalla de bienvenida.
## La UI se define en launcher.tscn. Este script contiene solo lógica.

const SessionDataClass := preload("res://scripts/session/session_data.gd")

@onready var recent_list: ItemList = %RecentList
@onready var recent_title: Label = %RecentTitle
@onready var recent_panel: PanelContainer = %RecentPanel
@onready var recovery_banner: PanelContainer = %RecoveryBanner
@onready var settings_overlay: ColorRect = %SettingsOverlay
@onready var new_btn: Button = %NewBtn
@onready var open_btn: Button = %OpenBtn
@onready var import_btn: Button = %ImportBtn
@onready var open_dialog: FileDialog = %OpenDialog
@onready var import_dialog: FileDialog = %ImportDialog
@onready var new_session_dialog: FileDialog = %NewSessionDialog
@onready var units_option: OptionButton = %UnitsOption
@onready var theme_option: OptionButton = %ThemeOption
@onready var view_mode_option: OptionButton = %ViewModeOption
@onready var language_option: OptionButton = %LanguageOption


func _ready() -> void:
	_apply_settings_to_controls()
	_refresh_recent_list()
	_check_autosave_recovery()


func _apply_settings_to_controls() -> void:
	units_option.selected = 0 if Settings.units == "feet" else 1
	theme_option.selected = 0 if Settings.theme_mode == "dark" else 1
	var view_map := {"synced": 0, "independent": 1, "follow_turn": 2}
	view_mode_option.selected = view_map.get(Settings.default_view_mode, 0)
	var lang_map := {"auto": 0, "es": 1, "en": 2}
	language_option.selected = lang_map.get(Settings.language, 0)


# ─── Botones principales ─────────────────────────────────

func _on_new_pressed() -> void:
	new_session_dialog.popup_centered()


func _on_new_dialog_file_selected(path: String) -> void:
	_create_and_open_session(path)


func _on_open_pressed() -> void:
	open_dialog.popup_centered()


func _on_import_pressed() -> void:
	import_dialog.popup_centered()


# ─── Ajustes ─────────────────────────────────────────────

func _on_settings_pressed() -> void:
	settings_overlay.visible = !settings_overlay.visible


func _on_settings_close_pressed() -> void:
	settings_overlay.visible = false
	Settings.save()


func _on_units_changed(idx: int) -> void:
	Settings.units = "feet" if idx == 0 else "meters"


func _on_theme_changed(idx: int) -> void:
	Settings.theme_mode = "dark" if idx == 0 else "light"


func _on_view_mode_changed(idx: int) -> void:
	var modes := {0: "synced", 1: "independent", 2: "follow_turn"}
	Settings.default_view_mode = modes[idx]


func _on_language_changed(idx: int) -> void:
	var locales := {0: "auto", 1: "es", 2: "en"}
	LocaleManager.set_locale(locales[idx])


func _on_help_pressed() -> void:
	OS.shell_open("https://github.com/anomalyco/opencode/issues")


# ─── Crear / Abrir sesión ────────────────────────────────

func _create_and_open_session(path: String) -> void:
	if not path.ends_with(".bmap"):
		path += ".bmap"
	GameState.session_name = path.get_file().trim_suffix(".bmap")
	GameState.session_path = path
	GameState.mark_clean()
	_ensure_session_file(path)
	_add_to_recent()
	EventBus.session_created.emit(path)
	_transition_to_dm()


func _ensure_session_file(path: String) -> void:
	if not FileAccess.file_exists(path):
		var f := FileAccess.open(path, FileAccess.WRITE)
		if f:
			f.store_string(JSON.stringify({
				"version": "0.1.0",
				"maps": [],
				"name": GameState.session_name
			}))
			f.close()


func _on_open_dialog_file_selected(path: String) -> void:
	_load_session(path)


func _load_session(path: String) -> void:
	if not FileAccess.file_exists(path):
		_show_error(tr("MSG_FILE_NOT_FOUND") + ": " + path)
		return
	GameState.session_path = path
	GameState.session_name = path.get_file().trim_suffix(".bmap")
	GameState.mark_clean()
	_add_to_recent()
	EventBus.session_loaded.emit(path)
	_transition_to_dm()


func _add_to_recent() -> void:
	var sd := SessionDataClass.new()
	sd.name = GameState.session_name
	sd.file_path = GameState.session_path
	sd.maps_count = GameState.maps.size()
	sd.last_modified = Time.get_date_string_from_system()
	sd.has_active_initiative = GameState.initiative_participants.size() > 0
	RecentSessions.add_or_update(sd)
	_refresh_recent_list()


# ─── Importar ZIP ────────────────────────────────────────

func _on_import_dialog_file_selected(path: String) -> void:
	if path.ends_with(".bmap"):
		_load_session(path)
	elif path.ends_with(".zip"):
		_import_zip(path)
	else:
		_show_error(tr("MSG_FORMAT_NOT_SUPPORTED"))


func _import_zip(path: String) -> void:
	var reader := ZIPReader.new()
	var err := reader.open(path)
	if err != OK:
		_show_error(tr("MSG_INVALID_ZIP"))
		return
	var import_dir := "user://library/imported/" + path.get_file().trim_suffix(".zip")
	DirAccess.make_dir_recursive_absolute(import_dir)
	var files := reader.get_files()
	for f in files:
		var data := reader.read_file(f)
		var target := import_dir.path_join(f)
		DirAccess.make_dir_recursive_absolute(target.get_base_dir())
		var out := FileAccess.open(target, FileAccess.WRITE)
		if out:
			out.store_buffer(data)
			out.close()
	reader.close()
	_show_info(tr("MSG_SESSION_IMPORTED"))


# ─── Sesiones recientes ──────────────────────────────────

func _refresh_recent_list() -> void:
	recent_list.clear()
	var all := RecentSessions.get_sessions()
	for s in all:
		if s.file_exists():
			recent_list.add_item(s.display_string())
		else:
			recent_list.add_item(s.display_string() + " (no encontrado)")
	var has_items := recent_list.item_count > 0
	recent_title.visible = has_items
	recent_panel.visible = has_items


func _on_recent_item_activated(index: int) -> void:
	if index < 0 or index >= RecentSessions.sessions.size():
		return
	var sd = RecentSessions.sessions[index]
	if not sd.file_exists():
		_show_error(tr("MSG_SESSION_NO_LONGER_AVAILABLE") + "\n" + sd.file_path)
		RecentSessions.remove_by_path(sd.file_path)
		_refresh_recent_list()
		return
	_load_session(sd.file_path)


func _on_recent_item_clicked(index: int, _at_position: Vector2, mouse_button: int) -> void:
	if mouse_button != MOUSE_BUTTON_RIGHT:
		return
	if index < 0 or index >= RecentSessions.sessions.size():
		return
	var sd = RecentSessions.sessions[index]
	RecentSessions.remove_by_path(sd.file_path)
	_refresh_recent_list()


# ─── Banner de recuperación ──────────────────────────────

func _check_autosave_recovery() -> void:
	recovery_banner.visible = FileAccess.file_exists("user://autosave.bmap")


func _on_recover_pressed() -> void:
	var autosave_path := "user://autosave.bmap"
	if FileAccess.file_exists(autosave_path):
		_load_session(autosave_path)
	recovery_banner.visible = false


func _on_discard_pressed() -> void:
	var autosave_path := "user://autosave.bmap"
	if FileAccess.file_exists(autosave_path):
		DirAccess.remove_absolute(autosave_path)
	recovery_banner.visible = false


# ─── Transición ──────────────────────────────────────────

func _transition_to_dm() -> void:
	get_tree().change_scene_to_file("res://scenes/ui/dm_window.tscn")


# ─── Utilidades ──────────────────────────────────────────

func _show_error(msg: String) -> void:
	var dialog := AcceptDialog.new()
	dialog.title = tr("TITLE_ERROR")
	dialog.dialog_text = msg
	dialog.add_theme_font_size_override("font_size", 14)
	add_child(dialog)
	dialog.popup_centered()


func _show_info(msg: String) -> void:
	var dialog := AcceptDialog.new()
	dialog.title = tr("TITLE_INFO")
	dialog.dialog_text = msg
	dialog.add_theme_font_size_override("font_size", 14)
	add_child(dialog)
	dialog.popup_centered()
