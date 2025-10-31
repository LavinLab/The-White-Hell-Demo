extends Control

var myself = false
var neighbour = false

var repl_one = false
var repl_two = false

var repliques = ["demo_electricity_not_our", "demo_electricity_needed_to_turn_on"]

var hint = false
var repl = false

@onready var hint_timer: Timer = $"../../HintTimer"
@onready var bulb_timer: Timer = $BulbTimer
var current_hint = 0
var hints = ["demo_electricity_pause_one", "demo_electricity_pause_two", "demo_electricity_pause_three"]
@onready var bulbs: Array = [
	$Electricity/Bulb1,
	$Electricity/Bulb2,
	$Electricity/Bulb5,
	$Electricity/Bulb6
]

var current_bulb: Sprite2D

var active_bulb_texture = load("res://assets/textures/house/active_bulb.png")
var inactive_bulb_texture = load("res://assets/textures/house/inactive_bulb.png")

func _ready() -> void:
	current_bulb = bulbs[randi() % bulbs.size()]
	

func _on_not_our_switch_gui_input(event: InputEvent) -> void:
	if visible and event.is_action_pressed("click") and not repl and not hint:
		hint_timer.stop()
		if not repl_one:
			DialogSystem.add_indialog_var("inattentive_demo", "1")
			repl_one = true
		$"../../UI".show_hint(repliques, 0)
		repl = true

func _on_switch_3_gui_input(event: InputEvent) -> void:
	if visible and event.is_action_pressed("click") and not repl and not hint:
		if Globals.hints:
			hint_timer.stop()
			hint_timer.start()
		$Electricity/Switches/Switch3.flip_v = not $Electricity/Switches/Switch3.flip_v
		myself = not myself
		$Electricity/Bulb3.texture = active_bulb_texture if myself else inactive_bulb_texture

func _on_switch_4_gui_input(event: InputEvent) -> void:
	if visible and event.is_action_pressed("click") and not repl and not hint:
		if Globals.hints:
			hint_timer.stop()
			hint_timer.start()
		$Electricity/Switches/Switch4.flip_v = not $Electricity/Switches/Switch4.flip_v
		neighbour = not neighbour
		$Electricity/Bulb4.texture = active_bulb_texture if neighbour else inactive_bulb_texture

func _on_ui_on_hint_clicked() -> void:
	if visible:
		if not repl:
			current_hint += 1
		hint = false
		repl = false
		if current_hint < hints.size():
			hint_timer.start()

func _on_hint_timer_timeout() -> void:
	if visible and current_hint < hints.size() and Globals.hints:
		hint = true
		DialogSystem.add_indialog_var("inattentive_demo", "1")
		$"../../UI".show_hint(hints, current_hint)

func _on_bulb_timer_timeout() -> void:
	if not visible:
		return
	
	if current_bulb.texture == active_bulb_texture:
		current_bulb.texture = inactive_bulb_texture
		bulb_timer.wait_time = randf_range(0.05, 0.3)
		bulb_timer.start()
	else:
		current_bulb.texture = active_bulb_texture
		bulb_timer.wait_time = randf_range(0.1, 1.5)
		current_bulb = bulbs[randi() % bulbs.size()]
		bulb_timer.start()

func _on_panel_gui_input(event: InputEvent) -> void:
	if visible and not repl and not hint and event.is_action_pressed("click"):
		$Electricity/Panel.visible = false


func _on_go_away_gui_input(event: InputEvent) -> void:
	if event.is_action_pressed("click") and visible and not repl and not hint:
		if myself:
			visible = false
			hint_timer.stop()
			if neighbour:
				DialogSystem.change_block("helped")
			else:
				DialogSystem.change_block("didnt_help")
		else:
			hint_timer.stop()
			if not repl_two:
				DialogSystem.add_indialog_var("inattentive_demo", "1")
				repl_two = true
			$"../../UI".show_hint(repliques, 1)
			repl = true
