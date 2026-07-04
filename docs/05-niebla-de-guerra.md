# 05 — Niebla de Guerra (Fog of War)

## Descripción

Sistema que oculta áreas del mapa no exploradas o no visibles por los tokens.
La niebla se revela automáticamente según el radio de visión de cada token aliado
mediante raycasting desde la posición del token.

## Funcionalidades

### 5.1 Modos de niebla

**Niebla global**:
- Mapa completamente cubierto. Solo se revela lo que los tokens han explorado
  o están viendo actualmente.

**Niebla por zonas**:
- El DM define zonas de niebla manualmente dibujando polígonos.
- Las zonas pueden activarse/desactivarse individualmente.

**Sin niebla**:
- Todo el mapa visible para los jugadores.

### 5.2 Revelado por visión de tokens

Cada token tiene un radio de visión configurable (en casillas). La aplicación
calcula qué área es visible usando raycasting:

1. Desde el centro del token se lanzan rayos en todas direcciones (360°).
2. Las paredes/obstáculos bloquean los rayos (definidos por el DM en una capa de
   colisión de visión).
3. El área visible se revela permanentemente (zona explorada) y se mantiene
   aunque el token se aleje.
4. El área actualmente visible por tokens vivos se muestra con un degradado suave
   en el borde.

### 5.3 Capa de colisión de visión

El DM puede dibujar líneas/polígonos en una capa dedicada que actúan como
bloqueadores de visión (paredes, puertas cerradas, pilares).

**Propiedades de un bloqueador**:
- Es visible solo para el DM (línea roja semitransparente).
- Bloquea rayos de visión completamente.
- Puede activarse/desactivarse (ej. abrir una puerta).

### 5.4 Revelado manual

El DM puede usar una herramienta de "revelar zona" (brocha circular) para
descubrir áreas manualmente, independientemente de la visión de tokens.

### 5.5 Capa de niebla

La niebla se renderiza como una capa semitransparente oscura sobre el mapa.
Visualmente:
- **Zona no explorada**: Opacidad 100% (negro).
- **Zona explorada, no visible actualmente**: Opacidad 60% (gris oscuro).
- **Zona visible**: Opacidad 0%.

---

## Casos de uso y ejemplos para test

| ID    | Caso                                              | Resultado esperado                                      |
|-------|---------------------------------------------------|---------------------------------------------------------|
| FOG-01| Activar niebla global sin tokens en mapa          | Toda la ventana de jugador se muestra negra             |
| FOG-02| Token con visión 6 casillas, sin obstáculos       | Círculo de radio 6 celdas visible alrededor del token   |
| FOG-03| Token con visión 6, con pared a 3 casillas        | Visión bloqueada por la pared; zona tras ella oculta    |
| FOG-04| Alejar token de zona previamente revelada         | Zona permanece en gris oscuro (explorada), token ve nuevo área|
| FOG-05| Dos tokens aliados con visión 6, separados 8 celdas| Dos círculos de visión; solapamiento se une suavemente  |
| FOG-06| Desactivar bloqueador de visión (abrir puerta)    | La zona antes bloqueada se vuelve visible               |
| FOG-07| Revelar zona manual con brocha tamaño 3           | Círculo de 3 celdas se destapa permanentemente          |
| FOG-08| Cambiar a modo "sin niebla"                       | Mapa completamente visible; exploración previa preservada|
| FOG-09| Token enemigo sin aliados cerca                   | El enemigo no revela niebla; zona sigue oscura          |
| FOG-10| Mover token 10 celdas en línea recta              | Cada paso intermedio revela niebla; 10 nuevas celdas visibles|
| FOG-11| Raycasting con 360 rayos, rendimiento             | Sin ralentización perceptible con 20 tokens y 100 paredes|
| FOG-12| Cargar sesión con niebla parcialmente revelada    | La niebla se restaura exactamente como se guardó        |
