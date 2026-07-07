extends Node

## GameState — estado global de la aplicación.
## Actúa como fuente única de verdad. Las vistas leen de aquí;
## los cambios de estado se realizan exclusivamente a través del CommandProcessor.

# ─── Sesión actual ──────────────────────────────────────────
var session_name: String = ""
var session_path: String = ""
var session_dirty: bool = false  # true si hay cambios sin guardar

# ─── Configuración de unidades ─────────────────────────────
enum Units { FEET, METERS }
var current_units: int = Units.FEET
var feet_per_cell: float = 5.0
var meters_per_cell: float = 1.5

# ─── Mapas ─────────────────────────────────────────────────
var maps: Array = []          # Array de MapData
var current_map_index: int = -1

# ─── Cuadricula por mapa ──────────────────────────────────
var map_grids: Dictionary = {}  # key: int (map_index), value: GridData

# ─── Tokens (por mapa) ─────────────────────────────────────
# key: int (map_index), value: Array de TokenData
var map_tokens: Dictionary = {}

# ─── Iniciativa ────────────────────────────────────────────
var initiative_participants: Array = []
var initiative_current_turn: int = -1
var initiative_global: bool = true  # true = global, false = por mapa

# ─── Efectos activos ──────────────────────────────────────
var active_effects: Dictionary = {}  # key: effect_id, value: EffectData

# ─── Modo de vista ────────────────────────────────────────
enum ViewMode { SYNCED, INDEPENDENT, FOLLOW_TURN }
var view_mode: int = ViewMode.SYNCED

# ─── Reglas ────────────────────────────────────────────────
var diagonal_rule: bool = true

# ─── Ventana de jugadores ─────────────────────────────────
var player_window_open: bool = false
var player_monitor: int = 1  # índice del monitor

# ─── Métodos helper ────────────────────────────────────────

func get_current_map():
	if current_map_index >= 0 and current_map_index < maps.size():
		return maps[current_map_index]
	return null


func get_cell_distance_ft(cells: int) -> float:
	return cells * feet_per_cell


func get_cell_distance_meters(cells: int) -> float:
	return cells * meters_per_cell


func get_distance_label(cells: int) -> String:
	match current_units:
		Units.METERS:
			return "%.1f m (%d casillas)" % [get_cell_distance_meters(cells), cells]
		_:
			return "%d pies (%d casillas)" % [int(get_cell_distance_ft(cells)), cells]


func get_distance_string(cells: int) -> String:
	match current_units:
		Units.FEET:
			return "%.0f pies (%d casillas)" % [get_cell_distance_ft(cells), cells]
		Units.METERS:
			return "%.1f m (%d casillas)" % [get_cell_distance_meters(cells), cells]
	return ""


func mark_dirty() -> void:
	session_dirty = true


func mark_clean() -> void:
	session_dirty = false


func get_current_tokens() -> Array:
	var idx: int = current_map_index if current_map_index >= 0 else -1
	if not map_tokens.has(idx):
		map_tokens[idx] = []
	return map_tokens[idx]


func add_token_for_current_map(td: Resource) -> void:
	var tokens_arr := get_current_tokens()
	tokens_arr.append(td)
	mark_dirty()


func remove_token_for_current_map(index: int) -> void:
	var tokens_arr := get_current_tokens()
	if index >= 0 and index < tokens_arr.size():
		tokens_arr.remove_at(index)
		mark_dirty()


func get_current_grid() -> Resource:
	var idx: int = current_map_index if current_map_index >= 0 else -1
	if not map_grids.has(idx):
		var GridDataClass := preload("res://scripts/grid/grid_data.gd")
		map_grids[idx] = GridDataClass.new()
	return map_grids[idx]


static func count_cells_grid(from: Vector2, to: Vector2, cell_px: float, origin: Vector2, diagonal_rule: bool) -> int:
	if cell_px <= 0:
		return 0
	var from_cell_x: int = int(floor((from.x - origin.x) / cell_px))
	var from_cell_y: int = int(floor((from.y - origin.y) / cell_px))
	var to_cell_x: int = int(floor((to.x - origin.x) / cell_px))
	var to_cell_y: int = int(floor((to.y - origin.y) / cell_px))
	var dx: int = abs(to_cell_x - from_cell_x)
	var dy: int = abs(to_cell_y - from_cell_y)
	if diagonal_rule:
		var max_delta: int = max(dx, dy)
		var min_delta: int = min(dx, dy)
		var straight: int = max_delta - min_delta
		if min_delta <= straight + 1:
			return max_delta
		return max_delta + int(floor(float(2 * min_delta - max_delta) / 2.0))
	return max(dx, dy)


# ─── Persistencia ──────────────────────────────────────────

const MapDataClass := preload("res://scripts/map/map_data.gd")
const GridDataClass := preload("res://scripts/grid/grid_data.gd")
const TokenDataClass := preload("res://scripts/token/token_data.gd")

const SESSION_VERSION := "0.2.0"


func to_dict() -> Dictionary:
	var d := {
		"version": SESSION_VERSION,
		"name": session_name,
		"settings": {
			"current_units": current_units,
			"feet_per_cell": feet_per_cell,
			"meters_per_cell": meters_per_cell,
			"view_mode": view_mode,
			"diagonal_rule": diagonal_rule,
		},
		"maps": [],
		"grids": {},
		"tokens": {},
		"initiative": {
			"participants": initiative_participants.duplicate(),
			"current_turn": initiative_current_turn,
			"global": initiative_global,
		},
		"player": {
			"window_open": player_window_open,
			"monitor": player_monitor,
		},
	}
	for m in maps:
		d["maps"].append(m.to_dict())
	for key in map_grids:
		d["grids"][str(key)] = map_grids[key].to_dict()
	for key in map_tokens:
		var arr: Array = []
		for td in map_tokens[key]:
			arr.append(td.to_dict())
		d["tokens"][str(key)] = arr
	return d


func from_dict(d: Dictionary) -> void:
	_clear_all()
	var settings: Dictionary = d.get("settings", {})
	current_units = settings.get("current_units", Units.FEET)
	feet_per_cell = settings.get("feet_per_cell", 5.0)
	meters_per_cell = settings.get("meters_per_cell", 1.5)
	view_mode = settings.get("view_mode", ViewMode.SYNCED)
	diagonal_rule = settings.get("diagonal_rule", true)
	var maps_arr: Array = d.get("maps", [])
	for md in maps_arr:
		maps.append(MapDataClass.from_dict(md))
	var grids_dict: Dictionary = d.get("grids", {})
	for key in grids_dict:
		map_grids[int(key)] = GridDataClass.from_dict(grids_dict[key])
	var tokens_dict: Dictionary = d.get("tokens", {})
	for key in tokens_dict:
		var arr: Array = []
		for td_dict in tokens_dict[key]:
			arr.append(TokenDataClass.from_dict(td_dict))
		map_tokens[int(key)] = arr
	var initiative_dict: Dictionary = d.get("initiative", {})
	initiative_participants = initiative_dict.get("participants", [])
	initiative_current_turn = initiative_dict.get("current_turn", -1)
	initiative_global = initiative_dict.get("global", true)
	var player_dict: Dictionary = d.get("player", {})
	player_window_open = player_dict.get("window_open", false)
	player_monitor = player_dict.get("monitor", 1)
	session_name = d.get("name", "")
	mark_clean()


func _clear_all() -> void:
	maps.clear()
	map_grids.clear()
	map_tokens.clear()
	initiative_participants.clear()
	initiative_current_turn = -1
	current_map_index = -1
	session_name = ""
	session_dirty = false
