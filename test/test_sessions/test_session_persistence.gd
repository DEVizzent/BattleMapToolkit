extends GutTest

const DMWindowScene := preload("res://scenes/ui/dm_window.tscn")
const MapDataClass := preload("res://scripts/map/map_data.gd")
const TokenDataClass := preload("res://scripts/token/token_data.gd")
const GridDataClass := preload("res://scripts/grid/grid_data.gd")

var _dm: Control


func before_each() -> void:
	_dm = DMWindowScene.instantiate()
	add_child_autofree(_dm)
	await get_tree().process_frame
	GameState._clear_all()
	await get_tree().process_frame


func test_to_dict_empty_has_required_keys() -> void:
	var d := GameState.to_dict()
	assert_true(d.has("version"), "should have version")
	assert_true(d.has("name"), "should have name")
	assert_true(d.has("settings"), "should have settings")
	assert_true(d.has("maps"), "should have maps array")
	assert_true(d.has("grids"), "should have grids dict")
	assert_true(d.has("tokens"), "should have tokens dict")
	assert_true(d.has("initiative"), "should have initiative")
	assert_true(d.has("player"), "should have player")


func test_to_dict_with_map_data() -> void:
	var md := MapDataClass.new()
	md.name = "TestMap"
	md.image_path = "/path/to/map.png"
	GameState.maps.append(md)
	var d := GameState.to_dict()
	assert_eq(d["maps"].size(), 1)
	assert_eq(d["maps"][0]["name"], "TestMap")


func test_to_dict_with_grid_data() -> void:
	var gd := GridDataClass.new()
	gd.size_px = 100.0
	gd.visible = true
	gd.origin = Vector2(10, 20)
	GameState.map_grids[0] = gd
	var d := GameState.to_dict()
	assert_eq(d["grids"]["0"]["size_px"], 100.0)
	assert_eq(d["grids"]["0"]["origin"]["x"], 10)
	assert_eq(d["grids"]["0"]["origin"]["y"], 20)


func test_to_dict_with_tokens() -> void:
	var td := TokenDataClass.new()
	td.name = "Goblin"
	td.speed_ft = 30
	var arr: Array = [td]
	GameState.map_tokens[0] = arr
	var d := GameState.to_dict()
	assert_eq(d["tokens"]["0"].size(), 1)
	assert_eq(d["tokens"]["0"][0]["name"], "Goblin")


func test_from_dict_restores_settings() -> void:
	var d := {
		"version": "0.2.0",
		"name": "test",
		"settings": {
			"current_units": 1,
			"diagonal_rule": false,
			"feet_per_cell": 10.0,
		},
		"maps": [],
		"grids": {},
		"tokens": {},
		"initiative": {"participants": [], "current_turn": -1, "global": true},
		"player": {"window_open": false, "monitor": 1},
	}
	GameState.from_dict(d)
	assert_eq(GameState.current_units, 1)
	assert_false(GameState.diagonal_rule)
	assert_eq(GameState.feet_per_cell, 10.0)


func test_roundtrip_preserves_maps_grids_tokens() -> void:
	var md := MapDataClass.new()
	md.name = "Dungeon"
	GameState.maps.append(md)
	var gd := GridDataClass.new()
	gd.size_px = 50.0
	gd.origin = Vector2(5, 5)
	GameState.map_grids[0] = gd
	var td := TokenDataClass.new()
	td.name = "Heroe"
	td.size_cells = 2.0
	td.speed_ft = 30
	GameState.map_tokens[0] = [td]
	GameState.diagonal_rule = false
	GameState.current_units = GameState.Units.METERS

	var json: String = JSON.stringify(GameState.to_dict())
	var parsed: Dictionary = JSON.parse_string(json)
	GameState._clear_all()
	GameState.from_dict(parsed)

	assert_eq(GameState.maps.size(), 1)
	assert_eq(GameState.maps[0].name, "Dungeon")
	var restored_grid: Resource = GameState.map_grids.get(0)
	assert_ne(restored_grid, null)
	assert_eq(restored_grid.size_px, 50.0)
	assert_eq(restored_grid.origin, Vector2(5, 5))
	var restored_tokens: Array = GameState.map_tokens.get(0, [])
	assert_eq(restored_tokens.size(), 1)
	assert_eq(restored_tokens[0].name, "Heroe")
	assert_eq(restored_tokens[0].size_cells, 2.0)
	assert_false(GameState.diagonal_rule)
	assert_eq(GameState.current_units, GameState.Units.METERS)


func test_session_file_write_read() -> void:
	GameState.session_name = "TestSesion"
	var path := "user://test_session.bmap"
	_dm._write_session_file(path)
	assert_true(FileAccess.file_exists(path), "session file should exist after write")
	var data: Dictionary = _dm._read_session_file(path)
	assert_eq(data.get("name"), "TestSesion")
	DirAccess.remove_absolute(path)


func test_session_dirty_cleared_after_save() -> void:
	GameState.session_name = "Sesion"
	GameState.mark_dirty()
	assert_true(GameState.session_dirty, "should be dirty before save")
	var path := "user://test_dirty.bmap"
	_dm._write_session_file(path)
	assert_false(GameState.session_dirty, "should be clean after save")
	DirAccess.remove_absolute(path)


func test_from_dict_clears_previous_state() -> void:
	GameState.maps.append(MapDataClass.new())
	GameState.maps.append(MapDataClass.new())
	assert_eq(GameState.maps.size(), 2)
	GameState.from_dict({"version": "0.2.0", "maps": [], "grids": {}, "tokens": {},
		"settings": {}, "initiative": {"participants": [], "current_turn": -1, "global": true},
		"player": {"window_open": false, "monitor": 1}})
	assert_eq(GameState.maps.size(), 0, "from_dict should clear existing maps")
	assert_eq(GameState.current_map_index, -1)


func test_initiative_roundtrip() -> void:
	GameState.initiative_participants = ["Aragorn", "Legolas"]
	GameState.initiative_current_turn = 0
	GameState.initiative_global = false
	var d := GameState.to_dict()
	GameState._clear_all()
	GameState.from_dict(d)
	assert_eq(GameState.initiative_participants.size(), 2)
	assert_eq(GameState.initiative_participants[0], "Aragorn")
	assert_eq(GameState.initiative_current_turn, 0)
	assert_false(GameState.initiative_global)
