extends GutTest

const FogRendererClass := preload("res://scripts/fog/fog_renderer.gd")

var _renderer: Node2D


func before_each() -> void:
	_renderer = FogRendererClass.new()
	add_child_autofree(_renderer)


func _make_vision(pos: Vector2, radius: float) -> Dictionary:
	return {"position": pos, "radius": radius}


# ─── Helpers ─────────────────────────────────────────────────

func _cell_center(col: int, row: int, cell_px: float, origin: Vector2) -> Vector2:
	return Vector2(col * cell_px + cell_px / 2.0 + origin.x, row * cell_px + cell_px / 2.0 + origin.y)


func _is_visible(col: int, row: int, cell_px: float, origin: Vector2) -> bool:
	return _renderer._is_cell_visible(_cell_center(col, row, cell_px, origin))


func _count_visible_in_range(min_col: int, max_col: int, min_row: int, max_row: int,
		cell_px: float, origin: Vector2) -> int:
	var count := 0
	for row in range(min_row, max_row + 1):
		for col in range(min_col, max_col + 1):
			if _is_visible(col, row, cell_px, origin):
				count += 1
	return count


# ─── Basic _is_cell_visible tests ────────────────────────────

func test_visible_at_vision_center() -> void:
	_renderer.set_visions([_make_vision(Vector2(35, 35), 70.0)], 70.0, Vector2.ZERO)
	assert_true(_renderer._is_cell_visible(Vector2(35, 35)))


func test_not_visible_outside_radius() -> void:
	_renderer.set_visions([_make_vision(Vector2(100, 100), 50.0)], 70.0, Vector2.ZERO)
	assert_false(_renderer._is_cell_visible(Vector2(500, 500)))


func test_exact_radius_boundary() -> void:
	_renderer.set_visions([_make_vision(Vector2(0, 0), 300.0)], 70.0, Vector2.ZERO)
	assert_true(_renderer._is_cell_visible(Vector2(300, 0)))
	assert_false(_renderer._is_cell_visible(Vector2(300.1, 0)))


# ─── Full grid scan: token near corner, vision_radius=6 cells ──
# Simulates the user's scenario: 20×30 cell map, token at cell (2,2),
# vision_radius=6. Verifies the circular shape is correct.

func test_grid_scan_circle_shape() -> void:
	var cell_px := 70.0
	var origin := Vector2.ZERO
	# Token at center of cell (2, 2): position = (2*70+35, 2*70+35) = (175, 175)
	var token_pos := Vector2(2.5 * cell_px, 2.5 * cell_px)
	var radius := 6.0 * cell_px  # 420 px
	_renderer.set_visions([_make_vision(token_pos, radius)], cell_px, origin)

	# Scan the 20×30 grid
	var visible_count := 0
	var total_cells := 0
	for row in range(0, 30):
		for col in range(0, 20):
			total_cells += 1
			if _is_visible(col, row, cell_px, origin):
				visible_count += 1

	# A circle of radius ~6 cells should have ~113 visible cells (π*r² ≈ 113)
	# But grid cells are discrete; with radius 6 from cell (2,2), we expect
	# roughly the area of a circle of radius 6 cells: up to ~113 cells
	assert_gt(visible_count, 50, "circle of radius 6 should cover at least 50 cells")
	assert_lt(visible_count, total_cells - 100,
		"circle of radius 6 on a 20×30 grid should NOT cover all %d cells" % total_cells)


func test_cells_far_from_token_are_hidden() -> void:
	var cell_px := 70.0
	var origin := Vector2.ZERO
	# Token at cell (2, 2)
	var token_pos := Vector2(2.5 * cell_px, 2.5 * cell_px)
	var radius := 6.0 * cell_px
	_renderer.set_visions([_make_vision(token_pos, radius)], cell_px, origin)

	# Far corner: cell (19, 29) — should be hidden
	assert_false(_is_visible(19, 29, cell_px, origin),
		"cell (19,29) must be hidden — far outside radius 6")

	# Opposite corner: cell (0, 29) — should be hidden
	assert_false(_is_visible(0, 29, cell_px, origin),
		"cell (0,29) must be hidden")

	# cell (19, 0) — should be hidden
	assert_false(_is_visible(19, 0, cell_px, origin),
		"cell (19,0) must be hidden")


