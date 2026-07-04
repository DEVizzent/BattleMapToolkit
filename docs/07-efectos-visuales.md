# 07 — Efectos Visuales

## Descripción

Sistema de efectos visuales superpuestos al mapa: partículas, iluminación
dinámica, niebla ambiental y capas de efectos. Pensado para ambientar escenas
y representar hechizos o fenómenos del entorno.

## Funcionalidades

### 7.1 Sistema de partículas

El DM puede colocar emisores de partículas predefinidos en puntos del mapa.

**Efectos incluidos**:
| Efecto      | Descripción visual                           |
|-------------|----------------------------------------------|
| Fuego       | Llamas con chispas ascendentes               |
| Humo/Niebla | Nubes grises flotantes y expansivas          |
| Magia       | Destellos brillantes, chispas de colores     |
| Veneno      | Burbujas verdes y gas denso                  |
| Polvo       | Partículas marrones cayendo lentamente       |
| Lluvia      | Gotas cayendo en toda la pantalla            |
| Nieve       | Copos blancos cayendo suavemente             |

**Parámetros configurables**:
- Intensidad (cantidad de partículas).
- Radio de emisión (en píxeles o casillas).
- Duración: infinita o temporizada.
- Color base.

### 7.2 Iluminación dinámica

Usando el sistema Light2D de Godot, se pueden colocar fuentes de luz.

**Tipos de luz**:
| Tipo       | Descripción                                      |
|------------|--------------------------------------------------|
| Puntual    | Luz radial desde un punto (antorcha, vela)       |
| Direccional| Luz en una dirección (ventana, rayo de luna)     |
| Ambiente   | Luz global que afecta a toda la escena           |

**Parámetros**:
- Color e intensidad.
- Radio / alcance.
- Atenuación (curva de caída).
- Sombras proyectadas (activado/desactivado).

**Interacción con niebla de guerra**: La iluminación solo es visible en zonas ya
reveladas o visibles.

### 7.3 Capa de efectos ambientales

Efectos globales que afectan a todo el mapa visible:
- Tinte de color (ej. tono azulado para ambiente nocturno).
- Niebla ambiental (opacidad y densidad graduales).
- Viñeta (oscurecimiento de bordes).

### 7.4 Animaciones de ataque/hechizo

Efectos puntuales de corta duración (1-3 segundos):
- Explosión (expansión rápida de partículas).
- Rayo (línea con flicker).
- Curación (destello ascendente).
- Golpe (chispas en punto de impacto).

### 7.5 Gestor de efectos

Panel donde el DM puede:
- Ver lista de efectos activos.
- Pausar/reanudar un efecto individual.
- Eliminar un efecto.
- Duplicar un efecto a otra posición.

---

## Casos de uso y ejemplos para test

| ID    | Caso                                              | Resultado esperado                                      |
|-------|---------------------------------------------------|---------------------------------------------------------|
| EFX-01| Colocar fuego en posición (10, 5)                 | Llamas y chispas visibles en esa zona                   |
| EFX-02| Colocar luz puntual amarilla radio 4              | Iluminación radial cálida; tokens bajo ella se iluminan |
| EFX-03| Luz en zona no revelada por niebla de guerra      | Luz no visible hasta que se revele la zona              |
| EFX-04| Activar niebla ambiental global al 30%            | Todo el viewport se vuelve ligeramente brumoso          |
| EFX-05| Efecto de rayo entre token A y token B            | Línea blanca con flicker durante 1 segundo               |
| EFX-06| Pausar efecto de niebla                           | Partículas se congelan en su estado actual              |
| EFX-07| Reanudar efecto pausado                           | Partículas continúan su animación normalmente           |
| EFX-08| Eliminar efecto de fuego                          | Partículas desaparecen; no quedan artefactos            |
| EFX-09| 10 efectos simultáneos (fuegos, luces, niebla)    | Rendimiento estable, sin caída de FPS                   |
| EFX-10| Cambiar intensidad de partículas al 200%          | El doble de partículas visibles                         |
| EFX-11| Tinte global azul nocturno                        | Todo el mapa visible adquiere tonalidad azulada         |
| EFX-12| Efecto de explosión centrado en token             | Partículas expansivas que se desvanecen en 1 segundo    |
| EFX-13| Duplicar efecto de luz a otra posición            | Segunda luz idéntica aparece en nueva ubicación         |
