extends GutTest

func test_fileaccess_exists_for_filesystem_paths() -> void:
	var tmp_path := OS.get_user_data_dir().path_join("test_image.png")
	var handler := FileAccess.open(tmp_path, FileAccess.WRITE)
	if handler:
		handler.close()

	assert_true(FileAccess.file_exists(tmp_path), "FileAccess debe encontrar archivos del sistema")

	DirAccess.remove_absolute(tmp_path)
	assert_false(FileAccess.file_exists(tmp_path), "Debe detectar archivo eliminado")


func test_resource_loader_fails_for_filesystem_paths() -> void:
	# ResourceLoader.exists solo funciona con paths res:// o user://, no con paths absolutos
	var abs_path := "C:/nonexistent/test.png"
	assert_false(ResourceLoader.exists(abs_path), "ResourceLoader no debe aceptar paths del filesystem")


func test_image_load_from_absolute_path() -> void:
	# Crear un PNG minimo valido (1x1 pixel)
	var tmp_path := OS.get_user_data_dir().path_join("test_pixel.png")
	_create_minimal_png(tmp_path)

	var image := Image.new()
	var err := image.load(tmp_path)
	assert_eq(err, OK, "Image.load debe funcionar con paths del filesystem")

	DirAccess.remove_absolute(tmp_path)


func _create_minimal_png(path: String) -> void:
	# PNG minimo: 1x1 pixel blanco
	var img := Image.create(1, 1, false, Image.FORMAT_RGBA8)
	img.fill(Color.WHITE)
	img.save_png(path)
