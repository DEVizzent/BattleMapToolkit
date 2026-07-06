# Plan de Implementación — BattleMap Toolkit

> Cada paso es verificable de forma independiente. Marcar `[x]` al completar.

---

## Fase 0: Andamiaje del proyecto

- [x] 0.1 Crear proyecto Godot 4, `.gitignore` — _Verificación: el proyecto abre en el editor sin errores_
- [x] 0.2 Crear estructura de carpetas (`scenes/`, `scripts/`, `assets/`, `test/`, `library/`) — _Las carpetas existen en el sistema de archivos_
- [x] 0.3 Configurar project settings (título ventana, resolución 1920×1080, input map para teclas) — _Al ejecutar, ventana con título "BattleMap Toolkit"_
- [x] 0.4 Crear Autoload `EventBus` (señales vacías: `session_created`, `map_loaded`, `token_moved`, etc.) — _Sin errores al iniciar; script accesible globalmente_
- [x] 0.5 Crear Autoload `GameState` (Resource con campos vacíos: sesión actual, mapas, tokens activos) — _`GameState` accesible desde cualquier nodo_

## Fase 1: Launcher — pantalla de bienvenida

- [x] 1.1 Escena `Launcher.tscn`: `Control` raíz, layout centrado, título "BattleMap Toolkit" — _Verificación: ejecutar proyecto → se ve título (LCH-01)_
- [x] 1.2 Botón "Nueva sesión" → emite señal `new_session_requested` — _Click → señal se emite (verificar con print)_
- [x] 1.3 Botón "Abrir sesión" → abre `FileDialog` filtrando `.bmap` — _Se abre diálogo del SO; solo muestra `.bmap`_
- [x] 1.4 Botón "Importar sesión" → abre `FileDialog` filtrando `.bmap` y `.zip` — _Se abre diálogo; muestra ambos formatos_
- [x] 1.5 `SessionData` Resource: `name: String`, `maps_count: int`, `last_modified: String`, `file_path: String` — _Crear recurso en inspector, campos editables_
- [x] 1.6 `RecentSessions` Autoload: guarda/carga lista de `SessionData` en `user://recent_sessions.json` — _Crear sesión falsa, cerrar app, reabrir → aparece en consola_
- [x] 1.7 Panel "Sesiones recientes": `ItemList` vacío condicional (oculto si 0 sesiones) — _App primer uso → panel oculto (LCH-01)_
- [x] 1.8 Rellenar `ItemList` con sesiones de `RecentSessions`: nombre + nº mapas + fecha — _3 sesiones en JSON → 3 filas visibles (LCH-03)_
- [x] 1.9 Doble click en sesión reciente → cargar `.bmap` y cambiar a escena DM — _Doble click → transición a DM (LCH-04)_
- [x] 1.10 Sesión reciente no encontrada en disco → entrada en gris "(no encontrado)" + aviso — _Borrar archivo → entrada gris, no crashea (LCH-05)_
- [x] 1.11 Click derecho > "Eliminar de recientes" en `ItemList` — _Entrada desaparece; JSON actualizado (LCH-06)_
- [x] 1.12 Banner de recuperación (visible si `user://autosave.bmap` existe) — _Crear autosave falso → banner visible (LCH-07)_
- [x] 1.13 Botón "Recuperar" en banner → cargar autosave, abrir DM — _Autosave cargado, sesión restaurada (LCH-07)_
- [x] 1.14 Botón "Descartar" en banner → borrar autosave, mostrar launcher limpio — _Autosave eliminado, banner oculto (LCH-08)_
- [x] 1.15 Botón "Ajustes" → panel con: carpeta por defecto, unidades (ft/m), idioma, tema — _Panel se abre/cierra; cambios persisten en `user://settings.json`_
- [x] 1.16 Al crear/abrir sesión: transición del launcher a la escena DM (`SceneTree.change_scene`) — _Se abre DM con sesión recién creada (LCH-02)_

## Fase 2: DM Window — carcasa

