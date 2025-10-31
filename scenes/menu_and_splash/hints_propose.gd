extends Control

var is_transitioning := false
var current_tween: Tween = null

func _ready() -> void:
	modulate.a = 0
	# Инициализация текстов
	$HintsProposeText.text = Globals.text_vars["hint_propose"]
	$MightBeChanged.text = Globals.text_vars["hint_might_be_changed"]
	$AboutHints.text = Globals.text_vars["about_hints"]
	$AboutFastChoises.text = Globals.text_vars["about_fast_choices"]
	$ChoiseBlock/MarginContainer/VBoxContainer/YesChoise/Label.text = Globals.text_vars["yes"]
	$ChoiseBlock/MarginContainer/VBoxContainer/NoChoise/Label.text = Globals.text_vars["no"]
	
	# Плавное появление
	var tween = create_tween()
	tween.tween_property(self, "modulate:a", 1, 0.5)
	await tween.finished

func cancel_current_tween() -> void:
	if current_tween != null and current_tween.is_valid():
		current_tween.kill()
	current_tween = null

func _on_yes_choise_gui_input(event: InputEvent) -> void:
	if event.is_action_pressed("click") and modulate.a == 1 and not is_transitioning:
		Globals.hints = true
		is_transitioning = true
		cancel_current_tween()
		
		current_tween = create_tween()
		current_tween.tween_property($HintsProposeText, "modulate:a", 0, 0.5)
		current_tween.parallel().tween_property($ChoiseBlock, "modulate:a", 0, 0.5)
		current_tween.parallel().tween_property($MightBeChanged, "modulate:a", 0, 0.5)
		await current_tween.finished
		
		$AboutHints.modulate.a = 0
		$AboutHints.visible = true
		current_tween = create_tween()
		current_tween.tween_property($AboutHints, "modulate:a", 1, 0.5)
		await current_tween.finished
		
		is_transitioning = false
		current_tween = null

func _on_no_choise_gui_input(event: InputEvent) -> void:
	if event.is_action_pressed("click") and modulate.a == 1 and not is_transitioning:
		Globals.hints = false
		is_transitioning = true
		cancel_current_tween()
		
		current_tween = create_tween()
		current_tween.tween_property($HintsProposeText, "modulate:a", 0, 0.5)
		current_tween.parallel().tween_property($ChoiseBlock, "modulate:a", 0, 0.5)
		current_tween.parallel().tween_property($MightBeChanged, "modulate:a", 0, 0.5)
		await current_tween.finished
		
		$AboutFastChoises.modulate.a = 0
		$AboutFastChoises.visible = true
		current_tween = create_tween()
		current_tween.tween_property($AboutFastChoises, "modulate:a", 1, 0.5)
		await current_tween.finished
		
		is_transitioning = false
		current_tween = null

func _input(event: InputEvent) -> void:
	if is_transitioning or current_tween != null:
		return
		
	if $AboutHints.visible and $AboutHints.modulate.a == 1 and event.is_action_pressed("click"):
		start_transition()
	elif $AboutFastChoises.visible and $AboutFastChoises.modulate.a == 1 and event.is_action_pressed("click"):
		start_scene_change()

func start_transition() -> void:
	is_transitioning = true
	cancel_current_tween()
	
	current_tween = create_tween()
	current_tween.tween_property($AboutHints, "modulate:a", 0, 0.5)
	await current_tween.finished
	
	$AboutHints.visible = false
	$AboutFastChoises.modulate.a = 0
	$AboutFastChoises.visible = true
	
	current_tween = create_tween()
	current_tween.tween_property($AboutFastChoises, "modulate:a", 1, 0.5)
	await current_tween.finished
	
	is_transitioning = false
	current_tween = null

func start_scene_change() -> void:
	is_transitioning = true
	cancel_current_tween()
	
	current_tween = create_tween()
	current_tween.tween_property($AboutFastChoises, "modulate:a", 0, 0.5)
	await current_tween.finished
	
	get_tree().change_scene_to_packed(ResourceLoader.load_threaded_get(Globals.new_game_we_are_loading))
