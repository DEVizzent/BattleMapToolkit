# AGENTS.md — Convenciones del proyecto BattleMap Toolkit

## Reglas de código

1. **Escenas con nodos, no UI programática**: toda la estructura de UI se define en archivos `.tscn` usando el editor de Godot o escribiendo nodos declarativos. Los scripts `.gd` solo contienen lógica (señales, estado). No se construyen nodos en `_ready()` con `add_child()`.

2. **`preload` para dependencias entre scripts**: cuando un script necesita otro tipo/clase, se usa `const MiClase := preload("res://...")`. No se depende de `class_name` para resolución automática (falla en autoloads y autoreferencias).

3. **Orden de autoloads**: EventBus → GameState → RecentSessions → Settings. Si un autoload B depende de A, A debe declararse antes en `project.godot`.

4. **Nombrado de nodos únicos**: usar `%NombreUnico` en la escena para los nodos referenciados desde `@onready var` en el script.

5. **Señales**: toda comunicación entre módulos pasa por `EventBus`. Los cambios de estado se emiten como señales. Las vistas reaccionan a señales, no modifican `GameState` directamente.

6. **Estilo de código**:
   - `snake_case` para archivos, carpetas, variables y funciones.
   - `PascalCase` para nombres de nodos en la escena.
   - Sin comentarios redundantes. Solo docstrings (`##`) en cabeceras de archivo/clase.
   - Sin comentarios inline salvo que expliquen un "por qué" no obvio.

7. **Verificación**: cada paso de implementación se verifica ejecutando el proyecto con `--headless --quit`. Si hay errores de parseo, se corrigen antes de marcar el paso como completado.

8. **No crear UI programáticamente** (`add_child`, `new()`, `Container.new()` en `_ready()`). Usar el editor para montar escenas. Si no se puede usar el editor, escribir el `.tscn` a mano con el formato correcto de Godot 4.

## Estructura de escenas (DM Window)

```
DMWindow (Control, full screen)
├── Toolbar (HBoxContainer, top)
│   ├── ZoomInBtn
│   ├── ZoomOutBtn
│   ├── FitBtn
│   ├── GridToggleBtn
│   ├── MeasureBtn
│   ├── EffectsBtn
│   └── ViewModeDropdown
├── HBoxContainer (fill)
│   ├── LeftPanel (VBoxContainer, 250px)
│   │   ├── MapListTitle (Label)
│   │   ├── AddMapBtn (Button)
│   │   ├── MapList (ItemList)
│   │   ├── TokenListTitle (Label)
│   │   ├── ImportTokenBtn (Button)
│   │   └── TokenList (ItemList)
│   ├── MapViewport (SubViewportContainer, fill)
│   │   └── SubViewport
│   │       └── MapRoot (Node2D)
│   │           ├── MapSprite (Sprite2D)
│   │           ├── GridLayer (Node2D)
│   │           ├── TokenLayer (Node2D)
│   │           ├── FogLayer (Node2D)
│   │           └── EffectLayer (Node2D)
│   └── RightPanel (VBoxContainer, 300px)
│       ├── PropertiesTitle (Label)
│       ├── PropertiesContent
│       ├── InitiativeTitle (Label)
│       ├── AddInitiativeBtn (Button)
│       └── InitiativeTable
├── StatusBar (HBoxContainer, bottom, 24px)
│   ├── ZoomLabel
│   ├── CoordsLabel
│   └── FPSLabel
├── OpenMapDialog (FileDialog)
└── ImportTokenDialog (FileDialog)
```

## Formato de escenas .tscn

Usar `format=3` con UIDs generados por Godot. Para crear nuevas escenas, abrir el editor. Si se escribe a mano:

```
[gd_scene load_steps=N format=3 uid="uid://xxx"]

[ext_resource type="Script" id="1_script" path="res://scripts/ui/escena.gd"]

[node name="Raiz" type="Control"]
layout_mode = 3
anchors_preset = 15
anchor_right = 1.0
anchor_bottom = 1.0
grow_horizontal = 2
grow_vertical = 2
script = ExtResource("1_script")

[node name="%HijoUnico" type="Button" parent="."]
layout_mode = 1
text = "Texto"

[connection signal="pressed" from="%HijoUnico" to="." method="_on_hijo_pressed"]
```

## Convenciones de internacionalización (i18n)

9. **Textos de UI en `.tscn`**: usar español como idioma base en los campos `text` de los nodos. El sistema de auto-translate de Godot los sustituye automáticamente cuando `TranslationServer.set_locale()` cambia.

10. **Textos en GDScript**: usar claves cortas con `tr("CLAVE")`. Las claves se definen en `locale/translations.csv`.

11. **CSV de traducciones**: formato `keys,en,es`. Primera columna = clave, resto = traducciones por locale. No usar `class_name` para referencias circulares; usar `preload`.

12. **Detección de idioma**: `LocaleManager` consulta `OS.get_locale_language()` al iniciar. La preferencia del usuario en `Settings.language` tiene prioridad.

13. **Nuevos textos**: añadir la clave al CSV y usar `tr("CLAVE")` en código. Para textos de escena, el valor del `text` del nodo es la clave.