func test_nearby_cells_are_visible() -> void:
	var cell_px := 70.0
	var origin := Vector2.ZERO
	var token_pos := Vector2(2.5 * cell_px, 2.5 * cell_px)
	var radius := 6.0 * cell_px
	_renderer.set_visions([_make_vision(token_pos, radius)], cell_px, origin)

	# Token's own cell (2,2) must be visible
	assert_true(_is_visible(2, 2, cell_px, origin), "token cell (2,2) must be visible")

	# Adjacent cells within radius
	assert_true(_is_visible(0, 2, cell_px, origin), "cell (0,2) must be visible")
	assert_true(_is_visible(4, 2, cell_px, origin), "cell (4,2) must be visible")
	assert_true(_is_visible(2, 0, cell_px, origin), "cell (2,0) must be visible")
	assert_true(_is_visible(2, 4, cell_px, origin), "cell (2,4) must be visible")


func test_cells_beyond_radius_are_hidden() -> void:
	var cell_px := 70.0
	var origin := Vector2.ZERO
	var token_pos := Vector2(2.5 * cell_px, 2.5 * cell_px)
	var radius := 6.0 * cell_px
	_renderer.set_visions([_make_vision(token_pos, radius)], cell_px, origin)

	# 6 cells to the right from (2,2) = cell (8,2): distance = 6*70 + 35 - 35 = 420 ✓
	# 7 cells to the right = cell (9,2): distance = 7*70 = 490 > 420 ✗
	assert_true(_is_visible(8, 2, cell_px, origin),
		"cell (8,2) should be at edge of vision — 6 cells from token")
	assert_false(_is_visible(9, 2, cell_px, origin),
		"cell (9,2) should be outside vision — 7 cells from token")

	assert_true(_is_visible(2, 8, cell_px, origin),
		"cell (2,8) should be at edge of vision")
	assert_false(_is_visible(2, 9, cell_px, origin),
		"cell (2,9) should be outside vision")

	# Diagonals: cell (6,6) = distance sqrt(280²+280²)=396 < 420 → visible
	assert_true(_is_visible(6, 6, cell_px, origin),
		"cell (6,6) should be visible — diagonal within radius")
	# cell (7,7) = distance sqrt(350²+350²)=495 > 420 → hidden
	assert_false(_is_visible(7, 7, cell_px, origin),
		"cell (7,7) should be hidden — diagonal outside radius")


# ─── All cells hidden when no tokens have vision ─────────────

func test_all_hidden_when_no_visions() -> void:
	var cell_px := 70.0
	var origin := Vector2.ZERO
	_renderer.set_visions([], cell_px, origin)

	# All cells in a 10×10 area should be hidden (not visible)
	for row in range(0, 10):
		for col in range(0, 10):
			assert_false(_is_visible(col, row, cell_px, origin),
				"cell (%d,%d) should be hidden with no visions" % [col, row])


# ─── Multiple tokens ─────────────────────────────────────────

func test_multiple_tokens_combine_visions() -> void:
	var cell_px := 70.0
	var origin := Vector2.ZERO
	_renderer.set_visions([
		_make_vision(Vector2(35, 35), 140.0),
		_make_vision(Vector2(525, 525), 140.0),
	], cell_px, origin)

	# Covered by first token
	assert_true(_is_visible(0, 0, cell_px, origin))
	assert_true(_is_visible(1, 0, cell_px, origin))

	# Covered by second token
	assert_true(_is_visible(7, 7, cell_px, origin))
	assert_true(_is_visible(8, 7, cell_px, origin))

	# Not covered by either (cell (4,4))
	assert_false(_is_visible(4, 4, cell_px, origin))


# ─── Boundary: visible cell count ≤ π*r²/cell_px² ────────────

