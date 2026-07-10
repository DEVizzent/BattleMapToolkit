extends Sprite2D

## TokenSprite — sprite de un token sobre el mapa.
## Gestiona textura, tamano en pixeles segun size_cells, seleccion y visibilidad.

var token_data: Resource
var selected: bool = false
var show_border: bool = true

var _cell_size_px: float = 70.0


func apply_data(td: Resource, cell_px: float) -> void:
	token_data = td
	_cell_size_px = cell_px
	texture = _load_texture(td.image_path)
	centered = true
	var size_px: float = td.size_cells * cell_px
	if texture:
		var tex_size: Vector2 = texture.get_size()
		var max_dim: float = maxf(tex_size.x, tex_size.y)
		if max_dim > 0:
			scale = Vector2(size_px / max_dim, size_px / max_dim)
	name = td.name if td.name != "" else "token"
	queue_redraw()


func select() -> void:
	selected = true
	queue_redraw()


func deselect() -> void:
	selected = false
	queue_redraw()


func update_cell_size(cell_px: float) -> void:
	if not token_data:
		return
	_cell_size_px = cell_px
	var size_px: float = token_data.size_cells * cell_px
	if texture:
		var tex_size: Vector2 = texture.get_size()
		var max_dim: float = maxf(tex_size.x, tex_size.y)
		if max_dim > 0:
			scale = Vector2(size_px / max_dim, size_px / max_dim)


func _draw() -> void:
	_draw_selection_border()
	_draw_name_label()
	_draw_condition_indicators()
	_draw_stack_badge()


func _draw_selection_border() -> void:
	if not selected:
		return
	var border_color: Color = token_data.border_color if token_data else Color.YELLOW
	border_color.a = 0.9
	var line_width: float = maxf(0.5, 3.0 / maxf(scale.x, 0.01))
	if texture:
		var tex_size: Vector2 = texture.get_size()
		var rect := Rect2(-tex_size / 2.0, tex_size)
		draw_rect(rect, border_color, false, line_width)
	else:
		var size_px: float = token_data.size_cells * _cell_size_px if token_data else _cell_size_px
		var half: float = size_px / 2.0
		draw_rect(Rect2(Vector2(-half, -half), Vector2(size_px, size_px)), border_color, false, line_width)


func _draw_name_label() -> void:
	if not selected:
		return
	if token_data and token_data.name != "":
		var tex_size: Vector2 = texture.get_size() if texture else Vector2(_cell_size_px, _cell_size_px)
		var half_h: float = tex_size.y / 2.0
		var label_pos := Vector2(0, half_h + 14)
		draw_string(ThemeDB.fallback_font, label_pos, token_data.name, HORIZONTAL_ALIGNMENT_CENTER, -1, 12)


func _draw_condition_indicators() -> void:
	if not token_data or token_data.conditions.is_empty():
		return
	var colors := {
		"envenenado": Color.PURPLE,
		"paralizado": Color.GRAY,
		"concentracion": Color.YELLOW,
		"hechizado": Color.PINK,
		"asustado": Color.ORANGE,
		"invisible": Color.CORNFLOWER_BLUE,
	}
	var tex_size: Vector2 = texture.get_size() if texture else Vector2(_cell_size_px, _cell_size_px)
	var start_x: float = -tex_size.x / 2.0 + 4
	var start_y: float = -tex_size.y / 2.0 + 4
	var dot_r: float = 5.0
	for i in token_data.conditions.size():
		var cond: String = token_data.conditions[i]
		var c: Color = colors.get(cond, Color.WHITE)
		c.a = 0.9
		var pos := Vector2(start_x + i * (dot_r * 2 + 3), start_y)
		draw_circle(pos, dot_r, c)


func _draw_stack_badge() -> void:
	var parent_node := get_parent()
	if not parent_node:
		return
	var same_cell := 0
	var threshold: float = _cell_size_px * 0.4
	for child in parent_node.get_children():
		if child != self and child is Sprite2D and child.has_method("apply_data"):
			if position.distance_squared_to(child.position) < threshold * threshold:
				same_cell += 1
	if same_cell > 0:
		var tex_size: Vector2 = texture.get_size() if texture else Vector2(_cell_size_px, _cell_size_px)
		var badge_pos := Vector2(tex_size.x / 2.0 - 8, -tex_size.y / 2.0 - 4)
		var color := Color.WHITE
		color.a = 0.9
		draw_circle(badge_pos, 8, Color(0.2, 0.2, 0.2, 0.8))
		draw_string(ThemeDB.fallback_font, badge_pos + Vector2(-3, 4), str(same_cell + 1), HORIZONTAL_ALIGNMENT_LEFT, -1, 12, color)


func _load_texture(path: String) -> Texture2D:
	if not FileAccess.file_exists(path):
		return null
	var image := Image.new()
	var err := image.load(path)
	if err != OK:
		return null
	image = _crop_transparent(image)
	return ImageTexture.create_from_image(image)


func _crop_transparent(img: Image) -> Image:
	var rect := img.get_used_rect()
	if rect.size.x == 0 or rect.size.y == 0:
		return img
	if rect.position == Vector2i.ZERO and rect.size == img.get_size():
		return img
	var cropped := Image.create(rect.size.x, rect.size.y, false, img.get_format())
	cropped.blit_rect(img, rect, Vector2i.ZERO)
	return cropped
