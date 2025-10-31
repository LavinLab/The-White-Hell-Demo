extends Node2D

func _ready() -> void:
	ResourceLoader.load_threaded_request("res://scenes/menu_and_splash/menu.tscn")
	DialogSystem.connect("dialog_paused", dialog_paused)
	DialogSystem.connect("hide_nondialog", hide_everything)
	if Globals.language.begins_with("ru"):
		DialogSystem.start_dialog("res://dialogs/demo_ru.dialog", 1)
	elif Globals.language.begins_with("en"):
		DialogSystem.start_dialog("res://dialogs/demo_en.dialog", 1)
	elif Globals.language.begins_with("be"):
		DialogSystem.start_dialog("res://dialogs/demo_be.dialog", 1)
	else:
		DialogSystem.start_dialog("res://dialogs/demo_ru.dialog", 1)
	

@onready var gameplay_blocks: Array = [
	$Gameplay/Factory,
	$Gameplay/FactoryGameplay,
	$Gameplay/Oleg,
	$Gameplay/KnockPause, 
	$Gameplay/WentAwayPause, 
	$Gameplay/GopnikInGateWay, 
	$Gameplay/ShowCity, 
	$Gameplay/Shop,
	$Gameplay/Entrance,
	$Gameplay/Radio,
	$Gameplay/Electricity,
	$Gameplay/Writing
	]

func hide_everything():
	for game_moment in gameplay_blocks:
		game_moment.visible = false
	DialogSystem.move_next()



func dialog_paused(tag: String):
	if tag == "factory":
		$Gameplay/Factory.visible = true
		$Gameplay/Factory.come_closer()
	elif tag == "factory_gameplay":
		$Gameplay/Factory.visible = false
		$Gameplay/FactoryGameplay.visible = true
	elif tag == "oleg":
		$Gameplay/FactoryGameplay.visible = false
		$Gameplay/Oleg.visible = true
		DialogSystem.move_next()
	elif tag == "knock":
		$Gameplay/KnockPause.visible = true
	elif tag == "go_out":
		$Gameplay/WentAwayPause.visible = true
	elif tag == "gop_stop":
		$Gameplay/GopnikInGateWay.visible = true
		$Gameplay/GopnikInGateWay.fade_in_gopnik()
	elif tag == "murder":
		$Gameplay/GopnikInGateWay.fade_in_knife()
	elif tag == "show_city":
		$Gameplay/ShowCity.visible = true
		$Gameplay/ShowCity.show_steps()
	elif tag == "shop":
		$Gameplay/Shop.visible = true
	elif tag == "entrance":
		$Gameplay/Entrance.visible = true
		DialogSystem.move_next()
	elif tag == "entrance_return":
		$Gameplay/Entrance.return_back()
	elif tag == "entrance_open":
		$Gameplay/Entrance.open_door()
	elif tag == "show_list":
		$Gameplay/Entrance.show_code_list()
	elif tag == "radio":
		$Gameplay/Radio.visible = true
		DialogSystem.move_next()
	elif tag == "radio_listen":
		$Gameplay/Radio.repl = false
		$Gameplay/Radio.hint_type = $Gameplay/Radio.hint_types.RADIO_LISTEN
		$Gameplay/Radio.current_hint = 0
	elif tag == "radio_fix":
		$Gameplay/Radio.show_back()
		$Gameplay/Radio.repl = false
		$Gameplay/Radio.hint_type = $Gameplay/Radio.hint_types.RADIO_FIXING
		$Gameplay/Radio.current_hint = 0
	elif tag == "radio_fixing":
		$Gameplay/Radio.fix = true
		$Gameplay/Radio.repl = false
	elif tag == "radio_fixed":
		$Gameplay/Radio.repl = false
	elif tag == "electricity":
		$Gameplay/Electricity.visible = true
		$Gameplay/Electricity/BulbTimer.start()
	elif tag == "writing":
		$Gameplay/Writing.visible = true
		DialogSystem.move_next()
	elif tag == "writing_check":
		$Gameplay/Writing.repl = false
	if Globals.hints:
		$HintTimer.start()
