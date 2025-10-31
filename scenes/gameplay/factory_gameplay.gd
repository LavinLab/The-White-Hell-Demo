extends Control

@onready var hint_timer: Timer = $"../../HintTimer"
var current_hint = 0
var hints = ["demo_factory_pause_one", "demo_factory_pause_two", "demo_factory_pause_three"]

var lamp: bool = false


func _on_ui_on_hint_clicked() -> void:
	if visible:
		Globals.demo_vars["hint"] = false
		current_hint += 1
		if current_hint < hints.size():
			hint_timer.start()


func _on_hint_timer_timeout() -> void:
	if visible and current_hint < hints.size() and not Globals.demo_vars.get("hint", false) and Globals.hints:
		Globals.demo_vars["hint"] = true
		DialogSystem.add_indialog_var("inattentive_demo", "1")
		$"../../UI".show_hint(hints, current_hint)


func _on_apple_gui_input(event: InputEvent) -> void:
	if visible and event.is_action_pressed("click"):
		$Workbench/Apple.texture = load("res://assets/textures/job/details/apple_two.png")


func _on_rubik_cube_gui_input(event: InputEvent) -> void:
	if visible and event.is_action_pressed("click"):
		$Workbench/RubikCube.texture = load("res://assets/textures/job/details/cube_two.png")


func _on_lamp_gui_input(event: InputEvent) -> void:
	if visible and event.is_action_pressed("click"):
		lamp = not lamp
		if not lamp:
			$Workbench/Lamp.texture = load("res://assets/textures/job/details/lamp_one.png")
		else:
			$Workbench/Lamp.texture = load("res://assets/textures/job/details/lamp_two.png")


func _on_figure_gui_input(event: InputEvent) -> void:
	if visible and event.is_action_pressed("click"):
		$Workbench/Figure.texture = load("res://assets/textures/job/details/figure_two.png")
