extends Node

## LocaleManager — gestiona el idioma actual de la aplicación.
## Carga las traducciones desde CSV y las aplica vía TranslationServer.

const TRANSLATIONS_PATH := "res://locale/translations.csv"
const SUPPORTED_LOCALES := ["es", "en"]
const DEFAULT_LOCALE := "es"

var current_locale: String = DEFAULT_LOCALE


func _ready() -> void:
	_load_translations()
	_apply_saved_or_system_locale()


func _load_translations() -> void:
	var file := FileAccess.open(TRANSLATIONS_PATH, FileAccess.READ)
	if not file:
		push_warning("LocaleManager: no se pudo abrir " + TRANSLATIONS_PATH)
		return
	var csv_text := file.get_as_text()
	file.close()

	var lines := csv_text.split("\n", false)
	if lines.size() < 2:
		return

	# parse header: keys,en,es
	var headers := _parse_csv_line(lines[0])
	if headers.size() < 3 or headers[0] != "keys":
		push_warning("LocaleManager: formato CSV inválido")
		return

	# create a Translation resource per locale (skip first column = keys)
	for loc_idx in range(1, headers.size()):
		var locale_code := headers[loc_idx].strip_edges()
		if locale_code not in SUPPORTED_LOCALES:
			continue
		var translation := Translation.new()
		translation.locale = locale_code
		for i in range(1, lines.size()):
			var cols := _parse_csv_line(lines[i])
			if cols.size() <= loc_idx:
				continue
			var key := cols[0]
			var value := cols[loc_idx]
			if value == "":
				value = key
			translation.add_message(key, value)
		TranslationServer.add_translation(translation)


func _parse_csv_line(line: String) -> PackedStringArray:
	var result: Array[String] = []
	var current := ""
	var in_quotes := false
	for c in line:
		if c == '"':
			in_quotes = !in_quotes
		elif c == ',' and not in_quotes:
			result.append(current)
			current = ""
		else:
			current += c
	result.append(current)
	return PackedStringArray(result)


func _apply_saved_or_system_locale() -> void:
	var saved := Settings.language
	if saved == "auto":
		var system_lang := OS.get_locale_language()
		if system_lang in SUPPORTED_LOCALES:
			current_locale = system_lang
		else:
			current_locale = DEFAULT_LOCALE
	else:
		if saved in SUPPORTED_LOCALES:
			current_locale = saved
		else:
			current_locale = DEFAULT_LOCALE
	TranslationServer.set_locale(current_locale)


func set_locale(locale: String) -> void:
	if locale == "auto":
		var system_lang := OS.get_locale_language()
		current_locale = system_lang if system_lang in SUPPORTED_LOCALES else DEFAULT_LOCALE
		Settings.language = "auto"
	elif locale in SUPPORTED_LOCALES:
		current_locale = locale
		Settings.language = locale
	else:
		return
	TranslationServer.set_locale(current_locale)
	EventBus.locale_changed.emit(current_locale)


func get_locale_label(locale: String) -> String:
	match locale:
		"es":
			return "Español"
		"en":
			return "English"
		_:
			return "Auto"
