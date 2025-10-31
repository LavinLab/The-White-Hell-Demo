extends Control

@export var timer_dur = 2

func _ready() -> void:
	$SplashImage.modulate.a = 0
	var tween = create_tween()
	tween.tween_property($SplashImage, "modulate:a", 1, 0.5)
	$Timer.wait_time = timer_dur
	$Timer.start()


func _on_timer_timeout() -> void:
	var tween = create_tween()
	tween.tween_property($SplashImage, "modulate:a", 0, 0.5)
	await tween.finished
	get_tree().change_scene_to_file("res://scenes/menu_and_splash/menu.tscn")
