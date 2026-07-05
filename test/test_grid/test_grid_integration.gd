extends GutTest

## Tests de integración para la cuadrícula, usando la escena dm_window completa.

const DMWindowScene := preload("res://scenes/ui/dm_window.tscn")
const GridDataClass := preload("res://scripts/grid/grid_data.gd")

var _dm: Control


func before_each() -> void:
	_dm = DMWindowScene.instantiate()
	add_child_autofree(_dm)
	await get_tree().process_frame
	var gd := GameState.get_current_grid()
	gd.size_px = 70.0
	gd.origin = Vector2.ZERO
	gd.color = Color.BLACK
	gd.opacity = 0.3
	gd.line_width = 1.0
	gd.visible = false
	gd.show_coords = false


func test_grid_toggle_visibility() -> void:
	var gd := GameState.get_current_grid()
	# Grid starts hidden
	assert_false(gd.visible)
	assert_false(_dm.grid_panel.visible)

	# Toggle on
	_dm._on_grid_toggle_pressed()
	assert_true(gd.visible)
	assert_true(_dm.grid_panel.visible)

	# Toggle off
	_dm._on_grid_toggle_pressed()
	assert_false(gd.visible)
	assert_false(_dm.grid_panel.visible)


func test_grid_data_persists_per_map() -> void:
	var gd1 := GameState.get_current_grid()
	gd1.size_px = 50.0
	gd1.visible = true

	# Same index returns same grid data
	var gd2 := GameState.get_current_grid()
	assert_eq(gd2.size_px, 50.0)
	assert_true(gd2.visible)


func test_cell_size_slider_updates_grid() -> void:
	var gd := GameState.get_current_grid()
	_dm._on_grid_toggle_pressed()

	_dm._on_grid_cell_size_slider(100.0)
	assert_eq(gd.size_px, 100.0)
	assert_string_contains(_dm.grid_cell_size_label.text, "Celda: 100 px")


func test_adjust_cell_size_buttons() -> void:
	var gd := GameState.get_current_grid()
	_dm._on_grid_toggle_pressed()
	gd.size_px = 70.0

	_dm._adjust_cell_size(1.0)
	assert_eq(gd.size_px, 71.0)

	_dm._adjust_cell_size(10.0)
	assert_eq(gd.size_px, 81.0)

	_dm._adjust_cell_size(-1.0)
	assert_eq(gd.size_px, 80.0)

	_dm._adjust_cell_size(-10.0)
	assert_eq(gd.size_px, 70.0)


func test_adjust_cell_size_clamped() -> void:
	var gd := GameState.get_current_grid()
	# Test lower bound
	gd.size_px = 10.0
	_dm._adjust_cell_size(-1.0)
	assert_eq(gd.size_px, 10.0)

	# Test upper bound
	gd.size_px = 500.0
	_dm._adjust_cell_size(1.0)
	assert_eq(gd.size_px, 500.0)


func test_grid_color_changes() -> void:
	var gd := GameState.get_current_grid()
	_dm._on_grid_toggle_pressed()

	_dm._on_grid_color_changed(Color.RED)
	assert_eq(gd.color, Color.RED)


func test_grid_opacity_changes() -> void:
	var gd := GameState.get_current_grid()
	_dm._on_grid_toggle_pressed()

	_dm._on_grid_opacity_changed(0.5)
	assert_eq(gd.opacity, 0.5)
	assert_string_contains(_dm.grid_opacity_label.text, "Opacidad: 50%")


func test_grid_line_width_changes() -> void:
	var gd := GameState.get_current_grid()
	_dm._on_grid_toggle_pressed()

	_dm._on_grid_line_width_changed(3.0)
	assert_eq(gd.line_width, 3.0)
	assert_string_contains(_dm.grid_line_width_label.text, "Grosor: 3 px")


