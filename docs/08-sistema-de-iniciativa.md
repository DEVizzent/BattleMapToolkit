# 08 — Sistema de Iniciativa

## Descripción

Tracker de iniciativa para gestionar el orden de turnos en combate, incluyendo
estadísticas básicas de criaturas (HP, CA) y control de visibilidad de tokens.

## Funcionalidades

### 8.1 Panel de iniciativa

Panel lateral o flotante que muestra la lista ordenada de participantes en combate.

**Columnas**:
| Columna     | Descripción                                          |
|-------------|------------------------------------------------------|
| Orden       | Número de turno actual resaltado                     |
| Nombre      | Nombre del token/personaje                           |
| Iniciativa  | Valor numérico de iniciativa                         |
| HP          | Puntos de vida actuales / máximos                    |
| CA          | Clase de armadura                                    |
| Estado      | Iconos de condiciones activas                        |

### 8.2 Añadir participante

- **Desde token en mapa**: Click derecho > "Añadir a iniciativa".
- **Manual**: Botón "Añadir" > formulario con nombre, iniciativa, HP, CA.
- **Iniciativa automática**: La app tira iniciativa por el usuario (d20 + modificador configurable).

### 8.3 Orden de turno

- Los participantes se ordenan por valor de iniciativa (descendente).
- El turno activo se resalta visualmente.
- Botones "Siguiente turno" y "Turno anterior".
- Al avanzar turno, se puede configurar un sonido o notificación visual.

### 8.4 Gestión de HP durante combate

- Campos de HP editables directamente en el panel.
- Botones de daño rápido: -1, -5, -10.
- Botones de curación: +1, +5, +10.
- Si HP llega a 0, el token se marca visualmente (tinte rojo, icono de calavera).

### 8.5 Vinculación token-iniciativa

- El token vinculado muestra un indicador (número de iniciativa junto al nombre).
- Al hacer click en una entrada de iniciativa, la cámara centra en el token.
- Si un token se elimina del mapa, se pregunta si también se elimina de iniciativa.

### 8.6 Control de visibilidad de tokens

- Columna "Visible" con toggle para mostrar/ocultar el token en la ventana de jugadores.
- Botón global "Revelar todos" / "Ocultar todos".
- Los tokens ocultos se muestran semitransparentes en la vista del DM.

---

## Casos de uso y ejemplos para test

| ID    | Caso                                              | Resultado esperado                                      |
|-------|---------------------------------------------------|---------------------------------------------------------|
| INI-01| Añadir 3 tokens a iniciativa desde mapa            | Los 3 aparecen en panel, ordenados por iniciativa       |
| INI-02| Añadir participante manual "Orco", INI 12, HP 45   | Nueva entrada en la lista, sin token asociado            |
| INI-03| Pulsar "Siguiente turno"                           | Turno activo avanza al siguiente; resalte se mueve      |
| INI-04| Último turno + "Siguiente turno"                   | Vuelve al primer participante (ciclo)                   |
| INI-05| Editar HP a 0                                     | Token se tiñe de rojo y muestra icono de calavera       |
| INI-06| Botón de daño rápido -10 sobre HP 15              | HP baja a 5                                             |
| INI-07| Click en entrada de iniciativa                     | Cámara centra en el token vinculado                     |
| INI-08| Ocultar token desde panel de iniciativa            | Token desaparece de ventana jugadores; DM lo ve gris    |
| INI-09| "Revelar todos" con 5 tokens ocultos               | Todos los tokens vuelven a ser visibles para jugadores  |
| INI-10| Eliminar token del mapa que está en iniciativa     | Diálogo: "¿Eliminar también de iniciativa?"             |
| INI-11| Reordenar iniciativa arrastrando entrada           | El orden cambia; se ignora el valor numérico de INI     |
| INI-12| Tirar iniciativa automática (d20 + mod +2)         | Valor generado entre 3 y 22, se asigna al participante  |
| INI-13| 15 participantes en iniciativa                     | Scroll fluido; sin degradación de rendimiento           |
| INI-14| Misma iniciativa para 2 participantes              | Se resuelve por orden de inserción; aviso al DM         |
