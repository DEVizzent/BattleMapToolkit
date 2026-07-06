extends Node2D

## TokenLayer — capa que contiene los sprites de tokens y dibuja lineas fantasma durante arrastre.

var _ghost_start: Vector2 = Vector2.ZERO
var _ghost_end: Vector2 = Vector2.ZERO
var _ghost_visible: bool = false
var _distance_text: String = ""


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


func _draw() -> void:
	if not _ghost_visible:
		return
	var dash_len := 6.0
	var gap_len := 4.0
	var dir_vec := _ghost_end - _ghost_start
	var total := dir_vec.length()
	if total < 1.0:
		return
	var unit := dir_vec.normalized()
	var pos := _ghost_start
	var remaining := total
	var draw := true
	while remaining > 0:
		var seg := dash_len if draw else gap_len
		if seg > remaining:
			seg = remaining
		if draw:
			draw_line(pos, pos + unit * seg, Color.WHITE, 2.0)
		pos += unit * seg
		remaining -= seg
		draw = not draw
	if _distance_text != "":
		var mid := (_ghost_start + _ghost_end) / 2.0
		draw_string(ThemeDB.fallback_font, mid + Vector2(0, -12), _distance_text, HORIZONTAL_ALIGNMENT_CENTER, -1, 14)
