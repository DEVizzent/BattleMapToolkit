extends GutTest

const SessionDataClass := preload("res://scripts/session/session_data.gd")

func before_all() -> void:
	if FileAccess.file_exists("user://recent_sessions.json"):
		DirAccess.remove_absolute("user://recent_sessions.json")


func after_all() -> void:
	if FileAccess.file_exists("user://recent_sessions.json"):
		DirAccess.remove_absolute("user://recent_sessions.json")


func test_empty_on_first_load() -> void:
	RecentSessions._load()
	assert_eq(RecentSessions.sessions.size(), 0, "Lista vacía si no hay JSON")


func test_add_session() -> void:
	var sd := SessionDataClass.new()
	sd.name = "Test Session"
	sd.file_path = "user://test1.bmap"
	sd.maps_count = 2
	RecentSessions.add_or_update(sd)

	assert_eq(RecentSessions.sessions.size(), 1, "Debe haber 1 sesión tras añadir")
	assert_eq(RecentSessions.sessions[0].name, "Test Session")
	assert_eq(RecentSessions.sessions[0].maps_count, 2)


func test_update_existing_session() -> void:
	var sd := SessionDataClass.new()
	sd.name = "Test Session Updated"
	sd.file_path = "user://test1.bmap"
	sd.maps_count = 5
	RecentSessions.add_or_update(sd)

	assert_eq(RecentSessions.sessions.size(), 1, "No debe duplicar, debe actualizar")
	assert_eq(RecentSessions.sessions[0].name, "Test Session Updated")
	assert_eq(RecentSessions.sessions[0].maps_count, 5)


func test_max_sessions_enforced() -> void:
	for i in range(15):
		var sd := SessionDataClass.new()
		sd.name = "Session " + str(i)
		sd.file_path = "user://unique_" + str(i) + ".bmap"
		RecentSessions.add_or_update(sd)

	assert_lte(RecentSessions.sessions.size(), 10, "Máximo 10 sesiones recientes")


func test_remove_by_path() -> void:
	var sd := SessionDataClass.new()
	sd.name = "To Remove"
	sd.file_path = "user://to_remove.bmap"
	RecentSessions.add_or_update(sd)

	var before := RecentSessions.sessions.size()
	RecentSessions.remove_by_path("user://to_remove.bmap")
	assert_eq(RecentSessions.sessions.size(), before - 1, "La sesión debe eliminarse")


func test_persistence_across_reloads() -> void:
	RecentSessions.sessions.clear()
	var sd := SessionDataClass.new()
	sd.name = "Persistent"
	sd.file_path = "user://persistent.bmap"
	sd.maps_count = 3
	RecentSessions.add_or_update(sd)
	RecentSessions._save()

	# Simular recarga
	RecentSessions.sessions.clear()
	RecentSessions._load()

	assert_eq(RecentSessions.sessions.size(), 1, "Debe cargar la sesión persistida")
	assert_eq(RecentSessions.sessions[0].name, "Persistent")
	assert_eq(RecentSessions.sessions[0].maps_count, 3)


func test_get_sessions_returns_copy() -> void:
	var sessions := RecentSessions.get_sessions()
	assert_eq(sessions.size(), RecentSessions.sessions.size())
