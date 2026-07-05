extends Control

## DMWindow — ventana principal del DM. Placeholder para Fase 2.

func _ready() -> void:
	var bg := Panel.new()
	bg.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	var style := StyleBoxFlat.new()
	style.bg_color = Color("#1a1a2e")
	bg.add_theme_stylebox_override("panel", style)
	add_child(bg)

	var vbox := VBoxContainer.new()
	vbox.set_anchors_and_offsets_preset(Control.PRESET_CENTER)
	add_child(vbox)

	var label := Label.new()
	label.text = tr("DM Window — En construccion")
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.add_theme_font_size_override("font_size", 24)
	label.add_theme_color_override("font_color", Color("#e94560"))
	vbox.add_child(label)

	var info := Label.new()
	info.text = "Sesion: " + GameState.session_name
	info.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	info.add_theme_color_override("font_color", Color("#e0e0e0"))
	vbox.add_child(info)

	var back_btn := Button.new()
	back_btn.text = tr("Volver al Launcher")
	back_btn.pressed.connect(func(): get_tree().change_scene_to_file("res://scenes/ui/launcher.tscn"))
	vbox.add_child(back_btn)
