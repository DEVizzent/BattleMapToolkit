extends Control

## DMWindow — ventana principal del Dungeon Master.
## Layout: toolbar arriba, 3 columnas (mapas/viewport/propiedades), status bar abajo.

const TokenDataClass := preload("res://scripts/token/token_data.gd")
const TokenSpriteClass := preload("res://scripts/token/token_sprite.gd")
const VisionBlockerDataClass := preload("res://scripts/fog/vision_blocker_data.gd")

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
@onready var properties_content: VBoxContainer = %PropertiesContent
@onready var prop_name_edit: LineEdit = %PropNameEdit
@onready var prop_size_spin: SpinBox = %PropSizeSpin
@onready var prop_visible_check: CheckButton = %PropVisibleCheck
@onready var prop_delete_btn: Button = %PropDeleteBtn
@onready var prop_border_color: ColorPickerButton = %PropBorderColor
@onready var prop_vision_label: Label = %PropVisionLabel
@onready var prop_vision_slider: HSlider = %PropVisionSlider
@onready var prop_speed_spin: SpinBox = %PropSpeedSpin
@onready var prop_conditions_flow: FlowContainer = %PropConditionsFlow
@onready var initiative_title: Label = %InitiativeTitle
@onready var add_initiative_btn: Button = %AddInitiativeBtn
@onready var initiative_table: Tree = %InitiativeTable

@onready var token_library_title: Label = %TokenLibraryTitle
@onready var refresh_library_btn: Button = %RefreshLibraryBtn
@onready var token_library: ItemList = %TokenLibrary

@onready var measure_toolbar: HBoxContainer = %MeasureToolbar
@onready var measure_waypoint_btn: Button = %MeasureWaypointBtn
@onready var measure_circle_btn: Button = %MeasureCircleBtn
@onready var measure_cone_btn: Button = %MeasureConeBtn
@onready var measure_square_btn: Button = %MeasureSquareBtn
@onready var measure_line_btn: Button = %MeasureLineBtn
@onready var template_color_picker: ColorPickerButton = %TemplateColorPicker
@onready var template_opacity_label: Label = %TemplateOpacityLabel
@onready var template_opacity_slider: HSlider = %TemplateOpacitySlider

@onready var blocker_btn: Button = %VisionBlockerBtn
@onready var blocker_toolbar: HBoxContainer = %BlockerToolbar
@onready var blocker_toggle_active_btn: Button = %BlockerToggleActiveBtn
@onready var blocker_delete_btn: Button = %BlockerDeleteBtn
@onready var blocker_color_picker: ColorPickerButton = %BlockerColorPicker

@onready var grid_panel: VBoxContainer = %GridPanel
@onready var grid_cell_size_label: Label = %CellSizeLabel
@onready var grid_cell_size_slider: HSlider = %CellSizeSlider
@onready var grid_cell_dec10_btn: Button = %CellSizeDec10
@onready var grid_cell_dec1_btn: Button = %CellSizeDec1
@onready var grid_cell_inc1_btn: Button = %CellSizeInc1
@onready var grid_cell_inc10_btn: Button = %CellSizeInc10
@onready var grid_color_picker: ColorPickerButton = %GridColorPicker
@onready var grid_opacity_label: Label = %OpacityLabel
@onready var grid_opacity_slider: HSlider = %OpacitySlider
@onready var grid_line_width_label: Label = %LineWidthLabel
@onready var grid_line_width_slider: HSlider = %LineWidthSlider
@onready var grid_show_coords_check: CheckButton = %ShowCoordsCheck

@onready var grid_origin_label: Label = %OriginLabel
@onready var grid_origin_x_label: Label = %OriginXLabel
@onready var grid_origin_y_label: Label = %OriginYLabel
@onready var origin_x_dec10: Button = %OriginXDec10
@onready var origin_x_dec1: Button = %OriginXDec1
@onready var origin_x_inc1: Button = %OriginXInc1
@onready var origin_x_inc10: Button = %OriginXInc10
@onready var origin_y_dec10: Button = %OriginYDec10
@onready var origin_y_dec1: Button = %OriginYDec1
@onready var origin_y_inc1: Button = %OriginYInc1
@onready var origin_y_inc10: Button = %OriginYInc10

@onready var grid_rotation_label: Label = %RotationLabel
@onready var rotation_dec1: Button = %RotationDec1
@onready var rotation_dec01: Button = %RotationDec01
@onready var rotation_inc01: Button = %RotationInc01
@onready var rotation_inc1: Button = %RotationInc1

@onready var grid_drag_btn: CheckButton = %GridDragBtn
@onready var feet_per_cell_label: Label = %FeetPerCellLabel
@onready var feet_per_cell_spin: SpinBox = %FeetPerCellSpin

@onready var status_bar: HBoxContainer = %StatusBar
@onready var zoom_label: Label = %ZoomLabel
@onready var coords_label: Label = %CoordsLabel
@onready var fps_label: Label = %FPSLabel

var _zoom_level: float = 1.0
var _panning: bool = false
var _pan_start: Vector2 = Vector2.ZERO
var _pan_root_start: Vector2 = Vector2.ZERO

var _touch1_idx: int = -1
var _touch2_idx: int = -1
var _touch1_pos: Vector2 = Vector2.ZERO
var _touch2_pos: Vector2 = Vector2.ZERO
var _touch_pinch_dist: float = 0.0
var _touch_pinch_scale: float = 0.0
var _touch_pinch_center: Vector2 = Vector2.ZERO
var _touch_two_pan: bool = false
var _touch_two_pan_center: Vector2 = Vector2.ZERO
var _touch_two_pan_root: Vector2 = Vector2.ZERO
var _touch_on_token: bool = false
var _touch_marquee: bool = false
var _touch_marquee_start: Vector2 = Vector2.ZERO
var _touch_drag_initialized: bool = false

var _selected_token: Sprite2D = null
var _selected_tokens: Array = []
var _dragging_token: bool = false
var _drag_offset: Vector2 = Vector2.ZERO
var _drag_start_pos: Vector2 = Vector2.ZERO
var _drag_start_positions: Dictionary = {}
var _dragging_grid_origin: bool = false
var _grid_drag_start_mouse: Vector2 = Vector2.ZERO
var _grid_drag_start_origin: Vector2 = Vector2.ZERO
var _player_window: Window
var _marquee_selecting: bool = false
var _marquee_start: Vector2 = Vector2.ZERO
var _marquee_end: Vector2 = Vector2.ZERO
var _library_drag_pending: String = ""
var _measuring: bool = false
var _measure_points: Array = []
var _measure_mode: int = 0
var _placing_template: bool = false
var _template_start: Vector2 = Vector2.ZERO
var _templates: Array = []
var _template_color: Color = Color(0.0, 0.8, 1.0, 1.0)
var _template_cell_alpha: float = 0.25
var _last_player_view_rect: Rect2 = Rect2()

var _blocker_mode: bool = false
var _current_blocker_points: Array = []
var _selected_blocker_id: String = ""
var _blocker_color: Color = Color(1.0, 0.3, 0.3, 0.7)
var _dragging_blocker_point: bool = false
var _dragging_point_index: int = -1
var _dragging_point_original_pos: Vector2 = Vector2.ZERO

enum MeasureMode { WAYPOINTS, CIRCLE, CONE, SQUARE, LINE }

const PlayerWindowScene := preload("res://scenes/player/player_window.tscn")

const ZOOM_MIN := 0.1
const ZOOM_MAX := 4.0
const ZOOM_STEP := 1.25
const PAN_SPEED := 10.0

const CONDITIONS := {
	"envenenado": {"label": "Envenenado", "color": Color.PURPLE},
	"paralizado": {"label": "Paralizado", "color": Color.GRAY},
	"concentracion": {"label": "Concentracion", "color": Color.YELLOW},
	"hechizado": {"label": "Hechizado", "color": Color.PINK},
	"asustado": {"label": "Asustado", "color": Color.ORANGE},
	"invisible": {"label": "Invisible", "color": Color.CORNFLOWER_BLUE},
}


