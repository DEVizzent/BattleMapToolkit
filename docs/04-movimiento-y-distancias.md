# 04 — Movimiento y Distancias

## Descripción

Sistema para mover tokens por el mapa y mostrar en tiempo real la distancia
recorrida en las unidades configuradas (pies o metros).

## Funcionalidades

### 4.1 Modos de movimiento

**Ratón**:
- Click + arrastre sobre un token para moverlo.
- Al arrastrar, una línea fantasma conecta la posición original con la actual.

**Táctil**:
- Toque + arrastre sobre un token.
- Misma línea fantasma y cálculo de distancia.

**Teclado**:
- Con token seleccionado, flechas mueven 1 celda por pulsación.
- Shift + flecha = movimiento fino (1 píxel, sin snap).
- Al soltar la tecla, el token hace snap si corresponde.

### 4.2 Indicador de distancia en tiempo real

Durante el arrastre, se muestra una etiqueta flotante junto al cursor con:

```
Distancia: X pies (Y casillas)
```

**Reglas**:
- Distancia en pies: número de casillas × 30 (o la medida configurada).
- Movimiento diagonal: cada 2 diagonales cuentan como 3 casillas (regla 5e opcional, configurable).
- La etiqueta sigue al cursor y es legible independientemente del zoom.

### 4.3 Rastro de movimiento (opcional)

Al completar el movimiento, se puede mostrar una línea punteada que conecta el
punto de origen con el destino durante 2 segundos, indicando la trayectoria.

### 4.4 Límite de velocidad

Si el token tiene velocidad base configurada, las celdas que exceden esa distancia
se marcan en rojo durante el arrastre. El token puede soltarse, pero el DM recibe
un aviso visual.

### 4.5 Movimiento de grupo

Al seleccionar múltiples tokens y arrastrar uno, todos se mueven manteniendo su
formación relativa.

### 4.6 Medición de alcance previa al movimiento

Al mantener Ctrl + hover sobre una celda (sin arrastrar token), se muestra la
distancia desde el token seleccionado hasta esa celda.

---

## Casos de uso y ejemplos para test

| ID    | Caso                                              | Resultado esperado                                      |
|-------|---------------------------------------------------|---------------------------------------------------------|
| MOV-01| Arrastrar token 3 celdas en línea recta           | Etiqueta: "90 pies (3 casillas)"                       |
| MOV-02| Arrastrar token 3 celdas en diagonal              | Etiqueta: "90 pies (3 casillas)" o equivalente regla   |
| MOV-03| Soltar token: hace snap al centro de la celda     | Token centrado exactamente en la celda destino          |
| MOV-04| Flecha derecha con token seleccionado             | Token se mueve 1 celda a la derecha con snap            |
| MOV-05| Shift + flecha derecha                            | Token se desplaza 1 px, sin snap                        |
| MOV-06| Arrastrar token más allá de su velocidad (ej. 60')| Celdas más allá de 60' se marcan en rojo               |
| MOV-07| Mover 5 tokens en selección múltiple              | Todos se mueven juntos, formación preservada            |
| MOV-08| Táctil: arrastrar token 4 celdas                  | Igual que ratón: etiqueta de distancia y línea fantasma|
| MOV-09| Ctrl + hover a 5 celdas del token seleccionado    | Muestra "150 pies (5 casillas)" sin mover el token     |
| MOV-10| Rastro de movimiento tras soltar token            | Línea punteada origen-destino visible 2 segundos        |
| MOV-11| Cambiar unidades a metros (1.5 m/celda)           | Arrastrar 2 celdas muestra "3.0 m (2 casillas)"        |
| MOV-12| Medida diagonal con regla "cada 2 diag = 3 celdas"| Secuencia: 1ª diag=1 celda, 2ª diag=2 celdas total     |
