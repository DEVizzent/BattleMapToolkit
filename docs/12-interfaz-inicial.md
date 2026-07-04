# 12 — Interfaz Inicial (Launcher)

## Descripción

Pantalla de bienvenida que el usuario ve al abrir la aplicación. Actúa como punto
de entrada para crear, abrir o importar sesiones, y muestra las sesiones recientes
para acceso rápido.

## Funcionalidades

### 12.1 Pantalla de bienvenida

```
┌──────────────────────────────────────────────────┐
│                                                  │
│              ⚔ BattleMap Toolkit                │
│                                                  │
│  ┌────────────────────────────────────────────┐  │
│  │  ⚡ Nueva sesión                           │  │
│  └────────────────────────────────────────────┘  │
│  ┌────────────────────────────────────────────┐  │
│  │  📂 Abrir sesión (.bmap)                   │  │
│  └────────────────────────────────────────────┘  │
│  ┌────────────────────────────────────────────┐  │
│  │  📥 Importar sesión (.bmap / .zip)         │  │
│  └────────────────────────────────────────────┘  │
│                                                  │
│  ——— Sesiones recientes ————————————————————    │
│  ┌────────────────────────────────────────────┐  │
│  │ 📁 La Tumba del Dragón    3 mapas  02/07  │  │
│  │ 📁 Bosque Oscuro          5 mapas  30/06  │  │
│  │ 📁 One-shot Goblins       2 mapas  28/06  │  │
│  │                              ...           │  │
│  └────────────────────────────────────────────┘  │
│                                                  │
│         ⚙ Ajustes         ❓ Ayuda             │
│                                                  │
└──────────────────────────────────────────────────┘
```

### 12.2 Banner de recuperación

Si la aplicación se cerró inesperadamente y existe un autoguardado reciente,
se muestra un banner en la parte superior:

```
┌──────────────────────────────────────────────────┐
│ ⚠ Se encontró una sesión sin guardar del 05/07.  │
│   [Recuperar]  [Descartar]                       │
└──────────────────────────────────────────────────┘
```

**Reglas**:
- Aparece solo si el autoguardado es más reciente que el último guardado manual.
- "Recuperar" restaura la sesión y abre la interfaz del DM directamente.
- "Descartar" elimina el autoguardado y muestra el launcher normal.
- El banner oculta las sesiones recientes hasta que se toma una decisión.

### 12.3 Nueva sesión

**Flujo**:
1. Click en "Nueva sesión".
2. Diálogo: nombre de la sesión y carpeta donde se guardará.
3. Se crea una sesión vacía (sin mapas) y se abre la interfaz del DM.

**Reglas**:
- El nombre por defecto es "Nueva sesión" con la fecha actual.
- Si la carpeta por defecto no existe, se crea automáticamente.

### 12.4 Abrir sesión

**Flujo**:
1. Click en "Abrir sesión" o doble click en una sesión reciente.
2. Si la sesión reciente ya no existe en disco, se muestra un aviso y se
   elimina de la lista de recientes.
3. Diálogo de sistema para buscar archivo `.bmap` (si se usó el botón "Abrir").
4. Se carga la sesión y se abre la interfaz del DM.

### 12.5 Importar sesión

**Flujo**:
1. Click en "Importar sesión".
2. Diálogo de sistema para seleccionar `.bmap` o `.zip`.
3. Si es `.zip`, se extrae a `library/imported/<nombre>/`.
4. La sesión se añade a la lista de recientes y se abre.

### 12.6 Sesiones recientes

**Lista**:
- Muestra las últimas 10 sesiones abiertas o creadas.
- Cada entrada muestra: nombre, número de mapas que contiene, fecha de última
  modificación.
- Un icono de campana junto a la sesión si contiene iniciativa activa (combate
  en curso).
- Click secundario ofrece: "Abrir ubicación del archivo", "Eliminar de recientes"
  (no borra el archivo).

**Reglas**:
- La lista persiste entre sesiones de la aplicación (se guarda en un archivo
  de configuración local, no en el .bmap).
- Si un archivo listado ya no existe, se marca en gris con el texto
  "(no encontrado)" y no se puede abrir.

### 12.7 Ajustes desde el launcher

El botón ⚙ abre un panel de configuración con:

| Ajuste                  | Descripción                                    |
|-------------------------|------------------------------------------------|
| Carpeta por defecto     | Donde se guardan las sesiones nuevas           |
| Unidades                | Pies (30'/celda) o metros (1.5 m/celda)        |
| Idioma                  | Español / English                              |
| Pantalla de jugadores   | Monitor donde se abre la ventana de jugadores  |
| Modo de vista inicial   | Sincronizado / Independiente                   |
| Tema                   | Claro / Oscuro                                 |

### 12.8 Transición al editor

Tras crear, abrir o importar una sesión, el launcher se transforma en la interfaz
del DM:
- La ventana actual pasa a ser la ventana del DM.
- Si hay una segunda pantalla configurada, se abre la ventana de jugadores.
- Si no se detecta segunda pantalla, se muestra un aviso no bloqueante:
  "No se detectó pantalla de jugadores. Puede configurarla en Ajustes."

---

## Casos de uso y ejemplos para test

| ID    | Caso                                              | Resultado esperado                                      |
|-------|---------------------------------------------------|---------------------------------------------------------|
| LCH-01| Abrir app por primera vez                         | Solo se muestran "Nueva sesión" e "Importar sesión". Sin banner de recuperación. Sin sesiones recientes. |
| LCH-02| Crear sesión "Mazmorra de prueba"                 | Se abre interfaz del DM con sesión vacía, 0 mapas       |
| LCH-03| Lista de recientes con 3 sesiones                 | Muestra nombre, nº de mapas y fecha de cada una         |
| LCH-04| Doble click en sesión reciente                    | Se carga y se abre la interfaz del DM                   |
| LCH-05| Abrir sesión cuyo archivo fue movido/borrado      | Entrada en gris "(no encontrado)". Click = aviso. No crashea. |
| LCH-06| Click secundario > "Eliminar de recientes"        | Entrada desaparece de la lista; archivo .bmap intacto   |
| LCH-07| Banner de recuperación: click en "Recuperar"      | Sesión restaurada, DM abierto, autoguardado conservado   |
| LCH-08| Banner de recuperación: click en "Descartar"      | Autoguardado eliminado, launcher normal                 |
| LCH-09| Importar .zip con sesión exportada                | Assets extraídos, sesión cargada, añadida a recientes   |
| LCH-10| Importar .zip corrupto                            | Error: "El archivo no es una sesión válida"             |
| LCH-11| Abrir app con 11 sesiones recientes               | Solo se muestran las 10 últimas; la 11ª se descarta     |
| LCH-12| Sesión con iniciativa activa en recientes         | Muestra icono de campana junto al nombre                |
| LCH-13| Sin segunda pantalla: abrir sesión                | Aviso no bloqueante. Ventana DM abre. Jugadores no.     |
| LCH-14| Con segunda pantalla configurada: abrir sesión    | Ventana DM + ventana jugadores en monitor correcto      |
| LCH-15| Cambiar tema a oscuro desde ajustes del launcher  | Launcher y futura interfaz del DM usan tema oscuro      |