func _ready() -> void:
	_setup_initiative_table()
	_setup_file_dialogs()
	_setup_grid_panel()
	_setup_properties_panel()
	_refresh_map_list()
	map_list.item_selected.connect(_on_map_list_selected)
	map_list.item_activated.connect(_on_map_list_double_clicked)
	map_list.item_clicked.connect(_on_map_list_clicked)
	token_list.item_activated.connect(_on_token_list_double_clicked)
	EventBus.grid_updated.connect(_on_grid_updated)
	EventBus.session_saved.connect(_on_session_saved)
	EventBus.session_loaded.connect(_on_session_loaded)
	EventBus.token_moved.connect(_on_token_moved_from_signal)
	EventBus.token_drag_update.connect(_on_token_drag_update)
	EventBus.token_drag_end.connect(_on_token_drag_end)
	refresh_library_btn.pressed.connect(_refresh_token_library)
	get_tree().root.files_dropped.connect(_on_files_dropped)
	measure_waypoint_btn.pressed.connect(func(): _set_measure_mode(MeasureMode.WAYPOINTS))
	measure_circle_btn.pressed.connect(func(): _set_measure_mode(MeasureMode.CIRCLE))
	measure_cone_btn.pressed.connect(func(): _set_measure_mode(MeasureMode.CONE))
	measure_square_btn.pressed.connect(func(): _set_measure_mode(MeasureMode.SQUARE))
	measure_line_btn.pressed.connect(func(): _set_measure_mode(MeasureMode.LINE))
	template_color_picker.color_changed.connect(_on_template_color_changed)
	template_opacity_slider.value_changed.connect(_on_template_opacity_changed)
	template_color_picker.color = _template_color
	template_opacity_slider.value = _template_cell_alpha
	blocker_color_picker.color_changed.connect(_on_blocker_color_changed)
	blocker_color_picker.color = _blocker_color
	blocker_toggle_active_btn.pressed.connect(_on_blocker_toggle_active)
	blocker_delete_btn.pressed.connect(_on_blocker_delete_selected)
	token_layer.set_template_color(_template_color, _template_cell_alpha)
	token_library.set_drag_forwarding(
		func(pos): return _on_library_get_drag_data(token_library, pos),
		Callable(),
		Callable()
	)
	set_drag_forwarding(
		Callable(),
		func(pos, data): return _can_drop_library_token(data),
		func(pos, data): _on_dm_drop(pos, data)
	)
	map_viewport.set_drag_forwarding(
		Callable(),
		func(pos, data): return _can_drop_library_token(data),
		func(pos, data): _on_viewport_drop(pos, data)
	)
	_refresh_token_library()
	EventBus.player_view_changed.connect(_on_player_view_changed)


func _input(event: InputEvent) -> void:
	if event is InputEventScreenTouch:
		if _is_touch_over_viewport(event):
			_handle_touch(event)
		return
	if event is InputEventScreenDrag:
		if _is_touch_over_viewport(event):
			_handle_drag(event)
		return
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			_library_drag_pending = ""
		if event.button_index == MOUSE_BUTTON_LEFT and not event.pressed:
			if _dragging_blocker_point:
				_finish_dragging_blocker_point()
				return
			if _dragging_token:
				_stop_dragging()
				return
			if _dragging_grid_origin:
				_dragging_grid_origin = false
				Input.set_default_cursor_shape(Input.CURSOR_ARROW)
				return
			if _marquee_selecting:
				_marquee_selecting = false
				_finish_marquee_select()
				token_layer.hide_marquee()
				return
			if _library_drag_pending != "":
				if _is_mouse_over_viewport():
					var map_pos := _screen_to_map_pos(map_viewport.get_global_mouse_position())
					_create_token_from_path(_library_drag_pending, map_pos)
				_library_drag_pending = ""
				get_viewport().set_input_as_handled()
				return

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
			elif event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
				if _blocker_mode:
					if _current_blocker_points.size() > 0:
						_add_blocker_point()
					elif _selected_blocker_id != "":
						var map_pos := _get_token_layer_mouse_pos()
						var point_idx := _find_blocker_point_near(_selected_blocker_id, map_pos, 12.0)
						if point_idx >= 0:
							_start_dragging_blocker_point(point_idx)
						else:
							var found_id := _find_blocker_near(map_pos, 10.0)
							if found_id != "":
								_select_blocker(found_id)
							else:
								_add_blocker_point()
					else:
						var map_pos := _get_token_layer_mouse_pos()
						var found_id := _find_blocker_near(map_pos, 10.0)
						if found_id != "":
							_select_blocker(found_id)
						else:
							_add_blocker_point()
				elif _measuring:
					_add_measure_waypoint()
				elif grid_drag_btn.button_pressed:
					var gd := GameState.get_current_grid()
					_dragging_grid_origin = true
					_grid_drag_start_mouse = Vector2(event.global_position)
					_grid_drag_start_origin = gd.origin
					Input.set_default_cursor_shape(Input.CURSOR_MOVE)
				else:
					_try_select_token_or_start_marquee()
			elif event.button_index == MOUSE_BUTTON_RIGHT and event.pressed:
				if _blocker_mode:
					if _dragging_blocker_point:
						_cancel_dragging_blocker_point()
					elif _current_blocker_points.size() >= 2:
						_finish_current_blocker()
					else:
						_cancel_blocker_drawing()
				elif _measuring:
					if _placing_template:
						_placing_template = false
						token_layer.show_template_preview(-1, Vector2.ZERO, Vector2.ZERO)
					elif _templates.size() > 0:
						_templates.clear()
						token_layer.show_templates(_templates)
					elif _measure_points.size() > 0:
						_cancel_measurement()
					else:
						_on_measure_pressed()
				else:
					_try_token_context_menu()
		if event is InputEventMouseMotion:
			if _dragging_blocker_point:
				_update_dragging_blocker_point()
			elif _blocker_mode and _current_blocker_points.size() > 0:
				_update_blocker_preview()
			elif _measuring and _placing_template:
				_update_template_preview()
			elif _measuring:
				_update_measurement_preview()
			elif _panning:
				var cur_pos: Vector2 = _get_viewport_mouse_pos() * viewport_scale
				var delta: Vector2 = cur_pos - _pan_start
				map_root.position = _pan_root_start + delta
				_recompute_player_view_indicator()
			elif _dragging_grid_origin:
				var gd := GameState.get_current_grid()
				var delta: Vector2 = Vector2(event.global_position) - _grid_drag_start_mouse
				var scale: float = map_root.scale.x
				gd.origin = _grid_drag_start_origin + delta / scale
				grid_origin_label.text = "Offset: (%d, %d)" % [int(gd.origin.x), int(gd.origin.y)]
				grid_origin_x_label.text = "X: %d" % int(gd.origin.x)
				grid_origin_y_label.text = "Y: %d" % int(gd.origin.y)
				_refresh_grid()
			elif _dragging_token and _selected_token:
				_update_drag_position()
			elif _marquee_selecting:
				_marquee_end = _get_token_layer_mouse_pos()
				token_layer.show_marquee(_marquee_start, _marquee_end)
			elif _selected_token and not _dragging_token and Input.is_key_pressed(KEY_CTRL):
				_update_distance_preview()
	if event is InputEventKey and event.pressed:
		if event.keycode == KEY_ESCAPE and _blocker_mode:
			if _current_blocker_points.size() > 0:
				_cancel_blocker_drawing()
			else:
				_on_blocker_pressed()
			return
		if event.keycode == KEY_ESCAPE and _measuring:
			if _placing_template:
				_placing_template = false
				token_layer.show_template_preview(-1, Vector2.ZERO, Vector2.ZERO)
			elif _templates.size() > 0:
				_templates.clear()
				token_layer.show_templates(_templates)
			elif _measure_points.size() > 0:
				_cancel_measurement()
			else:
				_on_measure_pressed()
			return
		if event.is_action_pressed("save_session"):
			_save_session()
		elif event.is_action_pressed("open_session"):
			_open_session()
		elif event.is_action_pressed("new_session"):
			_new_session()
		elif event.keycode == KEY_DELETE:
			if _blocker_mode and _selected_blocker_id != "":
				_delete_selected_blocker()
			elif _blocker_mode and _current_blocker_points.size() > 0:
				_cancel_blocker_drawing()
			else:
				_delete_selected_token()
		elif _selected_token and not _dragging_token:
			_handle_arrow_move(event)
		elif event.is_action_pressed("toggle_player_window"):
			_toggle_player_window()
	if event is InputEventKey and not event.pressed:
		if event.keycode == KEY_CTRL:
			token_layer.hide_distance_preview()


func _process(_delta: float) -> void:
	fps_label.text = "FPS: %d" % Engine.get_frames_per_second()
	_update_coords_label()
	if _handle_keyboard_pan():
		_recompute_player_view_indicator()


# ─── Viewport helpers ────────────────────────────────────

func _is_mouse_over_viewport() -> bool:
	var mouse_pos := map_viewport.get_global_mouse_position()
	var rect := Rect2(map_viewport.global_position, map_viewport.size)
	return rect.has_point(mouse_pos)


func _get_viewport_mouse_pos() -> Vector2:
	return map_viewport.get_local_mouse_position()


func _touch_to_map_pos(screen_pos: Vector2) -> Vector2:
	var vp: Vector2 = Vector2(viewport_node.size)
	var mv: Vector2 = Vector2(map_viewport.size)
	if vp.x <= 0 or vp.y <= 0:
		vp = size
	if mv.x <= 0 or mv.y <= 0:
		mv = size
	var viewport_scale: Vector2 = vp / mv
	var vp_pos: Vector2 = screen_pos * viewport_scale
	return (vp_pos - map_root.position) / map_root.scale.x