- [x] 2.1 Escena `DMWindow.tscn`: `Control` raíz con layout de 3 columnas (paneles laterales + viewport central) — _Ejecutar → 3 zonas visibles_
- [x] 2.2 Toolbar superior: botones placeholder (Zoom+, Zoom-, Ajustar, Grid toggle, Medir, Efectos) — _Botones visibles, prints en consola al click_
- [x] 2.3 Panel izquierdo "Mapas": `VBoxContainer` con título, botón "+ Añadir mapa", `ItemList` vacío — _Panel visible, botón "+" presente_
- [x] 2.4 Panel derecho "Propiedades": `VBoxContainer` con título, label "Selecciona un token" placeholder — _Panel visible, texto placeholder_
- [x] 2.5 Panel derecho "Iniciativa" (pestaña inferior): botón "Añadir a iniciativa", tabla vacía — _Pestaña visible, tabla vacía_
- [x] 2.6 Barra de estado inferior: zoom%, coordenadas cursor, FPS — _Labels visibles con "100%", "(0, 0)", "60"_
- [x] 2.7 Atajo de teclado: `Ctrl+O` → Abrir sesión, `Ctrl+S` → Guardar, `Ctrl+N` → Nueva sesión — _Prints en consola al pulsar atajos_

## Fase 3: Renderizado de mapa

- [x] 3.1 `MapData` Resource: `image_path`, `name`, `width`, `height` — _Crear recurso en inspector_
- [x] 3.2 `MapRenderer` (`SubViewport` + `Sprite2D`): carga imagen desde `image_path` y la muestra — _Cargar PNG 4000×3000 → visible (MAP-01)_
- [x] 3.3 Imagen escalada para ajustar al ancho del viewport si es más grande — _Mapa 4000 px cabe en viewport 1920 (MAP-01)_
- [x] 3.4 Imagen pequeña se muestra a tamaño real, centrada, sin escalar al alza — _BMP 200×200 → centrado, tamaño real (MAP-03)_
- [x] 3.5 Archivo corrupto o no soportado → diálogo de error — _JPG corrupto → error, no crashea (MAP-02)_
- [x] 3.6 Botón "+ Añadir mapa" en panel izquierdo → `FileDialog` → cargar imagen — _Mapa aparece en viewport y en lista lateral_
- [x] 3.7 `ItemList` de mapas muestra nombre del mapa; click → activa ese mapa — _Click en "Mazmorra" → se muestra en viewport (MAP-15)_
- [x] 3.8 Renombrar mapa con doble click en `ItemList` — _Doble click → editable, nombre se actualiza (MAP-16)_
- [x] 3.9 Reordenar mapas arrastrando en `ItemList` — _Arrastrar tercer mapa al primero → orden cambia (MAP-17)_
- [x] 3.10 Click derecho > "Eliminar mapa de la sesión" — _Mapa fuera de lista, archivo en disco intacto (MAP-18)_
- [x] 3.11 Click derecho > "Duplicar mapa" — _Copia en lista con "(copia)", independiente (MAP-19)_
- [x] 3.12 `GameState.current_map` actualizado al cambiar de mapa activo — _Print `GameState.current_map.name` → confirma cambio_

## Fase 4: Zoom y paneo

- [x] 4.1 Zoom con rueda del ratón sobre el viewport (centrado en cursor) — _Rueda arriba → acerca; rueda abajo → aleja_
- [x] 4.2 Límite zoom 400%: rueda arriba bloqueada al llegar — _Zoom+ se desactiva al llegar a 400% (MAP-04)_
- [x] 4.3 Límite zoom 10%: rueda abajo bloqueada al llegar — _Zoom- se desactiva al llegar a 10% (MAP-05)_
- [x] 4.4 Botones Zoom+ / Zoom- en toolbar (step 25%) — _Click → zoom cambia en saltos de 25%_
- [x] 4.5 Paneo con click medio + arrastre — _Click medio + mover → mapa se desplaza_
- [x] 4.6 Paneo con flechas de teclado — _Flechas → desplazamiento suave_
- [x] 4.7 Paneo se detiene en bordes del mapa — _Llegar a borde → no muestra fondo vacío (MAP-07)_
- [x] 4.8 Botón "Ajustar mapa": escala para caber entero en viewport — _Zoom 300% + ajustar → mapa completo visible (MAP-08)_
- [x] 4.9 Zoom% en barra de estado se actualiza — _Mover rueda → label "%" cambia en tiempo real_
- [x] 4.10 Coordenadas del cursor en barra de estado — _Mover ratón → label "(X, Y)" se actualiza_

## Fase 5: Cuadrícula

