# 06 — Herramientas de Medición

## Descripción

Herramientas que permiten al DM y jugadores medir distancias entre puntos y
visualizar áreas de efecto (cuadrados, círculos, conos) sobre el mapa.

## Funcionalidades

### 6.1 Medición de distancia punto a punto

**Activación**: Botón "Medir" en la toolbar o atajo (M).

**Uso**:
- Click en punto A, click en punto B.
- Se dibuja una línea recta entre ambos puntos.
- Etiqueta muestra: "X pies (Y casillas)".
- Se pueden añadir puntos intermedios (waypoints) con clicks adicionales para
  medir rutas no lineales.

**Reglas**:
- La medición se ajusta a la cuadrícula si está activa (snap de los puntos a centros de celda).
- Con Shift, los puntos no hacen snap.
- Escape cancela la medición actual.

### 6.2 Plantillas de área

El DM puede colocar plantillas de área predefinidas para visualizar el alcance
de hechizos y habilidades.

**Formas disponibles**:

| Forma     | Parámetros                        | Representación visual                        |
|-----------|-----------------------------------|----------------------------------------------|
| Cuadrado  | Lado en casillas                  | Cuadrado relleno semitransparente            |
| Círculo   | Radio en casillas                 | Círculo relleno semitransparente             |
| Cono      | Longitud en casillas              | Triángulo isósceles desde punto de origen    |
| Línea     | Longitud y ancho en casillas      | Rectángulo alargado                          |

**Interacción**:
- Click para colocar el centro/origen.
- Arrastre para rotar (cono, línea).
- Las plantillas hacen snap a la cuadrícula.
- Se pueden apilar múltiples plantillas.
- Click derecho > "Eliminar" sobre una plantilla.

### 6.3 Persistencia de plantillas

Las plantillas pueden marcarse como:
- **Temporal**: Desaparece al cambiar de herramienta.
- **Persistente**: Permanece hasta que se elimina manualmente.

### 6.4 Personalización visual

Cada plantilla puede personalizarse:
- Color de relleno y opacidad.
- Color y grosor del borde.
- Animación de pulso (opcional, para hechizos activos).

---

## Casos de uso y ejemplos para test

| ID    | Caso                                              | Resultado esperado                                      |
|-------|---------------------------------------------------|---------------------------------------------------------|
| MED-01| Medir distancia entre 2 celdas (3 casillas)       | Línea recta + etiqueta "90 pies (3 casillas)"          |
| MED-02| Medir ruta con 3 waypoints                        | Línea quebrada con distancia total acumulada            |
| MED-03| Colocar círculo de radio 4                        | Círculo relleno de 4 casillas de radio centrado         |
| MED-04| Colocar cono de longitud 6, rotar 45°             | Cono apuntando a 45°, longitud 6 casillas              |
| MED-05| Colocar cuadrado de 3×3                           | Cuadrado relleno de 3×3 celdas                         |
| MED-06| Apilar círculo y cono en misma zona               | Ambos visibles sin interferencia visual                 |
| MED-07| Medir con Shift (sin snap a grid)                 | Puntos se colocan en posición exacta del cursor         |
| MED-08| Cambiar a herramienta de medición, luego cancelar | La medición actual desaparece                           |
| MED-09| Plantilla persistente al cambiar de herramienta   | La plantilla sigue visible                              |
| MED-10| Plantilla temporal al cambiar de herramienta      | La plantilla se elimina automáticamente                 |
| MED-11| Personalizar color de plantilla a azul 40%        | Plantilla azul semitransparente                         |
| MED-12| Eliminar plantilla con click derecho              | Plantilla desaparece sin afectar a otras                |
| MED-13| Medición con unidades en metros (1 celda=1.5m)    | Etiqueta: "4.5 m (3 casillas)"                         |
| MED-14| Mapa sin cuadrícula, colocar círculo radio 4      | Se usa tamaño de celda por defecto (70 px)              |