func _is_touch_over_viewport(event: InputEventFromWindow) -> bool:
	return map_viewport.get_global_rect().has_point(event.position)


func _handle_touch(event: InputEventScreenTouch) -> void:
	if _blocker_mode:
		return
	var pos: Vector2 = event.position - map_viewport.global_position
	if event.pressed:
		if _touch1_idx == -1:
			_touch1_idx = event.index
			_touch1_pos = pos
			_touch_drag_initialized = false
			_touch_on_token = false
			_touch_marquee = false
			var map_pos := _touch_to_map_pos(pos)
			for child in token_layer.get_children():
				if child is TokenSpriteClass:
					var s: float = child.token_data.size_cells * _get_cell_px()
					if Rect2(child.position - Vector2(s * 0.5, s * 0.5), Vector2(s, s)).has_point(map_pos):
						if not _selected_tokens.has(child):
							_clear_selection()
							_selected_tokens.append(child)
							child.select()
						_selected_token = child
						_show_properties_for(child)
						_touch_on_token = true
						break
			if not _touch_on_token:
				_hide_properties()
		elif _touch2_idx == -1 and event.index != _touch1_idx:
			_touch2_idx = event.index
			_touch2_pos = pos
			_touch_pinch_dist = _touch1_pos.distance_to(_touch2_pos)
			_touch_pinch_scale = map_root.scale.x
			_touch_pinch_center = (_touch1_pos + _touch2_pos) / 2.0
			_touch_two_pan = false
			_touch_on_token = false
			_touch_marquee = false
			if _dragging_token:
				_stop_dragging()
			if _marquee_selecting:
				_marquee_selecting = false
				token_layer.hide_marquee()
	else:
		if event.index == _touch1_idx:
			if _dragging_token and _touch2_idx == -1:
				_stop_dragging()
			if _touch_on_token and not _touch_drag_initialized and not _dragging_token and _selected_token:
				var map_pos := _touch_to_map_pos(_touch1_pos)
				_dragging_token = true
				_drag_offset = map_pos - _selected_token.position
				_drag_start_pos = _selected_token.position
				_save_drag_start_positions()
			elif _touch_marquee and _touch2_idx == -1:
				_marquee_selecting = false
				_finish_marquee_select()
				token_layer.hide_marquee()
			_touch1_idx = _touch2_idx
			_touch1_pos = _touch2_pos
			_touch2_idx = -1
			_touch2_pos = Vector2.ZERO
			_touch_pinch_dist = 0.0
			_touch_two_pan = false
			_touch_on_token = false
			_touch_marquee = false
			_touch_drag_initialized = false
		elif event.index == _touch2_idx:
			_touch2_idx = -1
			_touch2_pos = Vector2.ZERO
			_touch_pinch_dist = 0.0
			_touch_two_pan = false


func _handle_drag(event: InputEventScreenDrag) -> void:
	if _blocker_mode:
		return
	var pos: Vector2 = event.position - map_viewport.global_position
	if event.index == _touch1_idx:
		_touch1_pos = pos
	elif event.index == _touch2_idx:
		_touch2_pos = pos
	if _touch2_idx != -1:
		var dist: float = _touch1_pos.distance_to(_touch2_pos)
		if _touch_pinch_dist > 0:
			var delta_dist: float = abs(dist - _touch_pinch_dist)
			if delta_dist > 30.0:
				var factor: float = dist / _touch_pinch_dist
				var new_scale: float = clampf(_touch_pinch_scale * factor, ZOOM_MIN, ZOOM_MAX)
				if new_scale != map_root.scale.x:
					var map_point: Vector2 = (_touch_pinch_center - map_root.position) / map_root.scale.x
					map_root.scale = Vector2(new_scale, new_scale)
					map_root.position = _touch_pinch_center - map_point * new_scale
					_zoom_level = new_scale
					_apply_zoom()
				_touch_two_pan = false
			else:
				var center := (_touch1_pos + _touch2_pos) / 2.0
				if not _touch_two_pan:
					_touch_two_pan = true
					_touch_two_pan_center = center
					_touch_two_pan_root = map_root.position
				else:
					map_root.position = _touch_two_pan_root + (center - _touch_two_pan_center)
		_sync_player_view_if_synced()
		_recompute_player_view_indicator()
	elif _touch1_idx != -1 and _touch2_idx == -1:
		if _touch_on_token and _selected_token:
			if not _touch_drag_initialized:
				var map_pos := _touch_to_map_pos(pos)
				if _selected_token.position.distance_to(map_pos) > 3.0:
					_touch_drag_initialized = true
					_dragging_token = true
					_drag_offset = map_pos - _selected_token.position
					_drag_start_pos = _selected_token.position
					_save_drag_start_positions()
			if _dragging_token:
				var map_pos := _touch_to_map_pos(pos)
				var new_pos := map_pos - _drag_offset
				var delta := new_pos - _selected_token.position
				for s in _selected_tokens:
					s.position += delta
					EventBus.token_moved.emit(str(s.token_data.get_instance_id()), _drag_start_positions.get(s.get_instance_id(), s.position), s.position)
				var cell_px := _get_cell_px()
				var cells := GameState.count_cells_grid(_drag_start_pos, _selected_token.position, cell_px,
					GameState.get_current_grid().origin, GameState.diagonal_rule)
				var limit_px: float = -1.0
				if _selected_token.token_data.speed_ft > 0 and cell_px > 0:
					limit_px = float(_selected_token.token_data.speed_ft) / GameState.feet_per_cell * cell_px
				EventBus.token_drag_update.emit(_drag_start_pos, _selected_token.position, GameState.get_distance_label(cells), limit_px)
				token_layer.show_drag_ghost(_drag_start_pos, _selected_token.position,
					GameState.get_distance_label(cells), limit_px)
		elif _touch_on_token and not _selected_token:
			_touch_on_token = false
		if not _touch_on_token and not _dragging_token:
			var map_pos := _touch_to_map_pos(pos)
			if not _touch_marquee:
				_touch_marquee = true
				_touch_marquee_start = map_pos
				_marquee_selecting = true
				_marquee_start = map_pos
				_marquee_end = map_pos
			else:
				_marquee_end = map_pos
				token_layer.show_marquee(_marquee_start, _marquee_end)


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
	_sync_player_view_if_synced()
	_recompute_player_view_indicator()


func _apply_zoom() -> void:
	var pct := int(_zoom_level * 100)
	zoom_label.text = "%d%%" % pct
	zoom_in_btn.disabled = _zoom_level >= ZOOM_MAX
	zoom_out_btn.disabled = _zoom_level <= ZOOM_MIN


# ─── Paneo ───────────────────────────────────────────────

func _handle_keyboard_pan() -> bool:
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
		return true
	return false


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
	var gd := GameState.get_current_grid()
	gd.visible = not gd.visible
	grid_panel.visible = gd.visible
	_apply_grid_panel_values(gd)
	_refresh_grid()
	EventBus.grid_updated.emit()


func _on_grid_updated() -> void:
	_refresh_grid()


func _refresh_grid() -> void:
	var gd := GameState.get_current_grid()
	if gd:
		grid_layer.rotation_degrees = gd.rotation_degrees
	grid_layer.refresh()


func _setup_grid_panel() -> void:
	grid_cell_size_slider.value_changed.connect(_on_grid_cell_size_slider)
	grid_cell_dec10_btn.pressed.connect(func(): _adjust_cell_size(-10))
	grid_cell_dec1_btn.pressed.connect(func(): _adjust_cell_size(-1))
	grid_cell_inc1_btn.pressed.connect(func(): _adjust_cell_size(1))
	grid_cell_inc10_btn.pressed.connect(func(): _adjust_cell_size(10))
	grid_color_picker.color_changed.connect(_on_grid_color_changed)
	grid_opacity_slider.value_changed.connect(_on_grid_opacity_changed)
	grid_line_width_slider.value_changed.connect(_on_grid_line_width_changed)
	grid_show_coords_check.toggled.connect(_on_grid_show_coords_toggled)
	origin_x_dec10.pressed.connect(func(): _adjust_origin_x(-10))
	origin_x_dec1.pressed.connect(func(): _adjust_origin_x(-1))
	origin_x_inc1.pressed.connect(func(): _adjust_origin_x(1))
	origin_x_inc10.pressed.connect(func(): _adjust_origin_x(10))
	origin_y_dec10.pressed.connect(func(): _adjust_origin_y(-10))
	origin_y_dec1.pressed.connect(func(): _adjust_origin_y(-1))
	origin_y_inc1.pressed.connect(func(): _adjust_origin_y(1))
	origin_y_inc10.pressed.connect(func(): _adjust_origin_y(10))
	rotation_dec1.pressed.connect(func(): _adjust_rotation(-1.0))
	rotation_dec01.pressed.connect(func(): _adjust_rotation(-0.1))
	rotation_inc01.pressed.connect(func(): _adjust_rotation(0.1))
	rotation_inc1.pressed.connect(func(): _adjust_rotation(1.0))
	feet_per_cell_spin.value_changed.connect(_on_feet_per_cell_changed)


