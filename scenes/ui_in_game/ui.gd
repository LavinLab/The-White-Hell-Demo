extends CanvasLayer

class_name UI

signal on_hint_clicked()

@onready var BG: TextureRect = $BG
@onready var music_player: AudioStreamPlayer = $Music
@onready var date: Label = $Date
@onready var text_box: TextureRect = $TextBox
@onready var choises: TextureRect = $Choises
@onready var date_timer: Timer = $DateTimer
@onready var text_timer: Timer = $TextTimer
@onready var next_repl_timer: Timer = $NextReplTimer
@onready var choice_timer: Timer = $ChoiceTimer
@onready var part_timer: Timer = $PartTimer
@onready var wait_timer: Timer = $WaitTimer
@onready var name_text: Label = $TextBox/Name
@onready var text_field: Label = $TextBox/Text
@onready var choise_location: VBoxContainer = $Choises/MarginContainer/ScrollContainer/VBoxContainer
@onready var auto_play_button: TextureRect = $TextBox/Buttons/Play
@onready var solid_color: ColorRect = $SolidColor
@onready var time_bar: ProgressBar = $Choises/TimeLeft
@onready var menu_button: Label = $TextBox/Buttons/Menu
@onready var achievements_handler: PlayGamesAchievementsClient = $PlayGamesAchievementsClient
@onready var inapp_review: InappReview = $InappReview
var choise_scene: PackedScene = preload("res://scenes/ui_in_game/choise.tscn")
var white_text_box_texture: CompressedTexture2D = preload("res://assets/textures/ui/new_text_box.png")
var black_text_box_texture: CompressedTexture2D = preload("res://assets/textures/ui/new_text_box_black.png")
var cursor_white: CompressedTexture2D = preload("res://assets/textures/ui/cursor64.png")
var cursor_black: CompressedTexture2D = preload("res://assets/textures/ui/cursor_black64.png")
var auto_play_texture_white: CompressedTexture2D = preload("res://assets/textures/ui/white_play_button.png")
var auto_play_texture_black: CompressedTexture2D = preload("res://assets/textures/ui/black_play_button.png")
var auto_pause_texture_white: CompressedTexture2D = preload("res://assets/textures/ui/white_pause_button.png")
var auto_pause_texture_black: CompressedTexture2D = preload("res://assets/textures/ui/black_pause_button.png")
var choices_panel_black: CompressedTexture2D = preload("res://assets/textures/ui/choises_panel_black.png")
var choices_panel_white: CompressedTexture2D = preload("res://assets/textures/ui/choises_panel.png")
var choice_block_white: CompressedTexture2D = preload("res://assets/textures/ui/choise.png")
var choice_block_black: CompressedTexture2D = preload("res://assets/textures/ui/choise_black.png")
var default_fade_length: float = 0.3

# Добавлены переменные для контроля печати текста
var current_name: String = ""
var current_text: String = ""
var name_index: int = 0
var text_index: int = 0
var auto_play: bool = false
var hint: bool = false
var dark: bool = false
var choises_to_remove: Array = []

# Переменные для управления анимациями
var bg_tween: Tween
var text_box_tween: Tween
var choices_tween: Tween
var animation_speed: float = 0.4

func _ready() -> void:
	music_player.volume_linear = 0
	DialogSystem.dialog_paused.connect(dialog_paused)
	DialogSystem.dialog_ended.connect(dialog_ended)
	DialogSystem.dialog_going.connect(dialog_going)
	DialogSystem.change_bg.connect(change_bg)
	DialogSystem.show_date.connect(show_date)
	DialogSystem.play_music.connect(play_music)
	DialogSystem.set_theme.connect(change_theme)
	DialogSystem.wait.connect(wait)
	DialogSystem.give_achievement.connect(unlock_achievement)
	hide_all()

func unlock_achievement(id: String):
	if Globals.SHOP_NAME == "play_market" and Globals.authed:
		achievements_handler.unlock_achievement(id)
	
