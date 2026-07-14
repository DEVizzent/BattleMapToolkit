extends Resource

@export var id: String = ""
@export var points: Array = []
@export var active: bool = true
@export var color: Color = Color(1.0, 0.3, 0.3, 0.7)


func to_dict() -> Dictionary:
	var pts: Array = []
	for p in points:
		pts.append({"x": p.x, "y": p.y})
	return {
		"id": id,
		"points": pts,
		"active": active,
		"color": {"r": color.r, "g": color.g, "b": color.b, "a": color.a},
	}


static func from_dict(d: Dictionary) -> Resource:
	var vb := Resource.new()
	vb.set_script(load("res://scripts/fog/vision_blocker_data.gd"))
	vb.id = d.get("id", "")
	var pts: Array = d.get("points", [])
	for p in pts:
		vb.points.append(Vector2(p.get("x", 0.0), p.get("y", 0.0)))
	vb.active = d.get("active", true)
	var c: Dictionary = d.get("color", {})
	vb.color = Color(c.get("r", 1.0), c.get("g", 0.3), c.get("b", 0.3), c.get("a", 0.7))
	return vb


static func create_id() -> String:
	return "vb_%d" % Time.get_ticks_msec()
