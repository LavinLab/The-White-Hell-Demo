extends Node

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	change_lang()

func change_lang():
	Globals.text_vars.clear()
	if Globals.language.begins_with("ru"):
		parse_lang_file("res://languages/ru.lang")
	elif Globals.language.begins_with("en"):
		parse_lang_file("res://languages/en.lang")
	elif Globals.language.begins_with("be"):
		parse_lang_file("res://languages/be.lang")
	else:
		parse_lang_file("res://languages/ru.lang")

func parse_lang_file(file_path: String):
	var file = FileAccess.open(file_path, FileAccess.READ)
	var text = file.get_as_text()
	file.close()
	for line in text.split("\n"):
		if "=" in line:
			var var_info = line.split("=")
			Globals.text_vars[var_info[0].strip_edges()] = var_info[1].strip_edges()
		else:
			continue
