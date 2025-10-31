extends CanvasLayer

@onready var content: Control = $Content

@onready var end_label: Label = $Content/EndText
@onready var title_label: Label = $Content/TitleText
@onready var menu_button: Button = $Content/Menu

func _ready() -> void:
	content.modulate.a = 0
	DialogSystem.dialog_ended.connect(dialog_ended)
	
func dialog_ended():
	end_label.text = Globals.text_vars["end_text"]
	menu_button.text = Globals.text_vars["menu_button"]
	if $"..".name == "Demo":
		$"../UI".play_music("res://assets/audio/music/erik_satie_je_te_veux.ogg", false)
		title_label.text = Globals.text_vars["demo_titles"]
	var tween = create_tween()
	tween.tween_property(content, "modulate:a", 1, 1)


func _on_menu_pressed() -> void:
	get_tree().change_scene_to_packed(ResourceLoader.load_threaded_get("res://scenes/menu_and_splash/menu.tscn"))