- [x] 5.1 `GridData` Resource: `size_px`, `origin` (Vector2), `color`, `opacity`, `line_width`, `visible`, `show_coords`, `rotation_degrees` — _Crear recurso, campos editables_
- [x] 5.2 `GridRenderer` (nodo `Node2D`): dibuja líneas con `draw_line()` según `GridData` — _Activar → grid visible sobre mapa (GRD-01)_
- [x] 5.3 Botón toggle Grid en toolbar → `GridData.visible = !visible` — _Click → grid aparece/desaparece_
- [x] 5.4 Grid escala con el zoom del mapa — _Zoom 200% → celdas también al 200% (GRD-04)_
- [x] 5.5 Panel de ajustes del grid: slider tamaño celda (10-500 px) — _Mover slider → celdas redimensionan (GRD-02)_
- [x] 5.6 Panel de ajustes: color picker — _Elegir rojo → líneas rojas (GRD-03)_
- [x] 5.7 Panel de ajustes: slider opacidad línea (10-100%) — _Mover slider → líneas más/menos opacas_
- [x] 5.8 Panel de ajustes: slider grosor línea (1-5 px) — _Mover slider → líneas más/menos gruesas_
- [ ] 5.9 Arrastrar para desplazar origen del grid — _Arrastrar → grid se desplaza (GRD-07)_
- [x] 5.10 Controles de ajuste fino (+1, -1, +10, -10 px) para tamaño — _Click +1 → celda crece 1 px_
- [x] 5.11 Coordenadas de celda (A1, B2...) toggle on/off — _Activar → etiquetas en esquinas de celdas visibles_
- [ ] 5.12 `GameState.cell_size_ft` configurable (default 30) — _Cambiar a 1.5 m → `GameState` refleja el cambio_
- [x] 5.13 Controles de offset X/Y (-10, -1, +1, +10 px) — _Desplazar origen para compensar bordes del mapa (GRD-12)_
- [x] 5.14 Controles de rotación (-1°, -0.1°, +0.1°, +1°) con rango ±5° — _Rotar cuadrícula para mapas torcidos (GRD-13)_

## Fase 6: Tokens — importación y visualización

- [x] 6.1 `TokenData` Resource: `name`, `image_path`, `size_cells`, `border_color`, `visible_to_players`, `vision_radius`, `speed_ft`, `conditions[]` — _Crear recurso, campos editables_
- [x] 6.2 Panel "Tokens en mapa": `ItemList` vacío — _Panel visible junto a lista de mapas_
- [x] 6.3 Botón "Importar token" → `FileDialog` (PNG, JPG, WebP) → `TokenData` creado — _PNG con transparencia → token en lista (TOK-01)_
- [x] 6.4 `TokenSprite` (`Sprite2D`): muestra imagen del token en posición del mapa — _Token visible sobre el mapa_
- [x] 6.5 Tamaño del sprite según `size_cells` × `cell_size_px` — _2×2 → sprite ocupa 2 celdas (TOK-03)_
- [x] 6.6 Auto-recorte al bounding box no transparente — _PNG con márgenes → recortado al contenido (TOK-01)_
- [x] 6.7 Aviso si imagen no tiene transparencia — _JPG → aviso, fondo blanco (TOK-02)_
- [ ] 6.8 Drag & drop de PNG desde explorador al viewport — _Soltar PNG → token creado (MAP-10)_
- [ ] 6.9 Biblioteca de tokens: `ItemList` con thumbnails cacheados — _30 tokens en carpeta → miniaturas visibles (TOK-05)_
- [ ] 6.10 Drag desde biblioteca de tokens al viewport — _Token instanciado en la posición del drop_

## Fase 7: Tokens — interacción y propiedades

