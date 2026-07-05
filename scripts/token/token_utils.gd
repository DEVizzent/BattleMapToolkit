extends RefCounted

## Utilidades para tokens: deteccion de transparencia, recorte, carga.

static func has_transparency(img: Image) -> bool:
	if img.get_format() != Image.FORMAT_RGBA8 and img.get_format() != Image.FORMAT_RGBA8:
		return false
	var used := img.get_used_rect()
	if used.size.x <= 0 or used.size.y <= 0:
		return false
	return used.size != img.get_size()
