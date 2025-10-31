extends Node2D

var dragged_sprite: Sprite2D = null
var original_position: Vector2
var original_rotation: float
var original_z_index: int
var is_dragging: bool = false
var mouse_offset: Vector2 = Vector2.ZERO
var start_drag_tween: Tween = null
# Храним все активные твины возврата
var return_tweens: Dictionary = {}  # Key: Sprite2D, Value: Tween

func _input(event: InputEvent) -> void:
	# Проверяем, что родительский элемент видим
	if not $"..".visible or Globals.demo_vars.get("hint", false):
		return
		
	if Globals.demo_vars.has("shoplist_going"):
		if Globals.demo_vars["shoplist_going"] == true:
			return
	
	# Начало перетаскивания
	if event.is_action_pressed("click") and not is_dragging:
		var sprites_under_mouse = []
		
		for child in get_children():
			if child is Sprite2D and is_instance_valid(child):
				# Пропускаем спрайты, которые уже возвращаются
				if return_tweens.has(child):
					continue
					
				var local_pos = child.to_local(event.position)
				if child.get_rect().has_point(local_pos):
					sprites_under_mouse.append(child)
		
		if sprites_under_mouse.size() > 0:
			sprites_under_mouse.sort_custom(func(a, b): 
				if a.z_index != b.z_index:
					return a.z_index > b.z_index
				else:
					return get_children().find(a) > get_children().find(b)
			)
			$"../../../HintTimer".stop()
			start_drag(sprites_under_mouse[0])
	
	# Перемещение спрайта
	if is_dragging and event is InputEventMouseMotion:
		if is_instance_valid(dragged_sprite):
			# Если есть активный твин начала перетаскивания - останавливаем его
			if start_drag_tween and start_drag_tween.is_valid():
				start_drag_tween.kill()
				start_drag_tween = null
			
			# Применяем поворот к смещению мыши
			var rotated_offset = mouse_offset.rotated(dragged_sprite.global_rotation)
			dragged_sprite.global_position = event.position + rotated_offset
	
	# Завершение перетаскивания
	if is_dragging and event.is_action_released("click") and Globals.demo_vars.has("dropping"):
		if Globals.demo_vars["dropping"]:
			if Globals.hints:
				$"../../../HintTimer".start()
			dragged_sprite = null
			is_dragging = false
	
	if is_dragging and event.is_action_released("click"):
		if Globals.hints:
			$"../../../HintTimer".start()
		stop_drag()

func start_drag(sprite: Sprite2D) -> void:
	if not is_instance_valid(sprite) or return_tweens.has(sprite):
		return
	
	# Рассчитываем смещение с учётом текущего поворота спрайта
	var global_mouse_pos = get_global_mouse_position()
	mouse_offset = (sprite.global_position - global_mouse_pos).rotated(-sprite.global_rotation)
	dragged_sprite = sprite
	original_position = sprite.position
	original_rotation = sprite.rotation
	original_z_index = sprite.z_index
	is_dragging = true
	sprite.z_index = 100  # Поднимаем на верхний слой
	
	# Сохраняем твин в переменную, чтобы можно было его остановить
	var rotate_tween = create_tween()
	start_drag_tween = create_tween()
	rotate_tween.tween_property(sprite, "rotation", 0, 0.4).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	start_drag_tween.parallel().tween_property(sprite, "global_position", global_mouse_pos + mouse_offset, 0.4).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	
func stop_drag() -> void:
	if not is_dragging or not is_instance_valid(dragged_sprite):
		reset_drag()
		return
	
	# Останавливаем твин начала перетаскивания, если он активен
	if start_drag_tween and start_drag_tween.is_valid():
		start_drag_tween.kill()
		start_drag_tween = null
	
	# Если для этого спрайта уже есть твин возврата - останавливаем его
	if return_tweens.has(dragged_sprite):
		var existing_tween = return_tweens[dragged_sprite]
		if existing_tween and existing_tween.is_valid():
			existing_tween.kill()
	
	# Создаем новый твин возврата
	dragged_sprite.z_index = original_z_index
	var new_return_tween = create_tween()
	return_tweens[dragged_sprite] = new_return_tween
	
	new_return_tween.tween_property(dragged_sprite, "position", original_position, 0.7)\
		.set_trans(Tween.TRANS_ELASTIC).set_ease(Tween.EASE_OUT)
	new_return_tween.parallel().tween_property(dragged_sprite, "rotation", original_rotation, 0.7)\
		.set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	
	# Удаляем твин из словаря после завершения
	new_return_tween.connect("finished", Callable(self, "_on_return_tween_finished").bind(dragged_sprite))
	
	# Сбрасываем состояние перетаскивания сразу, не ждём завершения анимации
	reset_drag()

func _on_return_tween_finished(sprite: Sprite2D) -> void:
	if return_tweens.has(sprite):
		return_tweens.erase(sprite)

func reset_drag() -> void:
	# Останавливаем твин начала перетаскивания, если он активен
	if start_drag_tween and start_drag_tween.is_valid():
		start_drag_tween.kill()
		start_drag_tween = null
	
	if is_instance_valid(dragged_sprite) and dragged_sprite.z_index == 100:
		dragged_sprite.z_index = original_z_index
	
	dragged_sprite = null
	is_dragging = false