func _apply_grid_panel_values(gd: Resource) -> void:
	grid_cell_size_slider.set_value_no_signal(gd.size_px)
	grid_cell_size_label.text = "Celda: %d px" % int(gd.size_px)
	grid_color_picker.color = gd.color
	grid_opacity_slider.set_value_no_signal(gd.opacity)
	grid_opacity_label.text = "Opacidad: %d%%" % int(gd.opacity * 100)
	grid_line_width_slider.set_value_no_signal(gd.line_width)
	grid_line_width_label.text = "Grosor: %d px" % int(gd.line_width)
	grid_show_coords_check.set_pressed_no_signal(gd.show_coords)
	grid_origin_label.text = "Offset: (%d, %d)" % [int(gd.origin.x), int(gd.origin.y)]
	grid_origin_x_label.text = "X: %d" % int(gd.origin.x)
	grid_origin_y_label.text = "Y: %d" % int(gd.origin.y)
	grid_rotation_label.text = "Rot: %.1f" % gd.rotation_degrees
	grid_layer.rotation_degrees = gd.rotation_degrees
	feet_per_cell_spin.set_value_no_signal(GameState.feet_per_cell)
	feet_per_cell_label.text = "Pies/celda: %.1f" % GameState.feet_per_cell


func _on_grid_cell_size_slider(value: float) -> void:
	var gd := GameState.get_current_grid()
	gd.size_px = value
	grid_cell_size_label.text = "Celda: %d px" % int(value)
	_refresh_grid()


func _adjust_cell_size(delta: float) -> void:
	var gd := GameState.get_current_grid()
	gd.size_px = clampf(gd.size_px + delta, 10.0, 500.0)
	grid_cell_size_slider.set_value_no_signal(gd.size_px)
	grid_cell_size_label.text = "Celda: %d px" % int(gd.size_px)
	_refresh_grid()


func _on_grid_color_changed(c: Color) -> void:
	var gd := GameState.get_current_grid()
	gd.color = c
	_refresh_grid()


func _on_grid_opacity_changed(value: float) -> void:
	var gd := GameState.get_current_grid()
	gd.opacity = value
	grid_opacity_label.text = "Opacidad: %d%%" % int(value * 100)
	_refresh_grid()


func _on_grid_line_width_changed(value: float) -> void:
	var gd := GameState.get_current_grid()
	gd.line_width = value
	grid_line_width_label.text = "Grosor: %d px" % int(value)
	_refresh_grid()


func _on_grid_show_coords_toggled(on: bool) -> void:
	var gd := GameState.get_current_grid()
	gd.show_coords = on
	_refresh_grid()


func _on_feet_per_cell_changed(value: float) -> void:
	GameState.feet_per_cell = value
	feet_per_cell_label.text = "Pies/celda: %.1f" % value


func _adjust_origin_x(delta: float) -> void:
	var gd := GameState.get_current_grid()
	gd.origin.x += delta
	grid_origin_label.text = "Offset: (%d, %d)" % [int(gd.origin.x), int(gd.origin.y)]
	grid_origin_x_label.text = "X: %d" % int(gd.origin.x)
	_refresh_grid()


func _adjust_origin_y(delta: float) -> void:
	var gd := GameState.get_current_grid()
	gd.origin.y += delta
	grid_origin_label.text = "Offset: (%d, %d)" % [int(gd.origin.x), int(gd.origin.y)]
	grid_origin_y_label.text = "Y: %d" % int(gd.origin.y)
	_refresh_grid()


func _adjust_rotation(delta: float) -> void:
	var gd := GameState.get_current_grid()
	gd.rotation_degrees = clampf(gd.rotation_degrees + delta, -5.0, 5.0)
	grid_rotation_label.text = "Rot: %.1f" % gd.rotation_degrees
	grid_layer.rotation_degrees = gd.rotation_degrees
	_refresh_grid()


func _on_measure_pressed() -> void:
	_measuring = not _measuring
	measure_btn.button_pressed = _measuring
	measure_toolbar.visible = _measuring
	if _measuring:
		_measure_points.clear()
		_placing_template = false
		_templates.clear()
		token_layer.show_measurement(_measure_points)
		_set_measure_mode(MeasureMode.WAYPOINTS)
		EventBus.measurement_started.emit()
	else:
		token_layer.hide_measurement()
		token_layer.hide_templates()
		_measure_points.clear()
		_templates.clear()
		EventBus.measurement_ended.emit()


func _set_measure_mode(mode: int) -> void:
	_measure_mode = mode
	measure_waypoint_btn.button_pressed = mode == MeasureMode.WAYPOINTS
	measure_circle_btn.button_pressed = mode == MeasureMode.CIRCLE
	measure_cone_btn.button_pressed = mode == MeasureMode.CONE
	measure_square_btn.button_pressed = mode == MeasureMode.SQUARE
	measure_line_btn.button_pressed = mode == MeasureMode.LINE
	_placing_template = false
	_measure_points.clear()
	_templates.clear()
	token_layer.show_measurement([])
	token_layer.hide_templates()


func _on_template_color_changed(new_color: Color) -> void:
	_template_color = new_color
	token_layer.set_template_color(_template_color, _template_cell_alpha)


func _on_template_opacity_changed(value: float) -> void:
	_template_cell_alpha = value
	template_opacity_label.text = "Opacidad: %d%%" % int(value * 100)
	token_layer.set_template_color(_template_color, _template_cell_alpha)


func _handle_template_click() -> void:
	var pos := _get_token_layer_mouse_pos()
	if not Input.is_key_pressed(KEY_SHIFT):
		var grid := GameState.get_current_grid()
		if grid and grid.size_px > 0:
			var size: int = 1
			if _measure_mode == MeasureMode.CIRCLE or _measure_mode == MeasureMode.SQUARE or _measure_mode == MeasureMode.CONE:
				size = 2
			pos = _snap_to_grid(pos, grid.size_px, grid.origin, size)
	if not _placing_template:
		_placing_template = true
		_template_start = pos
	else:
		if _measure_mode == MeasureMode.CONE:
			pos = _snap_cone_to_direction(_template_start, pos)
		_placing_template = false
		_templates.append({"type": _measure_mode, "start": _template_start, "end": pos})
		token_layer.show_templates(_templates)


func _update_template_preview() -> void:
	var pos := _get_token_layer_mouse_pos()
	if not Input.is_key_pressed(KEY_SHIFT):
		var grid := GameState.get_current_grid()
		if grid and grid.size_px > 0:
			var size: int = 1
			if _measure_mode == MeasureMode.CIRCLE or _measure_mode == MeasureMode.SQUARE or _measure_mode == MeasureMode.CONE:
				size = 2
			pos = _snap_to_grid(pos, grid.size_px, grid.origin, size)
	if _placing_template and _measure_mode == MeasureMode.CONE:
		pos = _snap_cone_to_direction(_template_start, pos)
	token_layer.show_template_preview(_measure_mode, _template_start, pos)


func _add_measure_waypoint() -> void:
	if _measure_mode != MeasureMode.WAYPOINTS:
		_handle_template_click()
		return
	var pos := _get_token_layer_mouse_pos()
	if not Input.is_key_pressed(KEY_SHIFT):
		var grid := GameState.get_current_grid()
		if grid and grid.size_px > 0:
			pos = _snap_to_grid(pos, grid.size_px, grid.origin, 1)
	_measure_points.append(pos)
	token_layer.show_measurement(_measure_points)


func _cancel_measurement() -> void:
	_measure_points.clear()
	_placing_template = false
	_templates.clear()
	token_layer.show_measurement(_measure_points)
	token_layer.hide_templates()


func _update_measurement_preview() -> void:
	var pos := _get_token_layer_mouse_pos()
	if not Input.is_key_pressed(KEY_SHIFT):
		var grid := GameState.get_current_grid()
		if grid and grid.size_px > 0:
			pos = _snap_to_grid(pos, grid.size_px, grid.origin, 1)
	token_layer.show_measurement(_measure_points, pos)


# ─── Bloqueadores de vision ──────────────────────────────

func _on_blocker_pressed() -> void:
	if _blocker_mode:
		if _current_blocker_points.size() >= 2:
			_finish_current_blocker()
		else:
			_cancel_blocker_drawing()
	_blocker_mode = not _blocker_mode
	blocker_btn.button_pressed = _blocker_mode
	blocker_toolbar.visible = _blocker_mode
	if _blocker_mode:
		_current_blocker_points.clear()
		_select_blocker("")
		_refresh_blocker_display()
	else:
		_current_blocker_points.clear()
		_select_blocker("")
		_refresh_blocker_display()


