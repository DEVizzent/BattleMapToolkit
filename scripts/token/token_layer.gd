extends Node2D

## TokenLayer — capa que contiene los sprites de tokens y dibuja lineas fantasma durante arrastre.

var _ghost_start: Vector2 = Vector2.ZERO
var _ghost_end: Vector2 = Vector2.ZERO
var _ghost_visible: bool = false
var _distance_text: String = ""
var _speed_limit_px: float = -1.0

var _trace_from: Vector2 = Vector2.ZERO
var _trace_to: Vector2 = Vector2.ZERO
var _trace_visible: bool = false

var _hover_text: String = ""
var _hover_start: Vector2 = Vector2.ZERO
var _hover_end: Vector2 = Vector2.ZERO

var _marquee_visible: bool = false
var _marquee_rect: Rect2 = Rect2()

var _measure_visible: bool = false
var _measure_points: Array = []
var _measure_preview: Vector2 = Vector2.ZERO
var _measure_has_preview: bool = false


func show_drag_ghost(start: Vector2, end: Vector2, distance_text: String, speed_limit_px: float = -1.0) -> void:
	_ghost_start = start
	_ghost_end = end
	_ghost_visible = true
	_distance_text = distance_text
	_speed_limit_px = speed_limit_px
	queue_redraw()


func hide_drag_ghost() -> void:
	_ghost_visible = false
	_distance_text = ""
	_speed_limit_px = -1.0
	queue_redraw()


func show_movement_trace(from: Vector2, to: Vector2) -> void:
	_trace_from = from
	_trace_to = to
	_trace_visible = true
	queue_redraw()
	var timer := get_tree().create_timer(2.0)
	timer.timeout.connect(hide_movement_trace)


func hide_movement_trace() -> void:
	_trace_visible = false
	queue_redraw()


func show_distance_preview(from: Vector2, to: Vector2, text: String) -> void:
	_hover_text = text
	_hover_start = from
	_hover_end = to
	queue_redraw()


func hide_distance_preview() -> void:
	_hover_text = ""
	queue_redraw()


func show_marquee(from: Vector2, to: Vector2) -> void:
	_marquee_visible = true
	_marquee_rect = Rect2(from, to - from).abs()
	queue_redraw()


func hide_marquee() -> void:
	_marquee_visible = false
	queue_redraw()


func show_measurement(points: Array, preview: Vector2 = Vector2.ZERO) -> void:
	_measure_visible = true
	_measure_points = points.duplicate()
	_measure_preview = preview
	_measure_has_preview = preview != Vector2.ZERO
	queue_redraw()


func hide_measurement() -> void:
	_measure_visible = false
	_measure_has_preview = false
	_measure_points.clear()
	queue_redraw()


func _draw() -> void:
	if _trace_visible:
		_draw_dashed_line(_trace_from, _trace_to, Color(1, 1, 1, 0.4), 1.5)
	if _marquee_visible:
		draw_rect(_marquee_rect, Color(0.3, 0.7, 1.0, 0.3), false, 1.5)
	if _measure_visible:
		_draw_measurement()
	if _hover_text != "":
		_draw_dashed_line(_hover_start, _hover_end, Color(1, 1, 1, 0.3), 1.0)
		var mid: Vector2 = (_hover_start + _hover_end) / 2.0
		draw_string(ThemeDB.fallback_font, mid + Vector2(0, -12), _hover_text, HORIZONTAL_ALIGNMENT_CENTER, -1, 14)
		return
	if _ghost_visible:
		if _speed_limit_px > 0:
			var dir_vec := _ghost_end - _ghost_start
			var total := dir_vec.length()
			if total > _speed_limit_px:
				var unit := dir_vec.normalized()
				_draw_dashed_line(_ghost_start, _ghost_start + unit * _speed_limit_px, Color.WHITE, 2.0)
				_draw_dashed_line(_ghost_start + unit * _speed_limit_px, _ghost_end, Color(0.9, 0.2, 0.2), 2.0)
			else:
				_draw_dashed_line(_ghost_start, _ghost_end, Color.WHITE, 2.0)
		else:
			_draw_dashed_line(_ghost_start, _ghost_end, Color.WHITE, 2.0)
		if _distance_text != "":
			var mid := (_ghost_start + _ghost_end) / 2.0
			draw_string(ThemeDB.fallback_font, mid + Vector2(0, -12), _distance_text, HORIZONTAL_ALIGNMENT_CENTER, -1, 14)


func _draw_measurement() -> void:
	var color: Color = Color(0.0, 0.8, 1.0, 0.8)
	var circle_r: float = 4.0
	var total_dist: float = 0.0
	for i in _measure_points.size():
		var pt: Vector2 = _measure_points[i]
		draw_circle(pt, circle_r, color)
		if i > 0:
			var prev: Vector2 = _measure_points[i - 1]
			draw_line(prev, pt, color, 1.5)
			var seg_dist: float = prev.distance_to(pt)
			total_dist += seg_dist
			var mid: Vector2 = (prev + pt) / 2.0
			var label: String = _measure_distance_label(seg_dist, total_dist)
			draw_string(ThemeDB.fallback_font, mid + Vector2(10, -10), label, HORIZONTAL_ALIGNMENT_LEFT, -1, 13, color)
	if _measure_has_preview and _measure_points.size() > 0:
		var last: Vector2 = _measure_points[-1]
		_draw_dashed_line(last, _measure_preview, Color(0.0, 0.8, 1.0, 0.4), 1.0)
		var preview_dist: float = last.distance_to(_measure_preview)
		var label: String = _measure_distance_label(preview_dist, total_dist + preview_dist)
		var mid: Vector2 = (last + _measure_preview) / 2.0
		draw_string(ThemeDB.fallback_font, mid + Vector2(10, -10), label, HORIZONTAL_ALIGNMENT_LEFT, -1, 13, Color(0.0, 0.8, 1.0, 0.4))


func _measure_distance_label(seg: float, total: float) -> String:
	var cell_px: float = 70.0
	var grid := GameState.get_current_grid()
	if grid and grid.size_px > 0:
		cell_px = grid.size_px
	var cells: float = seg / cell_px
	var total_cells: float = total / cell_px
	if GameState.current_units == GameState.Units.METERS:
		return "%.1fm | %.1fm" % [cells * GameState.meters_per_cell, total_cells * GameState.meters_per_cell]
	return "%.0fft | %.0fft" % [cells * GameState.feet_per_cell, total_cells * GameState.feet_per_cell]


func _draw_dashed_line(from: Vector2, to: Vector2, color: Color, width: float) -> void:
	var dash_len := 6.0
	var gap_len := 4.0
	var dir_vec := to - from
	var total := dir_vec.length()
	if total < 1.0:
		return
	var unit := dir_vec.normalized()
	var pos := from
	var remaining := total
	var draw := true
	while remaining > 0:
		var seg := dash_len if draw else gap_len
		if seg > remaining:
			seg = remaining
		if draw:
			draw_line(pos, pos + unit * seg, color, width)
		pos += unit * seg
		remaining -= seg
		draw = not draw
