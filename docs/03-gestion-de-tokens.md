# 03 — Gestión de Tokens

## Descripción

Módulo para importar, configurar y gestionar tokens que representan personajes,
criaturas y NPCs sobre el mapa.

## Funcionalidades

### 3.1 Importar token

El usuario importa una imagen (PNG recomendado, con transparencia) desde archivo
o desde la biblioteca de tokens (`library/tokens/`).

**Reglas**:
- La imagen se recorta automáticamente al bounding box no transparente.
- Si la imagen no tiene transparencia, se muestra un aviso.
- El token se añade al panel lateral de "Tokens en mapa".

### 3.2 Configuración del token

Propiedades editables por token:
- **Nombre**: Etiqueta mostrada bajo el token.
- **Tamaño en casillas**: 1×1 (Mediano), 2×2 (Grande), 3×3 (Enorme), 4×4 (Gargantuesco), o personalizado (X×Y).
- **Color de borde**: Para identificar dueño/equipo.
- **Visibilidad**: Visible / Oculto para jugadores.
- **Radio de visión**: En casillas, usado por el sistema de niebla de guerra.
- **Velocidad base**: En pies, usado para calcular alcance de movimiento.

### 3.3 Biblioteca de tokens

Similar a la de mapas. Subcarpetas organizables, thumbnails cacheados.
Drag & drop desde la biblioteca al mapa para instanciar tokens.

### 3.4 Interacción con tokens en el mapa

- **Click**: Seleccionar token (resalta con borde animado).
- **Doble click**: Abrir panel de configuración del token.
- **Click derecho**: Menú contextual (Duplicar, Eliminar, Ocultar/Mostrar, Centrar vista).
- **Tecla Supr**: Eliminar token seleccionado.
- **Selección múltiple**: Ctrl+Click o arrastre de marco.

### 3.5 Apilamiento de tokens

Cuando varios tokens ocupan la misma celda, se muestran ligeramente desplazados
en abanico. Un indicador numérico muestra cuántos tokens hay en esa posición.

### 3.6 Condiciones de estado

El token puede mostrar iconos de estado (envenenado, paralizado, concentración,
etc.) como pequeños overlays en la esquina del token.

---

## Casos de uso y ejemplos para test

| ID    | Caso                                              | Resultado esperado                                      |
|-------|---------------------------------------------------|---------------------------------------------------------|
| TOK-01| Importar PNG con transparencia de 256×256 px       | Token aparece centrado, fondo transparente respetado    |
| TOK-02| Importar JPG sin transparencia                     | Aviso: "La imagen no tiene transparencia" + fondo blanco|
| TOK-03| Crear token tamaño 2×2 casillas                   | Token ocupa 2×2 celdas visualmente                     |
| TOK-04| Cambiar visibilidad a "Oculto"                     | Token desaparece de la ventana de jugadores             |
| TOK-05| Biblioteca con 30 tokens en carpeta "Goblins"      | Scroll con miniaturas, drag & drop funcional            |
| TOK-06| Seleccionar 3 tokens con Ctrl+Click                | Los 3 muestran borde de selección; mover uno mueve todos|
| TOK-07| Apilar 4 tokens en misma celda                     | Se muestran en abanico con indicador "4"               |
| TOK-08| Doble click en token                               | Se abre panel de propiedades con todos los campos       |
| TOK-09| Eliminar token con Supr                            | Token desaparece del mapa y del panel lateral           |
| TOK-10| Duplicar token desde menú contextual               | Nuevo token idéntico aparece desplazado 1 celda         |
| TOK-11| Añadir condición "Envenenado"                      | Icono de veneno aparece en esquina superior del token   |
| TOK-12| Cambiar borde a color azul (aliado)                | Token muestra aro azul alrededor                        |
| TOK-13| Token con nombre muy largo                         | Etiqueta se trunca con "..." si excede el ancho del token|
| TOK-14| Importar token desde FileDialog                     | TokenData creado, sprite en TokenLayer, item en lista     |
| TOK-15| Crear token sin transparencia                        | Aviso mostrado, token se crea igualmente                  |
| TOK-16| Token de 2 casillas en grid de 70 px                 | Sprite escala a 140 px de ancho/alto                      |
