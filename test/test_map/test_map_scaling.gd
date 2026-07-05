extends GutTest

func test_vector2_math_with_mixed_types() -> void:
	var tex_size: Vector2 = Vector2(800, 600)
	var vp_size: Vector2 = Vector2(1920, 1080)
	var scale_x: float = vp_size.x / tex_size.x
	var scale_y: float = vp_size.y / tex_size.y
	var scale: float = minf(scale_x, scale_y)
	if scale > 1.0:
		scale = 1.0
	var pos: Vector2 = (vp_size - tex_size * scale) / 2.0

	assert_gt(scale, 0.0, "Scale debe ser positivo")
	assert_eq(pos.x, (1920.0 - 800.0 * scale) / 2.0, "Posicion X calculada correctamente")
	assert_eq(pos.y, (1080.0 - 600.0 * scale) / 2.0, "Posicion Y calculada correctamente")


func test_vector2i_to_vector2_conversion() -> void:
	var vp_i := Vector2i(1920, 1080)
	var vp_f: Vector2 = Vector2(vp_i)
	assert_eq(vp_f.x, 1920.0)
	assert_eq(vp_f.y, 1080.0)


func test_scale_clamped_to_one() -> void:
	var tex_size: Vector2 = Vector2(400, 300)
	var vp_size: Vector2 = Vector2(1920, 1080)
	var sx: float = vp_size.x / tex_size.x
	var sy: float = vp_size.y / tex_size.y
	var scale: float = minf(sx, sy)
	if scale > 1.0:
		scale = 1.0
	assert_eq(scale, 1.0, "Imagen mas pequeña que viewport → scale = 1.0")


func test_scale_down_large_image() -> void:
	var tex_size: Vector2 = Vector2(4000, 3000)
	var vp_size: Vector2 = Vector2(1920, 1080)
	var sx: float = vp_size.x / tex_size.x
	var sy: float = vp_size.y / tex_size.y
	var scale: float = minf(sx, sy)
	assert_lt(scale, 1.0, "Imagen mas grande que viewport → scale < 1.0")
	assert_eq(scale, 0.36, "Escala ajustada al lado mas restrictivo")