func _on_blocker_color_changed(new_color: Color) -> void:
	_blocker_color = new_color


func _on_blocker_toggle_active() -> void:
	if _selected_blocker_id == "":
		return
	var blockers: Array = GameState.get_current_vision_blockers()
	for vb in blockers:
		if vb.id == _selected_blocker_id:
			vb.active = not vb.active
			GameState.mark_dirty()
			blocker_toggle_active_btn.text = tr("Desactivar") if vb.active else tr("Activar")
			EventBus.vision_blocker_toggled.emit(vb.id, vb.active)
			break
	_refresh_blocker_display()


func _on_blocker_delete_selected() -> void:
	if _selected_blocker_id == "":
		return
	_delete_selected_blocker()


func _add_blocker_point() -> void:
	var pos := _get_token_layer_mouse_pos()
	if not Input.is_key_pressed(KEY_SHIFT):
		var grid := GameState.get_current_grid()
		if grid and grid.size_px > 0:
			pos = _snap_to_half_grid(pos, grid.size_px, grid.origin)
	_current_blocker_points.append(pos)
	if _selected_blocker_id != "":
		_select_blocker("")
	_update_blocker_preview()


func _finish_current_blocker() -> void:
	if _current_blocker_points.size() < 2:
		return
	var blockers: Array = GameState.get_current_vision_blockers()
	var vb := _make_blocker_data(_current_blocker_points)
	blockers.append(vb)
	GameState.mark_dirty()
	EventBus.vision_blocker_added.emit(vb.id)
	_current_blocker_points.clear()
	_select_blocker("")
	_refresh_blocker_display()


func _cancel_blocker_drawing() -> void:
	_current_blocker_points.clear()
	_select_blocker("")
	_refresh_blocker_display()


func _select_blocker(blocker_id: String) -> void:
	_selected_blocker_id = blocker_id
	if blocker_id == "":
		blocker_toggle_active_btn.text = tr("Activar")
		blocker_toggle_active_btn.disabled = true
		blocker_delete_btn.disabled = true
		return
	var blockers: Array = GameState.get_current_vision_blockers()
	blocker_delete_btn.disabled = false
	blocker_toggle_active_btn.disabled = false
	for vb in blockers:
		if vb.id == blocker_id:
			blocker_toggle_active_btn.text = tr("Desactivar") if vb.active else tr("Activar")
			break
	_refresh_blocker_display()


func _delete_selected_blocker() -> void:
	if _selected_blocker_id == "":
		return
	var blockers: Array = GameState.get_current_vision_blockers()
	var to_remove: int = -1
	for i in blockers.size():
		if blockers[i].id == _selected_blocker_id:
			to_remove = i
			break
	if to_remove >= 0:
		EventBus.vision_blocker_removed.emit(_selected_blocker_id)
		blockers.remove_at(to_remove)
		GameState.mark_dirty()
	_select_blocker("")
	_refresh_blocker_display()


func _find_blocker_near(pos: Vector2, threshold: float) -> String:
	var blockers: Array = GameState.get_current_vision_blockers()
	var best_id: String = ""
	var best_dist: float = threshold
	for vb in blockers:
		var pts: Array = vb.points
		for i in range(1, pts.size()):
			var a: Vector2 = pts[i - 1]
			var b: Vector2 = pts[i]
			var d := _point_to_segment_distance(pos, a, b)
			if d < best_dist:
				best_dist = d
				best_id = vb.id
	return best_id


func _find_blocker_point_near(blocker_id: String, pos: Vector2, threshold: float) -> int:
	var blockers: Array = GameState.get_current_vision_blockers()
	for vb in blockers:
		if vb.id != blocker_id:
			continue
		var pts: Array = vb.points
		for i in pts.size():
			if pos.distance_to(pts[i]) < threshold:
				return i
	return -1


func _start_dragging_blocker_point(index: int) -> void:
	_dragging_blocker_point = true
	_dragging_point_index = index
	var blockers: Array = GameState.get_current_vision_blockers()
	for vb in blockers:
		if vb.id == _selected_blocker_id:
			_dragging_point_original_pos = vb.points[index]
			break


func _update_dragging_blocker_point() -> void:
	if _selected_blocker_id == "" or _dragging_point_index < 0:
		return
	var pos := _get_token_layer_mouse_pos()
	if not Input.is_key_pressed(KEY_SHIFT):
		var grid := GameState.get_current_grid()
		if grid and grid.size_px > 0:
			pos = _snap_to_half_grid(pos, grid.size_px, grid.origin)
	var blockers: Array = GameState.get_current_vision_blockers()
	for vb in blockers:
		if vb.id == _selected_blocker_id:
			vb.points[_dragging_point_index] = pos
			_refresh_blocker_display()
			break


func _finish_dragging_blocker_point() -> void:
	if _dragging_blocker_point:
		GameState.mark_dirty()
	_dragging_blocker_point = false
	_dragging_point_index = -1


func _cancel_dragging_blocker_point() -> void:
	if _selected_blocker_id == "" or _dragging_point_index < 0:
		_dragging_blocker_point = false
		_dragging_point_index = -1
		return
	var blockers: Array = GameState.get_current_vision_blockers()
	for vb in blockers:
		if vb.id == _selected_blocker_id:
			vb.points[_dragging_point_index] = _dragging_point_original_pos
			break
	_dragging_blocker_point = false
	_dragging_point_index = -1
	_refresh_blocker_display()


func _update_blocker_preview() -> void:
	var pos := _get_token_layer_mouse_pos()
	if not Input.is_key_pressed(KEY_SHIFT):
		var grid := GameState.get_current_grid()
		if grid and grid.size_px > 0:
			pos = _snap_to_half_grid(pos, grid.size_px, grid.origin)
	token_layer.show_blocker_drawing(_current_blocker_points, pos)


func _refresh_blocker_display() -> void:
	var blockers: Array = GameState.get_current_vision_blockers()
	token_layer.show_blockers(blockers, _selected_blocker_id)
	if _current_blocker_points.size() > 0:
		token_layer.show_blocker_drawing(_current_blocker_points, _get_token_layer_mouse_pos())


func _make_blocker_data(points: Array) -> Resource:
	var vb := VisionBlockerDataClass.new()
	vb.id = VisionBlockerDataClass.create_id()
	vb.points = points.duplicate()
	vb.active = true
	vb.color = _blocker_color
	return vb


static func _point_to_segment_distance(p: Vector2, a: Vector2, b: Vector2) -> float:
	var ab := b - a
	var ap := p - a
	var length2 := ab.length_squared()
	if length2 == 0.0:
		return ap.length()
	var t := clampf(ap.dot(ab) / length2, 0.0, 1.0)
	var projection := a + t * ab
	return p.distance_to(projection)


func _on_effects_pressed() -> void:
	pass  # Fase 7 - panel de efectos


func _on_view_mode_changed(idx: int) -> void:
	GameState.view_mode = idx
	var modes := {0: "synced", 1: "independent", 2: "follow_turn"}
	EventBus.view_mode_changed.emit(modes.get(idx, "synced"))
	_sync_player_view_if_synced()


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
	elif GameState.session_path != "":
		_write_session_file(GameState.session_path)


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
	_write_session_file(path)
	EventBus.session_saved.emit(path)


func _write_session_file(path: String) -> void:
	var f := FileAccess.open(path, FileAccess.WRITE)
	if f:
		f.store_string(JSON.stringify(GameState.to_dict()))
		f.close()
		GameState.mark_clean()


func _read_session_file(path: String) -> Dictionary:
	var f := FileAccess.open(path, FileAccess.READ)
	if not f:
		return {}
	var text := f.get_as_text()
	f.close()
	var test_json_conv := JSON.new()
	var err := test_json_conv.parse(text)
	if err == OK:
		return test_json_conv.get_data()
	return {}


func _on_session_saved(path: String) -> void:
	_write_session_file(path)


func _on_session_loaded(path: String) -> void:
	var data := _read_session_file(path)
	if data.is_empty():
		return
	GameState.session_path = path
	GameState.session_name = data.get("name", path.get_file().trim_suffix(".bmap"))
	GameState.from_dict(data)
	_refresh_map_list()
	_refresh_token_list()
	_clear_token_sprites()
	if GameState.maps.size() > 0:
		GameState.current_map_index = 0
		_on_map_list_selected(0)


func _on_open_dialog_file_selected(path: String) -> void:
	if not FileAccess.file_exists(path):
		return
	_on_session_loaded(path)


