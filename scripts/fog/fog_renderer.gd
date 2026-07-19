extends Node2D

## FogRenderer — capa de niebla sobre el mapa (solo ventana Player).
## 11.2: revelado circular alrededor de tokens con vision.

var _enabled: bool = true
var _viewport_rect: Rect2 = Rect2()
var _visions: Array = []
var _cell_px: float = 70.0
var _origin: Vector2 = Vector2.ZERO

const MAX_CELLS := 2500 

func set_enabled(enabled: bool) -> void:
	_enabled = enabled
	queue_redraw()


func set_viewport_rect(rect: Rect2) -> void:
	_viewport_rect = rect
	queue_redraw()


func set_visions(visions: Array, cell_px: float, origin: Vector2) -> void:
	_visions = visions
	_cell_px = cell_px
	_origin = origin
	queue_redraw()


func _draw() -> void:
	if not _enabled:
		return
	var vr: Rect2 = _viewport_rect
	if vr.size.x <= 0 or vr.size.y <= 0:
		return
	if _visions.is_empty() or _cell_px <= 0:
		draw_rect(vr, Color(0, 0, 0, 1.0))
		return

	var cell_px: float = _cell_px
	var origin: Vector2 = _origin

	var min_col: int = int(floor((vr.position.x - origin.x) / cell_px)) - 1
	var max_col: int = int(ceil((vr.end.x - origin.x) / cell_px)) + 1
	var min_row: int = int(floor((vr.position.y - origin.y) / cell_px)) - 1
	var max_row: int = int(ceil((vr.end.y - origin.y) / cell_px)) + 1

	var col_count: int = max_col - min_col + 1
	var row_count: int = max_row - min_row + 1
	if col_count * row_count > MAX_CELLS:
		draw_rect(vr, Color(0, 0, 0, 1.0))
		return

	for row in range(min_row, max_row + 1):
		var y: float = row * cell_px + origin.y
		var cy: float = row * cell_px + cell_px / 2.0 + origin.y
		var run_start: int = min_col
		var run_visible: bool = true
		var run_was_started: bool = false

		for col in range(min_col, max_col + 2):
			var visible: bool = false
			if col <= max_col:
				var cx: float = col * cell_px + cell_px / 2.0 + origin.x
				visible = _is_cell_visible(Vector2(cx, cy))
			if col > max_col or visible != run_visible:
				if run_was_started and not run_visible:
					var x: float = run_start * cell_px + origin.x
					var w: float = (col - run_start) * cell_px
					draw_rect(Rect2(x, y, w, cell_px), Color(0, 0, 0, 1.0))
				run_start = col
				run_visible = visible
				run_was_started = true


func _is_cell_visible(cell_center: Vector2) -> bool:
	for v in _visions:
		var dist: float = cell_center.distance_to(v.position)
		if dist <= v.radius:
			return true
	return false
