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
	if not selected:
		return
	var border_color: Color = token_data.border_color if token_data else Color.YELLOW
	border_color.a = 0.9
	if texture:
		var tex_size: Vector2 = texture.get_size()
		var rect := Rect2(-tex_size / 2.0, tex_size)
		draw_rect(rect, border_color, false, 2.0)
	else:
		var size_px: float = token_data.size_cells * _cell_size_px if token_data else _cell_size_px
		var half: float = size_px / 2.0
		draw_rect(Rect2(Vector2(-half, -half), Vector2(size_px, size_px)), border_color, false, 2.0)
	if token_data and token_data.name != "":
		var tex_size: Vector2 = texture.get_size() if texture else Vector2(_cell_size_px, _cell_size_px)
		var half_h: float = tex_size.y / 2.0
		var label_pos := Vector2(0, half_h + 14)
		draw_string(ThemeDB.fallback_font, label_pos, token_data.name, HORIZONTAL_ALIGNMENT_CENTER, -1, 12)


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
