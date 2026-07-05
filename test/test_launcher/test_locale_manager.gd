extends GutTest

func test_supported_locales_es() -> void:
	LocaleManager.set_locale("es")
	assert_eq(LocaleManager.current_locale, "es")
	assert_eq(TranslationServer.get_locale(), "es")


func test_supported_locales_en() -> void:
	LocaleManager.set_locale("en")
	assert_eq(LocaleManager.current_locale, "en")
	assert_eq(TranslationServer.get_locale(), "en")


func test_unsupported_locale_ignored() -> void:
	LocaleManager.set_locale("es")
	LocaleManager.set_locale("fr")
	# Debe mantener el locale anterior válido
	assert_eq(LocaleManager.current_locale, "es")


func test_auto_locale() -> void:
	LocaleManager.set_locale("auto")
	# Debe resolver a un locale soportado
	assert_true(LocaleManager.current_locale in ["es", "en"])


func test_get_locale_label_es() -> void:
	assert_eq(LocaleManager.get_locale_label("es"), "Español")


func test_get_locale_label_en() -> void:
	assert_eq(LocaleManager.get_locale_label("en"), "English")


func test_get_locale_label_auto() -> void:
	assert_eq(LocaleManager.get_locale_label("auto"), "Auto")


func test_settings_persisted_on_set_locale() -> void:
	LocaleManager.set_locale("en")
	assert_eq(Settings.language, "en")

	LocaleManager.set_locale("auto")
	assert_eq(Settings.language, "auto")


func test_csv_translations_loaded() -> void:
	# Al cargar, debe existir al menos la traducción al inglés para "Ajustes"
	var en_translation := TranslationServer.get_translation_object("en")
	assert_not_null(en_translation, "Debe existir traducción al inglés")

	TranslationServer.set_locale("en")
	var translated := tr("Ajustes")
	assert_ne(translated, "", "La traducción no debe ser vacía")


func test_translation_key_map() -> void:
	TranslationServer.set_locale("es")
	assert_eq(tr("MSG_FILE_NOT_FOUND"), "Archivo no encontrado")

	TranslationServer.set_locale("en")
	assert_eq(tr("MSG_FILE_NOT_FOUND"), "File not found")


func after_all() -> void:
	TranslationServer.set_locale("es")
