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
var feet_per_cell: float = 30.0
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
