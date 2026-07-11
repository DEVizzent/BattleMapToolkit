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

var _templates: Array = []
var _template_preview_mode: int = -1
var _template_preview_start: Vector2 = Vector2.ZERO
var _template_preview_end: Vector2 = Vector2.ZERO
var _template_line_color: Color = Color(0.0, 0.8, 1.0, 1.0)
var _template_cell_alpha: float = 0.25

var _player_view_rect: Rect2 = Rect2()
var _player_view_visible: bool = false
var _dm_view_rect: Rect2 = Rect2()


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


func show_templates(templates: Array) -> void:
	_templates = templates.duplicate()
	queue_redraw()


func hide_templates() -> void:
	_templates.clear()
	_template_preview_mode = -1
	queue_redraw()


func show_template_preview(mode: int, from: Vector2, to: Vector2) -> void:
	_template_preview_mode = mode
	_template_preview_start = from
	_template_preview_end = to
	queue_redraw()


func set_template_color(color: Color, cell_alpha: float) -> void:
	_template_line_color = color
	_template_cell_alpha = cell_alpha
	queue_redraw()


func show_player_view(view_rect: Rect2, dm_view: Rect2 = Rect2()) -> void:
	if view_rect.size.x <= 0 or view_rect.size.y <= 0:
		_player_view_visible = false
	else:
		_player_view_rect = view_rect
		_dm_view_rect = dm_view
		_player_view_visible = true
	queue_redraw()


func _draw() -> void:
	if _trace_visible:
		_draw_dashed_line(_trace_from, _trace_to, Color(1, 1, 1, 0.4), 1.5)
	if _marquee_visible:
		draw_rect(_marquee_rect, Color(0.3, 0.7, 1.0, 0.3), false, 1.5)
	if _measure_visible:
		_draw_measurement()
	_draw_templates()
	if _player_view_visible:
		_draw_player_view_rect()
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


func _draw_player_view_rect() -> void:
	var color: Color = _template_line_color
	color.a = 0.7
	var r := _player_view_rect
	var dm := _dm_view_rect

	if dm.size.x <= 0 or dm.size.y <= 0:
		_draw_dashed_rect(r, color)
		return

	var overlap := dm.intersection(r)
	if overlap.size.x <= 0 or overlap.size.y <= 0:
		# Fully off-screen: arrow at closest edge
		_draw_arrow_toward(r, dm, color)
	elif overlap.size.x < r.size.x or overlap.size.y < r.size.y:
		# Partial overlap: visible portion + arrow
		_draw_dashed_rect(overlap, color)
		_draw_arrow_toward(r, dm, color)
	else:
		# Fully on screen
		_draw_dashed_rect(r, color)


func _draw_dashed_rect(r: Rect2, color: Color) -> void:
	_draw_dashed_line(Vector2(r.position.x, r.position.y), Vector2(r.end.x, r.position.y), color, 2.0)
	_draw_dashed_line(Vector2(r.end.x, r.position.y), r.end, color, 2.0)
	_draw_dashed_line(r.end, Vector2(r.position.x, r.end.y), color, 2.0)
	_draw_dashed_line(Vector2(r.position.x, r.end.y), r.position, color, 2.0)


