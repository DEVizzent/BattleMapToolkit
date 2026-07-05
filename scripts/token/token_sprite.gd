extends Sprite2D

## TokenSprite — sprite de un token sobre el mapa.
## Gestiona textura, tamano en pixeles segun size_cells, y visibilidad.

var token_data: Resource

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
