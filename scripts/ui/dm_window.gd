extends Control

## DMWindow — ventana principal del Dungeon Master.
## Layout: toolbar arriba, 3 columnas (mapas/viewport/propiedades), status bar abajo.

@onready var toolbar: HBoxContainer = %Toolbar
@onready var zoom_in_btn: Button = %ZoomInBtn
@onready var zoom_out_btn: Button = %ZoomOutBtn
@onready var fit_btn: Button = %FitBtn
@onready var grid_toggle_btn: Button = %GridToggleBtn
@onready var measure_btn: Button = %MeasureBtn
@onready var effects_btn: Button = %EffectsBtn
@onready var view_mode_dropdown: OptionButton = %ViewModeDropdown

@onready var map_list_title: Label = %MapListTitle
@onready var add_map_btn: Button = %AddMapBtn
@onready var map_list: ItemList = %MapList
@onready var token_list_title: Label = %TokenListTitle
@onready var import_token_btn: Button = %ImportTokenBtn
@onready var token_list: ItemList = %TokenList

@onready var properties_title: Label = %PropertiesTitle
@onready var initiative_title: Label = %InitiativeTitle
@onready var add_initiative_btn: Button = %AddInitiativeBtn
@onready var initiative_table: Tree = %InitiativeTable

@onready var status_bar: HBoxContainer = %StatusBar
@onready var zoom_label: Label = %ZoomLabel
@onready var coords_label: Label = %CoordsLabel
@onready var fps_label: Label = %FPSLabel

var _zoom_level: float = 1.0


func _ready() -> void:
	_setup_initiative_table()
	_setup_file_dialogs()


func _process(_delta: float) -> void:
	fps_label.text = "FPS: %d" % Engine.get_frames_per_second()


func _input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed:
		if event.is_action_pressed("save_session"):
			_save_session()
		elif event.is_action_pressed("open_session"):
			_open_session()
		elif event.is_action_pressed("new_session"):
			_new_session()
		elif event.is_action_pressed("delete_token"):
			pass  # Fase 7
		elif event.is_action_pressed("undo"):
			pass  # Fase 17
		elif event.is_action_pressed("redo"):
			pass  # Fase 17
		elif event.is_action_pressed("tool_measure"):
			_on_measure_pressed()


# ─── Toolbar ──────────────────────────────────────────────

func _on_zoom_in_pressed() -> void:
	_zoom_level = minf(_zoom_level * 1.25, 4.0)
	_apply_zoom()


func _on_zoom_out_pressed() -> void:
	_zoom_level = maxf(_zoom_level / 1.25, 0.1)
	_apply_zoom()


func _on_fit_pressed() -> void:
	_zoom_level = 1.0
	_apply_zoom()


func _on_grid_toggle_pressed() -> void:
	EventBus.grid_updated.emit()


func _on_measure_pressed() -> void:
	EventBus.measurement_started.emit()


func _on_effects_pressed() -> void:
	pass  # Fase 7 - panel de efectos


func _on_view_mode_changed(idx: int) -> void:
	GameState.view_mode = idx
	var modes := {0: "synced", 1: "independent", 2: "follow_turn"}
	EventBus.view_mode_changed.emit(modes.get(idx, "synced"))


func _apply_zoom() -> void:
	var pct := int(_zoom_level * 100)
	zoom_label.text = "%d%%" % pct
	zoom_in_btn.disabled = _zoom_level >= 4.0
	zoom_out_btn.disabled = _zoom_level <= 0.1


# ─── Paneles laterales ───────────────────────────────────

func _on_add_map_pressed() -> void:
	var dialog := get_node_or_null("OpenMapDialog") as FileDialog
	if dialog:
		dialog.popup_centered()


func _on_import_token_pressed() -> void:
	var dialog := get_node_or_null("ImportTokenDialog") as FileDialog
	if dialog:
		dialog.popup_centered()


func _on_add_initiative_pressed() -> void:
	pass  # Fase 14