func _draw_arrow_toward(target: Rect2, dm_rect: Rect2, color: Color) -> void:
	# Target extends past left edge
	if target.position.x < dm_rect.position.x:
		var dist: float = dm_rect.position.x - target.position.x
		var y: float = clampf(target.get_center().y, dm_rect.position.y, dm_rect.end.y)
		var ap := Vector2(dm_rect.position.x, y)
		_draw_arrow(ap, Vector2.LEFT, color)
		_draw_distance_label(ap, Vector2.LEFT, dist, color)
	
	# Target extends past right edge
	if target.end.x > dm_rect.end.x:
		var dist: float = target.end.x - dm_rect.end.x
		var y: float = clampf(target.get_center().y, dm_rect.position.y, dm_rect.end.y)
		var ap := Vector2(dm_rect.end.x, y)
		_draw_arrow(ap, Vector2.RIGHT, color)
		_draw_distance_label(ap, Vector2.RIGHT, dist, color)
	
	# Target extends past top edge
	if target.position.y < dm_rect.position.y:
		var dist: float = dm_rect.position.y - target.position.y
		var x: float = clampf(target.get_center().x, dm_rect.position.x, dm_rect.end.x)
		var ap := Vector2(x, dm_rect.position.y)
		_draw_arrow(ap, Vector2.UP, color)
		_draw_distance_label(ap, Vector2.UP, dist, color)
	
	# Target extends past bottom edge
	if target.end.y > dm_rect.end.y:
		var dist: float = target.end.y - dm_rect.end.y
		var x: float = clampf(target.get_center().x, dm_rect.position.x, dm_rect.end.x)
		var ap := Vector2(x, dm_rect.end.y)
		_draw_arrow(ap, Vector2.DOWN, color)
		_draw_distance_label(ap, Vector2.DOWN, dist, color)


func _draw_arrow(at: Vector2, dir: Vector2, color: Color) -> void:
	var s := 10.0
	if dir == Vector2.LEFT:
		draw_line(at, at + Vector2(s, s), color, 2.0)
		draw_line(at, at + Vector2(s, -s), color, 2.0)
	elif dir == Vector2.RIGHT:
		draw_line(at, at + Vector2(-s, s), color, 2.0)
		draw_line(at, at + Vector2(-s, -s), color, 2.0)
	elif dir == Vector2.UP:
		draw_line(at, at + Vector2(s, s), color, 2.0)
		draw_line(at, at + Vector2(-s, s), color, 2.0)
	elif dir == Vector2.DOWN:
		draw_line(at, at + Vector2(s, -s), color, 2.0)
		draw_line(at, at + Vector2(-s, -s), color, 2.0)


func _draw_distance_label(at: Vector2, dir: Vector2, dist_px: float, color: Color) -> void:
	var cell_px: float = 70.0
	var grid := GameState.get_current_grid()
	if grid and grid.size_px > 0:
		cell_px = grid.size_px
	var label: String
	var offset: Vector2
	if GameState.current_units == GameState.Units.METERS:
		var meters: float = (dist_px / cell_px) * GameState.meters_per_cell
		label = "%.1fm" % meters
	else:
		var feet: float = (dist_px / cell_px) * GameState.feet_per_cell
		label = "%.0fft" % feet
	
	if dir == Vector2.LEFT:
		offset = Vector2(-60, -6)
	elif dir == Vector2.RIGHT:
		offset = Vector2(12, -6)
	elif dir == Vector2.UP:
		offset = Vector2(12, -20)
	else:
		offset = Vector2(12, 14)
	draw_string(ThemeDB.fallback_font, at + offset, label, HORIZONTAL_ALIGNMENT_LEFT, -1, 12, color)


func _draw_templates() -> void:
	var color: Color = _template_line_color
	color.a = 0.5
	var fill_color: Color = _template_line_color
	fill_color.a = _template_cell_alpha * 0.4
	var cell_color: Color = _template_line_color
	cell_color.a = _template_cell_alpha
	for tmpl in _templates:
		var t: Dictionary = tmpl
		_draw_template_shape(t["type"] as int, t["start"] as Vector2, t["end"] as Vector2, color, fill_color, cell_color)
	if _template_preview_mode >= 0:
		var pc: Color = _template_line_color
		pc.a = 0.3
		_draw_template_shape(_template_preview_mode, _template_preview_start, _template_preview_end, pc, Color(1.0, 1.0, 1.0, 0.05), Color(1.0, 1.0, 1.0, 0.12))