- [x] 7.1 Click en token → seleccionar (borde resaltado) — _Click → borde amarillo en _draw()_
- [x] 7.2 Doble click en lista → centrar vista en token — _Doble click → vista centrada_
- [x] 7.3 Panel propiedades: editar nombre — _Escribir "Goblin 1" → nombre del token se actualiza_
- [x] 7.4 Panel propiedades: cambiar tamaño en casillas (SpinBox 0.5-10) — _Seleccionar 3×3 → sprite ocupa 3 celdas_
- [x] 7.5 Panel propiedades: color de borde — _Elegir azul → aro azul (TOK-12)_
- [x] 7.6 Panel propiedades: toggle visibilidad para jugadores — _"Oculto" → visible_to_players = false (TOK-04)_
- [x] 7.7 Panel propiedades: radio de visión (slider 0-30 casillas) — _Cambiar a 6 → `vision_radius` = 6_
- [x] 7.8 Panel propiedades: velocidad base (SpinBox 0-120 pies) — _Cambiar a 30 → `speed_ft` = 30_
- [ ] 7.9 Panel propiedades: añadir/eliminar condiciones (checkboxes: envenenado, paralizado, concentración...) — _Marcar "Envenenado" → icono en esquina (TOK-11)_
- [x] 7.10 Tecla Supr → eliminar token seleccionado del mapa y lista — _Supr → token desaparece (TOK-09)_
- [x] 7.11 Click derecho > "Duplicar" — _Copia idéntica desplazada 1 celda (TOK-10)_
- [ ] 7.12 Selección múltiple con Ctrl+Click — _3 tokens con borde de selección (TOK-06)_
- [ ] 7.13 Selección múltiple con arrastre de marco — _Arrastrar rectángulo → tokens dentro seleccionados_
- [ ] 7.14 Apilamiento: 4 tokens misma celda → abanico + indicador "4" — _4 tokens solapados → desplazados + contador (TOK-07)_
- [x] 7.15 Nombre largo → draw_string con nombre bajo token — _Nombre visible bajo el sprite_

## Fase 8: Movimiento de tokens y distancias

- [ ] 8.1 Arrastrar token con ratón → sigue al cursor — _Token se mueve en tiempo real con el cursor_
- [ ] 8.2 Línea fantasma origen → posición actual durante arrastre — _Línea discontinua visible_
- [ ] 8.3 Snap al centro de celda al soltar — _Soltar → token centrado en celda (MOV-03)_
- [ ] 8.4 Shift + soltar → sin snap (posición exacta) — _Shift+soltar → token en posición libre (MOV-05)_
- [ ] 8.5 Etiqueta de distancia durante arrastre: "X pies (Y casillas)" — _3 celdas → "90 pies (3 casillas)" (MOV-01)_
- [ ] 8.6 Distancia diagonal: regla 5e (1ª=1, 2ª=2 celdas totales) configurable — _3 diags → conteo correcto (MOV-02 / MOV-12)_
- [ ] 8.7 Movimiento con flechas (1 celda por pulsación) — _Flecha derecha → +1 celda (MOV-04)_
- [ ] 8.8 Rastro de movimiento: línea punteada 2 segundos tras soltar — _Soltar → línea fades en 2s (MOV-10)_
- [ ] 8.9 Límite de velocidad: celdas más allá de `speed_ft` en rojo durante arrastre — _Token speed 60', arrastrar 3 celdas → 3ª en rojo (MOV-06)_
- [ ] 8.10 Movimiento de grupo: arrastrar selección múltiple → formación preservada — _5 tokens juntos → se mueven como grupo (MOV-07)_
- [ ] 8.11 Ctrl + hover sobre celda → distancia desde token seleccionado — _Hover a 5 celdas → "150 pies (5 casillas)" (MOV-09)_
- [ ] 8.12 Cambiar unidades a metros → etiquetas en metros — _2 celdas → "3.0 m (2 casillas)" (MOV-11)_

## Fase 9: Doble ventana DM / Jugadores

- [ ] 9.1 `PlayerWindow` escena: solo viewport, sin toolbars ni paneles — _Abrir → ventana limpia con mapa (WIN-01)_
- [ ] 9.2 Detectar monitores disponibles al iniciar — _2 monitores → lista en ajustes (WIN-07)_
- [ ] 9.3 Configurar monitor de jugadores en ajustes — _Seleccionar monitor 2 → recordado entre sesiones_
- [ ] 9.4 Abrir ventana jugadores en monitor configurado (o menú > "Abrir ventana jugadores") — _Ventana en monitor correcto (WIN-07)_
- [ ] 9.5 Cerrar y reabrir ventana jugadores sin perder estado — _Reabrir → mismo mapa, tokens, niebla (WIN-08)_
- [ ] 9.6 Sincronización de tokens (mover en DM → se mueve en Player) — _Arrastrar token DM → se actualiza Player (WIN-02)_
- [ ] 9.7 Sincronización de visibilidad (ocultar en DM → desaparece en Player) — _Toggle visibilidad → Player refleja cambio (WIN-03)_
- [ ] 9.8 Modo sincronizado: zoom/pan del DM replica en Player — _Zoom 150% DM → Player zoom 150% (WIN-04)_
- [ ] 9.9 Modo independiente: zoom/pan del Player no afecta al DM — _Pan táctil → DM quieto (WIN-05)_
- [ ] 9.10 Selector de modo en toolbar DM: Sincronizado / Independiente / Seguir turno — _Dropdown funcional_
- [ ] 9.11 Modo "Seguir turno": avanzar turno → cámara Player centra token activo — _Siguiente turno → cámara se centra (WIN-06)_

