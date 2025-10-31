extends Control

@export var timer_dur = 6

func _ready() -> void:
	modulate.a = 0
	$DisclaimerBlock/DisclaimerName.text = Globals.text_vars["disclaimer"]
	$DisclaimerBlock/DisclaimerText.text = Globals.text_vars["disclaimer_text"]
	var tween = create_tween()
	tween.tween_property(self, "modulate:a", 1, 0.5)
	$DisclaimerTimer.wait_time = timer_dur
	$DisclaimerTimer.start()


func _on_timer_timeout() -> void:
	var tween = create_tween()
	tween.tween_property(self, "modulate:a", 0, 0.5)
	await tween.finished
	get_tree().change_scene_to_file("res://scenes/menu_and_splash/splash.tscn")


func _on_gui_input(event: InputEvent) -> void:
	if event.is_action_pressed("click"):
		_on_timer_timeout()
