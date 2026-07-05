# 02 — Sistema de Cuadrícula

## Descripción

Overlay de cuadrícula que se superpone al mapa. El usuario define su tamaño
manualmente y la cuadrícula escala con el mapa al hacer zoom.

## Funcionalidades

### 2.1 Añadir cuadrícula

El usuario activa la cuadrícula desde la toolbar. Inicialmente se muestra una
cuadrícula por defecto (70 px por celda) que el usuario ajusta.

**Parámetros configurables**:
- Tamaño de celda en píxeles (escala 1:1 del mapa).
- Offset X e Y del origen de la cuadrícula (para compensar bordes del mapa).
- Rotación de la cuadrícula (±5°, paso 0.1°).
- Color de la línea.
- Opacidad de la línea.
- Grosor de la línea.
- Mostrar/ocultar coordenadas (A1, B2...).

### 2.2 Ajuste manual de la cuadrícula

El usuario puede redimensionar y reposicionar la cuadrícula mediante:
- Slider de tamaño (10 px — 500 px).
- Controles de ajuste fino para tamaño (+1 px, -1 px, +10 px, -10 px).
- Controles de offset X e Y (-10, -1, +1, +10 px) para desplazar el origen.
- Controles de rotación (-1°, -0.1°, +0.1°, +1°) con rango ±5°.
- Arrastre para desplazar el origen.

**Regla**: Al hacer zoom sobre el mapa, la cuadrícula escala proporcionalmente.
Una celda siempre ocupa el mismo espacio relativo en el mapa base.

### 2.3 Escala de distancia

**Regla**: 1 celda = 30 pies (default) o 1.5 metros. Esta equivalencia es
configurable en ajustes de campaña.

La medida se usa para:
- Cálculo de distancias de movimiento.
- Herramienta de medición.
- Radios de habilidades y efectos.

### 2.4 Snapping

**Regla**: Los tokens, al ser soltados, hacen snap al centro de la celda más
cercana. El snapping puede desactivarse temporalmente (tecla Shift).

### 2.5 Visualización de medio movimiento

Al mover un token, se resaltan las celdas que están a la mitad de su velocidad
configurada, para ayudar al jugador a visualizar el alcance.

---

## Casos de uso y ejemplos para test

| ID    | Caso                                              | Resultado esperado                                      |
|-------|---------------------------------------------------|---------------------------------------------------------|
| GRD-01| Activar cuadrícula con mapa cargado               | Se muestra grid de 70 px por defecto sobre el mapa      |
| GRD-02| Cambiar tamaño de celda a 100 px                  | La cuadrícula se redibuja con celdas de 100 px          |
| GRD-03| Cambiar color de línea a rojo, opacidad 80%       | Las líneas se vuelven rojas semitransparentes           |
| GRD-04| Zoom 200% con cuadrícula activa                   | Las celdas escalan con el mapa; siguen siendo 100 px relativos|
| GRD-05| Soltar token sin Shift                            | Token se alinea al centro de la celda más cercana       |
| GRD-06| Soltar token con Shift pulsado                    | Token permanece en la posición exacta donde se soltó    |
| GRD-07| Desplazar origen de cuadrícula 10 px a la derecha | Toda la cuadrícula se desplaza, celdas mantienen tamaño |
| GRD-08| Cambiar medida de campaña a "metros, 1 celda=1.5m"| Las distancias se muestran en metros en toda la UI      |
| GRD-09| Cuadrícula con coordenadas visibles               | Esquinas muestran etiquetas (A1, B1, ...) sin solaparse |
| GRD-10| Mapa sin cuadrícula, mover token                  | No se muestra distancia recorrida                       |
| GRD-11| Cuadrícula en mapa de 10000×8000 px, celda 20 px  | La cuadrícula se renderiza sin degradación de rendimiento|
| GRD-12| Offset X=15, Y=25 aplicados                         | La cuadrícula se desplaza 15 px a la derecha y 25 abajo |
| GRD-13| Rotación de 2.5 grados aplicada                     | La cuadrícula se rota 2.5° en sentido horario            |
