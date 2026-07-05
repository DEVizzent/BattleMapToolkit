extends Resource

@export var name: String = ""
@export var maps_count: int = 0
@export var last_modified: String = ""
@export var file_path: String = ""
@export var has_active_initiative: bool = false


func to_dict() -> Dictionary:
	return {
		"name": name,
		"maps_count": maps_count,
		"last_modified": last_modified,
		"file_path": file_path,
		"has_active_initiative": has_active_initiative
	}


func file_exists() -> bool:
	return FileAccess.file_exists(file_path)


func display_string() -> String:
	var count_str := str(maps_count) + (" mapa" if maps_count == 1 else " mapas")
	var ini_icon := " *" if has_active_initiative else ""
	return name + "    " + count_str + "    " + last_modified + ini_icon
