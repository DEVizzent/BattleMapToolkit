extends Resource

@export var name: String = ""
@export var image_path: String = ""


func to_dict() -> Dictionary:
	return {
		"name": name,
		"image_path": image_path,
	}


static func from_dict(d: Dictionary) -> Resource:
	var sd := Resource.new()
	sd.set_script(load("res://scripts/map/map_data.gd"))
	sd.name = d.get("name", "")
	sd.image_path = d.get("image_path", "")
	return sd


func image_exists() -> bool:
	return FileAccess.file_exists(image_path)
