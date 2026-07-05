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

@onready var map_viewport: SubViewportContainer = %MapViewport
@onready var viewport_node: SubViewport = %Viewport
@onready var map_root: Node2D = %MapRoot
@onready var map_sprite: Sprite2D = %MapSprite
@onready var grid_layer: Node2D = %GridLayer
@onready var token_layer: Node2D = %TokenLayer
@onready var fog_layer: Node2D = %FogLayer
@onready var effect_layer: Node2D = %EffectLayer

@onready var properties_title: Label = %PropertiesTitle
@onready var initiative_title: Label = %InitiativeTitle
@onready var add_initiative_btn: Button = %AddInitiativeBtn
@onready var initiative_table: Tree = %InitiativeTable

@onready var status_bar: HBoxContainer = %StatusBar
@onready var zoom_label: Label = %ZoomLabel
@onready var coords_label: Label = %CoordsLabel
@onready var fps_label: Label = %FPSLabel

var _zoom_level: float = 1.0
var _panning: bool = false
var _pan_start: Vector2 = Vector2.ZERO
var _pan_root_start: Vector2 = Vector2.ZERO

const ZOOM_MIN := 0.1
const ZOOM_MAX := 4.0
const ZOOM_STEP := 1.25
const PAN_SPEED := 10.0


func _ready() -> void:
	_setup_initiative_table()
	_setup_file_dialogs()
	_refresh_map_list()
	map_list.item_selected.connect(_on_map_list_selected)
	map_list.item_activated.connect(_on_map_list_double_clicked)
	map_list.item_clicked.connect(_on_map_list_clicked)


func _input(event: InputEvent) -> void:
	if _is_mouse_over_viewport():
		var viewport_scale: Vector2 = Vector2(viewport_node.size) / Vector2(map_viewport.size)
		if event is InputEventMouseButton:
			if event.button_index == MOUSE_BUTTON_WHEEL_UP:
				_zoom_at_point(_get_viewport_mouse_pos() * viewport_scale, ZOOM_STEP)
			elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
				_zoom_at_point(_get_viewport_mouse_pos() * viewport_scale, 1.0 / ZOOM_STEP)
			elif event.button_index == MOUSE_BUTTON_MIDDLE:
				if event.pressed:
					_panning = true
					_pan_start = _get_viewport_mouse_pos() * viewport_scale
					_pan_root_start = map_root.position
				else:
					_panning = false
		if event is InputEventMouseMotion and _panning:
			var cur_pos: Vector2 = _get_viewport_mouse_pos() * viewport_scale
			var delta: Vector2 = cur_pos - _pan_start
			map_root.position = _pan_root_start + delta
	if event is InputEventKey and event.pressed:
		if event.is_action_pressed("save_session"):
			_save_session()
		elif event.is_action_pressed("open_session"):
			_open_session()
		elif event.is_action_pressed("new_session"):
			_new_session()


func _process(_delta: float) -> void:
	fps_label.text = "FPS: %d" % Engine.get_frames_per_second()
	_update_coords_label()
	_handle_keyboard_pan()


# ─── Viewport helpers ────────────────────────────────────

func _is_mouse_over_viewport() -> bool:
	var mouse_pos := map_viewport.get_global_mouse_position()
	var rect := Rect2(map_viewport.global_position, map_viewport.size)
	return rect.has_point(mouse_pos)


func _get_viewport_mouse_pos() -> Vector2:
	return map_viewport.get_local_mouse_position()


# ─── Zoom ────────────────────────────────────────────────

func _zoom_at_point(screen_pos: Vector2, factor: float) -> void:
	var old_scale: float = map_root.scale.x
	var new_scale: float = clampf(old_scale * factor, ZOOM_MIN, ZOOM_MAX)
	if new_scale == old_scale:
		return
	var map_point: Vector2 = (screen_pos - map_root.position) / old_scale
	map_root.scale = Vector2(new_scale, new_scale)
	map_root.position = screen_pos - map_point * new_scale
	_zoom_level = new_scale
	_apply_zoom()