func change_theme(new_dark: bool, move: bool):
	if dark != new_dark:
		dark = new_dark
		if dark:
			Input.set_custom_mouse_cursor(cursor_white, Input.CURSOR_ARROW, Vector2(0, 64))
			text_box.texture = black_text_box_texture
			name_text.label_settings.font_color = Color.WHITE
			text_field.label_settings.font_color = Color.WHITE
			menu_button.label_settings.font_color = Color.WHITE
			if not auto_play:
				auto_play_button.texture = auto_play_texture_white
			else:
				auto_play_button.texture = auto_pause_texture_white
			RenderingServer.set_default_clear_color(Color.BLACK)
		else:
			Input.set_custom_mouse_cursor(cursor_black, Input.CURSOR_ARROW, Vector2(0, 64))
			text_box.texture = white_text_box_texture
			name_text.label_settings.font_color = Color.BLACK
			text_field.label_settings.font_color = Color.BLACK
			menu_button.label_settings.font_color = Color.BLACK
			if not auto_play:
				auto_play_button.texture = auto_play_texture_black
			else:
				auto_play_button.texture = auto_pause_texture_black
			RenderingServer.set_default_clear_color(Color.WHITE)
	if move:
		DialogSystem.move_next()

func hide_all():
	BG.hide()
	date.hide()
	text_box.hide()
	choises.hide()

func fade_out(obj, length: float) -> void:
	var f_out_tween = create_tween()
	f_out_tween.tween_property(obj, "modulate:a", 0, length).from(1)
	await f_out_tween.finished
	obj.hide()

func fade_in(obj, length: float) -> void:
	obj.show()
	var f_in_tween = create_tween()
	f_in_tween.tween_property(obj, "modulate:a", 1, length).from(0)
	await f_in_tween.finished

# Анимированное показывание BG
func show_bg_animated():
	if bg_tween:
		bg_tween.kill()
	
	if not BG.visible:
		BG.modulate.a = 0
		BG.visible = true
		
	bg_tween = create_tween()
	bg_tween.set_ease(Tween.EASE_OUT)
	bg_tween.set_trans(Tween.TRANS_CUBIC)
	bg_tween.tween_property(BG, "modulate:a", 1.0, animation_speed)

# Анимированное скрывание BG  
func hide_bg_animated():
	if bg_tween:
		bg_tween.kill()
		
	if BG.visible:
		bg_tween = create_tween()
		bg_tween.set_ease(Tween.EASE_IN)
		bg_tween.set_trans(Tween.TRANS_CUBIC)
		bg_tween.tween_property(BG, "modulate:a", 0.0, animation_speed)
		bg_tween.tween_callback(func(): BG.visible = false)
		await bg_tween.finished

# Анимированное показывание text_box
func show_text_box_animated():
	if text_box_tween:
		text_box_tween.kill()
		
	if not text_box.visible:
		text_box.modulate.a = 0
		text_box.offset_top = 18
		text_box.offset_bottom = 230
		text_box.visible = true
		
	text_box_tween = create_tween()
	text_box_tween.set_ease(Tween.EASE_OUT)
	text_box_tween.set_trans(Tween.TRANS_BACK)
	text_box_tween.parallel().tween_property(text_box, "modulate:a", 1.0, animation_speed)
	text_box_tween.parallel().tween_property(text_box, "offset_top", -195, animation_speed)
	text_box_tween.parallel().tween_property(text_box, "offset_bottom", 17, animation_speed)

# Анимированное скрывание text_box
func hide_text_box_animated():
	if text_box_tween:
		text_box_tween.kill()
		
	if text_box.visible:
		text_box_tween = create_tween()
		text_box_tween.set_ease(Tween.EASE_IN)
		text_box_tween.set_trans(Tween.TRANS_BACK)
		text_box_tween.parallel().tween_property(text_box, "modulate:a", 0.0, animation_speed)
		text_box_tween.parallel().tween_property(text_box, "offset_top", 18, animation_speed)
		text_box_tween.parallel().tween_property(text_box, "offset_bottom", 230, animation_speed)
		text_box_tween.tween_callback(func(): text_box.visible = false)
		await text_box_tween.finished