## Fase 10: Indicador de vista de jugadores

- [ ] 10.1 Rectángulo discontinuo en viewport DM mostrando área visible del Player — _Rectángulo azul dibujado (WIN-12)_
- [ ] 10.2 Color del indicador configurable (default cian) — _Cambiar a naranja → rectángulo naranja (WIN-15)_
- [ ] 10.3 Indicador se actualiza en tiempo real al hacer pan/zoom el Player — _Player zoom → rectángulo crece/decrece (WIN-18)_
- [ ] 10.4 Vista Player fuera del viewport DM → flecha en borde + distancia — _Flecha "← 1200 px" (WIN-16)_
- [ ] 10.5 Vista Player parcialmente solapada → rectángulo parcial + flecha — _Porción visible + indicador de dirección (WIN-17)_
- [ ] 10.6 Modo sincronizado → sin indicador (redundante) — _Sincronizado → no se dibuja rectángulo (WIN-14)_
- [ ] 10.7 Redimensionar ventana Player → indicador se ajusta — _Cambiar tamaño Player → rectángulo actualizado (WIN-11)_
- [ ] 10.8 Touch en Player: arrastrar token (si DM lo permite) — _Arrastre táctil → token se mueve en DM también (WIN-10)_
- [ ] 10.9 Touch en Player desactivado → no se mueven tokens — _Tocar token → sin respuesta (WIN-09)_

## Fase 11: Niebla de guerra

- [ ] 11.1 Capa de niebla: `ColorRect` negro semitransparente sobre el mapa (solo en ventana Player) — _Activar → Player completamente negro (FOG-01)_
- [ ] 11.2 Revelar en círculo alrededor de token (radio = `vision_radius` casillas) — _Token visión 6 → círculo visible (FOG-02)_
- [ ] 11.3 Zona no explorada (negro) vs zona explorada sin token (gris oscuro) vs visible (transparente) — _Tres niveles de opacidad diferenciados_
- [ ] 11.4 Zona revelada permanece visible aunque el token se aleje (gris oscuro) — _Alejar token → zona queda en gris (FOG-04)_
- [ ] 11.5 Múltiples tokens combinan visión (unión de áreas visibles) — _2 tokens separados 8 celdas → 2 círculos (FOG-05)_
- [ ] 11.6 Capa de bloqueadores de visión (solo visible para DM, líneas rojas) — _Dibujar paredes con herramienta → líneas rojas en DM_
- [ ] 11.7 Raycasting desde token: bloquear visión tras paredes — _Token + pared a 3 celdas → zona tras pared oculta (FOG-03)_
- [ ] 11.8 Activar/desactivar bloqueador individual (puerta) — _Desactivar → zona antes bloqueada ahora visible (FOG-06)_
- [ ] 11.9 Herramienta "revelar zona" (brocha circular, tamaño configurable) — _Brocha radio 3 → círculo revelado permanentemente (FOG-07)_
- [ ] 11.10 Modo "sin niebla" → todo visible; exploración previa preservada — _Desactivar → mapa completo visible (FOG-08)_
- [ ] 11.11 Tokens enemigos no revelan niebla (solo aliados/visión configurable) — _Enemigo sin aliado → zona oscura (FOG-09)_
- [ ] 11.12 Movimiento de token revela niebla progresivamente — _Mover 10 celdas → 10 nuevas celdas visibles (FOG-10)_
- [ ] 11.13 Niebla se guarda/carga con la sesión — _Guardar + cargar → mismas celdas reveladas (FOG-12)_

