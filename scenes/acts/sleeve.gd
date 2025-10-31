extends Sprite2D

var original_position: Vector2
var original_rotation: float
var original_z_index: int
var is_dragging: bool = false
var mouse_offset: Vector2 = Vector2.ZERO
var start_drag_tween: Tween = null
var return_tween: Tween = null

var has_powder: bool = false

func _ready():
	# Сохраняем исходные значения
	original_position = position
	original_rotation = rotation
	original_z_index = z_index

func _input(event: InputEvent) -> void:
	# Проверяем видимость родителя
	if not $"../..".visible or not $"..".visible or Globals.demo_vars.get("hint", false) or Globals.demo_vars.get("bullet_falls", false):
		return
	
	# Начало перетаскивания
	if event.is_action_pressed("click") and not is_dragging and not Globals.demo_vars.get("bullet_falls", false):
		var local_pos = to_local(event.position)
		if get_rect().has_point(local_pos):
			# Останавливаем твин возврата, если он активен
			if return_tween and return_tween.is_valid():
				return_tween.kill()
				return_tween = null
			
			start_drag(event.position)
	
	# Перемещение спрайта
	if is_dragging and event is InputEventMouseMotion:
		# Если есть активный твин начала перетаскивания - останавливаем его
		if start_drag_tween and start_drag_tween.is_valid():
			start_drag_tween.kill()
			start_drag_tween = null
		
		# Применяем поворот к смещению мыши
		var rotated_offset = mouse_offset.rotated(global_rotation)
		global_position = event.position + rotated_offset
	
	# Завершение перетаскивания
	if is_dragging and event.is_action_released("click"):
		if Globals.hints:
			$"../../../../HintTimer".start()
		if not Globals.demo_vars.get("bullet_falls", false):
			stop_drag()

func start_drag(mouse_pos: Vector2) -> void:
	if is_dragging:
		return
		
	if Globals.hints:
		$"../../../../HintTimer".stop()
	
	# Рассчитываем смещение с учётом текущего поворота спрайта
	mouse_offset = (global_position - mouse_pos).rotated(-global_rotation)
	is_dragging = true
	z_index = 100  # Поднимаем на верхний слой
	
	# Анимация подъема и выравнивания
	var rotate_tween = create_tween()
	start_drag_tween = create_tween()
	rotate_tween.tween_property(self, "rotation", 0, 0.4).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	start_drag_tween.parallel().tween_property(self, "global_position", mouse_pos + mouse_offset, 0.4).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)

func stop_drag() -> void:
	if not is_dragging:
		return
	
	Globals.demo_vars["cartridge_return"] = true
	# Останавливаем твин начала перетаскивания, если он активен
	if start_drag_tween and start_drag_tween.is_valid():
		start_drag_tween.kill()
		start_drag_tween = null
	
	# Возвращаем исходный z_index
	z_index = original_z_index
	
	# Создаем твин возврата на место
	return_tween = create_tween()
	return_tween.tween_property(self, "position", original_position, 0.7)\
		.set_trans(Tween.TRANS_ELASTIC).set_ease(Tween.EASE_OUT)
	return_tween.parallel().tween_property(self, "rotation", original_rotation, 0.7)\
		.set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	
	# Сбрасываем состояние перетаскивания
	is_dragging = false
	
	# Очищаем твин после завершения
	return_tween.connect("finished", Callable(self, "_on_return_finished"))

func _on_return_finished() -> void:
	return_tween = null
	Globals.demo_vars["cartridge_return"] = false


func _on_area_2d_area_entered(area: Area2D) -> void:
	if area.get_parent().get_meta("tag") == "bullet" and has_powder:
		area.get_parent().queue_free()
		texture = load("res://assets/textures/job/cartridge_single.png")
		set_meta("tag", "cartridge")
		position.y -= 20
		original_position = position
		if Globals.hints:
			$"../../../../HintTimer".start()
		$Area2D.call_deferred("queue_free")
		$Area2D2.set_deferred("monitorable", true)