func _toggle_player_window() -> void:
	if _player_window and _player_window.visible:
		_player_window.hide()
		GameState.player_window_open = false
		EventBus.player_window_closed.emit()
		return
	if not _player_window:
		_player_window = PlayerWindowScene.instantiate()
		get_tree().root.add_child(_player_window)
	if map_sprite.texture:
		_player_window.show_map(map_sprite.texture)
	var gd := GameState.get_current_grid()
	if gd:
		_player_window.set_grid(gd)
	_sync_tokens_to_player()
	_player_window.show()
	GameState.player_window_open = true
	EventBus.player_window_opened.emit()
	_sync_player_view_if_synced()


func _on_player_view_changed(view_rect: Rect2) -> void:
	_last_player_view_rect = view_rect
	if GameState.view_mode == GameState.ViewMode.SYNCED:
		token_layer.show_player_view(Rect2())
		return
	_recompute_player_view_indicator()


func _recompute_player_view_indicator() -> void:
	if _last_player_view_rect.size.x <= 0:
		return
	var dm_rect: Rect2 = Rect2()
	if map_root.scale.x > 0:
		var vp_size: Vector2 = Vector2(viewport_node.size)
		if vp_size.x <= 0 or vp_size.y <= 0:
			vp_size = size
		if vp_size.x > 0:
			dm_rect = Rect2(-map_root.position / map_root.scale.x, vp_size / map_root.scale.x)
	token_layer.show_player_view(_last_player_view_rect, dm_rect)


func _sync_player_view_if_synced() -> void:
	if not _player_window or not GameState.player_window_open:
		return
	if GameState.view_mode != GameState.ViewMode.SYNCED:
		return
	_player_window.sync_view_from_dm(map_root.scale, map_root.position)


func _sync_tokens_to_player() -> void:
	if not _player_window:
		return
	_player_window.clear_tokens()
	await get_tree().process_frame
	var cell_px := _get_cell_px()
	for child in token_layer.get_children():
		if child is TokenSpriteClass:
			var td: Resource = child.token_data
			_player_window.spawn_token(td, child.position, cell_px, str(td.get_instance_id()))


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
		grid_layer.grid_data = null
		grid_panel.visible = false
		_clear_token_sprites()
		return
	GameState.current_map_index = index
	var md = GameState.maps[index]
	if md.image_exists():
		var texture := _load_map_texture(md.image_path)
		if texture:
			map_sprite.texture = texture
			_fit_map_to_viewport()
	map_list.select(index)
	var gd := GameState.get_current_grid()
	grid_layer.grid_data = gd
	grid_panel.visible = gd.visible
	if gd.visible:
		_apply_grid_panel_values(gd)
	_refresh_grid()
	_clear_token_sprites()
	_reload_token_sprites()
	_refresh_token_list()
	_refresh_blocker_display()
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
	_sync_player_view_if_synced()
	_recompute_player_view_indicator()


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
	get_tree().root.add_child(popup)
	popup.position = DisplayServer.mouse_get_position()
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
	_create_token_from_path(path, Vector2(100, 100))


func _create_token_from_path(path: String, pos: Vector2) -> void:
	if not FileAccess.file_exists(path):
		return
	var image := Image.new()
	var err := image.load(path)
	if err != OK:
		_show_error("No se pudo cargar la imagen: " + path)
		return

	var has_transparency := _image_has_transparency(image)
	if not has_transparency:
		_show_error("La imagen no tiene transparencia. El fondo se mostrará blanco.")

	var td := TokenDataClass.new()
	td.name = path.get_file().get_basename()
	td.image_path = path
	td.size_cells = 1.0
	GameState.add_token_for_current_map(td)

	var grid := GameState.get_current_grid()
	var cell_px: float = grid.size_px if grid else 70.0
	_spawn_token_sprite(td, pos, cell_px)
	_refresh_token_list()
	EventBus.token_added.emit(td.name)


func _spawn_token_sprite(td: Resource, pos: Vector2, cell_px: float) -> void:
	var sprite: Sprite2D = TokenSpriteClass.new()
	sprite.position = pos
	sprite.apply_data(td, cell_px)
	sprite.name = td.name if td.name != "" else "token"
	token_layer.add_child(sprite)
	EventBus.token_spawned.emit(str(td.get_instance_id()), td.to_dict(), pos, cell_px)
	call_deferred("_rearrange_stacked_tokens")


func _image_has_transparency(image: Image) -> bool:
	if image.get_format() != Image.FORMAT_RGBA8:
		return false
	var used := image.get_used_rect()
	if used.size.x <= 0 or used.size.y <= 0:
		return false
	for y in range(0, image.get_height()):
		for x in range(0, image.get_width()):
			var pixel: Color = image.get_pixel(x, y)
			if pixel.a < 1.0 and pixel.a > 0.0:
				return true
	return false


func _refresh_token_list() -> void:
	token_list.clear()
	for td in GameState.get_current_tokens():
		token_list.add_item(td.name)


func _on_token_list_double_clicked(index: int) -> void:
	var tokens_arr := GameState.get_current_tokens()
	if index < 0 or index >= tokens_arr.size():
		return
	var td = tokens_arr[index]
	_center_on_token(td)


func _center_on_token(td: Resource) -> void:
	for child in token_layer.get_children():
		if child is TokenSpriteClass and child.token_data == td:
			var target: Vector2 = child.position
			map_root.position = (Vector2(viewport_node.size) / 2.0) - target * map_root.scale.x
			_recompute_player_view_indicator()
			return


func _on_files_dropped(files: PackedStringArray) -> void:
	if not _is_mouse_over_viewport():
		return
	for path in files:
		var ext := path.get_extension().to_lower()
		if ext in ["png", "jpg", "jpeg", "webp"]:
			var pos := _screen_to_map_pos(map_viewport.get_global_mouse_position())
			_create_token_from_path(path, pos)


func _screen_to_map_pos(screen_pos: Vector2) -> Vector2:
	var local_pos := screen_pos - map_viewport.global_position
	var viewport_scale: Vector2 = Vector2(viewport_node.size) / Vector2(map_viewport.size)
	var viewport_pos := local_pos * viewport_scale
	return (viewport_pos - map_root.position) / map_root.scale.x


func _refresh_token_library() -> void:
	token_library.clear()
	var dir := "res://library/tokens"
	if not DirAccess.dir_exists_absolute(dir):
		DirAccess.make_dir_recursive_absolute(dir)
		return
	var d := DirAccess.open(dir)
	if d == null:
		return
	d.list_dir_begin()
	var file_name := d.get_next()
	while file_name != "":
		if not d.current_is_dir():
			var ext := file_name.get_extension().to_lower()
			if ext in ["png", "jpg", "jpeg", "webp"]:
				var full_path := dir.path_join(file_name)
				var idx := token_library.add_item(file_name.get_basename())
				token_library.set_item_metadata(idx, full_path)
				var thumb := _get_or_create_thumbnail(full_path)
				if thumb:
					token_library.set_item_icon(idx, thumb)
		file_name = d.get_next()
	d.list_dir_end()


func _get_or_create_thumbnail(image_path: String) -> Texture2D:
	var cache_dir := "res://library/.cache"
	if not DirAccess.dir_exists_absolute(cache_dir):
		DirAccess.make_dir_recursive_absolute(cache_dir)
	var hash := image_path.sha256_text().substr(0, 16)
	var thumb_path := cache_dir.path_join(hash + ".png")
	if ResourceLoader.exists(thumb_path):
		return load(thumb_path) as Texture2D
	var img := Image.new()
	if img.load(image_path) != OK:
		return null
	img.resize(48, 48, Image.INTERPOLATE_LANCZOS)
	img.save_png(thumb_path)
	return ImageTexture.create_from_image(img)


func _on_library_get_drag_data(list: ItemList, pos: Vector2) -> Variant:
	var item := list.get_item_at_position(pos)
	if item >= 0:
		var preview := TextureRect.new()
		preview.texture = list.get_item_icon(item)
		preview.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		preview.custom_minimum_size = Vector2(48, 48)
		list.set_drag_preview(preview)
		var path: String = list.get_item_metadata(item) as String
		_library_drag_pending = path
		return path
	return null


func _on_viewport_drop(pos: Vector2, data: Variant) -> void:
	if data is String:
		var map_pos := _screen_to_map_pos(map_viewport.global_position + pos)
		_create_token_from_path(data, map_pos)


func _can_drop_library_token(data: Variant) -> bool:
	return data is String and (data as String).get_extension().to_lower() in ["png", "jpg", "jpeg", "webp"]


func _can_drop_data(_position: Vector2, data: Variant) -> bool:
	return _can_drop_library_token(data)


func _drop_data(_position: Vector2, data: Variant) -> void:
	if _is_mouse_over_viewport():
		var map_pos := _screen_to_map_pos(map_viewport.get_global_mouse_position())
		_create_token_from_path(data, map_pos)


func _on_dm_drop(pos: Vector2, data: Variant) -> void:
	if not _can_drop_library_token(data):
		return
	if not _is_mouse_over_viewport():
		return
	var map_pos := _screen_to_map_pos(map_viewport.get_global_mouse_position())
	_create_token_from_path(data, map_pos)


