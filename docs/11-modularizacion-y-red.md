# 11 — Modularización y Red Futura

## Descripción

Arquitectura interna diseñada para que la aplicación funcione hoy en local (misma
máquina, dos ventanas) y pueda evolucionar hacia juego en red (DM y jugadores en
dispositivos distintos) sin reescribir el núcleo.

## Funcionalidades

### 11.1 Separación de responsabilidades

La aplicación se estructura en capas independientes:

```
┌─────────────────────────────────────────┐
│              UI (Godot Scenes)           │
│  ┌───────────┐  ┌─────────────────────┐ │
│  │ DM Window  │  │  Player Window      │ │
│  └─────┬─────┘  └──────────┬──────────┘ │
│        │                   │            │
├────────┴───────────────────┴────────────┤
│          Game Manager (Autoload)         │
│  ┌─────────────────────────────────────┐│
│  │         Game State (Resource)       ││
│  │  - Map, Grid, Tokens, FoW, Effects  ││
│  └─────────────────────────────────────┘│
├─────────────────────────────────────────┤
│          Command Processor               │
│  ┌─────────────────────────────────────┐│
│  │  Command Pattern:                    ││
│  │  Cada acción del DM es un Command    ││
│  │  que modifica el Game State          ││
│  └─────────────────────────────────────┘│
├─────────────────────────────────────────┤
│          Event Bus (Signal-based)        │
│  ┌─────────────────────────────────────┐│
│  │  Señales:                            ││
│  │  state_changed(delta)                ││
│  │  token_moved(id, from, to)           ││
│  │  fog_revealed(cells)                 ││
│  │  initiative_advanced(turn)           ││
│  │  effect_added/removed(type, pos)     ││
│  └─────────────────────────────────────┘│
└─────────────────────────────────────────┘
```

### 11.2 Patrón Command para acciones

Cada acción del DM que modifica el estado del juego se encapsula como un objeto
Command. Esto permite:

- **Deshacer/rehacer**: La pila de comandos permite Ctrl+Z / Ctrl+Y.
- **Sincronización**: Los comandos se pueden serializar y transmitir.
- **Auditoría**: Registro de qué acciones se realizaron.
- **Modo red**: Los comandos se envían por red al servidor/host.

**Estructura de un Command**:
```
Command
├── type: String ("move_token", "add_effect", ...)
├── payload: Dictionary (datos específicos de la acción)
├── timestamp: int
├── execute(game_state) -> void
└── undo(game_state) -> void
```

### 11.3 Game State como fuente única de verdad

El `GameState` es un recurso Godot (o nodo Autoload) que contiene TODO el estado
de la sesión. Las ventanas no tienen estado propio: leen del GameState y emiten
señales cuando el usuario interactúa.

**Principios**:
- Los cambios de estado solo ocurren a través del Command Processor.
- Las vistas se actualizan reaccionando a las señales del Event Bus.
- Ninguna vista modifica el GameState directamente.

### 11.4 Preparación para red

La arquitectura está diseñada para que en el futuro:

1. **Hoy (local)**: Command Processor ejecuta comandos directamente.
   ```
   UI DM → Command → CommandProcessor → GameState → EventBus → UI Player
   ```

2. **Futuro (red)**: Se interpone un `NetworkSync` entre el Command Processor
   y el GameState remoto.
   ```
   UI DM → Command → NetworkSync (host) → GameState (host)
                         ↓ WebSocket
   UI Player ← EventBus ← NetworkSync (client) ← GameState (cliente)
   ```

**Lo que cambia en modo red**:
- El GameState reside solo en el host (DM).
- El cliente (jugador) tiene una copia de solo lectura del estado relevante.
- Los comandos se validan en el host antes de aplicarse.
- El host transmite `state_changed` a todos los clientes conectados.

### 11.5 Plugin system (futuro)

La modularización permite añadir funcionalidades como plugins:

- Plugins de reglas de juego (DnD 5e, Pathfinder, sistema propio).
- Plugins de importación (Dungeon Scrawl, D&D Beyond).
- Plugins de efectos visuales adicionales.
- Plugins de idiomas/localización.

---

## Casos de uso y ejemplos para test

| ID    | Caso                                              | Resultado esperado                                      |
|-------|---------------------------------------------------|---------------------------------------------------------|
| MOD-01| Mover token → se emite Command                     | `move_token` command se procesa, GameState se actualiza|
| MOD-02| Deshacer movimiento con Ctrl+Z                     | Token vuelve a posición anterior; niebla se revierte    |
| MOD-03| Rehacer con Ctrl+Y                                 | Token vuelve a la nueva posición                        |
| MOD-04| Añadir efecto → comando emitido                    | `add_effect` se procesa, efecto visible en ambas ventanas|
| MOD-05| EventBus emite token_moved                         | Ventana jugadores recibe señal y actualiza sprite       |
| MOD-06| CommandProcessor con 100 comandos en pila          | Deshacer/rehacer funcionan sin degradación de memoria   |
| MOD-07| UI Player intenta modificar GameState directamente | No es posible; GameState solo acepta cambios vía Command|
| MOD-08| Simular cliente red: recibir state_changed         | UI Player se actualiza igual que en modo local          |
| MOD-09| Serializar un Command a JSON                       | Se puede reconstruir idéntico al deserializar           |
| MOD-10| Dos ventanas DM abiertas por error                 | Solo se permite una ventana DM; la segunda se rechaza   |
