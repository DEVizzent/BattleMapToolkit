extends Node2D

## GridRenderer — dibuja lineas de cuadricula con draw_line() sobre la capa GridLayer.

var grid_data: Resource

var _redraw_pending: bool = false


func refresh() -> void:
	if not _redraw_pending:
		_redraw_pending = true
		call_deferred("queue_redraw")


func _draw() -> void:
	_redraw_pending = false
	if not grid_data or not grid_data.visible:
		return

	var draw_color: Color = grid_data.color
	draw_color.a = grid_data.opacity
	var size_px: float = grid_data.size_px
	var origin: Vector2 = grid_data.origin
	var width: float = grid_data.line_width

	var bounds: Rect2 = _get_map_bounds()
	if size_px <= 0:
		return

	var x: float = origin.x
	while x <= bounds.end.x:
		draw_line(Vector2(x, bounds.position.y), Vector2(x, bounds.end.y), draw_color, width)
		x += size_px
	x = origin.x - size_px
	while x >= bounds.position.x:
		draw_line(Vector2(x, bounds.position.y), Vector2(x, bounds.end.y), draw_color, width)
		x -= size_px

	var y: float = origin.y
	while y <= bounds.end.y:
		draw_line(Vector2(bounds.position.x, y), Vector2(bounds.end.x, y), draw_color, width)
		y += size_px
	y = origin.y - size_px
	while y >= bounds.position.y:
		draw_line(Vector2(bounds.position.x, y), Vector2(bounds.end.x, y), draw_color, width)
		y -= size_px


func _get_map_bounds() -> Rect2:
	var parent := get_parent()
	if not parent:
		return Rect2(Vector2.ZERO, Vector2(10000, 10000))
	var sprite: Sprite2D = parent.get_node_or_null("MapSprite") as Sprite2D
	if sprite and sprite.texture:
		return Rect2(Vector2.ZERO, sprite.texture.get_size())
	return Rect2(Vector2.ZERO, Vector2(10000, 10000))
