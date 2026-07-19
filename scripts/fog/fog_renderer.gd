extends Node2D

## FogRenderer — capa de niebla sobre el mapa (solo ventana Player).
## 11.2: revelado circular alrededor de tokens con vision.
## 11.3: 3 niveles: oculto / explorado / visible.
## 11.5: borde suave en la transicion visible↔oculto.

const HIDDEN := 0
const HIDDEN_EDGE := 1
const EXPLORED := 2
const EXPLORED_EDGE := 3
const VISIBLE := 4

var _enabled: bool = true
var _viewport_rect: Rect2 = Rect2()
var _visions: Array = []
var _cell_px: float = 70.0
var _origin: Vector2 = Vector2.ZERO
var _explored: Dictionary = {}

const MAX_CELLS := 2500


func set_enabled(enabled: bool) -> void:
	_enabled = enabled
	queue_redraw()


func set_viewport_rect(rect: Rect2) -> void:
	_viewport_rect = rect
	queue_redraw()


func set_visions(visions: Array, cell_px: float, origin: Vector2, explored: Dictionary = {}) -> void:
	_visions = visions
	_cell_px = cell_px
	_origin = origin
	_explored = explored
	queue_redraw()


func _draw() -> void:
	if not _enabled:
		return
	var vr: Rect2 = _viewport_rect
	if vr.size.x <= 0 or vr.size.y <= 0:
		return
	if _visions.is_empty() or _cell_px <= 0:
		_draw_full_fog(vr)
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
		_draw_full_fog(vr)
		return

	for row in range(min_row, max_row + 1):
		var y: float = row * cell_px + origin.y
		var run_start: int = min_col
		var run_state: int = _get_cell_state(min_col, row)
		var run_was_started: bool = true

		for col in range(min_col + 1, max_col + 2):
			var state: int = -1
			if col <= max_col:
				state = _get_cell_state(col, row)
			if col > max_col or state != run_state:
				if run_was_started:
					match run_state:
						HIDDEN:
							var x: float = run_start * cell_px + origin.x
							var w: float = (col - run_start) * cell_px
							draw_rect(Rect2(x, y, w, cell_px), Color(0, 0, 0, 1.0))
						HIDDEN_EDGE:
							var x: float = run_start * cell_px + origin.x
							var w: float = (col - run_start) * cell_px
							draw_rect(Rect2(x, y, w, cell_px), Color(0, 0, 0, 0.8))
						EXPLORED:
							var x: float = run_start * cell_px + origin.x
							var w: float = (col - run_start) * cell_px
							draw_rect(Rect2(x, y, w, cell_px), Color(0, 0, 0, 0.55))
						EXPLORED_EDGE:
							var x: float = run_start * cell_px + origin.x
							var w: float = (col - run_start) * cell_px
							draw_rect(Rect2(x, y, w, cell_px), Color(0, 0, 0, 0.35))
				run_start = col
				run_state = state
				run_was_started = true


func _get_cell_state(col: int, row: int) -> int:
	if _is_cell_visible_at(col, row):
		_explore_cell(col, row)
		return VISIBLE
	var explored: bool = _explored.has("%d,%d" % [col, row])
	if _has_visible_neighbor(col, row):
		return EXPLORED_EDGE if explored else HIDDEN_EDGE
	return EXPLORED if explored else HIDDEN


func _is_cell_visible_at(col: int, row: int) -> bool:
	var cx: float = col * _cell_px + _cell_px / 2.0 + _origin.x
	var cy: float = row * _cell_px + _cell_px / 2.0 + _origin.y
	for v in _visions:
		var dist: float = Vector2(cx, cy).distance_to(v.position)
		if dist <= v.radius:
			return true
	return false


func _is_cell_visible(cell_center: Vector2) -> bool:
	for v in _visions:
		var dist: float = cell_center.distance_to(v.position)
		if dist <= v.radius:
			return true
	return false


func _has_visible_neighbor(col: int, row: int) -> bool:
	for dr in [-1, 0, 1]:
		for dc in [-1, 0, 1]:
			if dr == 0 and dc == 0:
				continue
			if _is_cell_visible_at(col + dc, row + dr):
				return true
	return false


func _explore_cell(col: int, row: int) -> void:
	var key := "%d,%d" % [col, row]
	if not _explored.has(key):
		_explored[key] = true


func _draw_full_fog(vr: Rect2) -> void:
	draw_rect(vr, Color(0, 0, 0, 1.0))
