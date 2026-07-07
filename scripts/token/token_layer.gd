extends Node2D

## TokenLayer — capa que contiene los sprites de tokens y dibuja lineas fantasma durante arrastre.

var _ghost_start: Vector2 = Vector2.ZERO
var _ghost_end: Vector2 = Vector2.ZERO
var _ghost_visible: bool = false
var _distance_text: String = ""

var _trace_from: Vector2 = Vector2.ZERO
var _trace_to: Vector2 = Vector2.ZERO
var _trace_visible: bool = false


func show_drag_ghost(start: Vector2, end: Vector2, distance_text: String) -> void:
	_ghost_start = start
	_ghost_end = end
	_ghost_visible = true
	_distance_text = distance_text
	queue_redraw()


func hide_drag_ghost() -> void:
	_ghost_visible = false
	_distance_text = ""
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


func _draw() -> void:
	if _trace_visible:
		_draw_dashed_line(_trace_from, _trace_to, Color(1, 1, 1, 0.4), 1.5)
	if _ghost_visible:
		_draw_dashed_line(_ghost_start, _ghost_end, Color.WHITE, 2.0)
		if _distance_text != "":
			var mid := (_ghost_start + _ghost_end) / 2.0
			draw_string(ThemeDB.fallback_font, mid + Vector2(0, -12), _distance_text, HORIZONTAL_ALIGNMENT_CENTER, -1, 14)


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
