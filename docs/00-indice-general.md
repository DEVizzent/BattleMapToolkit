# BattleMap Toolkit — Documento General

## Propósito

Aplicación de escritorio multiplataforma para gestionar y jugar partidas de DnD con
una pantalla táctil externa. El DM prepara una sesión que contiene múltiples mapas
(taberna, mazmorra, sala del jefe...), alternando entre ellos durante la partida.
La ventana del DM incluye un indicador visual de qué porción del mapa están viendo
los jugadores en su pantalla.

## Stack tecnológico

- **Motor**: Godot 4 (GDScript / C# opcional)
- **Renderizado**: Godot 2D (TileMap, Light2D, GPUParticles2D, RayCast2D)
- **Plataformas**: Windows, macOS, Linux
- **Formato de sesión**: JSON o binario propio (.bmap)

## Funcionalidades principales

| ID  | Módulo                     | Descripción breve                                        |
|-----|----------------------------|----------------------------------------------------------|
| 01  | Gestión de mapas           | Carga, biblioteca, zoom, paneo                           |
| 02  | Sistema de cuadrícula      | Overlay de grid escalable con el mapa                    |
| 03  | Gestión de tokens          | Importar, posicionar, tamaño en casillas                 |
| 04  | Movimiento y distancias    | Mover tokens y mostrar distancia recorrida               |
| 05  | Niebla de guerra           | Fog of War revelado por visión de tokens                 |
| 06  | Herramientas de medición   | Medir distancias y mostrar áreas (cuadrado, círculo, cono)|
| 07  | Efectos visuales           | Partículas, iluminación dinámica, capas de efectos       |
| 08  | Sistema de iniciativa      | Orden de turno, stats de criaturas (HP, CA)              |
| 09  | Sistema de ventanas        | Ventana DM con controles + ventana Jugadores táctil      |
| 10  | Gestión de sesiones        | Guardar, cargar, exportar e importar sesiones            |
| 11  | Modularización y red       | Arquitectura preparada para juego en red futuro          |
| 12  | Interfaz inicial           | Launcher: nueva sesión, abrir, importar, recientes       |
| 13  | Plan de implementación     | 18 fases, ~150 pasos con checkboxes verificables          |
| 14  | Internacionalización (i18n)| Español, inglés, auto-detección, selector en ajustes      |

## Convenciones

- **Casilla base**: 30 pies (9.144 m) o 1.5 metros, configurable.
- **Formato de imagen soportado**: PNG, JPG, WebP, BMP.
- **Resolución máxima de mapa**: sin límite duro; se aplica streaming/mipmapping según GPU.
- **Idioma de la documentación**: castellano.
- **Unidades de medida**: pies por defecto, metros configurables.

## Estructura del proyecto (prevista)

```
DndMap/
├── project.godot
├── docs/                  # Documentación
├── assets/                # Recursos embebidos
├── scenes/
│   ├── ui/                # Escenas de UI
│   ├── map/               # Escenas del mapa
│   └── tokens/            # Escenas de tokens
├── scripts/
│   ├── core/              # Lógica central
│   ├── map/               # Gestión del mapa
│   ├── tokens/            # Gestión de tokens
│   ├── fog/               # Niebla de guerra
│   ├── effects/           # Efectos visuales
│   ├── initiative/        # Sistema de iniciativa
│   ├── session/           # Guardado/carga
│   └── network/           # Capa de red futura
├── test/                   # Tests unitarios y de integración
│   ├── test_map/           # 01 — Gestión de mapas
│   ├── test_grid/          # 02 — Sistema de cuadrícula
│   ├── test_tokens/        # 03 — Gestión de tokens
│   ├── test_movement/      # 04 — Movimiento y distancias
│   ├── test_fog/           # 05 — Niebla de guerra
│   ├── test_measurement/   # 06 — Herramientas de medición
│   ├── test_effects/       # 07 — Efectos visuales
│   ├── test_initiative/    # 08 — Sistema de iniciativa
│   ├── test_windows/       # 09 — Sistema de ventanas
│   ├── test_sessions/      # 10 — Gestión de sesiones
│   ├── test_network/       # 11 — Modularización y red
│   └── test_launcher/      # 12 — Interfaz inicial
└── library/               # Biblioteca de assets del usuario
```
