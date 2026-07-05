extends GutTest

var _dm: Control


func before_each() -> void:
	var scene := load("res://scenes/ui/dm_window.tscn")
	_dm = scene.instantiate()
	add_child(_dm)
	await get_tree().process_frame
	await get_tree().process_frame


func after_each() -> void:
	if _dm:
		_dm.queue_free()


func test_zoom_at_point_changes_scale() -> void:
	var initial_scale: float = _dm.map_root.scale.x

	_dm._zoom_at_point(Vector2(960, 540), 1.25)
	assert_gt(_dm.map_root.scale.x, initial_scale, "Zoom in debe aumentar scale")
	assert_eq(_dm.map_root.scale.x, _dm.map_root.scale.y, "Scale debe ser uniforme")


func test_zoom_in_clamped_to_max() -> void:
	_dm.map_root.scale = Vector2(3.9, 3.9)
	_dm._zoom_at_point(Vector2(0, 0), 1.25)
	assert_lte(_dm.map_root.scale.x, 4.0, "Scale no debe superar 4.0")


func test_zoom_out_clamped_to_min() -> void:
	_dm.map_root.scale = Vector2(0.12, 0.12)
	_dm._zoom_at_point(Vector2(0, 0), 0.8)
	assert_gte(_dm.map_root.scale.x, 0.1, "Scale no debe bajar de 0.1")


func test_zoom_at_point_keeps_cursor_fixed() -> void:
	_dm.map_root.scale = Vector2(1.0, 1.0)
	_dm.map_root.position = Vector2(0, 0)

	var screen_pos: Vector2 = Vector2(500, 300)
	var map_point_before: Vector2 = (screen_pos - _dm.map_root.position) / _dm.map_root.scale.x

	_dm._zoom_at_point(screen_pos, 2.0)

	var map_point_after: Vector2 = (screen_pos - _dm.map_root.position) / _dm.map_root.scale.x
	assert_almost_eq(map_point_after.x, map_point_before.x, 0.01, "Cursor debe apuntar al mismo punto del mapa tras zoom")
	assert_almost_eq(map_point_after.y, map_point_before.y, 0.01, "Cursor debe apuntar al mismo punto del mapa tras zoom")


func test_zoom_updates_label_and_buttons() -> void:
	_dm._zoom_at_point(Vector2(0, 0), 4.0)
	assert_string_contains(_dm.zoom_label.text, "%")
	assert_true(_dm.zoom_in_btn.disabled, "Boton + desactivado en zoom max")
	assert_false(_dm.zoom_out_btn.disabled, "Boton - activo en zoom max")

	_dm._zoom_at_point(Vector2(0, 0), 0.025)
	assert_false(_dm.zoom_in_btn.disabled, "Boton + activo en zoom min")
	assert_true(_dm.zoom_out_btn.disabled, "Boton - desactivado en zoom min")


func test_fit_button_resets_to_fit() -> void:
	_dm.map_root.scale = Vector2(3.0, 3.0)
	_dm.map_root.position = Vector2(500, 500)
	_dm._on_fit_pressed()
	var new_scale: float = _dm.map_root.scale.x
	assert_gte(new_scale, 0.0, "Fit debe calcular scale valido")


func test_keyboard_pan_moves_map() -> void:
	_dm.map_root.scale = Vector2(1.0, 1.0)
	var initial_pos: Vector2 = _dm.map_root.position

	# Simular flecha derecha presionada
	Input.action_press("pan_right")
	_dm._process(0.016)
	var pos_after_pan: Vector2 = _dm.map_root.position
	assert_ne(pos_after_pan, initial_pos, "El mapa debe haberse movido con pan derecho")
	Input.action_release("pan_right")


func test_coords_label_updates() -> void:
	_dm.map_root.scale = Vector2(1.0, 1.0)
	_dm.map_root.position = Vector2(0, 0)
	_dm._update_coords_label()
	assert_string_contains(_dm.coords_label.text, "(")
	assert_string_contains(_dm.coords_label.text, ")")


func test_zoom_without_map_texture_works() -> void:
	_dm.map_sprite.texture = null
	_dm._zoom_at_point(Vector2(0, 0), 1.25)
	# No debe crashear aunque no haya textura
	assert_gte(_dm.map_root.scale.x, 0.0)
