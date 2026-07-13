extends Window

## PlayerWindow — ventana independiente para jugadores.
## Muestra mapa, rejilla y tokens visibles. Sin toolbars.

const TokenSpriteClass := preload("res://scripts/token/token_sprite.gd")
const GridRendererClass := preload("res://scripts/grid/grid_renderer.gd")

@onready var viewport_container: SubViewportContainer = %ViewportContainer
@onready var viewport_node: SubViewport = %Viewport
@onready var map_root: Node2D = %MapRoot
@onready var map_sprite: Sprite2D = %MapSprite
@onready var grid_layer: Node2D = %GridLayer
@onready var token_layer: Node2D = %TokenLayer

var _token_sprites: Dictionary = {}
var _grid_renderer: Node2D
var _grid_data: Resource

var _dragging_token: bool = false
var _drag_sprite: Sprite2D
var _drag_offset: Vector2 = Vector2.ZERO
var _drag_start_pos: Vector2 = Vector2.ZERO

var _panning: bool = false
var _pan_start: Vector2 = Vector2.ZERO
var _pan_root_start: Vector2 = Vector2.ZERO

var _touch1_index: int = -1
var _touch2_index: int = -1
var _touch1_pos: Vector2 = Vector2.ZERO
var _touch2_pos: Vector2 = Vector2.ZERO
var _pinch_start_dist: float = 0.0
var _pinch_start_scale: float = 0.0
var _pinch_center: Vector2 = Vector2.ZERO
var _two_pan: bool = false
var _two_pan_center: Vector2 = Vector2.ZERO
var _two_pan_root: Vector2 = Vector2.ZERO
var _touch_on_token: bool = false
var _touch_drag_init: bool = false

const ZOOM_MIN := 0.1
const ZOOM_MAX := 4.0
const ZOOM_STEP := 1.25


func _ready() -> void:
	_setup_grid_renderer()
	set_process_input(true)
	close_requested.connect(_on_close_requested)
	size_changed.connect(_notify_view_changed)
	EventBus.token_moved.connect(_on_token_moved)
	EventBus.token_spawned.connect(_on_token_spawned)
	EventBus.token_removed.connect(_on_token_removed)
	EventBus.token_visibility_changed.connect(_on_token_visibility_changed)
	EventBus.grid_updated.connect(_on_grid_updated)
	EventBus.view_mode_changed.connect(_on_view_mode_changed)
	EventBus.token_drag_update.connect(_on_token_drag_update)
	EventBus.token_drag_end.connect(_on_token_drag_end)
	call_deferred("_notify_view_changed")


func _setup_grid_renderer() -> void:
	_grid_renderer = GridRendererClass.new()
	grid_layer.add_child(_grid_renderer)


func show_map(texture: Texture2D) -> void:
	map_sprite.texture = texture
	_fit_map_to_viewport()
	call_deferred("_notify_view_changed")


func _fit_map_to_viewport() -> void:
	if not map_sprite.texture:
		return
	var tex_size := map_sprite.texture.get_size()
	if tex_size.x <= 0 or tex_size.y <= 0:
		return
	var vp_size: Vector2 = Vector2(viewport_node.size)
	var scale_x: float = vp_size.x / tex_size.x
	var scale_y: float = vp_size.y / tex_size.y
	var s: float = min(scale_x, scale_y)
	map_root.scale = Vector2(s, s)
	map_root.position = Vector2.ZERO
	_notify_view_changed()


func set_grid(grid_data: Resource) -> void:
	_grid_data = grid_data
	if _grid_renderer:
		_grid_renderer.grid_data = grid_data
		_grid_renderer.queue_redraw()


func spawn_token(td: Resource, position: Vector2, cell_px: float, token_id: String = "") -> void:
	if token_id == "":
		token_id = str(td.get_instance_id())
	if _token_sprites.has(token_id):
		return
	var sprite := TokenSpriteClass.new()
	sprite.apply_data(td, cell_px)
	sprite.position = position
	token_layer.add_child(sprite)
	_token_sprites[token_id] = sprite


func move_token(token_id: String, to_pos: Vector2) -> void:
	var sprite: Sprite2D = _token_sprites.get(token_id)
	if sprite:
		sprite.position = to_pos


func remove_token(token_id: String) -> void:
	var sprite: Sprite2D = _token_sprites.get(token_id)
	if sprite:
		sprite.queue_free()
		_token_sprites.erase(token_id)


func clear_tokens() -> void:
	for child in token_layer.get_children():
		child.queue_free()
	_token_sprites.clear()


func set_token_visible(token_id: String, visible: bool) -> void:
	var sprite: Sprite2D = _token_sprites.get(token_id)
	if sprite:
		sprite.visible = visible


func _on_token_moved(token_id: String, _from_pos: Vector2, to_pos: Vector2) -> void:
	move_token(token_id, to_pos)


func _on_token_spawned(token_id: String, td_dict: Dictionary, position: Vector2, cell_px: float) -> void:
	var TokenDataClass := preload("res://scripts/token/token_data.gd")
	var td := TokenDataClass.from_dict(td_dict)
	spawn_token(td, position, cell_px, token_id)