# Анимированное показывание choices
func show_choices_animated():
	if choices_tween:
		choices_tween.kill()
		
	if not choises.visible:
		choises.modulate.a = 0
		choises.scale = Vector2(0.5, 0.5)  # Начинаем с меньшего размера
		choises.visible = true
		
	choices_tween = create_tween()
	choices_tween.set_ease(Tween.EASE_OUT)
	choices_tween.set_trans(Tween.TRANS_BACK)
	choices_tween.parallel().tween_property(choises, "modulate:a", 1.0, animation_speed)
	choices_tween.parallel().tween_property(choises, "scale", Vector2(1.0, 1.0), animation_speed)

# Анимированное скрывание choices
func hide_choices_animated():
	if choices_tween:
		choices_tween.kill()
		
	if choises.visible:
		choices_tween = create_tween()
		choices_tween.set_ease(Tween.EASE_IN)
		choices_tween.set_trans(Tween.TRANS_BACK)
		choices_tween.parallel().tween_property(choises, "modulate:a", 0.0, animation_speed * 0.7)
		choices_tween.parallel().tween_property(choises, "scale", Vector2(0.5, 0.5), animation_speed * 0.7)
		choices_tween.tween_callback(func(): choises.visible = false)

func _on_date_timer_timeout() -> void:
	await fade_out(date, 0.5)
	DialogSystem.move_next()
	
func show_date(text: String):
	date.text = text
	hide_bg_animated()
	hide_text_box_animated()
	hide_choices_animated()
	await fade_in(date, 0.5)
	date_timer.start()

func _on_text_box_gui_input(event: InputEvent) -> void:
	if event.is_action_pressed("click") and text_box.modulate.a == 1:
		if not text_timer.is_stopped():
			text_timer.stop()
			name_text.text = current_name
			text_field.text = current_text
			if auto_play:
				next_repl_timer.start()
		elif text_timer.is_stopped() and not choises.visible and not hint:
			if not next_repl_timer.is_stopped():
				next_repl_timer.stop()
			DialogSystem.move_next()
		elif text_timer.is_stopped() and not choises.visible and hint:
			on_hint_clicked.emit()
			await hide_text_box_animated()
			$TextBox/Buttons/Play.visible = true
			hint = false

func _on_text_timer_timeout() -> void:
	if name_index < current_name.length():
		name_text.text += current_name[name_index]
		name_index += 1
	elif text_index < current_text.length():
		text_field.text += current_text[text_index]
		text_index += 1
	else:
		text_timer.stop()
		if auto_play:
			next_repl_timer.start()
		
func dialog_paused(_tag: String):
	hide_bg_animated()
	hide_text_box_animated()
	hide_choices_animated()
	
func dialog_ended():
	hide_all()
	Globals.dialog_vars = {}
	Globals.demo_vars = {}
	music_player.stop()
	if Globals.SHOP_NAME == "play_market" and Globals.authed:
		Globals.until_rate += 1
		if Globals.until_rate >= 10:
			inapp_review.generate_review_info()
			Globals.until_rate = 0
	
func update_text():
	current_name = DialogSystem.get_current_name()
	current_text = DialogSystem.get_current_text()
	name_index = 0
	text_index = 0
	name_text.text = ""
	text_field.text = ""
	text_timer.start()
	
func update_choices():
	if DialogSystem.get_current_choises():
		if dark:
			choises.texture = choices_panel_black
		else:
			choises.texture = choices_panel_white
		var is_timer = false
		var time_to_wait = 0
		for choise in DialogSystem.get_current_choises():
			var choise_block = choise_scene.instantiate()
			if dark:
				choise_block.texture = choice_block_black
				choise_block.get_child(0).label_settings.font_color = Color.WHITE
			else:
				choise_block.texture = choice_block_white
				choise_block.get_child(0).label_settings.font_color = Color.BLACK
			choise_block.get_child(0).text = choise["text"]
			if choise.has("next_br"):
				choise_block.set_meta("next_br", choise["next_br"])
			else:
				choise_block.set_meta("next_br", "that")
			choise_block.connect("gui_input", _on_choise_clicked.bind(choise_block))
			if choise.has("wait_time") and not is_timer:
				is_timer = true
				choises_to_remove.append(choise_block)
				time_to_wait = choise["wait_time"]
			choise_location.add_child(choise_block)
		if is_timer:
			time_bar.visible = true
			time_bar.max_value = time_to_wait
			time_bar.value = time_to_wait
		else:
			time_bar.visible = false
		show_choices_animated()
		if is_timer:
			choice_timer.wait_time = time_to_wait
			part_timer.wait_time = 0.01
			part_timer.start()
			choice_timer.start()
	else:
		hide_choices_animated()
			