## Fase 12: Herramientas de medición

- [ ] 12.1 Botón "Medir" en toolbar (toggle) — _Click → modo medición activo, cursor cambia_
- [ ] 12.2 Click punto A, click punto B → línea recta + etiqueta "X pies (Y casillas)" — _3 celdas → "90 pies (3 casillas)" (MED-01)_
- [ ] 12.3 Waypoints: clicks adicionales añaden puntos intermedios, distancia acumulada — _3 puntos → línea quebrada + total (MED-02)_
- [ ] 12.4 Snap a grid activo (puntos caen en centros de celda) — _Puntos alineados a grid_
- [ ] 12.5 Shift → sin snap, posición libre del cursor — _Shift+click → punto en posición exacta (MED-07)_
- [ ] 12.6 Escape → cancela medición actual — _Escape → línea desaparece (MED-08)_
- [ ] 12.7 Plantilla círculo: elegir radio, colocar con click — _Radio 4 → círculo relleno (MED-03)_
- [ ] 12.8 Plantilla cono: elegir longitud, colocar origen, arrastrar para rotar — _Cono 6, rotar 45° (MED-04)_
- [ ] 12.9 Plantilla cuadrado: elegir lado en casillas, colocar — _3×3 → cuadrado relleno (MED-05)_
- [ ] 12.10 Plantilla línea: elegir longitud y ancho — _Línea recta con grosor_
- [ ] 12.11 Apilar múltiples plantillas — _Círculo + cono → ambos visibles (MED-06)_
- [ ] 12.12 Personalizar plantilla: color relleno, opacidad, borde — _Azul 40% → plantilla azul (MED-11)_
- [ ] 12.13 Plantilla temporal (desaparece al cambiar herramienta) / persistente — _Sin/con check "persistente" (MED-09 / MED-10)_
- [ ] 12.14 Click derecho sobre plantilla → "Eliminar" — _Plantilla eliminada, otras intactas (MED-12)_
- [ ] 12.15 Unidades en metros → etiquetas de plantilla en metros — _Radio 3 → "4.5 m (3 casillas)" (MED-13)_

## Fase 13: Efectos visuales

- [ ] 13.1 `GPUParticles2D` base: sistema de partículas fuego — _Colocar → llamas y chispas (EFX-01)_
- [ ] 13.2 Efecto humo/niebla — _Partículas grises flotantes_
- [ ] 13.3 Efecto magia (destellos) — _Chispas brillantes de colores_
- [ ] 13.4 Efecto veneno (burbujas verdes) — _Burbujas verdes + gas_
- [ ] 13.5 Efectos ambientales: lluvia, nieve — _Partículas cayendo en toda la pantalla_
- [ ] 13.6 Parámetros: intensidad, radio de emisión, duración, color — _Intensidad 200% → doble de partículas (EFX-10)_
- [ ] 13.7 Temporizador: efecto se autodestruye tras duración — _Partículas se detienen y desaparecen_
- [ ] 13.8 `PointLight2D`: luz puntual (antorcha) — _Luz amarilla radial (EFX-02)_
- [ ] 13.9 Luz direccional — _Haz de luz en una dirección_
- [ ] 13.10 Luz ambiental global (afecta toda la escena visible) — _Color ambiente cambia escena_
- [ ] 13.11 Luz solo visible en zonas reveladas por niebla de guerra — _Luz en zona oscura → no visible hasta revelar (EFX-03)_
- [ ] 13.12 Efectos ambientales globales: tinte de color, niebla, viñeta — _Niebla 30%, tinte azul (EFX-04 / EFX-11)_
- [ ] 13.13 Animaciones cortas: explosión, rayo, curación, golpe — _Explosión → expansión + fade en 1s (EFX-12)_
- [ ] 13.14 Panel gestor de efectos: lista, pausar/reanudar, eliminar, duplicar — _Acciones funcionan (EFX-06/07/08/13)_
- [ ] 13.15 10 efectos simultáneos → rendimiento estable — _FPS no baja de 30 (EFX-09)_

## Fase 14: Iniciativa