# ─── Iniciativa ───────────────────────────────────────────

func _setup_initiative_table() -> void:
	initiative_table.set_column_title(0, "#")
	initiative_table.set_column_title(1, "Nombre")
	initiative_table.set_column_title(2, "HP")
	initiative_table.set_column_expand(0, false)
	initiative_table.set_column_custom_minimum_width(0, 30)
	initiative_table.set_column_custom_minimum_width(1, 80)
	initiative_table.hide_root = true


# ─── Atajos de teclado ───────────────────────────────────

func _save_session() -> void:
	var dialog := get_node_or_null("SaveDialog") as FileDialog
	if dialog and GameState.session_path == "":
		dialog.popup_centered()
	else:
		EventBus.session_saved.emit(GameState.session_path)


func _open_session() -> void:
	var dialog := get_node_or_null("OpenDialog") as FileDialog
	if dialog:
		dialog.popup_centered()


func _new_session() -> void:
	get_tree().change_scene_to_file("res://scenes/ui/launcher.tscn")


# ─── Diálogos de archivos ────────────────────────────────

func _setup_file_dialogs() -> void:
	var save_dialog := FileDialog.new()
	save_dialog.title = tr("Guardar sesion")
	save_dialog.access = FileDialog.ACCESS_FILESYSTEM
	save_dialog.file_mode = FileDialog.FILE_MODE_SAVE_FILE
	save_dialog.add_filter("*.bmap", "Sesion BattleMap (*.bmap)")
	save_dialog.file_selected.connect(_on_save_dialog_file_selected)
	save_dialog.name = "SaveDialog"
	add_child(save_dialog)

	var open_dialog := FileDialog.new()
	open_dialog.title = tr("Abrir sesion")
	open_dialog.access = FileDialog.ACCESS_FILESYSTEM
	open_dialog.file_mode = FileDialog.FILE_MODE_OPEN_FILE
	open_dialog.add_filter("*.bmap", "Sesiones BattleMap (*.bmap)")
	open_dialog.file_selected.connect(_on_open_dialog_file_selected)
	open_dialog.name = "OpenDialog"
	add_child(open_dialog)

	var open_map_dialog := FileDialog.new()
	open_map_dialog.title = tr("Abrir mapa")
	open_map_dialog.access = FileDialog.ACCESS_FILESYSTEM
	open_map_dialog.file_mode = FileDialog.FILE_MODE_OPEN_FILE
	open_map_dialog.add_filter("*.png,*.jpg,*.jpeg,*.webp,*.bmp", "Imagenes")
	open_map_dialog.file_selected.connect(_on_open_map_dialog_file_selected)
	open_map_dialog.name = "OpenMapDialog"
	add_child(open_map_dialog)

	var import_token_dialog := FileDialog.new()
	import_token_dialog.title = tr("Importar token")
	import_token_dialog.access = FileDialog.ACCESS_FILESYSTEM
	import_token_dialog.file_mode = FileDialog.FILE_MODE_OPEN_FILE
	import_token_dialog.add_filter("*.png,*.jpg,*.jpeg,*.webp", "Imagenes")
	import_token_dialog.file_selected.connect(_on_import_token_dialog_file_selected)
	import_token_dialog.name = "ImportTokenDialog"
	add_child(import_token_dialog)


func _on_save_dialog_file_selected(path: String) -> void:
	if not path.ends_with(".bmap"):
		path += ".bmap"
	GameState.session_path = path
	EventBus.session_saved.emit(path)


func _on_open_dialog_file_selected(path: String) -> void:
	if not FileAccess.file_exists(path):
		return
	GameState.session_path = path
	GameState.session_name = path.get_file().trim_suffix(".bmap")
	EventBus.session_loaded.emit(path)


func _on_open_map_dialog_file_selected(path: String) -> void:
	EventBus.map_added.emit(path)


func _on_import_token_dialog_file_selected(path: String) -> void:
	EventBus.token_added.emit(path)