func _draw_template_shape(mode: int, start: Vector2, end: Vector2, line_color: Color, fill: Color, cell_fill: Color) -> void:
	match mode:
		0, -1: return
		1:  # Circle
			var r: float = start.distance_to(end)
			_draw_template_cells(mode, start, end, cell_fill)
			draw_circle(start, r, fill)
			draw_arc(start, r, 0, TAU, 64, line_color, 1.5)
		2:  # Cone
			_draw_template_cells(mode, start, end, cell_fill)
			_draw_cone(start, end, line_color, fill)
		3:  # Square
			_draw_template_cells(mode, start, end, cell_fill)
			var rect := Rect2(start, end - start).abs()
			draw_rect(rect, fill)
			draw_rect(rect, line_color, false, 1.5)
		4:  # Line
			_draw_template_cells(mode, start, end, cell_fill)
			var dir_vec := end - start
			var length: float = dir_vec.length()
			if length > 0:
				var perp := Vector2(-dir_vec.y, dir_vec.x).normalized() * 5.0
				draw_line(start, end, line_color, 2.0)
				draw_line(start + perp, end + perp, line_color, 1.0)
				draw_line(start - perp, end - perp, line_color, 1.0)


func _draw_cone(origin: Vector2, target: Vector2, line_color: Color, fill: Color) -> void:
	var dir_vec := target - origin
	var length: float = dir_vec.length()
	if length < 1.0:
		return
	var angle: float = dir_vec.angle()
	var half_angle: float = deg_to_rad(40.0)
	var arc_points: PackedVector2Array = [origin]
	var steps := 16
	for i in range(steps + 1):
		var a: float = angle - half_angle + (2.0 * half_angle) * i / steps
		arc_points.append(origin + Vector2(cos(a), sin(a)) * length)
	if fill.a > 0:
		draw_colored_polygon(arc_points, fill)
	for i in range(1, arc_points.size() - 1):
		draw_line(arc_points[i], arc_points[i + 1], line_color, 1.0)
	draw_line(origin, arc_points[1], line_color, 1.5)
	draw_line(origin, arc_points[arc_points.size() - 1], line_color, 1.5)


func _point_to_segment_distance(p: Vector2, a: Vector2, b: Vector2) -> float:
	var ab := b - a
	var ap := p - a
	var ab_len_sq := ab.length_squared()
	if ab_len_sq < 0.0001:
		return ap.length()
	var t := clampf(ap.dot(ab) / ab_len_sq, 0.0, 1.0)
	var proj := a + t * ab
	return p.distance_to(proj)


func _is_cell_in_shape(mode: int, start: Vector2, end: Vector2, center: Vector2, cell_px: float) -> bool:
	match mode:
		1:
			return center.distance_squared_to(start) <= start.distance_squared_to(end)
		2:
			return _is_in_xanathar_cone(center, start, end, cell_px)
		3:
			var rect := Rect2(start, end - start).abs()
			return rect.has_point(center)
		4:
			return _point_to_segment_distance(center, start, end) <= cell_px / 2.0
		_:
			return false


