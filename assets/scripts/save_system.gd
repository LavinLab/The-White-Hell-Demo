extends Node

var PATH: String = ""
const PASSW: String = "twh25"

var values: Dictionary = {}

func _ready() -> void:
	initialize()

func initialize() -> void:
	# Определяем правильный путь для сохранения в зависимости от платформы
	var save_dir: String
	
	if OS.get_name() == "Android" or OS.get_name() == "iOS" or OS.get_name() == "Web" or OS.get_name() == "macOS" or OS.get_name() == "Linux":
		# Для мобильных платформ используем системную папку документов
		save_dir = "user://saves/"
	elif OS.has_feature("editor"):
		# В редакторе сохраняем в проект
		save_dir = "res://saves/"
	else:
		# В готовой сборке - рядом с исполняемым файлом
		save_dir = OS.get_executable_path().get_base_dir().path_join("saves/")
	
	# Создаем директорию если не существует
	if not DirAccess.dir_exists_absolute(save_dir):
		var err = DirAccess.make_dir_recursive_absolute(save_dir)
		if err != OK:
			push_error("Failed to create save directory: " + save_dir)
	
	PATH = save_dir.path_join("save.twh")
	load_data()

func load_data() -> void:
	if FileAccess.file_exists(PATH):
		var file = FileAccess.open_encrypted_with_pass(PATH, FileAccess.READ, PASSW)
		if file:
			values = file.get_var()
			file.close()
		else:
			var error = FileAccess.get_open_error()
			push_error("Failed to load save file. Error code: " + str(error))
	else:
		save_data()

func save_data() -> void:
	var file = FileAccess.open_encrypted_with_pass(PATH, FileAccess.WRITE, PASSW)
	if file:
		file.store_var(values)
		file.close()
	else:
		var error = FileAccess.get_open_error()
		push_error("Failed to save data. Error code: " + str(error))

func get_val(key: String, default = null):
	return values.get(key, default)

func set_val(key: String, value) -> void:
	values[key] = value
	save_data()
