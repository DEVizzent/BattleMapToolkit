extends Node

## RecentSessions — gestiona la lista de sesiones recientes.
## Persiste en user://recent_sessions.json

const SessionDataClass := preload("res://scripts/session/session_data.gd")
const RECENT_FILE := "user://recent_sessions.json"
const MAX_RECENT := 10

var sessions: Array = []


func _ready() -> void:
	_load()


func _load() -> void:
	if not FileAccess.file_exists(RECENT_FILE):
		return
	var file := FileAccess.open(RECENT_FILE, FileAccess.READ)
	if not file:
		return
	var text := file.get_as_text()
	file.close()
	var json := JSON.new()
	var err := json.parse(text)
	if err != OK:
		push_warning("RecentSessions: JSON parse error")
		return
	sessions.clear()
	for item in json.data:
		var sd := SessionDataClass.new()
		sd.name = item.get("name", "")
		sd.maps_count = item.get("maps_count", 0)
		sd.last_modified = item.get("last_modified", "")
		sd.file_path = item.get("file_path", "")
		sd.has_active_initiative = item.get("has_active_initiative", false)
		sessions.append(sd)


func _save() -> void:
	var data: Array = []
	for s in sessions:
		data.append(s.to_dict())
	var file := FileAccess.open(RECENT_FILE, FileAccess.WRITE)
	if not file:
		return
	file.store_string(JSON.stringify(data, "\t"))
	file.close()


func add_or_update(session) -> void:
	for i in range(sessions.size()):
		if sessions[i].file_path == session.file_path:
			sessions.remove_at(i)
			break
	sessions.insert(0, session)
	while sessions.size() > MAX_RECENT:
		sessions.pop_back()
	_save()


func remove_by_path(path: String) -> void:
	for i in range(sessions.size()):
		if sessions[i].file_path == path:
			sessions.remove_at(i)
			_save()
			return


func get_sessions() -> Array:
	var valid: Array = []
	for s in sessions:
		valid.append(s)
	return valid
