extends Control


var act_names: Array[String]
var act_descs: Array[String]
@export_category("Page characteristics")
@export var hover_height: int = 8
@export var hover_duration: float = 0.2

var load_save_button: PackedScene = preload("res://scenes/menu_and_splash/load_save_button.tscn")

# Используем backing variable для избежания рекурсии
var current_page: int = 0:
	set(value):
		if ((value >= 0 and value <= act_names.size()) or value == -1) and value != current_page :
			current_page = value
			update_page()
	get:
		return current_page

# Словарь для отслеживания текущих анимаций закладок
var _bookmark_tweens: Dictionary = {}

@onready var act_name: Label = $OpenedDiary/Act/ActName
@onready var act_desc: Label = $OpenedDiary/Act/ActDesc

@onready var settings: Control = $OpenedDiary/Settings
@onready var act: Control = $OpenedDiary/Act
@onready var saves_list: Control = $OpenedDiary/SavesList
@onready var checkpoint_container: VBoxContainer = $OpenedDiary/SavesList/MarginContainer/ScrollContainer/VBoxContainer
@onready var music_volume_slider: HSlider = $OpenedDiary/Settings/Sound/SoundVolumeSlider
@onready var sfx_volume_slider: HSlider = $OpenedDiary/Settings/Sound/SFXVolumeSlider
@onready var play_button: Button = $OpenedDiary/Act/PlayButton
@onready var sfx: AudioStreamPlayer = $SFX
@onready var settings_label: Label = $OpenedDiary/Settings/SettingsLabel
@onready var music_volume_text: Label = $OpenedDiary/Settings/Sound/SoundVolume
@onready var saves_text: Label = $OpenedDiary/Settings/SaveDataManage/Saves
@onready var wipe_all_button: Button = $OpenedDiary/Settings/SaveDataManage/WipeAll
@onready var languages_text: Label = $OpenedDiary/Settings/Language/Languages
@onready var inact_saves_text: Label = $OpenedDiary/SavesList/SavesText
@onready var hints: Label = $OpenedDiary/Settings/Hints/Hints
@onready var hints_text: Label = $OpenedDiary/Settings/Hints/HintsText
@onready var hints_recomended: Label = $OpenedDiary/Settings/Hints/Recomended
@onready var hints_toggle: CheckBox = $OpenedDiary/Settings/Hints/HintsCheckBox
@onready var cloud_saves: Control = $OpenedDiary/Settings/CloudSave
@onready var cloud_saves_text: Label = $OpenedDiary/Settings/CloudSave/CloudSave
@onready var snapshots_handler: PlayGamesSnapshotsClient = $PlayGamesSnapshotsClient
@onready var achievements_handler: PlayGamesAchievementsClient = $PlayGamesAchievementsClient
@onready var achievements: Control = $OpenedDiary/Settings/Achievements
@onready var achievements_text: Label = $OpenedDiary/Settings/Achievements/Achievements
@onready var achievements_open: Button = $OpenedDiary/Settings/Achievements/OpenAchievements
@onready var cloud_saves_open: Button = $OpenedDiary/Settings/CloudSave/OpenSaves
@onready var save_name: LineEdit = $OpenedDiary/Settings/CloudSave/SaveName
@onready var save_button: Button = $OpenedDiary/Settings/CloudSave/Save
@onready var input_field_for_mobile: TextureRect = $TextFieldForMobile
@onready var text_field_for_mobile: Label = $TextFieldForMobile/TextInputed
var hover_sound: AudioStreamOggVorbis = preload("res://assets/audio/SFX/bookmark_hover.ogg")
var play_sound: AudioStreamOggVorbis = preload("res://assets/audio/SFX/play_clicked.ogg")
var bookmark_click_sound: AudioStreamOggVorbis = preload("res://assets/audio/SFX/bookmark_clicked.ogg")

func _ready() -> void:
	
	ResourceLoader.load_threaded_request("res://scenes/acts/demo.tscn")
	
	set_lang()
	# Инициализация состояний
	reset_diary_state()
	if Globals.authed:
		if Globals.first_opened:
			Globals.first_opened = false
			Globals.started_game_time = Time.get_ticks_msec()
	# Сохраняем исходные позиции всех закладок
	for i in range($Bookmarks.get_child_count()):
		var bookmark = $Bookmarks.get_child(i)
		bookmark.set_meta("original_position", bookmark.position)

func next_page() -> void:
	if current_page == act_names.size():
		current_page = -1
	else:
		current_page += 1
	
func prev_page() -> void:
	if current_page == -1:
		current_page = act_names.size()
	else:
		current_page -= 1

func update_page() -> void:
	# Создаем плавное затемнение
	var fade_in = create_tween()
	fade_in.tween_property($WhiteScreen, "modulate:a", 1, 0.3).from(0)
	await fade_in.finished
	
	# Обновление состояния дневника
	update_diary_visibility()
	
	update_page_content()
	
	# Плавное убирание затемнения
	var fade_out = create_tween()
	fade_out.tween_property($WhiteScreen, "modulate:a", 0, 0.3).from(1)
	
