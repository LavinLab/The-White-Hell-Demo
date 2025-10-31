extends Control

@onready var code_text: Label = $DoorEntranceClosed/Entered
@onready var code_list: Sprite2D = $CodeList
@onready var code_list_text: Label = $CodeList/CodeListText

var can_go_inside: bool = false

			
var first_code: bool = false
var second_code: bool = false
var third_code: bool = false
var fourth_code: bool = false
var fifth_code: bool = false
var last_code: bool = false

@onready var buttons: Array = [
	$DoorEntranceClosed/Numbers/Num1, 
	$DoorEntranceClosed/Numbers/Num2, 
	$DoorEntranceClosed/Numbers/Num3, 
	$DoorEntranceClosed/Numbers/Num4, 
	$DoorEntranceClosed/Numbers/Num5, 
	$DoorEntranceClosed/Numbers/Num6, 
	$DoorEntranceClosed/Numbers/Num7,
	$DoorEntranceClosed/Numbers/Num8,
	$DoorEntranceClosed/Numbers/Num9,
	$DoorEntranceClosed/Numbers/Num0
	]
	
var hint = false
var repl = true

var point_to_return: Array = []

@onready var hint_timer: Timer = $"../../HintTimer"
var current_hint = 0
var hints = ["demo_entrance_pause_one", "demo_entrance_pause_two", "demo_entrance_pause_three"]

func _ready() -> void:
	code_list.visible = false
	code_list_text.text = Globals.text_vars["demo_code_list_text"]
	for num in buttons:
		num.gui_input.connect(_on_num_gui_input.bind(num.text))

func show_code_list():
	code_list.visible = true
	var tween = create_tween()
	tween.tween_property(code_list, "position:y", 264, 0.7).set_trans(Tween.TRANS_ELASTIC)
	await tween.finished
	repl = false
	point_to_return.append(DialogSystem.selected_block)
	point_to_return.append(DialogSystem.current_ind)
	
func hide_code_list():
	var tween = create_tween()
	tween.tween_property(code_list, "position:y", 383, 0.7).set_trans(Tween.TRANS_ELASTIC)
	await tween.finished
	code_list.visible = false

func _on_num_gui_input(event: InputEvent, number: String) -> void:
	if visible and event.is_action_pressed("click") and not hint and not repl:
		if Globals.hints:
			hint_timer.stop()
			hint_timer.start()
		if code_text.text.length() < 4:
			code_text.text = code_text.text + number
		elif code_text.text == "Error":
			code_text.text = number

func return_back():
	DialogSystem.selected_block = point_to_return[0]
	DialogSystem.current_ind = point_to_return[1]
	code_text.text = ""
	repl = false
	if Globals.hints:
		hint_timer.start()
	
func open_door():
	DialogSystem.selected_block = point_to_return[0]
	DialogSystem.current_ind = point_to_return[1]
	code_text.text = ""
	$DoorEntranceClosed.texture = load("res://assets/textures/house/door_entrance_opened.png")
	can_go_inside = true
	hide_code_list()
	repl = false
	
func check_for_signalman():
	if first_code and second_code and third_code and fourth_code and fifth_code and last_code:
		$"../../UI".unlock_achievement("CgkIip_apLcbEAIQDQ")

func check_for_good_memory():
	if not first_code and not second_code and not third_code and not fourth_code and not fifth_code and not last_code:
		$"../../UI".unlock_achievement("CgkIip_apLcbEAIQDg")

func _on_num_k_gui_input(event: InputEvent) -> void:
	if visible and event.is_action_pressed("click") and not hint and not repl:
		hint_timer.stop()
		if code_text.text == "2121":
			repl = true
			check_for_good_memory()
			last_code = true
			DialogSystem.change_block("last_code")
		elif code_text.text == "189":
			repl = true
			first_code = true
			DialogSystem.change_block("first_code")
		elif code_text.text == "371":
			repl = true
			second_code = true
			DialogSystem.change_block("second_code")
		elif code_text.text == "238":
			repl = true
			third_code = true
			DialogSystem.change_block("third_code")
		elif code_text.text == "670":
			repl = true
			fourth_code = true
			DialogSystem.change_block("fourth_code")
		elif code_text.text == "0000":
			repl = true
			fifth_code = true
			DialogSystem.change_block("fifth_code")
		else:
			code_text.text = "Error"
		check_for_signalman()


func _on_num_c_gui_input(event: InputEvent) -> void:
	if visible and event.is_action_pressed("click") and not hint and not repl:
		if Globals.hints:
			hint_timer.stop()
			hint_timer.start()
		code_text.text = ""


func _on_go_inside_gui_input(event: InputEvent) -> void:
	if visible and event.is_action_pressed("click"):
		if can_go_inside:
			visible = false
			DialogSystem.move_next()
		else:
			#hint closed
			pass


func _on_hint_timer_timeout() -> void:
	if visible and not repl and current_hint < hints.size() and Globals.hints:
		hint = true
		DialogSystem.add_indialog_var("inattentive_demo", "1")
		$"../../UI".show_hint(hints, current_hint)


func _on_ui_on_hint_clicked() -> void:
	if visible:
		hint = false
		current_hint += 1
		if current_hint < hints.size():
			hint_timer.start()