func _on_token_removed(token_id: String) -> void:
	remove_token(token_id)


func _on_token_visibility_changed(token_name: String, visible: bool) -> void:
	for id in _token_sprites:
		var sprite: Sprite2D = _token_sprites[id]
		if sprite.name == token_name:
			sprite.visible = visible
			return


func _on_grid_updated(_grid_data: Resource) -> void:
	if _grid_data:
		set_grid(_grid_data)


func _on_view_mode_changed(_mode: String) -> void:
	pass


func sync_view_from_dm(scale: Vector2, position: Vector2) -> void:
	map_root.scale = scale
	map_root.position = position


func _on_token_drag_update(from: Vector2, to: Vector2, distance_text: String, _limit_px: float) -> void:
	token_layer.show_drag_ghost(from, to, distance_text)


func _on_token_drag_end() -> void:
	token_layer.hide_drag_ghost()


func _on_close_requested() -> void:
	GameState.player_window_open = false
	EventBus.player_window_closed.emit()
	hide()


func _input(event: InputEvent) -> void:
	if GameState.view_mode == GameState.ViewMode.SYNCED:
		return
	var vp_mouse := viewport_container.get_local_mouse_position()
	var in_viewport: bool = vp_mouse.x >= 0 and vp_mouse.y >= 0 and vp_mouse.x <= viewport_container.size.x and vp_mouse.y <= viewport_container.size.y
	if not in_viewport:
		return
	if event is InputEventScreenTouch:
		_handle_touch(event)
		return
	if event is InputEventScreenDrag:
		_handle_drag(event)
		return
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_WHEEL_UP:
			_zoom(vp_mouse, ZOOM_STEP)
			return
		elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			_zoom(vp_mouse, 1.0 / ZOOM_STEP)
			return
		elif event.button_index == MOUSE_BUTTON_LEFT:
			if event.pressed:
				_try_start_drag()
			elif _dragging_token:
				_stop_drag()
				return
		elif event.button_index == MOUSE_BUTTON_MIDDLE:
			if event.pressed:
				_panning = true
				_pan_start = vp_mouse
				_pan_root_start = map_root.position
			else:
				_panning = false
	if event is InputEventMouseMotion:
		if _panning:
			var delta: Vector2 = vp_mouse - _pan_start
			map_root.position = _pan_root_start + delta
			_notify_view_changed()
		elif _dragging_token:
			_update_drag_position()


func _handle_touch(event: InputEventScreenTouch) -> void:
	var pos: Vector2 = event.position
	if event.pressed:
		if _touch1_index == -1:
			_touch1_index = event.index
			_touch1_pos = pos
			_touch_drag_init = false
			_touch_on_token = false
			var click_pos := _touch_to_map_pos(pos)
			for child in token_layer.get_children():
				if child is TokenSpriteClass:
					var td: Resource = child.token_data
					var cell_px: float = td.size_cells * (_grid_data.size_px if _grid_data else 70.0)
					var half: float = cell_px * 0.5
					if Rect2(child.position - Vector2(half, half), Vector2(cell_px, cell_px)).has_point(click_pos):
						_touch_on_token = true
						_drag_sprite = child
						_drag_start_pos = child.position
						_touch_drag_init = false
						break
		elif _touch2_index == -1 and event.index != _touch1_index:
			_touch2_index = event.index
			_touch2_pos = pos
			_pinch_start_dist = _touch1_pos.distance_to(_touch2_pos)
			_pinch_start_scale = map_root.scale.x
			_pinch_center = (_touch1_pos + _touch2_pos) / 2.0
			_two_pan = false
			_touch_on_token = false
			if _dragging_token:
				_stop_drag()
	else:
		if event.index == _touch1_index:
			if _dragging_token and _touch2_index == -1:
				_stop_drag()
			_touch1_index = _touch2_index
			_touch1_pos = _touch2_pos
			_touch2_index = -1
			_touch2_pos = Vector2.ZERO
			_pinch_start_dist = 0.0
			_two_pan = false
			_touch_drag_init = false
		elif event.index == _touch2_index:
			_touch2_index = -1
			_touch2_pos = Vector2.ZERO
			_pinch_start_dist = 0.0
			_two_pan = false