- [ ] 14.1 Panel de iniciativa: tabla (orden, nombre, iniciativa, HP, CA, estado, visible) — _3 tokens añadidos → 3 filas (INI-01)_
- [ ] 14.2 Click derecho en token → "Añadir a iniciativa" — _Token aparece en tabla con stats_
- [ ] 14.3 Añadir participante manual (sin token): nombre, iniciativa, HP, CA — _"Orco", INI 12, HP 45 → nueva fila (INI-02)_
- [ ] 14.4 Ordenar por iniciativa descendente — _Valores 12, 18, 5 → orden 18, 12, 5_
- [ ] 14.5 Botón "Siguiente turno" → avanza turno activo — _Resalte se mueve al siguiente (INI-03)_
- [ ] 14.6 Último turno + "Siguiente" → vuelve al primero (ciclo) — _Ciclo completo (INI-04)_
- [ ] 14.7 HP editable directamente en tabla — _Doble click + escribir → HP actualizado_
- [ ] 14.8 Botones daño rápido: -1, -5, -10 — _-10 en HP 15 → HP = 5 (INI-06)_
- [ ] 14.9 Botones curación: +1, +5, +10 — _+5 en HP 10 → HP = 15_
- [ ] 14.10 HP = 0 → token tinte rojo + icono calavera — _HP 0 → calavera visible (INI-05)_
- [ ] 14.11 Click en fila de iniciativa → cámara centra token vinculado — _Click → cámara se mueve al token (INI-07)_
- [ ] 14.12 Columna "Visible" con toggle para mostrar/ocultar en Player — _Ocultar → desaparece de Player (INI-08)_
- [ ] 14.13 Botón "Revelar todos" / "Ocultar todos" — _5 ocultos → todos visibles (INI-09)_
- [ ] 14.14 Eliminar token del mapa que está en iniciativa → diálogo confirmación — _"¿Eliminar también de iniciativa?" (INI-10)_
- [ ] 14.15 Arrastrar fila para reordenar (ignorar valor INI) — _Arrastrar → orden manual (INI-11)_
- [ ] 14.16 Tirar iniciativa automática (d20 + mod) — _Click "Tirar" → valor 3-22 generado (INI-12)_
- [ ] 14.17 Misma iniciativa → aviso al DM — _Dos 15 → notificación (INI-14)_
- [ ] 14.18 15 participantes → scroll fluido — _15 filas sin lag (INI-13)_
- [ ] 14.19 Iniciativa global vs por mapa (config en ajustes de sesión) — _Cambiar mapa → iniciativa se mantiene o se reinicia según setting_

## Fase 15: Persistencia de sesión

- [ ] 15.1 Serializar `GameState` a JSON (mapas, grids, tokens, posiciones) — _Archivo `.bmap` generado_
- [ ] 15.2 Guardar sesión (`Ctrl+S`): sin nombre → diálogo "Guardar como" — _Diálogo, usuario elige ruta (SAV-01)_
- [ ] 15.3 Guardar sesión ya nombrada (`Ctrl+S`): sobrescribe sin diálogo — _Archivo actualizado silenciosamente (SAV-02)_
- [ ] 15.4 Deserializar `GameState` desde JSON — _Cargar → niebla, tokens, grid restaurados (SAV-12)_
- [ ] 15.5 Cargar sesión con imagen de mapa no encontrada → placeholder + alerta — _Alerta, rectángulo gris en lugar de mapa (SAV-03)_
- [ ] 15.6 Cargar sesión con token PNG no encontrado → alerta + placeholder — _Alerta, icono "?" en lugar de token (SAV-04)_
- [ ] 15.7 Cerrar sesión con cambios sin guardar → diálogo confirmación — _"¿Guardar cambios?" (SAV-05)_
- [ ] 15.8 Autoguardado cada 5 minutos en `user://autosave/` — _Archivo con timestamp creado (SAV-09)_
- [ ] 15.9 Mantener últimos 5 autoguardados, borrar más antiguos — _Carpeta autosave nunca tiene más de 5 archivos_
- [ ] 15.10 Recuperar autoguardado al abrir app tras cierre forzoso — _Banner + opción recuperar (SAV-10)_
- [ ] 15.11 Exportar sesión: ZIP con `.bmap` + assets/ con todas las imágenes — _ZIP válido con todas las imágenes (SAV-06)_
- [ ] 15.12 Importar ZIP: extraer assets a `library/imported/<nombre>/`, cargar sesión — _Sesión cargada, assets en library (SAV-07)_
- [ ] 15.13 Importar con conflicto de nombres → diálogo (sobrescribir/renombrar/saltar) — _Diálogo de opciones (SAV-08)_
- [ ] 15.14 Cargar `.bmap` corrupto → error graceful — _"Archivo no válido", no crashea (SAV-11)_
- [ ] 15.15 Iniciativa activa guardada y restaurada (turno actual incluido) — _Guardar en turno 3 → cargar sigue en turno 3 (SAV-13)_

