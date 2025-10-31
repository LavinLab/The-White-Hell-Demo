extends Control

@onready var closed_door: Sprite2D = $ClosedDoor
@onready var opened_door: Sprite2D = $OpenedDoor
@onready var hint_timer: Timer = $"../../HintTimer"
var current_click = 0
var current_hint = 0
var hints = ["demo_knock_pause_one", "demo_knock_pause_two", "demo_knock_pause_three"]
var hint = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	opened_door.visible = false
	
# Called every frame. 'delta' is the elapsed time since the previous frame.



func _on_tap_zone_gui_input(event: InputEvent) -> void:
	if event.is_action_pressed("click") and visible and not hint:
		if Globals.hints:
			hint_timer.stop()
			hint_timer.start()
		match current_click:
			0:
				opened_door.visible = true
				closed_door.texture = load("res://assets/textures/job/cabinet.png")
				current_click += 1
			1:
				opened_door.visible = false
				visible = false
				hint_timer.stop()
				DialogSystem.move_next()
		


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


func _on_portrait_one_gui_input(event: InputEvent) -> void:
	if visible and event.is_action_pressed("click"):
		$PortraitOne.texture = load("res://assets/textures/job/details/portrait_one.png")


func _on_portrait_two_gui_input(event: InputEvent) -> void:
	if visible and event.is_action_pressed("click"):
		$PortraitTwo.texture = load("res://assets/textures/job/details/portrait_two.png")