func test_visible_count_not_excessive() -> void:
	var cell_px := 70.0
	var origin := Vector2.ZERO
	var token_pos := Vector2(385, 385)  # cell (5,5)
	var radius_cells := 4.0
	var radius_px := radius_cells * cell_px
	_renderer.set_visions([_make_vision(token_pos, radius_px)], cell_px, origin)

	# Scan a 15x15 area centered on the token
	var count := _count_visible_in_range(0, 11, 0, 11, cell_px, origin)
	# Circle area = π*r² = π*4² ≈ 50. Grid cells ≈ ceil(50) = at most ~50-60
	assert_lt(count, 70, "visible cells should be ~50, not 100+")


# ─── Origin offset does not affect relative visibility ───────

func test_origin_offset() -> void:
	var cell_px := 70.0
	var origin := Vector2(200, -100)
	var token_pos := Vector2(500, 300)
	_renderer.set_visions([_make_vision(token_pos, 200.0)], cell_px, origin)

	assert_true(_renderer._is_cell_visible(Vector2(550, 320)))
	assert_false(_renderer._is_cell_visible(Vector2(1000, 1000)))
	assert_false(_renderer._is_cell_visible(Vector2(10, 10)))


# ─── Regression: negative min_col with fully hidden rows ──────
# Exact configuration that triggered the bug:
# origin=(-4,-6), cell_px=27, viewport=(0,0,800,600), vision at (100,100) radius=162

func test_negative_min_col_fully_hidden_rows() -> void:
	var cell_px := 27.0
	var origin := Vector2(-4.0, -6.0)
	var token_pos := Vector2(100.0, 100.0)
	var radius := 6.0 * cell_px  # 162 px
	_renderer.set_visions([_make_vision(token_pos, radius)], cell_px, origin)

	# Compute cell range as _draw() would: vr=(0,0,800,600)
	var min_col := int(floor((0.0 - origin.x) / cell_px)) - 1  # = -1
	var max_col := int(ceil((800.0 - origin.x) / cell_px)) + 1  # = 31
	var min_row := int(floor((0.0 - origin.y) / cell_px)) - 1  # = -1
	var max_row := int(ceil((600.0 - origin.y) / cell_px)) + 1  # = 24

	assert_eq(min_col, -1, "min_col should be -1 with origin.x=-4")
	assert_eq(min_row, -1, "min_row should be -1 with origin.y=-6")

	# Row far from token (row 20): ALL cells must be hidden
	for col in range(min_col, max_col + 1):
		assert_false(_is_visible(col, 20, cell_px, origin),
			"row 20, col %d must be hidden — outside vision radius" % col)

	# Row at token's Y (row ~3-4): some cells visible, others hidden
	# Cells far to the right must be hidden
	assert_false(_is_visible(20, 4, cell_px, origin),
		"col 20 at token's row must be hidden")

	# Cells near the token should be visible
	assert_true(_is_visible(3, 4, cell_px, origin),
		"col 3, row 4 must be visible — near token at (100,100)")

	# Count: fully hidden rows should outnumber partially visible rows
	var hidden_rows := 0
	var partial_rows := 0
	for row in range(min_row, max_row + 1):
		var all_hidden := true
		var any_visible := false
		for col in range(min_col, max_col + 1):
			var v := _is_visible(col, row, cell_px, origin)
			if v:
				all_hidden = false
				any_visible = true
		if all_hidden:
			hidden_rows += 1
		elif any_visible:
			partial_rows += 1

	assert_gt(hidden_rows, 0, "there must be rows where all cells are hidden")
	assert_gt(partial_rows, 0, "there must be rows where some cells are visible")
	assert_gt(hidden_rows, partial_rows,
		"fully hidden rows are the majority when token is near a corner")


# ─── Regression: state machine on fully hidden row ────────────
# Ensures run_was_started flag correctly tracks first transition.

func test_fully_hidden_row_all_cells_not_visible() -> void:
	var cell_px := 70.0
	var origin := Vector2.ZERO
	var token_pos := Vector2(385, 385)  # cell (5,5)
	var radius := 1.0 * cell_px  # only covers immediate neighbors
	var explored: Dictionary = {}
	_renderer.set_visions([_make_vision(token_pos, radius)], cell_px, origin, explored)

	# Row far from token (row 20 = 1435 px from token → hidden)
	for col in range(0, 11):
		assert_false(_is_visible(col, 20, cell_px, origin),
			"row 20 fully outside vision — every cell must be hidden")
		var state: int = _renderer._get_cell_state(col, 20)
		assert_eq(state, FogRendererClass.HIDDEN,
			"cell (%d,20) must be HIDDEN — outside vision and not explored" % col)