func _is_in_xanathar_cone(center: Vector2, start: Vector2, end: Vector2, cell_px: float) -> bool:
	var grid := GameState.get_current_grid()
	if not grid or grid.size_px <= 0:
		return false
	var go: Vector2 = grid.origin

	var sc_float: float = (start.x - go.x) / cell_px
	var sr_float: float = (start.y - go.y) / cell_px
	var cc: int = floor((center.x - go.x) / cell_px)
	var cr: int = floor((center.y - go.y) / cell_px)
	var sc: int = floor(sc_float)
	var sr: int = floor(sr_float)

	var de_c: float = (end.x - start.x) / cell_px
	var de_r: float = (end.y - start.y) / cell_px

	var dir_c: int = sign(de_c) if abs(de_c) > 0.4 else 0
	var dir_r: int = sign(de_r) if abs(de_r) > 0.4 else 0

	var cone_len: int = 0
	if dir_c != 0 or dir_r != 0:
		var ec: int = floor((end.x - go.x) / cell_px)
		var er: int = floor((end.y - go.y) / cell_px)
		cone_len = max(abs(ec - sc), abs(er - sr))
	else:
		return false
	if cone_len < 1:
		return false

	if dir_c != 0 and dir_r != 0:
		var cone_dir := end - start
		var cone_len_sq: float = cone_dir.length_squared()
		if cone_len_sq < 1.0:
			return false
		var vec := center - start
		var dist_sq: float = vec.length_squared()
		if dist_sq > cone_len_sq + cell_px * cell_px:
			return false
		var cone_angle: float = cone_dir.angle()
		var cell_angle: float = vec.angle()
		var diff: float = abs(cell_angle - cone_angle)
		if diff > PI:
			diff = TAU - diff
		return diff <= deg_to_rad(30.0)
	elif dir_c != 0:
		var da: int
		if dir_c > 0:
			var dc_off: int = cc - sc
			if dc_off < 0:
				return false
			da = dc_off + 1
		else:
			var dc_off: int = sc - cc
			if dc_off < 0:
				return false
			da = dc_off
		if da < 1 or da > cone_len:
			return false
		return abs(cr - sr) <= da - 1
	else:
		var da: int
		if dir_r > 0:
			var dr_off: int = cr - sr
			if dr_off < 0:
				return false
			da = dr_off + 1
		else:
			var dr_off: int = sr - cr
			if dr_off < 0:
				return false
			da = dr_off
		if da < 1 or da > cone_len:
			return false
		return abs(cc - sc) <= da - 1


func _draw_template_cells(mode: int, start: Vector2, end: Vector2, cell_color: Color) -> void:
	var grid := GameState.get_current_grid()
	if not grid or grid.size_px <= 0:
		return
	var cell_px: float = grid.size_px
	var origin: Vector2 = grid.origin

	var min_v: Vector2
	var max_v: Vector2
	match mode:
		1:
			var r: float = start.distance_to(end)
			min_v = start - Vector2(r, r)
			max_v = start + Vector2(r, r)
		2:
			var cone_dir := end - start
			var cone_len: float = cone_dir.length()
			if cone_len < 1.0:
				return
			var cone_angle: float = cone_dir.angle()
			var hangle: float = deg_to_rad(40.0)
			var fan: Array = [start]
			for i in range(7):
				var a: float = cone_angle - hangle + (2.0 * hangle) * i / 6.0
				fan.append(start + Vector2(cos(a), sin(a)) * cone_len)
			min_v = fan[0]
			max_v = fan[0]
			for pt in fan:
				var p: Vector2 = pt
				min_v = Vector2(min(min_v.x, p.x), min(min_v.y, p.y))
				max_v = Vector2(max(max_v.x, p.x), max(max_v.y, p.y))
		3:
			var rect := Rect2(start, end - start).abs()
			min_v = rect.position
			max_v = rect.end
		4:
			min_v = Vector2(min(start.x, end.x), min(start.y, end.y))
			max_v = Vector2(max(start.x, end.x), max(start.y, end.y))
		_: return

	var margin := Vector2(cell_px, cell_px)
	min_v -= margin
	max_v += margin

	var min_cell := Vector2i(floor((min_v.x - origin.x) / cell_px), floor((min_v.y - origin.y) / cell_px))
	var max_cell := Vector2i(ceil((max_v.x - origin.x) / cell_px), ceil((max_v.y - origin.y) / cell_px))

	for col in range(min_cell.x, max_cell.x + 1):
		for row in range(min_cell.y, max_cell.y + 1):
			var cx: float = col * cell_px + cell_px / 2.0 + origin.x
			var cy: float = row * cell_px + cell_px / 2.0 + origin.y
			var cell_center := Vector2(cx, cy)
			if _is_cell_in_shape(mode, start, end, cell_center, cell_px):
				var cr := Rect2(col * cell_px + origin.x, row * cell_px + origin.y, cell_px, cell_px)
				draw_rect(cr, cell_color)
