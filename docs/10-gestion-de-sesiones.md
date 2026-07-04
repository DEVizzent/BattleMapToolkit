# 10 — Gestión de Sesiones

## Descripción

Sistema para guardar, cargar, exportar e importar el estado completo de una
sesión de juego. Una sesión actúa como contenedor de uno o varios mapas, cada uno
con su propio grid, tokens, niebla y efectos.

## Funcionalidades

### 10.1 Estado de sesión

Una sesión comprende:

| Componente            | Datos guardados                                        |
|-----------------------|--------------------------------------------------------|
| Mapas                 | Lista de mapas con su orden. Cada mapa contiene:       |
|   └─ Imagen           | Ruta al archivo, capas adicionales, opacidad           |
|   └─ Cuadrícula       | Tamaño, color, opacidad, origen                        |
|   └─ Tokens           | Posición, tamaño, nombre, visibilidad, stats, condiciones|
|   └─ Niebla de guerra | Matriz de celdas reveladas                             |
|   └─ Bloqueadores     | Posiciones y estados de todas las paredes              |
|   └─ Efectos visuales | Tipo, posición, parámetros de cada efecto activo       |
|   └─ Plantillas       | Tipo, posición, rotación, personalización              |
| Iniciativa            | Lista de participantes, HP, turno actual (global o por mapa)|
| Vista DM              | Mapa activo, zoom, posición del viewport               |
| Vista jugadores       | Zoom, posición del viewport                            |
| Unidades              | Pies o metros, equivalencia por celda                  |

### 10.2 Guardar sesión

**Acción**: Ctrl+S o menú Archivo > Guardar.

**Formato**: Archivo `.bmap` (JSON estructurado o binario Godot `Resource`).

**Reglas**:
- Si la sesión no tiene nombre, se solicita ubicación (Save As).
- Las imágenes de mapas y tokens NO se incrustan; se guardan referencias relativas.
- Si una referencia no se encuentra al cargar, se alerta y se muestra un placeholder.

### 10.3 Cargar sesión

**Acción**: Ctrl+O o menú Archivo > Abrir.

**Reglas**:
- Se restaura el estado completo.
- Si hay una sesión abierta con cambios sin guardar, se solicita confirmación.
- Las imágenes referenciadas se buscan en ruta absoluta y, si falla, en `library/`.

### 10.4 Exportar sesión

**Acción**: Archivo > Exportar.

**Formato**: Carpeta ZIP que incluye:
- Archivo `.bmap` con el estado.
- Carpeta `assets/` con copias de todas las imágenes usadas.
- Las referencias se ajustan a rutas relativas dentro del ZIP.

**Uso**: Compartir la sesión con otro DM o trasladarla a otro equipo.

### 10.5 Importar sesión

**Acción**: Archivo > Importar.

**Proceso**:
1. Seleccionar archivo `.bmap` o `.zip`.
2. Si es ZIP, extraer assets a `library/imported/<nombre_sesion>/`.
3. Cargar el estado.
4. Si hay conflictos de nombres, preguntar (sobrescribir / renombrar / saltar).

### 10.6 Autoguardado

**Reglas**:
- Autoguardado cada 5 minutos (configurable).
- Se guarda en `sessions/.autosave/` con timestamp.
- Se mantienen los últimos 5 autoguardados.
- Al iniciar la app tras un cierre inesperado, se ofrece recuperar el autoguardado.

---

## Casos de uso y ejemplos para test

| ID    | Caso                                              | Resultado esperado                                      |
|-------|---------------------------------------------------|---------------------------------------------------------|
| SAV-01| Guardar sesión nueva con Ctrl+S                   | Se abre diálogo "Guardar como", se crea archivo .bmap   |
| SAV-02| Guardar sesión ya nombrada con Ctrl+S             | Se sobrescribe sin diálogo                              |
| SAV-03| Cargar sesión con mapa cuyo archivo no existe     | Alerta: "Mapa no encontrado en <ruta>", placeholder gris |
| SAV-04| Cargar sesión con token PNG no encontrado         | Alerta con opción de buscar manualmente o usar placeholder|
| SAV-05| Cerrar sesión con cambios sin guardar              | Diálogo: "¿Guardar cambios antes de cerrar?"            |
| SAV-06| Exportar sesión con 2 mapas y 10 tokens            | ZIP contiene .bmap + assets/ con todas las imágenes     |
| SAV-07| Importar sesión exportada en otro PC               | Sesión se restaura completamente, assets en library/     |
| SAV-08| Importar sesión con conflicto de nombres           | Diálogo con opciones: sobrescribir, renombrar, saltar   |
| SAV-09| Autoguardado cada 5 minutos                       | Archivo en .autosave/ con timestamp                     |
| SAV-10| Recuperar autoguardado tras cierre forzoso         | Al abrir la app: "Se encontró sesión sin guardar. ¿Recuperar?"|
| SAV-11| Cargar .bmap corrupto o mal formado                | Error: "Archivo de sesión no válido o corrupto"         |
| SAV-12| Sesión guardada y recargada: niebla restaurada     | Mismas celdas reveladas que antes de guardar            |
| SAV-13| Sesión guardada con iniciativa en turno 3          | Al cargar, el turno activo sigue siendo el 3            |
