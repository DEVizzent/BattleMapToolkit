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

const ZOOM_MIN := 0.1
const ZOOM_MAX := 4.0
const ZOOM_STEP := 1.25


func _ready() -> void:
	_setup_grid_renderer()
	connect("close_requested", _on_close_requested)
	EventBus.token_moved.connect(_on_token_moved)
	EventBus.token_spawned.connect(_on_token_spawned)
	EventBus.token_removed.connect(_on_token_removed)
	EventBus.token_visibility_changed.connect(_on_token_visibility_changed)
	EventBus.grid_updated.connect(_on_grid_updated)
	EventBus.view_mode_changed.connect(_on_view_mode_changed)
	close_requested.connect(hide)


func _setup_grid_renderer() -> void:
	_grid_renderer = GridRendererClass.new()
	grid_layer.add_child(_grid_renderer)


func show_map(texture: Texture2D) -> void:
	map_sprite.texture = texture
	_fit_map_to_viewport()


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


func set_grid(grid_data: Resource) -> void:
	_grid_data = grid_data
	if _grid_renderer:
		_grid_renderer.grid_data = grid_data
		_grid_renderer.queue_redraw()


func spawn_token(td: Resource, position: Vector2, cell_px: float) -> void:
	var token_id := str(td.get_instance_id())
	if _token_sprites.has(token_id):
		return
	var sprite := TokenSpriteClass.new()
	sprite.token_data = td
	sprite.update_cell_size(cell_px)
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


func set_token_visible(token_id: String, visible: bool) -> void:
	var sprite: Sprite2D = _token_sprites.get(token_id)
	if sprite:
		sprite.visible = visible


func _on_token_moved(token_id: String, _from_pos: Vector2, to_pos: Vector2) -> void:
	move_token(token_id, to_pos)


func _on_token_spawned(token_id: String, td_dict: Dictionary, position: Vector2, cell_px: float) -> void:
	var TokenDataClass := preload("res://scripts/token/token_data.gd")
	var td := TokenDataClass.from_dict(td_dict)
	spawn_token(td, position, cell_px)


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


func _on_close_requested() -> void:
	GameState.player_window_open = false
	EventBus.player_window_closed.emit()
	hide()


func _gui_input(event: InputEvent) -> void:
	if GameState.view_mode != GameState.ViewMode.INDEPENDENT:
		return
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_WHEEL_UP:
			_zoom(viewport_container.get_local_mouse_position(), ZOOM_STEP)
		elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			_zoom(viewport_container.get_local_mouse_position(), 1.0 / ZOOM_STEP)


func _zoom(at_pos: Vector2, factor: float) -> void:
	var new_scale := map_root.scale * factor
	if new_scale.x < ZOOM_MIN or new_scale.x > ZOOM_MAX:
		return
	var before: Vector2 = _to_world(at_pos)
	map_root.scale = new_scale
	var after: Vector2 = _to_world(at_pos)
	map_root.position += before - after


func _to_world(vp_pos: Vector2) -> Vector2:
	var scale_vec: Vector2 = Vector2(viewport_container.size) / Vector2(viewport_node.size)
	var world_pos: Vector2 = vp_pos * scale_vec
	return (world_pos - map_root.position) / map_root.scale.x
