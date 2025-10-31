extends Node

func _ready() -> void:
	pass
	
func reset_dialog_data():
	dialog_data = {
		"current_ind": 0,
		"current_block": "start",
		"bg": "hide",
		"music": "stop",
		"dark": false
	}

var new_game_we_are_loading: String

const SHOP_NAME: String = "play_market"

var authed: bool = false

var first_opened = true

var started_game_time: int = 0

var time_in_game: int = 0:
	set(value):
		time_in_game = value
		SaveSystem.set_val("time_in_game", value)
	get:
		return SaveSystem.get_val("time_in_game", 0)

var music_volume: float = 1:
	set(value):
		music_volume = value
		SaveSystem.set_val("music_volume", value)
	get:
		return SaveSystem.get_val("music_volume", 1)
		
var sfx_volume: float = 1:
	set(value):
		sfx_volume = value
		SaveSystem.set_val("sfx_volume", value)
	get:
		return SaveSystem.get_val("sfx_volume", 1)
		
var language: String = OS.get_locale():
	set(value):
		language = value
		SaveSystem.set_val("language", value)
	get:
		return SaveSystem.get_val("language", OS.get_locale())
		
var hints: bool = true:
	set(value):
		hints = value
		SaveSystem.set_val("hints", value)
	get:
		return SaveSystem.get_val("hints", true)
		
var until_rate: int = 9:
	set(value):
		until_rate = value
		SaveSystem.set_val("until_rate", value)
	get:
		return SaveSystem.get_val("until_rate", 9)

var dialog_data: Dictionary = {
	"current_ind": 0,
	"current_block": "start",
	"bg": "hide",
	"music": "stop",
	"dark": false
}

var dialog_vars: Dictionary = {
	
}

var demo_vars: Dictionary = {}

func load_checkpoint(dialog_ind: int, checkpoint_key: String):
	var dialog_name = "dial" + str(dialog_ind)
	for point in SaveSystem.values[dialog_name]:
		if point["key"] == checkpoint_key:
			dialog_data = point["data"].duplicate(true)
			break

func checkpoint(dialog_ind: int, checkpoint_key: String):
	var dialog_name = "dial" + str(dialog_ind)
	var save_data = dialog_data.duplicate(true)
	if SaveSystem.values.has(dialog_name):
		var existing = false
		var ind: int = 0
		for current in SaveSystem.values[dialog_name].size():
			if SaveSystem.values[dialog_name][current]["key"] == checkpoint_key:
				existing = true
				ind = current
				break
		if not existing:
			SaveSystem.values[dialog_name].append({"key": checkpoint_key, "data": save_data})
			SaveSystem.save_data()
		else:
			SaveSystem.values[dialog_name][ind]["data"] = save_data
	else:
		SaveSystem.values[dialog_name] = [{"key": checkpoint_key, "data": save_data}]
		SaveSystem.save_data()

func set_dialog_data(key: String, value):
	dialog_data[key] = value
	
func get_dialog_data(key: String):
	return dialog_data.get(key)
	
func set_dialog_vars(key: String, value):
	dialog_vars[key] = value
	
func get_dialog_vars(key: String):
	return dialog_vars.get(key)

# lang_diff_vars

var text_vars: Dictionary = {}