func set_lang():
	act_names.clear()
	act_descs.clear()
	$ExitButton.text = Globals.text_vars["exit_button"]
	act_names.append(Globals.text_vars["demo_act"])
	act_descs.append(Globals.text_vars["demo_act_desc"])
	save_name.placeholder_text = Globals.text_vars["name_of_save"]
	save_button.text = Globals.text_vars["save_button"]
	cloud_saves_text.text = Globals.text_vars["cloud_saves"]
	cloud_saves_open.text = Globals.text_vars["saves_list"]
	achievements_text.text = Globals.text_vars["achievements"]
	achievements_open.text = Globals.text_vars["achievements_list"]
	settings_label.text = Globals.text_vars["settings"]
	music_volume_text.text = Globals.text_vars["sound_volume"]
	saves_text.text = Globals.text_vars["saves_in_settings"]
	wipe_all_button.text = Globals.text_vars["wipe_all"]
	languages_text.text = Globals.text_vars["lang"]
	inact_saves_text.text = Globals.text_vars["saves"]
	hints.text = Globals.text_vars["hints"]
	hints_text.text = Globals.text_vars["hints_text"]
	hints_recomended.text = Globals.text_vars["recomended"]

func set_page(page: int) -> void:
	current_page = page

func reset_diary_state() -> void:
	"""Сброс состояния дневника к начальному"""
	if Globals.SHOP_NAME == "play_market" and Globals.authed:
		cloud_saves.visible = true
		achievements.visible = true
	else:
		cloud_saves.visible = false
		achievements.visible = false
	$ClosedDiary.visible = true
	$OpenedDiary.visible = false
	$Bookmarks.visible = false
	$BGMusic.volume_linear = Globals.music_volume
	music_volume_slider.value = Globals.music_volume
	sfx.volume_linear = Globals.sfx_volume
	sfx_volume_slider.value = Globals.sfx_volume
	hints_toggle.button_pressed = Globals.hints
	if not Globals.hints:
		hints_recomended.visible = false
	else:
		hints_recomended.visible = true
	if OS.has_feature("mobile") or OS.has_feature("web"):
		$ExitButton.visible = false

func update_diary_visibility() -> void:
	"""Обновление видимости элементов дневника"""
	var is_cover = current_page == 0
	$ClosedDiary.visible = is_cover
	$OpenedDiary.visible = !is_cover
	$Bookmarks.visible = !is_cover

func update_page_content() -> void:
	"""Обновление текстового содержимого страницы"""
	# Защита от выхода за границы массива
	if current_page == -1:
		settings.visible = true
		act.visible = false
		saves_list.visible = false
	elif current_page >= 1:
		settings.visible = false
		act.visible = true
		#since there is no first act
		play_button.visible = true
		var dialog_name = "dial" + str(current_page)
		
		if SaveSystem.values.has(dialog_name):
			for point_button in checkpoint_container.get_children():
				point_button.queue_free()
			saves_list.visible = true
			play_button.text = Globals.text_vars["continue"]
			for ind in SaveSystem.values[dialog_name].size():
				var point = SaveSystem.values[dialog_name][ind]
				var current_point = load_save_button.instantiate()
				current_point.text = str(ind + 1) + ". " + Globals.text_vars[point["key"]]
				current_point.pressed.connect(on_checkpoint_clicked.bind(point["key"]))
				checkpoint_container.add_child(current_point)
		else:
			saves_list.visible = false
			play_button.text = Globals.text_vars["new_game"]
		
		#since there is no first act
		if current_page == 2:
			play_button.visible = false
		
		var page_index = current_page - 1
		if page_index < act_names.size():
			act_name.text = act_names[page_index]
		if page_index < act_descs.size():
			act_desc.text = act_descs[page_index]
			
func on_checkpoint_clicked(point_key: String):
	Globals.load_checkpoint(current_page, point_key)
	load_act_scene(false)
	

func hover_bookmark(index: int, is_hovering: bool) -> void:
	"""Анимация поднятия/опускания закладки (только для ПК)"""
	# На мобильных устройствах отключаем анимацию при наведении
	if OS.has_feature("mobile"):
		return
	
	var bookmark = $Bookmarks.get_child(index)
	
	# Останавливаем предыдущую анимацию для этой закладки
	if _bookmark_tweens.has(index):
		_bookmark_tweens[index].kill()
		_bookmark_tweens.erase(index)
	
	# Получаем целевую позицию
	var original_pos = bookmark.get_meta("original_position")
	var target_pos = original_pos
	if is_hovering:
		target_pos.y -= hover_height
	
	# Создаем новую анимацию
	var tween = create_tween()
	tween.set_ease(Tween.EASE_OUT)
	tween.set_trans(Tween.TRANS_QUAD)
	tween.tween_property(bookmark, "position", target_pos, hover_duration)

# Сигнальные обработчики
func _on_bookmark_gui_input(event: InputEvent, page: int) -> void:
	if event.is_action_pressed("click"):
		sfx.stream = bookmark_click_sound
		sfx.play()
		set_page(page)

func _on_closed_diary_gui_input(event: InputEvent) -> void:
	if event.is_action_pressed("click"):
		next_page()

