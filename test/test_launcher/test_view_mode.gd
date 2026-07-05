extends GutTest

func test_view_mode_enum_values() -> void:
	assert_eq(GameState.ViewMode.SYNCED, 0)
	assert_eq(GameState.ViewMode.INDEPENDENT, 1)
	assert_eq(GameState.ViewMode.FOLLOW_TURN, 2)


func test_view_mode_default() -> void:
	assert_eq(GameState.view_mode, GameState.ViewMode.SYNCED, "View mode default es SYNCED (0)")


func test_view_mode_changes_correctly() -> void:
	GameState.view_mode = GameState.ViewMode.INDEPENDENT
	assert_eq(GameState.view_mode, 1)
	assert_eq(GameState.view_mode, GameState.ViewMode.INDEPENDENT)

	GameState.view_mode = GameState.ViewMode.FOLLOW_TURN
	assert_eq(GameState.view_mode, 2)

	GameState.view_mode = GameState.ViewMode.SYNCED
	assert_eq(GameState.view_mode, 0)


func test_view_mode_signal_emits() -> void:
	watch_signals(EventBus)
	EventBus.view_mode_changed.emit("synced")
	assert_signal_emitted(EventBus, "view_mode_changed")
	assert_signal_emitted_with_parameters(EventBus, "view_mode_changed", ["synced"])

	EventBus.view_mode_changed.emit("independent")
	assert_signal_emitted_with_parameters(EventBus, "view_mode_changed", ["independent"])


func after_all() -> void:
	GameState.view_mode = GameState.ViewMode.SYNCED