func _setup_properties_panel() -> void:
	prop_name_edit.text_changed.connect(_on_token_name_changed)
	prop_size_spin.value_changed.connect(_on_token_size_changed)
	prop_visible_check.toggled.connect(_on_token_visibility_toggled)
	prop_border_color.color_changed.connect(_on_token_border_color_changed)
	prop_vision_slider.value_changed.connect(_on_token_vision_changed)
	prop_speed_spin.value_changed.connect(_on_token_speed_changed)
	prop_delete_btn.pressed.connect(_delete_selected_token)

	for child in prop_conditions_flow.get_children():
		child.queue_free()

	for key in CONDITIONS:
		var info: Dictionary = CONDITIONS[key]
		var capture_key: String = key
		var cb := CheckButton.new()
		cb.text = info["label"]
		cb.add_theme_color_override("font_color", info["color"] as Color)
		cb.toggled.connect(Callable(self, "_on_condition_toggled").bind(capture_key))
		prop_conditions_flow.add_child(cb)


func _show_properties_for(sprite: Sprite2D) -> void:
	var td = sprite.token_data
	prop_name_edit.text = td.name
	prop_size_spin.set_value_no_signal(td.size_cells)
	prop_visible_check.set_pressed_no_signal(td.visible_to_players)
	prop_border_color.color = td.border_color
	prop_vision_slider.set_value_no_signal(td.vision_radius)
	prop_vision_label.text = "Vision: %d" % td.vision_radius
	prop_speed_spin.set_value_no_signal(td.speed_ft)
	for child in prop_conditions_flow.get_children():
		if child is CheckButton:
			var cb := child as CheckButton
			var key := _condition_key_for_label(cb.text)
			cb.set_pressed_no_signal(key in td.conditions)
	properties_content.visible = true


func _hide_properties() -> void:
	properties_content.visible = false


func _condition_key_for_label(label: String) -> String:
	for key in CONDITIONS:
		if CONDITIONS[key]["label"] == label:
			return key
	return ""


func _on_condition_toggled(key: String, on: bool) -> void:
	if not _selected_token or not _selected_token.token_data:
		return
	var td = _selected_token.token_data
	if on:
		if key not in td.conditions:
			td.conditions.append(key)
	else:
		td.conditions.erase(key)
	_selected_token.queue_redraw()


func _get_selected_token_data() -> Resource:
	if _selected_token:
		return _selected_token.token_data
	return null


func _on_token_name_changed(new_name: String) -> void:
	var td := _get_selected_token_data()
	if not td:
		return
	td.name = new_name
	_selected_token.name = new_name if new_name != "" else "token"
	_selected_token.queue_redraw()
	_refresh_token_list()
	EventBus.token_properties_changed.emit(_selected_token.name)


func _on_token_size_changed(value: float) -> void:
	var td := _get_selected_token_data()
	if not td:
		return
	td.size_cells = value
	_selected_token.update_cell_size(_get_cell_px())
	_selected_token.queue_redraw()
	EventBus.token_properties_changed.emit(_selected_token.name)


func _on_token_visibility_toggled(on: bool) -> void:
	var td := _get_selected_token_data()
	if not td:
		return
	td.visible_to_players = on
	EventBus.token_visibility_changed.emit(_selected_token.name, on)


func _on_token_border_color_changed(c: Color) -> void:
	var td := _get_selected_token_data()
	if not td:
		return
	td.border_color = c
	_selected_token.queue_redraw()
	EventBus.token_properties_changed.emit(_selected_token.name)


func _on_token_vision_changed(value: float) -> void:
	var td := _get_selected_token_data()
	if not td:
		return
	td.vision_radius = int(value)
	prop_vision_label.text = "Vision: %d" % int(value)
	EventBus.token_properties_changed.emit(_selected_token.name)


func _on_token_speed_changed(value: float) -> void:
	var td := _get_selected_token_data()
	if not td:
		return
	td.speed_ft = int(value)
	EventBus.token_properties_changed.emit(_selected_token.name)


func _clear_token_sprites() -> void:
	_clear_selection()
	for child in token_layer.get_children():
		child.queue_free()


func _reload_token_sprites() -> void:
	var grid := GameState.get_current_grid()
	var cell_px: float = grid.size_px if grid else 70.0
	var tokens_arr := GameState.get_current_tokens()
	var pos := Vector2(100, 100)
	for td in tokens_arr:
		_spawn_token_sprite(td, pos, cell_px)
		pos.x += cell_px * 2


func _try_select_token_or_start_marquee() -> void:
	var click_pos := _get_token_layer_mouse_pos()
	var hit: Sprite2D = null
	for child in token_layer.get_children():
		if child is TokenSpriteClass:
			var sprite_size: float = child.token_data.size_cells * _get_cell_px()
			var rect := Rect2(child.position - Vector2(sprite_size / 2, sprite_size / 2), Vector2(sprite_size, sprite_size))
			if rect.has_point(click_pos):
				hit = child
				break
	if Input.is_key_pressed(KEY_CTRL):
		if hit:
			_toggle_selection(hit)
		return
	if hit:
		if not _selected_tokens.has(hit):
			_clear_selection()
			_selected_tokens.append(hit)
			hit.select()
		_selected_token = hit
		_show_properties_for(hit)
		_dragging_token = true
		_drag_offset = click_pos - hit.position
		_drag_start_pos = hit.position
		_save_drag_start_positions()
	else:
		_hide_properties()
		_marquee_selecting = true
		_marquee_start = click_pos
		_marquee_end = click_pos


func _try_token_context_menu() -> void:
	var click_pos := _get_token_layer_mouse_pos()
	for child in token_layer.get_children():
		if child is TokenSpriteClass:
			var sprite_size: float = child.token_data.size_cells * _get_cell_px()
			var rect := Rect2(child.position - Vector2(sprite_size / 2, sprite_size / 2), Vector2(sprite_size, sprite_size))
			if rect.has_point(click_pos):
				_select_token(child)
				_show_token_context_menu(child)
				return


func _select_token(sprite: Sprite2D) -> void:
	_clear_selection()
	if sprite:
		_selected_tokens.append(sprite)
		_selected_token = sprite
		sprite.select()
		_show_properties_for(sprite)


func _toggle_selection(sprite: Sprite2D) -> void:
	if _selected_tokens.has(sprite):
		_remove_from_selection(sprite)
	else:
		_selected_tokens.append(sprite)
		sprite.select()
		if _selected_tokens.size() == 1:
			_selected_token = sprite
			_show_properties_for(sprite)


func _finish_marquee_select() -> void:
	var rect := Rect2(_marquee_start, _marquee_end - _marquee_start).abs()
	_clear_selection()
	for child in token_layer.get_children():
		if child is TokenSpriteClass:
			if rect.has_point(child.position):
				_selected_tokens.append(child)
				child.select()
	if _selected_tokens.size() > 0:
		_selected_token = _selected_tokens[0]
		_show_properties_for(_selected_token)


func _rearrange_stacked_tokens() -> void:
	var cell_px: float = _get_cell_px()
	var origin: Vector2 = GameState.get_current_grid().origin
	var pos_map: Dictionary = {}
	for child in token_layer.get_children():
		if not child is TokenSpriteClass:
			continue
		var key: Vector2 = ((child.position - origin) / cell_px).round()
		var key_str := "%d,%d" % [int(key.x), int(key.y)]
		if key_str not in pos_map:
			pos_map[key_str] = []
		pos_map[key_str].append(child)
	for key_str in pos_map:
		var sprites: Array = pos_map[key_str]
		if sprites.size() <= 1:
			continue
		var offset_r: float = cell_px * 0.15
		for i in sprites.size():
			var sprite: Sprite2D = sprites[i]
			var angle: float = TAU * i / sprites.size()
			var real_pos: Vector2 = ((sprite.position - origin) / cell_px).round() * cell_px + origin
			sprite.position = real_pos + Vector2(cos(angle), sin(angle)) * offset_r


func _remove_from_selection(sprite: Sprite2D) -> void:
	sprite.deselect()
	_selected_tokens.erase(sprite)
	if _selected_token == sprite:
		_selected_token = _selected_tokens[0] if _selected_tokens.size() > 0 else null
		if _selected_token:
			_show_properties_for(_selected_token)
		else:
			_hide_properties()


func _clear_selection() -> void:
	for s in _selected_tokens:
		if is_instance_valid(s):
			s.deselect()
	_selected_tokens.clear()
	_selected_token = null
	_hide_properties()


func _save_drag_start_positions() -> void:
	_drag_start_positions.clear()
	for s in _selected_tokens:
		if is_instance_valid(s):
			_drag_start_positions[s.get_instance_id()] = s.position


