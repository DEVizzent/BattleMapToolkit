# 14 — Internacionalización (i18n)

## Descripción

Sistema de traducción que permite cambiar el idioma de la aplicación en caliente.
Soporta español e inglés, con detección automática del idioma del sistema y
selector manual en el panel de ajustes.

## Funcionalidades

### 14.1 Idiomas soportados

| Código | Idioma   | Estado |
|--------|----------|--------|
| `es`   | Español  | Base   |
| `en`   | English  | Traducido |

### 14.2 Detección automática

Al iniciar la aplicación, `LocaleManager` consulta `OS.get_locale_language()` para
obtener el idioma del sistema. Si coincide con un idioma soportado, se aplica
automáticamente. Si no, se usa español (fallback).

**Regla**: La preferencia guardada por el usuario en ajustes tiene prioridad
sobre la detección automática. Si el usuario selecciona "Sistema", se vuelve
a usar la detección.

### 14.3 Selector de idioma en ajustes

El panel de ajustes incluye un `OptionButton` con tres opciones:

| Opción    | Comportamiento                                    |
|-----------|---------------------------------------------------|
| Sistema   | Usa `OS.get_locale_language()` (auto-detección)   |
| Español   | Fuerza `es`                                       |
| English   | Fuerza `en`                                       |

**Regla**: Al cambiar el idioma desde ajustes, la interfaz se actualiza
inmediatamente (`TranslationServer.set_locale()`). No es necesario reiniciar.

### 14.4 Archivo de traducciones

Las traducciones se definen en `locale/translations.csv`:

**Formato**: CSV estándar con cabecera `keys,en,es`.
- Primera columna: clave (texto original en español).
- Segunda columna: traducción al inglés.
- Tercera columna: traducción al español (opcional, misma clave si no hay variación).

**Reglas**:
- Los textos de la UI en `.tscn` se traducen automáticamente (auto-translate).
  La clave es el valor exacto del campo `text` del nodo.
- Los textos en GDScript se traducen con `tr("CLAVE")`.
- Si una traducción está vacía en el CSV, se usa la clave como valor.

### 14.5 API de traducción

```gdscript
# Cambiar idioma
LocaleManager.set_locale("en")

# Traducir texto en código
label.text = tr("MSG_FILE_NOT_FOUND")

# Obtener idioma actual
var lang := TranslationServer.get_locale()
```

### 14.6 Auto-translate en escenas

Los nodos `Button`, `Label` y otros controles con `Auto Translate` habilitado
(por defecto) sustituyen automáticamente su texto por la traducción correspondiente
cuando `TranslationServer` encuentra una clave coincidente.

**Ejemplo**: si un `Button` tiene `text = "Ajustes"` y el locale es `en`, el
`TranslationServer` busca la clave `"Ajustes"` en la traducción inglesa y la
reemplaza por `"Settings"`.

**Regla**: Para nodos cuyo texto no debe traducirse (ej. nombres de jugador),
desactivar `Auto Translate` en el inspector.

### 14.7 Persistencia

La preferencia de idioma se guarda en `Settings.language` y persiste en
`user://settings.json`. Al reiniciar la aplicación, se restaura la preferencia.

---

## Casos de uso y ejemplos para test

| ID    | Caso                                              | Resultado esperado                                      |
|-------|---------------------------------------------------|---------------------------------------------------------|
| I18-01| Sistema en español, abrir app                     | Launcher muestra "Nueva sesion", "Ajustes", etc.        |
| I18-02| Sistema en inglés, abrir app                      | Launcher muestra "New session", "Settings", etc.        |
| I18-03| Sistema en francés, abrir app (no soportado)      | Fallback a español: "Nueva sesion", "Ajustes"           |
| I18-04| Usuario cambia a English en ajustes               | UI cambia inmediatamente a inglés                       |
| I18-05| Usuario cambia a Sistema en ajustes               | Vuelve al idioma detectado del SO                       |
| I18-06| Cerrar y reabrir: preferencia English guardada    | Launcher se abre en inglés                              |
| I18-07| Diálogo de error con locale=en                    | Título "Error", mensaje en inglés                       |
| I18-08| CSV con clave sin traducción en columna en        | Se muestra la clave original en inglés (fallback)       |
| I18-09| Añadir nuevo texto a CSV sin reiniciar            | Requiere reinicio de la app para cargar nuevas claves   |
| I18-10| Texto en GDScript con tr() y locale=es            | Muestra el texto en español                             |
| I18-11| Nodo con Auto Translate desactivado               | Texto no cambia al cambiar idioma                       |
| I18-12| Cambiar idioma durante sesión abierta             | DM Window actualiza su texto; estado del juego intacto  |