func test_all_cells_hidden_row_consistent_state() -> void:
	# Regression: ensures all cells in a fully hidden row have the same state (HIDDEN).
	# If _get_cell_state returns inconsistent values across a row, the row-marching
	# state machine won't detect the run correctly.
	var cell_px := 70.0
	var origin := Vector2.ZERO
	var explored: Dictionary = {}
	_renderer.set_visions([_make_vision(Vector2(385, 385), 70.0)], cell_px, origin, explored)

	var states: Array[int] = []
	for col in range(0, 11):
		states.append(_renderer._get_cell_state(col, 20))

	var first := states[0]
	for i in states.size():
		assert_eq(states[i], first,
			"all cells in fully hidden row must have the same state")
	assert_eq(first, FogRendererClass.HIDDEN,
		"fully hidden row state must be HIDDEN")


# ─── 11.3: 3-level fog (hidden / explored / visible) ─────────

func test_visible_cell_marks_explored() -> void:
	var cell_px := 70.0
	var origin := Vector2.ZERO
	var explored: Dictionary = {}
	_renderer.set_visions([_make_vision(Vector2(385, 385), 200.0)], cell_px, origin, explored)

	# Force a call to _get_cell_state for a visible cell
	var state: int = _renderer._get_cell_state(5, 5)
	assert_eq(state, FogRendererClass.VISIBLE, "cell (5,5) within vision radius should be VISIBLE")
	assert_true(explored.has("5,5"), "visible cell (5,5) should be added to explored dict")


func test_explored_cell_outside_vision_returns_explored() -> void:
	var cell_px := 70.0
	var origin := Vector2.ZERO
	var explored: Dictionary = {"10,10": true}
	_renderer.set_visions([_make_vision(Vector2(35, 35), 70.0)], cell_px, origin, explored)

	var state: int = _renderer._get_cell_state(10, 10)
	assert_eq(state, FogRendererClass.EXPLORED,
		"cell (10,10) outside vision but in explored should be EXPLORED")


func test_unknown_cell_outside_vision_returns_hidden() -> void:
	var cell_px := 70.0
	var origin := Vector2.ZERO
	var explored: Dictionary = {}
	_renderer.set_visions([_make_vision(Vector2(35, 35), 70.0)], cell_px, origin, explored)

	var state: int = _renderer._get_cell_state(20, 20)
	assert_eq(state, FogRendererClass.HIDDEN,
		"cell (20,20) outside vision and not explored should be HIDDEN")


func test_already_explored_stays_in_dict() -> void:
	var cell_px := 70.0
	var origin := Vector2.ZERO
	var explored: Dictionary = {"5,5": true}
	_renderer.set_visions([_make_vision(Vector2(35, 35), 70.0)], cell_px, origin, explored)

	# (5,5) is outside vision of token at (35,35) with radius 70
	# distance = sqrt((385-35)² + (385-35)²) = sqrt(245000) ≈ 495 > 70
	var state: int = _renderer._get_cell_state(5, 5)
	assert_eq(state, FogRendererClass.EXPLORED,
		"previously explored cell should remain EXPLORED")


func test_visible_overrides_explored() -> void:
	var cell_px := 70.0
	var origin := Vector2.ZERO
	var explored: Dictionary = {"5,5": true}
	_renderer.set_visions([_make_vision(Vector2(385, 385), 200.0)], cell_px, origin, explored)

	var state: int = _renderer._get_cell_state(5, 5)
	assert_eq(state, FogRendererClass.VISIBLE,
		"visible cell should be VISIBLE even if it was already explored")


func test_new_visible_cells_accumulate() -> void:
	var cell_px := 70.0
	var origin := Vector2.ZERO
	var explored: Dictionary = {"10,10": true}
	_renderer.set_visions([_make_vision(Vector2(35, 35), 200.0)], cell_px, origin, explored)

	# Check cells at (0,0) and (1,0) — should be visible and added
	_renderer._get_cell_state(0, 0)
	_renderer._get_cell_state(1, 0)
	assert_true(explored.has("10,10"), "pre-existing explored key should be preserved")
	assert_true(explored.has("0,0"), "newly visible cell (0,0) should be added")
	assert_true(explored.has("1,0"), "newly visible cell (1,0) should be added")


