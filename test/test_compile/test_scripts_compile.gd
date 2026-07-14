extends GutTest

## Preloads all project scripts to trigger strict-mode parse errors at test time.
## If any script has a type inference issue, preload fails and this test fails.

const DMWindowClass := preload("res://scripts/ui/dm_window.gd")
const LauncherClass := preload("res://scripts/ui/launcher.gd")
const GameStateClass := preload("res://scripts/core/game_state.gd")
const EventBusClass := preload("res://scripts/core/event_bus.gd")
const LocaleManagerClass := preload("res://scripts/core/locale_manager.gd")
const RecentSessionsClass := preload("res://scripts/core/recent_sessions.gd")
const SettingsClass := preload("res://scripts/core/settings.gd")
const PlayerWindowClass := preload("res://scripts/player/player_window.gd")
const GridDataClass := preload("res://scripts/grid/grid_data.gd")
const GridRendererClass := preload("res://scripts/grid/grid_renderer.gd")
const MapDataClass := preload("res://scripts/map/map_data.gd")
const SessionDataClass := preload("res://scripts/session/session_data.gd")
const TokenDataClass := preload("res://scripts/token/token_data.gd")
const TokenLayerClass := preload("res://scripts/token/token_layer.gd")
const TokenSpriteClass := preload("res://scripts/token/token_sprite.gd")
const TokenUtilsClass := preload("res://scripts/token/token_utils.gd")
const VisionBlockerDataClass := preload("res://scripts/fog/vision_blocker_data.gd")


func test_all_core_scripts_compile() -> void:
	assert_not_null(GameStateClass, "game_state.gd")
	assert_not_null(EventBusClass, "event_bus.gd")
	assert_not_null(LocaleManagerClass, "locale_manager.gd")
	assert_not_null(RecentSessionsClass, "recent_sessions.gd")
	assert_not_null(SettingsClass, "settings.gd")


func test_all_ui_scripts_compile() -> void:
	assert_not_null(DMWindowClass, "dm_window.gd")
	assert_not_null(LauncherClass, "launcher.gd")


func test_player_scripts_compile() -> void:
	assert_not_null(PlayerWindowClass, "player_window.gd")


func test_grid_scripts_compile() -> void:
	assert_not_null(GridDataClass, "grid_data.gd")
	assert_not_null(GridRendererClass, "grid_renderer.gd")


func test_map_scripts_compile() -> void:
	assert_not_null(MapDataClass, "map_data.gd")


func test_session_scripts_compile() -> void:
	assert_not_null(SessionDataClass, "session_data.gd")


func test_token_scripts_compile() -> void:
	assert_not_null(TokenDataClass, "token_data.gd")
	assert_not_null(TokenLayerClass, "token_layer.gd")
	assert_not_null(TokenSpriteClass, "token_sprite.gd")
	assert_not_null(TokenUtilsClass, "token_utils.gd")


func test_fog_scripts_compile() -> void:
	assert_not_null(VisionBlockerDataClass, "vision_blocker_data.gd")
