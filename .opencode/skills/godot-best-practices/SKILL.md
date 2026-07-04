---
name: godot-best-practices
description: Use when working with Godot Engine projects to apply best practices on scene organization, OOP principles, scripts vs scenes, autoloads, node alternatives, interfaces, notifications, data/logic preferences, project structure, and version control. Triggered by Godot, gdscript, game development, or godot best practices keywords.
---

# Godot Best Practices

This skill contains the most relevant best practices from the official Godot Engine documentation (v4.7) for structuring projects, scenes, scripts, and logic.

---

## 1. Object-Oriented Principles in Godot

- **Scripts** are resources that extend built-in engine classes. They register data (methods, properties, signals, constants) into the `ClassDB`. Even scripts without `extends` inherit from `RefCounted`.
- **Scenes** are reusable, instantiable groups of nodes. A scene is always an extension of the script attached to its root node — think of a scene as a class.
- Apply OOP principles to both scripts and scenes: single responsibility, encapsulation, loose coupling.

---

## 2. Scene Organization

### Loose Coupling & Dependency Injection
- **Design scenes with no external dependencies** whenever possible.
- If a scene must interact with an external context, use dependency injection. The parent context initializes the child's dependencies via one of these methods (ordered from safest to most coupled):
  1. **Signal connection** — safest, use only to "respond" to behavior.
  2. **Method call** — used to start behavior.
  3. **Callable property** — safer than method, ownership not required.
  4. **Node/Object reference** — pass a direct reference.
  5. **NodePath** — pass a path string.

- Sibling nodes should NOT know about each other directly. An ancestor should mediate their communications.
- Use `_get_configuration_warnings()` in tool scripts to self-document dependencies in the editor via warning icons.

### Choosing Node Tree Structure
- Recommended root structure:
  ```
  Node "Main" (main.gd)          ← Primary controller / entry point
    ├── Node2D/Node3D "World"    ← Game world (swap children for level changes)
    └── Control "GUI"            ← Menus and widgets
  ```
- Use **autoloads** only for systems that: track data internally, need global accessibility, and exist in isolation.
- Use parent-child relationships only when removing the parent logically means children should also be removed.
- Use `RemoteTransform2D`/`RemoteTransform3D` to position separated nodes relative to each other.
- For nodes that shouldn't inherit parent transforms: insert a plain `Node` between them (declarative), or use `top_level` property (imperative).
- Organize the SceneTree in **relational terms**, not spatial terms.

### OOP Principles to Follow
**SOLID**, **DRY** (Don't Repeat Yourself), **KISS** (Keep It Simple Stupid), **YAGNI** (You Aren't Gonna Need It).

---

## 3. When to Use Scenes vs Scripts

### Scenes (`.tscn`)
- Define node composition declaratively.
- **Faster** than scripts at initialization — the engine processes scenes in batches.
- Use scenes for **game-specific concepts** — easier to track/edit, more security.

### Scripts (`.gd` / `.cs`)
- Define behavior with imperative code.
- Can be registered as named types via **Script Classes** (`class_name`) — accessible at runtime and in the editor, supports inheritance.
- Use scripts for **reusable tools** across multiple projects, especially for non-programmers.

### Performance
- Building node hierarchies from scripts is slower than instantiating scenes. Each script instruction calls the scripting API with multiple lookups.
- Scenes use serialized data; the engine processes them much faster.

---

## 4. Autoloads vs Regular Nodes

### Avoid Global State — Prefer Local Management
- **Problem with autoloads**: global state, global access (hard to trace bugs), global resource allocation.
- **Prefer**: each scene manages its own state and nodes.

### Alternatives to Autoloads
- For shared **functions**: use `class_name` + `static func`.
- For shared **data**: use custom `Resource` types, or store data in the scene root (`owner`).
- Since Godot 4.1: `static var` in GDScript for shared class-level variables.

### When Autoloads ARE Appropriate
- Systems with a wide scope that manage their own data without invading other objects: quest systems, dialogue systems.
- An autoload is **not necessarily a singleton** — you can still instantiate copies.

---

## 5. Avoid Using Nodes for Everything

Use lighter alternatives when you don't need the full `Node` overhead:

| Type | Use Case | Notes |
|---|---|---|
| **Object** | Custom data structures | Manual memory management; references can become invalid. |
| **RefCounted** | Most custom data classes | Auto-frees when no references remain. |
| **Resource** | Serializable, inspector-compatible data | Save/load support, displays properties in Inspector. Extends RefCounted. |

Build custom tree/list structures extending `Object`/`RefCounted` instead of `Node` when you don't need scene tree features.

---

## 6. Godot Interfaces

### Acquiring Object References
- **Property/method access**: `node.object`, `node.get_object()`
- **Load access**: `preload(path)` (static, at script load), `load(path)` (runtime). Cache scenes/scripts in constants with PascalCase.
- **SceneTree access**: `get_node()`, `$Child` (GDScript shorthand), `@onready var`, or `@export var` for editor-assignable references.

### Duck-Typed Access
Godot's scripting API is duck-typed. Property lookup sequence:
1. Script override (setter/getter)
2. ClassDB HashMap lookup (class + inherited types)
3. `script`/`meta` property check
4. `_set`/`_get` implementation
5. `_get_property_list`

### Access Patterns (ordered by safety)
1. **Callable property** — most decoupled (`child.fn.call()`)
2. **Has-method check** — `if child.has_method("set_visible"): child.set_visible(false)`
3. **Cast check** — `if child is CanvasItem: child.set_visible(false)`
4. **Groups/Names** — `if child.is_in_group("quest"): child.complete()`
5. **Assert** — `assert(child.has_method("set_visible"))`

---

## 7. Godot Notifications