## Fase 16: Biblioteca de assets

- [ ] 16.1 Panel biblioteca de mapas: explorador de `library/maps/` con carpetas — _50 mapas, 3 carpetas → scroll fluido (MAP-09)_
- [ ] 16.2 Generar thumbnails en `library/.cache/` (solo si no existen) — _Thumbnails cacheados, no regenerados_
- [ ] 16.3 Drag & drop de mapa desde biblioteca a sesión — _Mapa añadido a la sesión_
- [ ] 16.4 Crear/renombrar/eliminar carpetas en biblioteca — _Click derecho → opciones contextuales_
- [ ] 16.5 Panel biblioteca de tokens: igual estructura en `library/tokens/` — _Funcionalidad simétrica a mapas_
- [ ] 16.6 Drag & drop de token desde biblioteca al viewport — _Token instanciado en la posición del drop_
- [ ] 16.7 Importar assets desde el launcher/ajustes (copiar imágenes a library) — _Archivo copiado a `library/`, no referenciado externamente_

## Fase 17: Comando, EventBus y preparación red

- [ ] 17.1 `Command` clase base: `execute()`, `undo()`, `serialize()`, `deserialize()` — _Clase funcional, métodos abstractos_
- [ ] 17.2 `MoveTokenCommand`: implementa `execute` y `undo` — _Mover token → comando emitido y ejecutado (MOD-01)_
- [ ] 17.3 `CommandProcessor`: pila de comandos, `do()`, `undo()`, `redo()` — _Comandos apilados correctamente_
- [ ] 17.4 Ctrl+Z → deshacer último comando — _Mover token + Ctrl+Z → token vuelve (MOD-02)_
- [ ] 17.5 Ctrl+Y → rehacer comando deshecho — _Ctrl+Y → token vuelve a posición nueva (MOD-03)_
- [ ] 17.6 Comandos para todas las acciones modificadoras de estado — _Cada acción del DM genera un comando_
- [ ] 17.7 `EventBus` emite señales en cada cambio de estado — _`token_moved` → Player recibe y actualiza (MOD-05)_
- [ ] 17.8 UI solo lee de `GameState`; cambios solo vía `CommandProcessor` — _Intentar modificar GameState directo → rechazado (MOD-07)_
- [ ] 17.9 Serializar/deserializar comandos a JSON — _Comando serializado → reconstruido idéntico (MOD-09)_
- [ ] 17.10 Pila de 100 comandos → sin degradación — _100 deshacer → memoria y velocidad estables (MOD-06)_
- [ ] 17.11 Prevenir múltiples ventanas DM — _Segunda ventana DM → rechazada (MOD-10)_

## Fase 18: Capas de mapa y ajustes finales

- [ ] 18.1 Añadir capa extra sobre mapa base — _Capa con opacidad 50% → ambas visibles (MAP-11)_
- [ ] 18.2 Eliminar capa extra — _Solo mapa base, sin artefactos (MAP-12)_
- [ ] 18.3 Cambiar mapa con sesión abierta → confirmación si cambios — _Diálogo de advertencia (MAP-13)_
- [ ] 18.4 Cambiar de mapa durante combate (iniciativa global) — _Turno mantenido, tokens del nuevo mapa activos (MAP-21)_
- [ ] 18.5 Pellizco táctil para zoom — _Pellizco → zoom en centro del gesto (MAP-06)_
- [ ] 18.6 Rendimiento: mapa 10000×8000 px, grid 20 px — _Sin degradación (GRD-11)_
- [ ] 18.7 Rendimiento: 20 tokens, 10 efectos, niebla activa — _FPS estable (FOG-11)_
- [ ] 18.8 Tema oscuro/claro desde ajustes — _Cambiar tema → UI se actualiza (LCH-15)_

---

**Totales: 18 fases, ~150 pasos verificables.**
