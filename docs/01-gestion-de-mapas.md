# 01 — Gestión de Mapas

## Descripción

Módulo encargado de cargar, visualizar y gestionar imágenes de mapas. Soporta
carga directa de archivos y una biblioteca interna organizada por campañas.

Una sesión puede contener **múltiples mapas** (ej. taberna, camino, mazmorra,
sala del jefe). El DM alterna entre ellos desde un selector lateral y el cambio
se refleja instantáneamente en la ventana de jugadores.

## Funcionalidades

### 1.1 Carga de mapa desde archivo

El usuario selecciona un archivo de imagen (PNG, JPG, WebP, BMP) mediante un
diálogo de sistema. La imagen se carga como textura y se muestra centrada en el
viewport.

**Reglas**:
- Si el mapa es más grande que el viewport, se escala para ajustar al ancho.
- El zoom mínimo no puede reducir el mapa por debajo del 10% de su tamaño real.
- El zoom máximo no puede exceder el 400%.

### 1.2 Biblioteca de mapas

La aplicación mantiene una carpeta `library/maps/` donde el usuario puede
organizar mapas en subcarpetas (por campaña, categoría, etc.).

**Reglas**:
- El panel de biblioteca muestra miniaturas (thumbnails) generadas automáticamente.
- Las miniaturas se cachean en `library/.cache/` para evitar regeneración.
- El usuario puede crear, renombrar y eliminar carpetas.
- Se acepta drag & drop desde el explorador de archivos del sistema.

### 1.3 Zoom y paneo

**Zoom**:
- Rueda del ratón centrado en la posición del cursor.
- Pellizco táctil (pinch) con dos dedos.
- Botones de zoom +/- en la toolbar.

**Paneo**:
- Click medio + arrastre con ratón.
- Flechas de teclado (desplazamiento suave).
- Dos dedos táctiles (arrastre).
- Al llegar al borde del mapa, el paneo se detiene (no hay scroll infinito).

### 1.4 Ajuste de mapa al viewport

Botón "Ajustar mapa" que escala el mapa para que sea completamente visible
dentro del viewport actual, centrándolo.

### 1.5 Capas del mapa

El mapa base es una capa. El usuario puede añadir capas adicionales superpuestas
(otro mapa, una textura de suelo diferenciada, etc.) con opacidad configurable.

### 1.6 Gestión de mapas dentro de la sesión

Cada sesión puede contener varios mapas. El panel lateral "Mapas" lista todos
los mapas de la sesión con su nombre y miniatura.

**Acciones sobre mapas en la sesión**:
- **Añadir mapa**: Desde la biblioteca o desde archivo.
- **Activar mapa**: Click en el mapa de la lista. El mapa activo se muestra en
  el viewport del DM y en la ventana de jugadores.
- **Renombrar mapa**: Doble click sobre el nombre.
- **Reordenar**: Arrastrar mapas en la lista para cambiar el orden.
- **Eliminar mapa**: Click derecho > "Eliminar mapa de la sesión". El archivo
  original no se borra del disco.
- **Duplicar mapa**: Click derecho > "Duplicar". Crea una copia independiente
  con sus propios tokens, grid y niebla.

**Reglas**:
- Cada mapa mantiene su propio grid, tokens, niebla de guerra y efectos.
- La iniciativa puede ser global a la sesión o independiente por mapa
  (configurable en ajustes de sesión).
- El cambio de mapa activo es instantáneo: los jugadores ven el nuevo mapa con
  su niebla correspondiente.
- Solo hay un mapa activo a la vez.

---

## Casos de uso y ejemplos para test

| ID    | Caso                                              | Resultado esperado                                      |
|-------|---------------------------------------------------|---------------------------------------------------------|
| MAP-01| Cargar PNG de 4000×3000 px con viewport 1920×1080 | Mapa se escala a ancho 1920, manteniendo ratio          |
| MAP-02| Cargar JPG corrupto o no válido                   | Diálogo de error: "Formato de imagen no soportado"      |
| MAP-03| Cargar BMP de 200×200 px con viewport 1920×1080   | Se muestra a tamaño real, centrado, sin escalar al alza |
| MAP-04| Zoom con rueda hasta 400%                         | No se permite superar 400%. El botón de zoom+ se desactiva|
| MAP-05| Zoom con rueda hasta 10%                          | No se permite bajar de 10%. El botón de zoom- se desactiva|
| MAP-06| Pellizco táctil de zoom                           | El zoom sigue el centro del gesto                       |
| MAP-07| Paneo con flechas hasta borde derecho del mapa    | El mapa se detiene en el borde, no muestra fondo vacío   |
| MAP-08| Ajustar mapa al viewport tras zoom 300%           | El mapa se reescala para caber entero en pantalla       |
| MAP-09| Biblioteca con 50 mapas en 3 carpetas             | Los thumbnails se generan bajo demanda; scroll fluido    |
| MAP-10| Drag & drop de PNG desde explorador               | El mapa se carga y se añade a la biblioteca             |
| MAP-11| Añadir capa extra con opacidad 50%                | Ambas capas visibles, la superior semitransparente      |
| MAP-12| Eliminar capa extra                               | Solo queda el mapa base, sin artefactos visuales        |
| MAP-13| Cambiar de mapa con sesión abierta                | Se solicita confirmación si hay cambios sin guardar     |
| MAP-14| Añadir 3 mapas a una sesión                       | Los 3 aparecen en el panel lateral con miniaturas       |
| MAP-15| Activar mapa "Mazmorra" desde el panel            | Viewport cambia al nuevo mapa; jugadores lo ven también |
| MAP-16| Renombrar mapa con doble click                    | El nombre se vuelve editable y se actualiza en la lista |
| MAP-17| Reordenar mapas arrastrando en el panel           | El orden se actualiza; el mapa activo no cambia         |
| MAP-18| Eliminar mapa de la sesión                        | Mapa desaparece del panel; archivo original intacto     |
| MAP-19| Duplicar mapa "Taberna" → "Taberna (copia)"       | Nuevo mapa con mismo grid y tokens, independiente       |
| MAP-20| Cambiar de mapa mientras jugadores miran otra zona| Ventana jugadores carga el nuevo mapa con su niebla     |
| MAP-21| Iniciativa global: cambiar mapa durante combate   | El orden de turno se mantiene; tokens del nuevo mapa activos|