func _apply_zoom() -> void:
	var pct := int(_zoom_level * 100)
	zoom_label.text = "%d%%" % pct
	zoom_in_btn.disabled = _zoom_level >= ZOOM_MAX
	zoom_out_btn.disabled = _zoom_level <= ZOOM_MIN


# ─── Paneo ───────────────────────────────────────────────

func _handle_keyboard_pan() -> void:
	var pan_dir := Vector2.ZERO
	var speed: float = PAN_SPEED / map_root.scale.x
	if Input.is_action_pressed("pan_left"):
		pan_dir.x += speed
	if Input.is_action_pressed("pan_right"):
		pan_dir.x -= speed
	if Input.is_action_pressed("pan_up"):
		pan_dir.y += speed
	if Input.is_action_pressed("pan_down"):
		pan_dir.y -= speed
	if pan_dir != Vector2.ZERO:
		map_root.position += pan_dir


func _update_coords_label() -> void:
	var viewport_scale: Vector2 = Vector2(viewport_node.size) / Vector2(map_viewport.size)
	var mouse_pos: Vector2 = _get_viewport_mouse_pos() * viewport_scale
	var map_coords: Vector2 = (mouse_pos - map_root.position) / map_root.scale.x
	coords_label.text = "(%d, %d)" % [int(map_coords.x), int(map_coords.y)]


# ─── Toolbar ──────────────────────────────────────────────

func _on_zoom_in_pressed() -> void:
	var center: Vector2 = Vector2(viewport_node.size) / 2.0
	_zoom_at_point(center, ZOOM_STEP)


func _on_zoom_out_pressed() -> void:
	var center: Vector2 = Vector2(viewport_node.size) / 2.0
	_zoom_at_point(center, 1.0 / ZOOM_STEP)


func _on_fit_pressed() -> void:
	_fit_map_to_viewport()


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
	open_map_dialog.add_filter("*.png ; *.jpg ; *.jpeg ; *.webp ; *.bmp", "Imagenes")
	open_map_dialog.file_selected.connect(_on_open_map_dialog_file_selected)
	open_map_dialog.name = "OpenMapDialog"
	add_child(open_map_dialog)

	var import_token_dialog := FileDialog.new()
	import_token_dialog.title = tr("Importar token")
	import_token_dialog.access = FileDialog.ACCESS_FILESYSTEM
	import_token_dialog.file_mode = FileDialog.FILE_MODE_OPEN_FILE
	import_token_dialog.add_filter("*.png ; *.jpg ; *.jpeg ; *.webp", "Imagenes")
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
	var texture := _load_map_texture(path)
	if not texture:
		return
	var md := _create_map_data(path)
	GameState.maps.append(md)
	_refresh_map_list()
	var idx := GameState.maps.size() - 1
	GameState.current_map_index = idx
	_activate_map(idx)


func _load_map_texture(path: String) -> Texture2D:
	if not FileAccess.file_exists(path):
		return null
	var image := Image.new()
	var err := image.load(path)
	if err != OK:
		_show_error("No se pudo cargar la imagen: " + path)
		return null
	return ImageTexture.create_from_image(image)


func _create_map_data(path: String) -> Resource:
	var MapDataClass := preload("res://scripts/map/map_data.gd")
	var md := MapDataClass.new()
	md.name = path.get_file().get_basename()
	md.image_path = path
	return md


func _activate_map(index: int) -> void:
	if index < 0 or index >= GameState.maps.size():
		map_sprite.texture = null
		return
	GameState.current_map_index = index
	var md = GameState.maps[index]
	if md.image_exists():
		var texture := _load_map_texture(md.image_path)
		if texture:
			map_sprite.texture = texture
			_fit_map_to_viewport()
	map_list.select(index)
	EventBus.map_activated.emit(md.name)


