extends Node

signal dialog_paused(tag: String)
signal dialog_ended()
signal dialog_going()
signal play_music(music_path: String, move: bool)
signal change_bg(bg_path: String, anim: bool, move: bool)
signal show_date(date_text: String)
signal wait(seconds: float)
signal set_theme(dark: bool, move: bool)
signal give_achievement(id: String)
signal hide_nondialog()

var current_bg = "hide"
var current_music = "stop"
var current_theme = false

const CACHE_PATH: String = "user://dialogs_cache"

var dialog_ind: int
var current_ind = 0:
	set(value):
		if blocks.has(selected_block):
			if value < blocks[selected_block].size():
				current_ind = value
				
var selected_block: String:
	set(value):
		selected_block = value
var blocks: Dictionary = {}
var _regex: RegEx



func _init():
	_regex = RegEx.new()
	_regex.compile("{(.*?)}")

# Заменяет все переменные в строке на их значения из Globals
func replace_globals(text: String) -> String:
	var result = text
	for match_text in _regex.search_all(text):
		var var_name = match_text.get_string(1).strip_edges()
		result = result.replace("{" + var_name + "}", Globals.get_dialog_vars(var_name))
	return result

func start_dialog(dialog_path: String, ind: int):
	dialog_ind = ind
	var file = FileAccess.open(dialog_path, FileAccess.READ)
	if not file:
		push_error("Failed to open dialog file: " + dialog_path)
		return {}
	
	var text = file.get_as_text()
	file.close()
	blocks = parse_dialog(text)
	selected_block = Globals.get_dialog_data("current_block")
	current_ind = Globals.get_dialog_data("current_ind")
	#print(current_ind)
	current_bg = Globals.get_dialog_data("bg")
	current_music = Globals.get_dialog_data("music")
	current_theme = Globals.get_dialog_data("dark")
	play_music.emit(replace_globals(current_music), false)
	change_bg.emit(replace_globals(current_bg), true, false)
	set_theme.emit(current_theme, false)
	#print(blocks)
	emit_check()
	
func get_current_name() -> String:
	return blocks[selected_block][current_ind]["name"]
	
func get_current_text() -> String:
	return blocks[selected_block][current_ind]["text"]
	
func get_current_choises():
	if blocks[selected_block][current_ind].has("choises"):
		return blocks[selected_block][current_ind]["choises"]
	else:
		return false
		
func change_block(block_name: String):
	if blocks.has(block_name):
		if blocks[block_name].size() == 0:
			dialog_ended.emit()
			return
	if block_name == "that" and current_ind == blocks[selected_block].size() - 1:
		dialog_ended.emit()
		return
	elif block_name == "that":
		current_ind += 1
		emit_check()
	else:
		selected_block = block_name
		current_ind = 0
		emit_check()
			
	
func move_next():
	if blocks[selected_block].size() == 0:
		dialog_ended.emit()
		return
	var current_part = blocks[selected_block][current_ind]
	if current_part.has("next_br"):
		if not blocks[current_part["next_br"]].size() == 0:
			selected_block = current_part["next_br"]
			current_ind = 0
			emit_check()
		else:
			dialog_ended.emit()
			return
	elif current_ind == blocks[selected_block].size() - 1:
		dialog_ended.emit()
		return
	else:
		current_ind += 1
		#print(selected_block, " ", current_ind)
		emit_check()
	
func emit_check():
	var current_part = blocks[selected_block][current_ind]
	#print("here ", current_part["type"])
	match current_part["type"]:
		"show":
			if current_part["name"] == "date":
				show_date.emit(replace_globals(current_part["text"]))
			elif current_part["name"] == "bg":
				current_bg = current_part["text"].split(",")[0].strip_edges()
				var anim = current_part["text"].split(",")[1].strip_edges() == "anim" if true else false
				change_bg.emit(replace_globals(current_bg), anim, true)
		"set_val":
			set_indialog_var(current_part["name"], current_part["value"])
			move_next()
		"add_val":
			add_indialog_var(current_part["name"], current_part["add_value"])
			move_next()
		"checkpoint":
			#print("check")
			Globals.set_dialog_data("current_ind", current_ind)
			Globals.set_dialog_data("current_block", selected_block)
			Globals.set_dialog_data("bg", current_bg)
			Globals.set_dialog_data("music", current_music)
			Globals.set_dialog_data("dark", current_theme)
			Globals.checkpoint(dialog_ind, current_part["name"])
			move_next()
		"play":
			current_music = current_part["path"]
			play_music.emit(replace_globals(current_part["path"]), true)
		"pause":
			dialog_paused.emit(current_part["tag"])
		"hide":
			hide_nondialog.emit()
		"set_theme":
			current_theme = current_part["dark"]
			set_theme.emit(current_part["dark"], true)
		"wait":
			wait.emit(current_part["seconds"])
		"change":
			change_block(current_part["block"])
		"achievement":
			give_achievement.emit(current_part["id"])
			move_next()
		"repl":
			dialog_going.emit()
			
func set_indialog_var(key: String, value: String):
	if value.is_valid_int():
		Globals.set_dialog_vars(key, int(value))
	elif value.is_valid_float():
		Globals.set_dialog_vars(key, float(value))
	else:
		Globals.set_dialog_vars(key, value.trim_prefix("\"").trim_suffix("\""))
			