func test_hidden_cell_not_added_to_explored() -> void:
	var cell_px := 70.0
	var origin := Vector2.ZERO
	var explored: Dictionary = {}
	_renderer.set_visions([_make_vision(Vector2(35, 35), 70.0)], cell_px, origin, explored)

	# Cell (20,20) is far from token → hidden
	_renderer._get_cell_state(20, 20)
	assert_false(explored.has("20,20"),
		"hidden cell should NOT be added to explored dict")


# ─── 11.5: edge gradient states ──────────────────────────────

func test_cell_next_to_visible_is_hidden_edge() -> void:
	var cell_px := 70.0
	var origin := Vector2.ZERO
	var explored: Dictionary = {}
	# Token at (35,35) radius 70 → cell (0,0) and (1,0) are visible
	_renderer.set_visions([_make_vision(Vector2(35, 35), 70.0)], cell_px, origin, explored)

	# Cell (2,0) is adjacent to visible (1,0) but outside vision → HIDDEN_EDGE
	var state: int = _renderer._get_cell_state(2, 0)
	assert_eq(state, FogRendererClass.HIDDEN_EDGE,
		"cell (2,0) adjacent to visible should be HIDDEN_EDGE")


func test_cell_far_from_visible_is_hidden() -> void:
	var cell_px := 70.0
	var origin := Vector2.ZERO
	var explored: Dictionary = {}
	_renderer.set_visions([_make_vision(Vector2(35, 35), 70.0)], cell_px, origin, explored)

	# Cell (4,0) is 2 cells away from visible (1,0) → not adjacent → HIDDEN
	var state: int = _renderer._get_cell_state(4, 0)
	assert_eq(state, FogRendererClass.HIDDEN,
		"cell (4,0) not adjacent to visible should be HIDDEN")


func test_explored_adjacent_to_visible_is_explored_edge() -> void:
	var cell_px := 70.0
	var origin := Vector2.ZERO
	var explored: Dictionary = {"2,0": true}
	_renderer.set_visions([_make_vision(Vector2(35, 35), 70.0)], cell_px, origin, explored)

	# Cell (2,0) was explored, adjacent to visible (1,0) → EXPLORED_EDGE
	var state: int = _renderer._get_cell_state(2, 0)
	assert_eq(state, FogRendererClass.EXPLORED_EDGE,
		"explored cell adjacent to visible should be EXPLORED_EDGE")


func test_explored_far_from_visible_stays_explored() -> void:
	var cell_px := 70.0
	var origin := Vector2.ZERO
	var explored: Dictionary = {"5,0": true}
	_renderer.set_visions([_make_vision(Vector2(35, 35), 70.0)], cell_px, origin, explored)

	# Cell (5,0) explored, far from visible → EXPLORED
	var state: int = _renderer._get_cell_state(5, 0)
	assert_eq(state, FogRendererClass.EXPLORED,
		"explored cell far from visible should be EXPLORED")


func test_diagonal_visible_neighbor_counts() -> void:
	var cell_px := 70.0
	var origin := Vector2.ZERO
	var explored: Dictionary = {}
	# Token at (35,35) radius 100 → covers (0,0), (1,0), (0,1), (1,1)
	_renderer.set_visions([_make_vision(Vector2(35, 35), 100.0)], cell_px, origin, explored)

	# Cell (2,2) is diagonal-neighbor to visible (1,1) → HIDDEN_EDGE
	var state: int = _renderer._get_cell_state(2, 2)
	assert_eq(state, FogRendererClass.HIDDEN_EDGE,
		"cell diagonal-adjacent to visible should be HIDDEN_EDGE")

	# Cell (3,3) is not adjacent to any visible → HIDDEN
	var state2: int = _renderer._get_cell_state(3, 3)
	assert_eq(state2, FogRendererClass.HIDDEN,
		"cell 2 away from visible on diagonal should be HIDDEN")