func _fit_map_to_viewport() -> void:
	if not map_sprite.texture:
		return
	var tex_size: Vector2 = map_sprite.texture.get_size()
	var vp_size: Vector2 = Vector2(viewport_node.size)
	if tex_size.x <= 0 or tex_size.y <= 0:
		return
	var scale_x: float = vp_size.x / tex_size.x
	var scale_y: float = vp_size.y / tex_size.y
	var scale: float = minf(scale_x, scale_y)
	if scale > 1.0:
		scale = 1.0
	map_root.scale = Vector2(scale, scale)
	map_root.position = (vp_size - tex_size * scale) / 2.0
	_zoom_level = scale
	zoom_label.text = "%d%%" % int(_zoom_level * 100)


# ─── Lista de mapas ──────────────────────────────────────

func _refresh_map_list() -> void:
	map_list.clear()
	for md in GameState.maps:
		map_list.add_item(md.name)


func _on_map_list_selected(index: int) -> void:
	_activate_map(index)


func _on_map_list_double_clicked(index: int) -> void:
	_rename_map(index)


func _on_map_list_clicked(index: int, _at_position: Vector2, mouse_button: int) -> void:
	if mouse_button != MOUSE_BUTTON_RIGHT:
		return
	if index < 0 or index >= GameState.maps.size():
		return
	var md = GameState.maps[index]
	_show_map_context_menu(index, md)


func _rename_map(index: int) -> void:
	var md = GameState.maps[index]
	var dialog := AcceptDialog.new()
	dialog.title = "Renombrar mapa"
	var line := LineEdit.new()
	line.text = md.name
	line.select_all()
	dialog.add_child(line)
	dialog.confirmed.connect(func():
		var new_name := line.text.strip_edges()
		if new_name != "":
			md.name = new_name
			_refresh_map_list()
			EventBus.map_renamed.emit(md.name, new_name)
		dialog.queue_free()
	)
	line.text_submitted.connect(func(_t: String): dialog.get_ok_button().pressed.emit())
	add_child(dialog)
	dialog.popup_centered()
	line.grab_focus()


func _show_map_context_menu(index: int, _md: Resource) -> void:
	var popup := PopupMenu.new()
	popup.add_item("Activar", 0)
	popup.add_item("Renombrar", 1)
	popup.add_item("Duplicar", 2)
	popup.add_separator()
	popup.add_item("Eliminar de la sesion", 3)
	popup.id_pressed.connect(func(id: int):
		match id:
			0: _activate_map(index)
			1: _rename_map(index)
			2: _duplicate_map(index)
			3: _remove_map(index)
		popup.queue_free()
	)
	add_child(popup)
	popup.position = get_global_mouse_position()
	popup.popup()


func _duplicate_map(index: int) -> void:
	var original = GameState.maps[index]
	var MapDataClass := preload("res://scripts/map/map_data.gd")
	var copy := MapDataClass.new()
	copy.name = original.name + " (copia)"
	copy.image_path = original.image_path
	GameState.maps.append(copy)
	_refresh_map_list()
	EventBus.map_duplicated.emit(original.name, copy.name)


func _remove_map(index: int) -> void:
	var md = GameState.maps[index]
	GameState.maps.remove_at(index)
	_refresh_map_list()
	if GameState.current_map_index == index:
		if GameState.maps.size() > 0:
			_activate_map(0)
		else:
			map_sprite.texture = null
			GameState.current_map_index = -1
	EventBus.map_removed.emit(md.name)


# ─── Utilidades ──────────────────────────────────────────

func _show_error(msg: String) -> void:
	var dialog := AcceptDialog.new()
	dialog.title = tr("TITLE_ERROR")
	dialog.dialog_text = msg
	add_child(dialog)
	dialog.popup_centered()


func _on_import_token_dialog_file_selected(path: String) -> void:
	EventBus.token_added.emit(path)
