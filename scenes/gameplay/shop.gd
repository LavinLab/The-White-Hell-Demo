extends Control

@onready var shop_list_text: Label = $ShopList/ShopListText
@onready var shop_text: RichTextLabel = $ShopList/ShopText
@onready var restart_button: Button = $ShopList/Restart

@onready var hint_timer: Timer = $"../../HintTimer"
var current_hint = 0
var hints = ["demo_shop_pause_one", "demo_shop_pause_two", "demo_shop_pause_three"]

@export var beer_count = 3:
	set(value):
		beer_count = max(0, value)  # Ensure it doesn't go below 0
		update_shop_text()
@export var candy_count = 2:
	set(value):
		candy_count = max(0, value)  # Ensure it doesn't go below 0
		update_shop_text()
@export var bread_count = 1:
	set(value):
		bread_count = max(0, value)  # Ensure it doesn't go below 0
		update_shop_text()
		
@export var product_count = 45:
	set(value):
		product_count = max(0, value)  # Ensure it doesn't go below 0
		update_shop_text()

var not_passed = false

func _ready() -> void:
	shop_list_text.text = Globals.text_vars["demo_shop_list_text"]
	update_shop_text()
	
func update_shop_text():
	var first_part = Globals.text_vars["demo_shop_list_one"] + " x3" + "\n"
	var second_part = Globals.text_vars["demo_shop_list_two"] + "\n"
	var third_part = Globals.text_vars["demo_shop_list_three"] + " x2"
	
	# Only strike through when count reaches 0
	if not not_passed:
		first_part = "[s]" + first_part + "[/s]" if beer_count <= 0 else first_part
		second_part = "[s]" + second_part + "[/s]" if bread_count <= 0 else second_part
		third_part = "[s]" + third_part + "[/s]" if candy_count <= 0 else third_part
	
	shop_text.text = first_part + second_part + third_part
	
	
	if beer_count <= 0 and candy_count <= 0 and bread_count <= 0 and not not_passed:
		visible = false
		hint_timer.stop()
		DialogSystem.change_block("shop_took_needed")
	elif product_count <= 0:
		$"../../UI".unlock_achievement("CgkIip_apLcbEAIQAQ")


func _on_restart_pressed() -> void:
	Globals.load_checkpoint(1, "demo_shop")
	Globals.demo_vars = {}
	get_tree().change_scene_to_file("res://scenes/acts/demo.tscn")


func _on_ui_on_hint_clicked() -> void:
	if visible:
		Globals.demo_vars["hint"] = false
		current_hint += 1
		if current_hint < hints.size():
			hint_timer.start()
	

func _on_hint_timer_timeout() -> void:
	if visible and current_hint < hints.size() and Globals.hints:
		Globals.demo_vars["hint"] = true
		DialogSystem.add_indialog_var("inattentive_demo", "1")
		$"../../UI".show_hint(hints, current_hint)