func add_indialog_var(key: String, add_value: String):
	if add_value.is_valid_int():
		if Globals.dialog_vars.get(key) == null:
			Globals.dialog_vars[key] = int(add_value)
		else:
			Globals.dialog_vars[key] += int(add_value)
	if dialog_ind == 1:
		if Globals.dialog_vars.get("said_nothing_demo") == 14:
			give_achievement.emit("CgkIip_apLcbEAIQDw")
		if Globals.dialog_vars.get("inattentive_demo") == 32:
			give_achievement.emit("CgkIip_apLcbEAIQEQ")

func parse_dialog(text: String) -> Dictionary:
	var parsed_blocks := {}
	var current_block := ""
	var lines := text.split("\n", false)
	
	for i in lines.size():
		var line := lines[i].strip_edges()
		if line.is_empty() or line.begins_with("#"):
			continue
		
		# Обработка блоков [block_name]
		if line.begins_with("[") && line.ends_with("]"):
			current_block = line.substr(1, line.length() - 2)
			parsed_blocks[current_block] = []
			continue
		
		# Пропускаем строки вне блоков
		if current_block.is_empty():
			continue
			
		if line.begins_with("show"):
			var dict = {
				"type": "show"
			}
			var item_info = line.trim_prefix("show").strip_edges().split("(")
			var item_name = item_info[0].strip_edges()
			var item_text = item_info[1].trim_suffix(")").strip_edges()
			dict["name"] = item_name
			dict["text"] = item_text
			parsed_blocks[current_block].append(dict)
		elif "+=" in line:
			var dict = {
				"type": "add_val"
			}
			var eval_info = line.split("+=")
			var eval_name = eval_info[0].strip_edges()
			var eval_value = eval_info[1].strip_edges()
			dict["name"] = eval_name
			dict["add_value"] = eval_value
			parsed_blocks[current_block].append(dict)
		elif "=" in line:
			var dict = {
				"type": "set_val"
			}
			var eval_info = line.split("=")
			var eval_name = eval_info[0].strip_edges()
			var eval_value = eval_info[1].strip_edges()
			dict["name"] = eval_name
			dict["value"] = eval_value
			parsed_blocks[current_block].append(dict)
		elif line.to_lower().begins_with("pause"):
			var dict = {
				"type": "pause"
			}
			var pause_tag = line.trim_prefix("pause").strip_edges()
			dict["tag"] = pause_tag
			parsed_blocks[current_block].append(dict)
		elif line.to_lower().begins_with("checkpoint"):
			var checkpoint_name = line.trim_prefix("checkpoint").strip_edges()
			parsed_blocks[current_block].append({
				"type": "checkpoint",
				"name": checkpoint_name
			})
		elif line.to_lower().begins_with("achievement"):
			var achievement_id = line.trim_prefix("achievement").strip_edges()
			parsed_blocks[current_block].append({
				"type": "achievement",
				"id": achievement_id
			})
		elif line.to_lower().begins_with("change"):
			var new_block = line.trim_prefix("change").strip_edges()
			parsed_blocks[current_block].append({
				"type": "change",
				"block": new_block
			})
		elif line.to_lower().begins_with("set_theme"):
			var theme_name = line.trim_prefix("set_theme").strip_edges()
			parsed_blocks[current_block].append({
				"type": "set_theme",
				"dark": theme_name == "dark" if true else false
			})
		elif line.to_lower().begins_with("wait"):
			var wait_time = float(line.trim_prefix("wait").strip_edges().trim_suffix("s"))
			parsed_blocks[current_block].append({
				"type": "wait",
				"seconds": wait_time
			})
		elif line.to_lower().begins_with("play"):
			parsed_blocks[current_block].append({
				"type": "play",
				"path": line.trim_prefix("play(").trim_suffix(")").strip_edges()
			})
		elif line.begins_with("hide"):
			parsed_blocks[current_block].append({"type": "hide"})
		elif ":" in line:
			var parts := line.split(":", true, 1)
			var name_str := parts[0].strip_edges()
			var content := parts[1].strip_edges()
			
			var dict := {
				"type": "repl",
				"name": name_str,
				"text": content
			}
			
			# Извлечение перехода (next_br)
			if "(" in content:
				var parts2 := content.split("(", true, 1)
				dict["text"] = parts2[0].strip_edges()
				dict["next_br"] = parts2[1].trim_suffix(")").strip_edges()
			
			# Обработка вариантов ответа
			var choices := []
			var j := i + 1
			while j < lines.size():
				var choice_line := lines[j].strip_edges()
				if choice_line.begins_with("->"):
					var choice_text := choice_line.substr(2).strip_edges()
					var choice_dict := {"text": choice_text}
					
					# Извлечение перехода для варианта
					if "(" in choice_text && choice_text.ends_with(")"):
						var choice_parts := choice_text.split("(", true, 1)
						choice_dict["text"] = choice_parts[0].strip_edges()
						if "," not in choice_parts[1].trim_suffix(")").strip_edges():
							choice_dict["next_br"] = choice_parts[1].trim_suffix(")").strip_edges()
						else:
							var choice_data = choice_parts[1].trim_suffix(")").strip_edges().split(",")
							choice_dict["next_br"] = choice_data[0].strip_edges()
							choice_dict["wait_time"] = int(choice_data[1].strip_edges().trim_suffix("s"))
					
					choices.append(choice_dict)
					j += 1
				else:
					break
			
			# Заменяем переменные во всех текстовых элементах
			dict["text"] = replace_globals(dict["text"])
			
			if not choices.is_empty():
				for choice in choices:
					choice["text"] = replace_globals(choice["text"])
				dict["choises"] = choices
			
			parsed_blocks[current_block].append(dict)

	return parsed_blocks
