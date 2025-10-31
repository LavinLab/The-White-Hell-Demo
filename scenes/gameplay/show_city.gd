extends Control

@onready var city_bg: Sprite2D = $CityBG

var current_ind = 0
@onready var hint_timer: Timer = $"../../HintTimer"
var current_hint = 0
var hints = ["demo_show_city_one", "demo_show_city_two", "demo_show_city_three"]
var hint = false

func change_city_bg():
	await $"../../UI".fade_in_solid(Color.BLACK, 0.6)
	current_ind += 1
	$CityBG/Steps.visible = false
	match current_ind:
		1:
			city_bg.texture = load("res://assets/textures/city/homeless.jpg")
		2:
			city_bg.texture = load("res://assets/textures/city/gangsters.jpg")
		3:
			city_bg.texture = load("res://assets/textures/city/addicted.jpg")
		4:
			city_bg.texture = load("res://assets/textures/city/whores.jpg")
	$"../../UI".fade_out_solid(0.6)



func show_steps():
	city_bg.texture = null
	if not current_ind == 0:
		await $"../../UI".fade_out_solid(0.6)
	match current_ind:
		0:
			$CityBG/Steps.visible = true
			$"../../AnimationPlayer".play("steps")
		1:
			$"../../AnimationPlayer".play("RESET")
			await $"../../AnimationPlayer".animation_finished
			$CityBG/Steps.visible = true
			$CityBG/Steps.position = Vector2(191, 164)
			$CityBG/Steps.rotation_degrees = -28.4
			$"../../AnimationPlayer".play("steps")
		2:
			$"../../AnimationPlayer".play("RESET")
			await $"../../AnimationPlayer".animation_finished
			$CityBG/Steps.visible = true
			$CityBG/Steps.position = Vector2(1, 5)
			$CityBG/Steps.rotation_degrees = -142.4
			$"../../AnimationPlayer".play("steps")
		3:
			$"../../AnimationPlayer".play("RESET")
			await $"../../AnimationPlayer".animation_finished
			$CityBG/Steps.visible = true
			$CityBG/Steps.position = Vector2(-27, 1)
			$CityBG/Steps.rotation_degrees = -62.8
			$"../../AnimationPlayer".play("steps")


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("click") and $CityBG.get_rect().has_point($CityBG.to_local(event.position)) and $CityBG.texture != null and visible and not hint and not $"../../UI/SolidColor".visible:
		if Globals.hints:
			hint_timer.stop()
			hint_timer.start()
		if current_ind < 4:
			await $"../../UI".fade_in_solid(Color.BLACK, 0.6)
			show_steps()
		elif current_ind == 5:
			visible = false
			hint_timer.stop()
			DialogSystem.move_next()
		else:
			await $"../../UI".fade_in_solid(Color.BLACK, 0.6)
			city_bg.texture = load("res://assets/textures/ui/twh_splash.png")
			await $"../../UI".fade_out_solid(0.6)
			current_ind += 1
		

func _on_hint_timer_timeout() -> void:
	if visible and current_hint < hints.size() and Globals.hints:
		hint = true
		DialogSystem.add_indialog_var("inattentive_demo", "1")
		$"../../UI".show_hint(hints, current_hint)


func _on_ui_on_hint_clicked() -> void:
	if visible:
		hint = false
		current_hint += 1
		if current_hint < hints.size():
			hint_timer.start()