func _on_back_gui_input(event: InputEvent) -> void:
	if event.is_action_pressed("click"):
		prev_page()

func _on_forward_gui_input(event: InputEvent) -> void:
	if event.is_action_pressed("click"):
		next_page()

func _on_bookmark_mouse_entered(index: int) -> void:
	sfx.stream = hover_sound
	sfx.play()
	hover_bookmark(index, true)

func _on_bookmark_mouse_exited(index: int) -> void:
	hover_bookmark(index, false)

func _on_exit_button_pressed() -> void:
	get_tree().quit()


func _on_sound_volume_slider_value_changed(value: float) -> void:
	Globals.music_volume = value
	$BGMusic.volume_linear = Globals.music_volume

func load_act_scene(new_game: bool):
	if current_page == 1:
		Globals.demo_vars = {}
		if not new_game:
			get_tree().change_scene_to_packed(ResourceLoader.load_threaded_get("res://scenes/acts/demo.tscn"))
		else:
			Globals.new_game_we_are_loading = "res://scenes/acts/demo.tscn"
			get_tree().change_scene_to_file("res://scenes/menu_and_splash/hints_propose.tscn")

func _on_play_button_pressed() -> void:
	var dialog_name = "dial" + str(current_page)
	if SaveSystem.values.has(dialog_name):
		Globals.load_checkpoint(current_page, SaveSystem.values[dialog_name][SaveSystem.values[dialog_name].size() - 1]["key"])
		load_act_scene(false)
	else:
		load_act_scene(true)


func _on_wipe_all_pressed() -> void:
	Globals.reset_dialog_data()
	SaveSystem.values = {}
	SaveSystem.save_data()
	music_volume_slider.value = Globals.music_volume
	sfx_volume_slider.value = Globals.sfx_volume
	hints_toggle.button_pressed = Globals.hints
	hints_recomended.visible = true
	LangParser.change_lang()
	set_lang()


func _on_sfx_volume_slider_value_changed(value: float) -> void:
	Globals.sfx_volume = value
	sfx.volume_linear = Globals.sfx_volume


func _on_wipe_act_saves_gui_input(event: InputEvent) -> void:
	if event.is_action_pressed("click"):
		Globals.reset_dialog_data()
		sfx.stream = hover_sound
		sfx.play()
		var ind = current_page
		while true:
			var dialog_name = "dial" + str(ind)
			if SaveSystem.values.has(dialog_name):
				SaveSystem.values.erase(dialog_name)
				SaveSystem.save_data()
			else:
				break
			ind += 1
		saves_list.visible = false
		play_button.text = Globals.text_vars["new_game"]


func _on_russian_pressed() -> void:
	Globals.language = "ru"
	LangParser.change_lang()
	set_lang()

func _on_english_pressed() -> void:
	Globals.language = "en"
	LangParser.change_lang()
	set_lang()


func _on_belorussian_pressed() -> void:
	Globals.language = "be"
	LangParser.change_lang()
	set_lang()


func _on_telegram_button_gui_input(event: InputEvent) -> void:
	if event.is_action_pressed("click"):
		OS.shell_open("https://t.me/Lavin_Lab")


func _on_hints_check_box_toggled(toggled_on: bool) -> void:
	Globals.hints = toggled_on
	if not toggled_on:
		hints_recomended.visible = false
	else:
		hints_recomended.visible = true


func _on_open_saves_pressed() -> void:
	snapshots_handler.show_saved_games("Saved Games", false, true, PlayGamesSnapshot.DISPLAY_LIMIT_NONE)


func _on_save_pressed() -> void:
	Globals.time_in_game += Time.get_ticks_msec() - Globals.started_game_time
	Globals.started_game_time = Time.get_ticks_msec()
	snapshots_handler.save_game(save_name.text, save_name.text, var_to_str(SaveSystem.values).to_utf8_buffer(), Globals.time_in_game)


func _on_play_games_snapshots_client_game_saved(is_saved: bool, _save_data_name: String, _save_data_description: String) -> void:
	if is_saved:
		save_name.text = ""
		text_field_for_mobile.text = ""


func _on_play_games_snapshots_client_game_loaded(snapshot: PlayGamesSnapshot) -> void:
	SaveSystem.values = str_to_var(snapshot.content.get_string_from_utf8())
	SaveSystem.save_data()
	music_volume_slider.value = Globals.music_volume
	sfx_volume_slider.value = Globals.sfx_volume
	hints_toggle.button_pressed = Globals.hints
	if hints:
		hints_recomended.visible = true
	else:
		hints_recomended.visible = false
	LangParser.change_lang()
	set_lang()


func _on_open_achievements_pressed() -> void:
	# reloads every time
	achievements_handler.show_achievements()

func _process(_delta: float) -> void:
	if DisplayServer.has_feature(DisplayServer.FEATURE_VIRTUAL_KEYBOARD):
		if DisplayServer.virtual_keyboard_get_height() > 0:
			input_field_for_mobile.visible = true
		else:
			input_field_for_mobile.visible = false

func _on_save_name_text_changed(new_text: String) -> void:
	if input_field_for_mobile.visible:
		text_field_for_mobile.text = new_text