func _handle_drag(event: InputEventScreenDrag) -> void:
	var pos: Vector2 = event.position
	if event.index == _touch1_index:
		_touch1_pos = pos
	elif event.index == _touch2_index:
		_touch2_pos = pos
	if _touch2_index != -1:
		var dist: float = _touch1_pos.distance_to(_touch2_pos)
		if _pinch_start_dist > 0:
			var delta_dist: float = abs(dist - _pinch_start_dist)
			if delta_dist > 5.0:
				var factor: float = dist / _pinch_start_dist
				var new_scale: float = clampf(_pinch_start_scale * factor, ZOOM_MIN, ZOOM_MAX)
				var before: Vector2 = _to_world(_pinch_center)
				map_root.scale = Vector2(new_scale, new_scale)
				var after: Vector2 = _to_world(_pinch_center)
				map_root.position += before - after
				_notify_view_changed()
				_two_pan = false
			else:
				var center := (_touch1_pos + _touch2_pos) / 2.0
				if not _two_pan:
					_two_pan = true
					_two_pan_center = center
					_two_pan_root = map_root.position
				else:
					map_root.position = _two_pan_root + (center - _two_pan_center)
					_notify_view_changed()
	elif _touch1_index != -1 and _touch2_index == -1:
		if _touch_on_token and _drag_sprite:
			var map_pos := _touch_to_map_pos(pos)
			if not _touch_drag_init and _drag_start_pos.distance_to(map_pos) > 3.0:
				_touch_drag_init = true
				_dragging_token = true
				_drag_offset = map_pos - _drag_sprite.position
			if _dragging_token:
				var new_pos := map_pos - _drag_offset
				_drag_sprite.position = new_pos
				var cell_px: float = _grid_data.size_px if _grid_data else 70.0
				var origin: Vector2 = _grid_data.origin if _grid_data else Vector2.ZERO
				var cells := GameState.count_cells_grid(_drag_start_pos, _drag_sprite.position, cell_px, origin, GameState.diagonal_rule)
				token_layer.show_drag_ghost(_drag_start_pos, _drag_sprite.position, GameState.get_distance_label(cells))
				EventBus.token_drag_update.emit(_drag_start_pos, _drag_sprite.position, GameState.get_distance_label(cells), -1.0)


func _touch_to_map_pos(screen_pos: Vector2) -> Vector2:
	var scale_vec := Vector2(viewport_container.size) / Vector2(viewport_node.size)
	var world_pos := screen_pos * scale_vec
	return (world_pos - map_root.position) / map_root.scale.x


func _to_world(vp_pos: Vector2) -> Vector2:
	var scale_vec: Vector2 = Vector2(viewport_container.size) / Vector2(viewport_node.size)
	var world_pos: Vector2 = vp_pos * scale_vec
	return (world_pos - map_root.position) / map_root.scale.x


func _zoom(at_pos: Vector2, factor: float) -> void:
	var new_scale := map_root.scale * factor
	if new_scale.x < ZOOM_MIN or new_scale.x > ZOOM_MAX:
		return
	var before: Vector2 = _to_world(at_pos)
	map_root.scale = new_scale
	var after: Vector2 = _to_world(at_pos)
	map_root.position += before - after
	_notify_view_changed()


func _to_token_layer_pos() -> Vector2:
	var vp_mouse := viewport_container.get_local_mouse_position()
	var scale_vec: Vector2 = Vector2(viewport_container.size) / Vector2(viewport_node.size)
	var world_pos: Vector2 = vp_mouse * scale_vec
	return (world_pos - map_root.position) / map_root.scale.x


func _try_start_drag() -> void:
	var click_pos := _to_token_layer_pos()
	for child in token_layer.get_children():
		if child is TokenSpriteClass:
			var td: Resource = child.token_data
			var cell_px: float = td.size_cells * (_grid_data.size_px if _grid_data else 70.0)
			var half: float = cell_px / 2.0
			var rect := Rect2(child.position - Vector2(half, half), Vector2(cell_px, cell_px))
			if rect.has_point(click_pos):
				_dragging_token = true
				_drag_sprite = child
				_drag_offset = click_pos - child.position
				_drag_start_pos = child.position
				return


func _update_drag_position() -> void:
	if not _drag_sprite:
		return
	var pos := _to_token_layer_pos()
	_drag_sprite.position = pos - _drag_offset
	var cell_px: float = _grid_data.size_px if _grid_data else 70.0
	var origin: Vector2 = _grid_data.origin if _grid_data else Vector2.ZERO
	var snapped: Vector2 = pos  # player doesn't snap during drag
	var cells := GameState.count_cells_grid(_drag_start_pos, snapped, cell_px, origin, GameState.diagonal_rule)
	token_layer.show_drag_ghost(_drag_start_pos, snapped, GameState.get_distance_label(cells))
	EventBus.token_drag_update.emit(_drag_start_pos, snapped, GameState.get_distance_label(cells), -1.0)


func _stop_drag() -> void:
	_dragging_token = false
	token_layer.hide_drag_ghost()
	EventBus.token_drag_end.emit()
	if _drag_sprite:
		var token_id: String = ""
		for id in _token_sprites:
			if _token_sprites[id] == _drag_sprite:
				token_id = id
				break
		if token_id != "":
			EventBus.token_moved.emit(token_id, _drag_start_pos, _drag_sprite.position)
	_drag_sprite = null
	_drag_offset = Vector2.ZERO
	_drag_start_pos = Vector2.ZERO


func _notify_view_changed() -> void:
	var vp_size: Vector2 = Vector2(viewport_node.size)
	if vp_size.x <= 0 or vp_size.y <= 0:
		vp_size = size
	if vp_size.x <= 0 or vp_size.y <= 0:
		return
	var s: Vector2 = map_root.scale
	if s.x <= 0:
		return
	var view_rect := Rect2(-map_root.position / s.x, vp_size / s.x)
	EventBus.player_view_changed.emit(view_rect)