### Key Notification Callbacks
| Virtual Method | Notification | Purpose |
|---|---|---|
| `_init()` | — | Initialization; runs before `_enter_tree()`. |
| `_enter_tree()` | `NOTIFICATION_ENTER_TREE` | When node enters scene tree. |
| `_ready()` | `NOTIFICATION_READY` | After all children are ready. Cascades up from leaves to root. |
| `_process(delta)` | `NOTIFICATION_PROCESS` | Every frame, framerate-dependent. |
| `_physics_process(delta)` | `NOTIFICATION_PHYSICS_PROCESS` | Fixed timestep, framerate-independent. |
| `_exit_tree()` | `NOTIFICATION_EXIT_TREE` | When node leaves scene tree. |

### Init Sequence for Instantiated Scenes
1. **Initial value assignment** — property gets default/init value (setter NOT triggered)
2. **`_init()` assignment** — overwrites values (setter IS triggered)
3. **Exported value assignment** — Inspector values overwrite (setter IS triggered)

### Choosing Update Methods
- `_process(delta)`: use when updates should happen as often as possible.
- `_physics_process(delta)`: use for physics, kinematics, consistent-time operations.
- `*_input(event)`: use for input handling — only fires when input is detected (more efficient than polling in `_process`).
- **Timer loop**: use for recurring logic that doesn't need every frame.

### NOTIFICATION_PARENTED / NOTIFICATION_UNPARENTED
Use these to react to parent changes in data-centric nodes created at runtime, without needing `_enter_tree`/`_exit_tree`.

---

## 8. Data Preferences

### Array vs Dictionary vs Object

| Operation | Array | Dictionary | Object |
|---|---|---|---|
| Iterate | Fastest (contiguous) | Fast | Varies |
| Insert/Erase | Slow (except at end) | Fastest | Varies |
| Get/Set | Fast (by position) | Fast (by key) | Slower (multi-source queries) |
| Find | Slowest | Slowest | Varies |

- **Array**: contiguous memory (`Vector<Variant>`). Best for iteration. Slow for arbitrary insertion/removal at front (invert array → modify end → re-invert).
- **Dictionary**: HashMap. Best for key-based lookup. O(1) access.
- **Object**: multi-source queries through script → ClassDB → inherited types. Slower but offers control, clarity, signals, and convenience.

### Enums: int vs string
- Integer comparisons are faster (constant-time vs linear-time).
- Use strings for enums if printing values is the primary use case.

### Animation Classes
- **AnimatedTexture** (Resource): simple looping texture. Can be used in TileSets.
- **AnimatedSprite2D** + SpriteFrames: 2D frame-based sprite animations.
- **AnimationPlayer**: cut-out animations, 2D mesh animations, trigger effects, call functions.
- **AnimationTree**: blending, hierarchical state machines for animations.

---

## 9. Logic Preferences

### Set Properties Before Adding to Scene Tree
Always modify node properties **before** `add_child()`. Some setter code is expensive, especially noticeable in procedural generation.

### Loading vs Preloading
- **`preload(path)`**: loads at script compile time. Use for constants/classes. Cannot be unloaded except by unloading the script.
- **`load(path)`**: loads at statement execution. Use for optional/dynamic dependencies. Can be unloaded by setting to `null`.

**When to use each:**
- If load timing is unpredictable → avoid preloading.
- If value can be replaced by export/Inspector → `load()` or null default.
- If importing a stable class resource → `preload()` constant.
- If memory-sensitive with many dependencies → `load()` and unload as needed.

### Large Levels: Static vs Dynamic
- **Static**: load everything at once. Simpler, but high memory. Good for small games.
- **Dynamic**: load/unload pieces in real-time. Complex, but memory-efficient. Good for large/procedural games.
- Break large scenes into smaller reusable sub-scenes regardless of approach.

---

## 10. Project Organization

### Recommended Folder Structure
```
/project.godot
/models/town/house/house.dae
/models/town/house/window.png
/characters/player/cubio.dae
/characters/npcs/suzanne/suzanne.dae
/levels/riverdale/riverdale.scn
/docs/.gdignore          ← Excluded from import
```

### Naming Conventions
- **Files and folders**: `snake_case` (avoids case-sensitivity issues on export).
- **C# scripts**: PascalCase (matching class name convention).
- **Node names in scene tree**: PascalCase (matching built-in node casing).
- Third-party resources: top-level `addons/` folder.

### Case Sensitivity
- Windows/macOS: case-insensitive. Linux/PCK export: case-sensitive.
- **Always use `snake_case`** to prevent cross-platform issues.
- Optional: enable case sensitivity on Windows via `fsutil file setcasesensitiveinfo <path> enable`.

### Ignoring Folders from Import
Create an empty `.gdignore` file in a folder to prevent Godot from importing its contents.

---

## 11. Version Control

### Files to Exclude (`.gitignore`)
```
.godot/           ← Project cache data
*.translation     ← Binary imported translations
```

### Git Configuration on Windows
Set `core.autocrlf` to `input` to prevent unnecessary line-ending changes:
```
git config --global core.autocrlf input
```
Alternatively, Godot's generated `.gitattributes` enforces LF line endings automatically.

### Git LFS Setup
Install and configure for large assets:
```bash
git lfs install
git lfs track "*.png"
git lfs track "*.glb"
git lfs track "*.wav"
git lfs track "*.blend"
# etc.
```

Key LFS-tracked types: `.fbx`, `.gltf`, `.glb`, `.blend`, `.obj`, `.png`, `.jpg`, `.tga`, `.webp`, `.mp3`, `.wav`, `.ogg`, `.ttf`, `.otf`.

### Generating VCS Metadata
In the editor: **Project > Version Control > Generate Version Control Metadata** — creates `.gitignore` and `.gitattributes` automatically.