func _on_choise_clicked(event: InputEvent, obj: TextureRect):
	if event.is_action_pressed("click"):
		for choise in choise_location.get_children():
			choise.queue_free()
		DialogSystem.change_block(obj.get_meta("next_br"))
	
func dialog_going():
	update_text()
	update_choices()
	show_text_box_animated()

func show_hint(hints: Array, current_hint: int):
	hint = true
	$TextBox/Buttons/Play.visible = false
	show_text_box_animated()
	current_name = "..."
	current_text = Globals.text_vars[hints[current_hint]]
	name_index = 0
	text_index = 0
	name_text.text = ""
	text_field.text = ""
	text_timer.start()

func change_bg(bg_path: String, anim: bool, move: bool):
	if bg_path == "hide":
		BG.texture = null
		hide_bg_animated()
	else:
		if anim:
			await hide_bg_animated()
		BG.texture = load(bg_path)
		if anim:
			show_bg_animated()
		else:
			BG.modulate.a = 1
			BG.visible = true
	if move:
		DialogSystem.move_next()

func play_music(music_path: String, move: bool):
	var loud_out_tween = create_tween()
	loud_out_tween.tween_property(music_player, "volume_linear", 0, 1).from_current()
	if move:
		DialogSystem.move_next()
	await loud_out_tween.finished
	if music_path == "stop":
		music_player.stop()
	else:
		music_player.stream = load(music_path)
		music_player.play()
		var loud_in_tween = create_tween()
		loud_in_tween.tween_property(music_player, "volume_linear", Globals.music_volume, 1).from_current()
	
func start_auto_play():
	auto_play = true
	if text_timer.is_stopped():
		next_repl_timer.start()

func stop_auto_play():
	auto_play = false
	next_repl_timer.stop()

func fade_in_solid(color: Color, length: float):
	solid_color.color = color
	await fade_in(solid_color, length)
	
func fade_out_solid(length: float):
	await fade_out(solid_color, length)

func _on_next_repl_timer_timeout() -> void:
	if not choises.visible and text_box.visible and text_box.modulate.a == 1 and not hint:
		DialogSystem.move_next()

func _on_text_box_auto_play() -> void:
	if auto_play:
		if dark:
			auto_play_button.texture = auto_play_texture_black
		else:
			auto_play_button.texture = auto_play_texture_white
		stop_auto_play()
	else:
		if dark:
			auto_play_button.texture = auto_pause_texture_black
		else:
			auto_play_button.texture = auto_pause_texture_white
		start_auto_play()

func _on_choice_timer_timeout() -> void:
	part_timer.stop()
	time_bar.visible = false
	for choice in choise_location.get_children():
		if choice in choises_to_remove:
			choice.queue_free()

func _on_part_timer_timeout() -> void:
	var elapsed_time = choice_timer.wait_time - choice_timer.time_left
	time_bar.value = choice_timer.wait_time - elapsed_time

func wait(seconds: float):
	wait_timer.wait_time = seconds
	wait_timer.start()

func _on_wait_timer_timeout() -> void:
	DialogSystem.move_next()


func _on_text_box_menu() -> void:
	change_theme(false, false)
	Globals.dialog_vars = {}
	Globals.demo_vars = {}
	get_tree().change_scene_to_packed(ResourceLoader.load_threaded_get("res://scenes/menu_and_splash/menu.tscn"))

func _on_inapp_review_review_info_generated() -> void:
	inapp_review.launch_review_flow()
