extends Resource

@export var size_px: float = 70.0
@export var origin: Vector2 = Vector2.ZERO
@export var color: Color = Color.BLACK
@export var opacity: float = 0.3
@export var line_width: float = 1.0
@export var visible: bool = false
@export var show_coords: bool = false
@export var rotation_degrees: float = 0.0


func to_dict() -> Dictionary:
	return {
		"size_px": size_px,
		"origin": {"x": origin.x, "y": origin.y},
		"color": {"r": color.r, "g": color.g, "b": color.b, "a": color.a},
		"opacity": opacity,
		"line_width": line_width,
		"visible": visible,
		"show_coords": show_coords,
		"rotation_degrees": rotation_degrees,
	}


static func from_dict(d: Dictionary) -> Resource:
	var gd := Resource.new()
	gd.set_script(load("res://scripts/grid/grid_data.gd"))
	gd.size_px = d.get("size_px", 70.0)
	var o: Dictionary = d.get("origin", {})
	gd.origin = Vector2(o.get("x", 0.0), o.get("y", 0.0))
	var c: Dictionary = d.get("color", {})
	gd.color = Color(c.get("r", 0.0), c.get("g", 0.0), c.get("b", 0.0), c.get("a", 0.0))
	gd.opacity = d.get("opacity", 0.3)
	gd.line_width = d.get("line_width", 1.0)
	gd.visible = d.get("visible", false)
	gd.show_coords = d.get("show_coords", false)
	gd.rotation_degrees = d.get("rotation_degrees", 0.0)
	return gd
