extends GutTest

const DMWindowScene := preload("res://scenes/ui/dm_window.tscn")
const TokenDataClass := preload("res://scripts/token/token_data.gd")

var _dm: Control


func before_each() -> void:
	_dm = DMWindowScene.instantiate()
	add_child_autofree(_dm)
	await get_tree().process_frame
	GameState.map_tokens.clear()
	GameState.current_map_index = -1
	_dm._clear_token_sprites()
	await get_tree().process_frame


func test_token_list_starts_empty() -> void:
	var tokens_arr := GameState.get_current_tokens()
	assert_eq(tokens_arr.size(), 0)
	assert_eq(_dm.token_list.item_count, 0)


func test_add_token_to_game_state() -> void:
	var td := TokenDataClass.new()
	td.name = "Goblin"
	td.image_path = "user://nonexistent.png"
	GameState.add_token_for_current_map(td)

	var tokens_arr := GameState.get_current_tokens()
	assert_eq(tokens_arr.size(), 1)
	assert_eq(tokens_arr[0].name, "Goblin")


func test_remove_token_from_game_state() -> void:
	var td := TokenDataClass.new()
	td.name = "Orco"
	GameState.add_token_for_current_map(td)
	assert_eq(GameState.get_current_tokens().size(), 1)

	GameState.remove_token_for_current_map(0)
	assert_eq(GameState.get_current_tokens().size(), 0)


func test_refresh_token_list_shows_tokens() -> void:
	var td := TokenDataClass.new()
	td.name = "Esqueleto"
	GameState.add_token_for_current_map(td)

	_dm._refresh_token_list()
	assert_eq(_dm.token_list.item_count, 1)
	assert_string_contains(_dm.token_list.get_item_text(0), "Esqueleto")


func test_refresh_token_list_empty() -> void:
	_dm._refresh_token_list()
	assert_eq(_dm.token_list.item_count, 0)


func test_spawn_token_sprite_adds_to_layer() -> void:
	var td := TokenDataClass.new()
	td.name = "Heroe"
	td.size_cells = 2.0
	var children_before: int = _dm.token_layer.get_child_count()

	_dm._spawn_token_sprite(td, Vector2(200, 300), 70.0)

	var children_after: int = _dm.token_layer.get_child_count()
	assert_eq(children_after, children_before + 1)


func test_clear_token_sprites_removes_all() -> void:
	var td := TokenDataClass.new()
	_dm._spawn_token_sprite(td, Vector2(100, 100), 70.0)
	_dm._spawn_token_sprite(td, Vector2(200, 200), 70.0)
	assert_eq(_dm.token_layer.get_child_count(), 2)

	_dm._clear_token_sprites()
	await get_tree().process_frame
	assert_eq(_dm.token_layer.get_child_count(), 0)


func test_token_per_map_isolation() -> void:
	var td := TokenDataClass.new()
	td.name = "Map0Token"
	GameState.current_map_index = 0
	GameState.add_token_for_current_map(td)

	assert_eq(GameState.get_current_tokens().size(), 1)

	# Switch to map 1 — should have no tokens
	GameState.current_map_index = 1
	assert_eq(GameState.get_current_tokens().size(), 0)

	# Back to map 0 — token still there
	GameState.current_map_index = 0
	assert_eq(GameState.get_current_tokens().size(), 1)


func test_image_has_transparency_detects_opaque() -> void:
	var img := Image.create(10, 10, false, Image.FORMAT_RGBA8)
	img.fill(Color.WHITE)
	assert_false(_dm._image_has_transparency(img))


func test_image_has_transparency_detects_transparent() -> void:
	var img := Image.create(10, 10, false, Image.FORMAT_RGBA8)
	img.fill(Color.WHITE)
	img.set_pixel(5, 5, Color(1.0, 1.0, 1.0, 0.5))
	assert_true(_dm._image_has_transparency(img))


func test_token_library_title_exists() -> void:
	assert_not_null(_dm.token_library_title)
	assert_not_null(_dm.token_library)


func test_token_library_empty_by_default() -> void:
	_dm._refresh_token_library()
	assert_eq(_dm.token_library.item_count, 0)


func test_screen_to_map_pos_at_center() -> void:
	_dm.map_root.position = Vector2.ZERO
	_dm.map_root.scale = Vector2.ONE
	var pos: Vector2 = _dm._screen_to_map_pos(_dm.map_viewport.global_position + Vector2(100, 200))
	var viewport_scale: Vector2 = Vector2(_dm.viewport_node.size) / Vector2(_dm.map_viewport.size)
	assert_almost_eq(pos.x, 100.0 * viewport_scale.x, 0.01)
	assert_almost_eq(pos.y, 200.0 * viewport_scale.y, 0.01)


func test_screen_to_map_pos_with_offset() -> void:
	_dm.map_root.position = Vector2(50, -30)
	_dm.map_root.scale = Vector2(2, 2)
	var vp_pos := Vector2(200, 300)
	var viewport_scale: Vector2 = Vector2(_dm.viewport_node.size) / Vector2(_dm.map_viewport.size)
	var expected: Vector2 = (vp_pos * viewport_scale - _dm.map_root.position) / 2.0
	var pos: Vector2 = _dm._screen_to_map_pos(_dm.map_viewport.global_position + vp_pos)
	assert_almost_eq(pos.x, expected.x, 0.01)
	assert_almost_eq(pos.y, expected.y, 0.01)