func _get_token_layer_mouse_pos() -> Vector2:
	var vp_mouse := _get_viewport_mouse_pos()
	var viewport_scale: Vector2 = Vector2(viewport_node.size) / Vector2(map_viewport.size)
	var world_pos: Vector2 = vp_mouse * viewport_scale
	return (world_pos - map_root.position) / map_root.scale.x


func _get_cell_px() -> float:
	var grid := GameState.get_current_grid()
	return grid.size_px if grid else 70.0


func _update_drag_position() -> void:
	if not _selected_token:
		return
	var pos := _get_token_layer_mouse_pos()
	var delta := (pos - _drag_offset) - _selected_token.position
	for s in _selected_tokens:
		s.position += delta
		EventBus.token_moved.emit(str(s.token_data.get_instance_id()), _drag_start_positions.get(s.get_instance_id(), s.position), s.position)
	var snapped := _compute_snap_position(_selected_token.position, _selected_token.token_data.size_cells)
	var cell_px := _get_cell_px()
	var cells := GameState.count_cells_grid(_drag_start_pos, snapped, cell_px,
		GameState.get_current_grid().origin, GameState.diagonal_rule)
	var limit_px: float = -1.0
	if _selected_token.token_data.speed_ft > 0 and cell_px > 0:
		var max_cells: float = float(_selected_token.token_data.speed_ft) / GameState.feet_per_cell
		limit_px = max_cells * cell_px
	EventBus.token_drag_update.emit(_drag_start_pos, snapped, GameState.get_distance_label(cells), limit_px)
	token_layer.show_drag_ghost(_drag_start_pos, snapped,
		GameState.get_distance_label(cells), limit_px)


func _stop_dragging() -> void:
	_dragging_token = false
	token_layer.hide_drag_ghost()
	EventBus.token_drag_end.emit()
	if _selected_tokens.size() > 0:
		var use_snap := not Input.is_key_pressed(KEY_SHIFT)
		for s in _selected_tokens:
			var start_pos: Vector2 = _drag_start_positions.get(s.get_instance_id(), s.position)
			if use_snap:
				_snap_token_position(s)
			EventBus.token_moved.emit(str(s.token_data.get_instance_id()), start_pos, s.position)
		if _selected_token:
			token_layer.show_movement_trace(_drag_start_pos, _selected_token.position)
	_rearrange_stacked_tokens()
	_drag_start_pos = Vector2.ZERO
	_drag_offset = Vector2.ZERO
	_drag_start_positions.clear()


func _on_token_moved_from_signal(token_id: String, _from_pos: Vector2, to_pos: Vector2) -> void:
	for child in token_layer.get_children():
		if child is TokenSpriteClass:
			if str(child.token_data.get_instance_id()) == token_id:
				if not _dragging_token or not _selected_tokens.has(child):
					child.position = to_pos
					_rearrange_stacked_tokens()
				return


func _on_token_drag_update(from: Vector2, to: Vector2, distance_text: String, limit_px: float) -> void:
	token_layer.show_drag_ghost(from, to, distance_text, limit_px)


func _on_token_drag_end() -> void:
	token_layer.hide_drag_ghost()


func _handle_arrow_move(event: InputEventKey) -> void:
	var cell_px: float = _get_cell_px()
	if cell_px <= 0:
		return
	var fine: bool = event.shift_pressed
	var step: float = 1.0 if fine else cell_px
	var dir := Vector2.ZERO
	match event.keycode:
		KEY_LEFT:  dir.x = -1.0
		KEY_RIGHT: dir.x = 1.0
		KEY_UP:    dir.y = -1.0
		KEY_DOWN:  dir.y = 1.0
		_: return
	var start_pos := _selected_token.position
	_selected_token.position += dir * step
	if not fine:
		_snap_token_position(_selected_token)
	EventBus.token_moved.emit(str(_selected_token.token_data.get_instance_id()), start_pos, _selected_token.position)
	token_layer.show_movement_trace(start_pos, _selected_token.position)
	_rearrange_stacked_tokens()


func _snap_token_position(sprite: Sprite2D) -> void:
	var grid := GameState.get_current_grid()
	var cell_px: float = grid.size_px
	if cell_px <= 0:
		return
	var size: int = int(ceil(sprite.token_data.size_cells))
	sprite.position = _snap_to_grid(sprite.position, cell_px, grid.origin, size)


func _compute_snap_position(pos: Vector2, size_cells: float = 1.0) -> Vector2:
	var grid := GameState.get_current_grid()
	var cell_px: float = grid.size_px
	if cell_px <= 0:
		return pos
	return _snap_to_grid(pos, cell_px, grid.origin, int(ceil(size_cells)))


func _snap_to_grid(pos: Vector2, cell_px: float, origin: Vector2, size: int) -> Vector2:
	if size % 2 == 0:
		return Vector2(
			round((pos.x - origin.x) / cell_px) * cell_px + origin.x,
			round((pos.y - origin.y) / cell_px) * cell_px + origin.y
		)
	return Vector2(
		floor((pos.x - origin.x) / cell_px) * cell_px + cell_px / 2.0 + origin.x,
		floor((pos.y - origin.y) / cell_px) * cell_px + cell_px / 2.0 + origin.y
	)


func _snap_to_half_grid(pos: Vector2, cell_px: float, origin: Vector2) -> Vector2:
	if cell_px <= 0:
		return pos
	var half: float = cell_px / 2.0
	return Vector2(
		round((pos.x - origin.x) / half) * half + origin.x,
		round((pos.y - origin.y) / half) * half + origin.y
	)


func _snap_cone_to_direction(start: Vector2, end: Vector2) -> Vector2:
	var dir := end - start
	var dist: float = dir.length()
	if dist < 1.0:
		return end
	var angle: float = dir.angle()
	var snapped: float = round(angle / (PI / 4.0)) * (PI / 4.0)
	return start + Vector2(cos(snapped), sin(snapped)) * dist


func _update_distance_preview() -> void:
	if not _selected_token:
		return
	var cursor := _get_token_layer_mouse_pos()
	var snapped := _compute_snap_position(cursor, _selected_token.token_data.size_cells)
	var cell_px := _get_cell_px()
	var cells := GameState.count_cells_grid(_selected_token.position, snapped, cell_px,
		GameState.get_current_grid().origin, GameState.diagonal_rule)
	token_layer.show_distance_preview(_selected_token.position, snapped,
		GameState.get_distance_label(cells))


func _show_token_context_menu(sprite: Sprite2D) -> void:
	var popup := PopupMenu.new()
	popup.add_item("Duplicar", 0)
	popup.add_item("Guardar en biblioteca", 1)
	popup.add_separator()
	popup.add_item("Eliminar", 2)
	popup.id_pressed.connect(func(id: int):
		match id:
			0: _duplicate_token(sprite)
			1: _save_token_to_library(sprite)
			2: _delete_token_sprite(sprite)
		popup.queue_free()
	)
	get_tree().root.add_child(popup)
	popup.position = DisplayServer.mouse_get_position()
	popup.popup()


func _duplicate_token(sprite: Sprite2D) -> void:
	var td: Resource = sprite.token_data
	var copy := TokenDataClass.new()
	copy.name = td.name + " (copia)"
	copy.image_path = td.image_path
	copy.size_cells = td.size_cells
	copy.border_color = td.border_color
	copy.visible_to_players = td.visible_to_players
	copy.vision_radius = td.vision_radius
	copy.speed_ft = td.speed_ft
	GameState.add_token_for_current_map(copy)
	var offset := Vector2(_get_cell_px(), 0)
	_spawn_token_sprite(copy, sprite.position + offset, _get_cell_px())
	_refresh_token_list()


func _save_token_to_library(sprite: Sprite2D) -> void:
	var td: Resource = sprite.token_data
	if not td or td.image_path == "":
		return
	var abs_lib: String = ProjectSettings.globalize_path("res://library/tokens")
	if not DirAccess.dir_exists_absolute(abs_lib):
		DirAccess.make_dir_recursive_absolute(abs_lib)
	var src_path: String = td.image_path
	var dest_name: String = td.name + "." + src_path.get_extension()
	var dest_path: String = abs_lib.path_join(dest_name)
	if src_path != "" and FileAccess.file_exists(src_path):
		var img := Image.new()
		if img.load(src_path) == OK:
			img.save_png(dest_path)
	_refresh_token_library()


func _delete_selected_token() -> void:
	if not _selected_token:
		return
	_delete_token_sprite(_selected_token)


func _delete_token_sprite(sprite: Sprite2D) -> void:
	var tokens_arr := GameState.get_current_tokens()
	var idx := tokens_arr.find(sprite.token_data)
	if idx >= 0:
		GameState.remove_token_for_current_map(idx)
	_remove_from_selection(sprite)
	sprite.queue_free()
	_refresh_token_list()
	EventBus.token_removed.emit(sprite.name)
