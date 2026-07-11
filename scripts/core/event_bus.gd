extends Node

## EventBus — bus de señales global para comunicación desacoplada entre módulos.
## Cada acción que modifica el estado del juego emite una señal desde aquí.

# ─── Sesión ──────────────────────────────────────────────
signal session_created(session_path: String)
signal session_loaded(session_path: String)
signal session_saved(session_path: String)
signal session_closed

# ─── Mapas ────────────────────────────────────────────────
signal map_added(map_id: String)
signal map_removed(map_id: String)
signal map_activated(map_id: String)
signal map_renamed(map_id: String, new_name: String)
signal map_reordered(from_index: int, to_index: int)
signal map_duplicated(source_id: String, new_id: String)

# ─── Grid ────────────────────────────────────────────────
signal grid_updated

# ─── Tokens ──────────────────────────────────────────────
signal token_added(token_id: String)
signal token_removed(token_id: String)
signal token_spawned(token_id: String, td_dict: Dictionary, position: Vector2, cell_px: float)
signal token_moved(token_id: String, from_pos: Vector2, to_pos: Vector2)
signal token_drag_update(from: Vector2, to: Vector2, distance_text: String, limit_px: float)
signal token_drag_end
signal token_selected(token_id: String)
signal token_deselected(token_id: String)
signal token_properties_changed(token_id: String)
signal token_visibility_changed(token_id: String, visible: bool)

# ─── Niebla de guerra ──────────────────────────────────
signal fog_mode_changed(mode: String)
signal fog_cells_revealed(cells: Array)
signal vision_blocker_added(blocker_id: String)
signal vision_blocker_removed(blocker_id: String)
signal vision_blocker_toggled(blocker_id: String, active: bool)

# ─── Medición y plantillas ─────────────────────────────
signal measurement_started
signal measurement_ended
signal template_added(template_id: String)
signal template_removed(template_id: String)

# ─── Efectos visuales ──────────────────────────────────
signal effect_added(effect_id: String)
signal effect_removed(effect_id: String)
signal effect_paused(effect_id: String)
signal effect_resumed(effect_id: String)

# ─── Iniciativa ────────────────────────────────────────
signal initiative_participant_added(participant_id: String)
signal initiative_participant_removed(participant_id: String)
signal initiative_turn_advanced(new_turn_index: int)
signal initiative_hp_changed(participant_id: String, new_hp: int)

# ─── Ventanas ──────────────────────────────────────────
signal player_window_opened
signal player_window_closed
signal view_mode_changed(mode: String)
signal player_view_changed(view_rect: Rect2)

# ─── Comandos / Undo ────────────────────────────────────
signal command_executed
signal command_undone
signal command_redone

# ─── Ajustes ────────────────────────────────────────────
signal units_changed(unit: String)
signal theme_changed(theme: String)
signal locale_changed(locale: String)
