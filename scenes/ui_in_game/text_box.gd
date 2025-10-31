extends TextureRect

signal auto_play()
signal menu()

func _ready() -> void:
	$Buttons/Menu.text = Globals.text_vars["menu_button"]
	if OS.has_feature("mobile") or OS.has_feature("editor"):
		$Name.label_settings.font_size = 20
		$Text.label_settings.font_size = 14
		$Text.offset_top = -48
		$Text.offset_bottom = 49



func _on_menu_gui_input(event: InputEvent) -> void:
	if event.is_action_pressed("click"):
		menu.emit()


func _on_play_gui_input(event: InputEvent) -> void:
	if event.is_action_pressed("click"):
		auto_play.emit()
