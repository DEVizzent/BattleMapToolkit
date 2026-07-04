# 09 — Sistema de Ventanas DM/Jugadores

## Descripción

Sistema de dos ventanas independientes: la ventana del DM con todos los controles
y la ventana de los jugadores (proyectada en pantalla táctil externa) que muestra
solo lo que los jugadores deben ver.

## Funcionalidades

### 9.1 Ventana del DM

Ventana principal con acceso completo:

**Zonas de la interfaz**:
```
┌──────────────────────────────────────────────────────┐
│ Toolbar (zoom, herramientas, efectos, ajustes)        │
├──────────┬────────────────────────┬──────────────────┤
│ Panel    │                        │ Panel            │
│ Tokens   │   Viewport del Mapa    │ Iniciativa       │
│ en mapa  │   (con todos los       │                  │
│          │    overlays del DM)      │                  │
│ Biblioteca│                        │ Propiedades      │
│ Mapas    │                        │ del seleccionado │
│ Tokens   │                        │                  │
├──────────┴────────────────────────┴──────────────────┤
│ Barra de estado (zoom%, coordenadas, FPS)            │
└──────────────────────────────────────────────────────┘
```

**Indicador de vista de jugadores**:

El viewport del DM muestra un rectángulo superpuesto que delimita exactamente
la porción del mapa que los jugadores están viendo en su ventana.

- Rectángulo de borde discontinuo, color a elegir (default: azul cian).
- Se actualiza en tiempo real al hacer zoom/pan en cualquiera de las dos ventanas.
- En modo sincronizado, el rectángulo coincide con el viewport del DM (no se dibuja,
  por redundante).
- En modo independiente, el DM puede ver de un vistazo si los jugadores están
  mirando otra zona del mapa.

**Caso: mapa muy grande** (ej. 8000×6000 px, el DM tiene zoom 200% en la esquina
superior izquierda):

- Si la vista de jugadores está **dentro** del viewport del DM: se dibuja el
  rectángulo discontinuo sobre la zona que ven.
- Si la vista de jugadores está **fuera** del viewport del DM: aparece una flecha
  en el borde del viewport, apuntando hacia la dirección de la vista de jugadores.
  La flecha incluye una etiqueta con la distancia aproximada (ej. "← 1200 px").
- Si la vista de jugadores está **parcialmente solapada**: se dibuja la porción
  visible del rectángulo en el viewport del DM y la flecha en el borde más cercano.

**Lo que ve el DM y los jugadores NO**:
- Capa de bloqueadores de visión (paredes rojas).
- Tokens ocultos (visibles en gris semitransparente para el DM).
- Panel de iniciativa y stats completos.
- Herramientas activas (brocha de revelar, líneas de medición temporales).
- Interfaz de control completa.

### 9.2 Ventana de jugadores

Segunda ventana, normalmente extendida a la pantalla táctil.

**Características**:
- Solo muestra: mapa, cuadrícula, tokens visibles, niebla de guerra, efectos y plantillas.
- Sin toolbars ni paneles de control.
- Interacción táctil limitada a mover tokens (si el DM lo permite en ajustes).
- La vista (zoom, paneo) puede sincronizarse con el DM o ser independiente.

### 9.3 Sincronización de vistas

**Modos de sincronización**:
| Modo               | Descripción                                        |
|---------------------|----------------------------------------------------|
| Sincronizado        | La vista de jugadores sigue al DM exactamente      |
| Independiente       | Los jugadores pueden hacer zoom/pan libremente     |
| Seguir turno        | La cámara centra automáticamente en el token activo|

### 9.4 Comunicación entre ventanas

Las ventanas comparten el estado del juego mediante señales/bus interno.
Cambios en el DM se reflejan instantáneamente en la ventana de jugadores.

**Eventos que se sincronizan**:
- Movimiento de tokens.
- Cambios en niebla de guerra.
- Efectos visuales y plantillas.
- Visibilidad de tokens.
- Zoom y paneo (si el modo es sincronizado).

### 9.5 Detección y configuración de pantallas

- Al iniciar, la app detecta monitores disponibles.
- El usuario selecciona cuál es la pantalla del jugador.
- Se recuerda la configuración entre sesiones.

---

## Casos de uso y ejemplos para test

| ID    | Caso                                              | Resultado esperado                                      |
|-------|---------------------------------------------------|---------------------------------------------------------|
| WIN-01| Abrir ventana de jugadores                        | Segunda ventana sin toolbars, solo el viewport del mapa |
| WIN-02| Mover token en ventana DM                         | Token se mueve instantáneamente en ventana jugadores    |
| WIN-03| Ocultar token desde DM                            | Token desaparece solo de la ventana de jugadores        |
| WIN-04| Modo sincronizado: DM hace zoom 150%              | Ventana jugadores también hace zoom a 150%              |
| WIN-05| Modo independiente: jugador hace pan táctil       | Vista del DM no se ve afectada                          |
| WIN-06| Modo "seguir turno": avanzar turno                | Cámara de jugadores centra en el nuevo token activo     |
| WIN-07| Detectar 2 monitores y asignar ventana jugador    | Ventana jugador se abre en el monitor correcto          |
| WIN-08| Cerrar ventana de jugadores                       | Se puede reabrir desde el menú del DM sin pérdida de estado|
| WIN-09| Interacción táctil desactivada en ventana jugador | Toques en la pantalla táctil no mueven tokens           |
| WIN-10| Arrastrar token desde pantalla táctil (permitido) | Token se mueve en ambas ventanas simultáneamente        |
| WIN-11| Redimensionar ventana de jugadores                | El viewport se ajusta; el mapa se reescala correctamente |
| WIN-12| Modo independiente: DM mueve su vista a otra zona | Rectángulo azul muestra dónde miran los jugadores       |
| WIN-13| Jugadores hacen pan a zona fuera de vista del DM  | Flecha en borde del viewport DM indica dirección        |
| WIN-14| Modo sincronizado: DM hace zoom                   | Sin indicador de vista (redundante, viewports idénticos) |
| WIN-15| DM cambia color del indicador a naranja           | Rectángulo de vista de jugadores se vuelve naranja      |
| WIN-16| Mapa 8000 px, DM zoom 200% esquina, jugadores otra | Flecha en borde DM + etiqueta "← 1200 px"              |
| WIN-17| Vista de jugadores parcialmente solapada con DM   | Rectángulo parcial + flecha en borde más cercano        |
| WIN-18| Jugadores hacen zoom, indicador en DM se actualiza | Rectángulo crece/decrece en tiempo real                 |