func test_grid_show_coords_toggles() -> void:
	var gd := GameState.get_current_grid()
	_dm._on_grid_toggle_pressed()

	assert_false(gd.show_coords)
	_dm._on_grid_show_coords_toggled(true)
	assert_true(gd.show_coords)
	_dm._on_grid_show_coords_toggled(false)
	assert_false(gd.show_coords)


func test_grid_toggle_button_reflects_state() -> void:
	var gd := GameState.get_current_grid()
	_dm._on_grid_toggle_pressed()
	assert_true(gd.visible)

	_dm._on_grid_toggle_pressed()
	assert_false(gd.visible)


func test_apply_grid_panel_values_reflects_grid_data() -> void:
	var gd := GameState.get_current_grid()
	gd.size_px = 42.0
	gd.color = Color.BLUE
	gd.opacity = 0.75
	gd.line_width = 4.0
	gd.show_coords = true

	_dm._apply_grid_panel_values(gd)

	assert_eq(_dm.grid_cell_size_slider.value, 42.0)
	assert_eq(_dm.grid_color_picker.color, Color.BLUE)
	assert_eq(_dm.grid_opacity_slider.value, 0.75)
	assert_eq(_dm.grid_line_width_slider.value, 4.0)
	assert_true(_dm.grid_show_coords_check.button_pressed)


func test_grid_absent_without_map() -> void:
	# No map loaded — grid data should be null (no _activate_map called)
	assert_null(_dm.grid_layer.grid_data)


func test_grid_renderer_does_not_draw_when_invisible() -> void:
	var gd := GameState.get_current_grid()
	gd.visible = false
	_dm.grid_layer.grid_data = gd
	_dm.grid_layer.refresh()
	assert_false(gd.visible)


func test_origin_offset_x_moves_grid() -> void:
	var gd := GameState.get_current_grid()
	_dm._on_grid_toggle_pressed()
	assert_eq(gd.origin.x, 0.0)

	_dm._adjust_origin_x(10.0)
	assert_eq(gd.origin.x, 10.0)
	assert_string_contains(_dm.grid_origin_label.text, "Offset: (10, 0)")

	_dm._adjust_origin_x(-5.0)
	assert_eq(gd.origin.x, 5.0)


func test_origin_offset_y_moves_grid() -> void:
	var gd := GameState.get_current_grid()
	_dm._on_grid_toggle_pressed()

	_dm._adjust_origin_y(20.0)
	assert_eq(gd.origin.y, 20.0)
	assert_string_contains(_dm.grid_origin_label.text, "Offset: (0, 20)")

	_dm._adjust_origin_y(-20.0)
	assert_eq(gd.origin.y, 0.0)
	assert_string_contains(_dm.grid_origin_label.text, "Offset: (0, 0)")


func test_origin_offset_both_axes() -> void:
	var gd := GameState.get_current_grid()
	_dm._on_grid_toggle_pressed()

	_dm._adjust_origin_x(15.0)
	_dm._adjust_origin_y(25.0)
	assert_eq(gd.origin.x, 15.0)
	assert_eq(gd.origin.y, 25.0)
	assert_string_contains(_dm.grid_origin_label.text, "Offset: (15, 25)")


func test_origin_offset_negative_allowed() -> void:
	var gd := GameState.get_current_grid()
	_dm._on_grid_toggle_pressed()

	_dm._adjust_origin_x(-30.0)
	_dm._adjust_origin_y(-40.0)
	assert_eq(gd.origin.x, -30.0)
	assert_eq(gd.origin.y, -40.0)
	assert_string_contains(_dm.grid_origin_label.text, "Offset: (-30, -40)")


func test_origin_labels_updated_on_toggle() -> void:
	var gd := GameState.get_current_grid()
	gd.origin = Vector2(12, 34)
	_dm._on_grid_toggle_pressed()
	assert_string_contains(_dm.grid_origin_label.text, "Offset: (12, 34)")
	assert_string_contains(_dm.grid_origin_x_label.text, "X: 12")
	assert_string_contains(_dm.grid_origin_y_label.text, "Y: 34")
