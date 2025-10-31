extends Control

var repl: bool = true
var screws: int = 4
var fix: bool = false
var current_ind: int = 0
var is_anim: bool = false

var hint = false

enum hint_types { RADIO_LISTEN, RADIO_FIXING }

var hint_type: hint_types = hint_types.RADIO_LISTEN

@onready var hint_timer: Timer = $"../../HintTimer"
var current_hint = 0
var hints_radio_listen = ["demo_radio_listen_pause_one", "demo_radio_listen_pause_two", "demo_radio_listen_pause_three"]
var hints_radio_fixing = ["demo_radio_fixing_pause_one", "demo_radio_fixing_pause_two", "demo_radio_fixing_pause_three"]

func _ready() -> void:
	for screw in $Dresser/RadioBack.get_children():
		screw.gui_input.connect(on_screw_clicked.bind(screw))

func _on_button_gui_input(event: InputEvent) -> void:
	if visible and event.is_action_pressed("click") and not repl and not hint:
		if current_ind == 3:
			hint_timer.stop()
			visible = false
		repl = true
		DialogSystem.move_next()
		
func show_back():
	$Dresser/Radio.visible = false
	$Dresser/RadioBack.visible = true

func on_screw_clicked(event: InputEvent, screw: TextureRect):
	if visible and event.is_action_pressed("click") and not hint and current_ind == 0 and not is_anim:
		if Globals.hints:
			hint_timer.stop()
			hint_timer.start()
		
		is_anim = true
		# Создаем анимацию уменьшения
		var tween = create_tween()
		tween.tween_property(screw, "scale", Vector2(0, 0), 0.3)\
			.set_ease(Tween.EASE_IN)\
			.set_trans(Tween.TRANS_BACK)
		tween.tween_callback(func(): 
			screw.visible = false
			screws -= 1
			is_anim = false
			if screws == 0:
				$Dresser/RadioBack.texture = load("res://assets/textures/house/radio_opened.png")
				repl = true
				DialogSystem.move_next()
		)

func _on_radio_back_gui_input(event: InputEvent) -> void:
	if visible and fix and event.is_action_pressed("click") and not repl and not hint and not is_anim:
		if current_ind == 0:
			current_ind += 1
			$Dresser/RadioBack.texture = load("res://assets/textures/house/radio_fixed.png")
			$"../../UI".unlock_achievement("CgkIip_apLcbEAIQEA")
			repl = true
			DialogSystem.move_next()
		elif current_ind == 1:
			current_ind += 1
			$Dresser/RadioBack.texture = load("res://assets/textures/house/radio_back.png")
		elif current_ind == 2:
			is_anim = true
			# Создаем общий tween для всех болтов
			var tween = create_tween()
			
			for screw in $Dresser/RadioBack.get_children():
				screw.scale = Vector2.ZERO
				screw.visible = true
				# Анимация появления
				tween.tween_property(screw, "scale", Vector2(0.213, 0.213), 0.5)\
					.set_ease(Tween.EASE_OUT)\
					.set_trans(Tween.TRANS_ELASTIC)
			await tween.finished
			is_anim = false
			current_ind += 1
		elif current_ind == 3:
			$Dresser/RadioBack.visible = false
			$Dresser/Radio.visible = true


func _on_ui_on_hint_clicked() -> void:
	if visible:
		hint = false
		current_hint += 1
		if hint_type == hint_types.RADIO_LISTEN:
			if current_hint < hints_radio_listen.size():
				hint_timer.start()
		elif hint_type == hint_types.RADIO_FIXING:
			if current_hint < hints_radio_fixing.size():
				hint_timer.start()
		


func _on_hint_timer_timeout() -> void:
	if visible and current_hint < 3 and not repl and screws > 0 and Globals.hints:
		hint = true
		DialogSystem.add_indialog_var("inattentive_demo", "1")
		if hint_type == hint_types.RADIO_LISTEN:
			$"../../UI".show_hint(hints_radio_listen, current_hint)
		elif hint_type == hint_types.RADIO_FIXING:
			$"../../UI".show_hint(hints_radio_fixing, current_hint)
