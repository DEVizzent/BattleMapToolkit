extends Resource

@export var name: String = ""
@export var image_path: String = ""
@export var size_cells: float = 1.0
@export var border_color: Color = Color.YELLOW
@export var visible_to_players: bool = true
@export var vision_radius: int = 0
@export var speed_ft: int = 30
@export var conditions: Array = []


func to_dict() -> Dictionary:
	return {
		"name": name,
		"image_path": image_path,
		"size_cells": size_cells,
		"border_color": {"r": border_color.r, "g": border_color.g, "b": border_color.b, "a": border_color.a},
		"visible_to_players": visible_to_players,
		"vision_radius": vision_radius,
		"speed_ft": speed_ft,
		"conditions": conditions,
	}


static func from_dict(d: Dictionary) -> Resource:
	var td := Resource.new()
	td.set_script(load("res://scripts/token/token_data.gd"))
	td.name = d.get("name", "")
	td.image_path = d.get("image_path", "")
	td.size_cells = d.get("size_cells", 1.0)
	var c: Dictionary = d.get("border_color", {})
	td.border_color = Color(c.get("r", 1.0), c.get("g", 1.0), c.get("b", 0.0), c.get("a", 1.0))
	td.visible_to_players = d.get("visible_to_players", true)
	td.vision_radius = d.get("vision_radius", 0)
	td.speed_ft = d.get("speed_ft", 30)
	td.conditions = d.get("conditions", [])
	return td
