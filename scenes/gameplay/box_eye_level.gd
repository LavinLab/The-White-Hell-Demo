extends Sprite2D
var cartridge_amount: int = 4:
	set(value):
		cartridge_amount = value
		if cartridge_amount == 0:
			if Globals.hints:
				$"../../../../HintTimer".stop()
				Globals.demo_vars["hint"] = false
			$"..".visible = false
			$"../../WorkbenchTop".visible = true

func _on_area_2d_area_entered(area: Area2D) -> void:
	if area.get_parent().get_meta("tag") == "cartridge" and not Globals.demo_vars.get("cartridge_return", false):
		var cartridge_object = area.get_parent()
		
		# Создаем анимацию падения
		animate_fall_and_destroy(cartridge_object)

func animate_fall_and_destroy(object: Node2D) -> void:
	# Создаем Tween для анимации
	var tween = create_tween()
	
	# Простое падение вниз
	var fall_distance = 200  # Расстояние падения в пикселях
	var fall_duration = 0.4  # Длительность падения в секундах
	
	Globals.demo_vars["bullet_falls"] = true
	# Анимируем падение с ускорением
	tween.tween_property(object, "position:y", object.position.y + fall_distance, fall_duration)
	tween.set_ease(Tween.EASE_IN)  # Ускорение при падении
	await tween.finished
	Globals.demo_vars["bullet_falls"] = false
	if Globals.hints:
		$"../../../../HintTimer".start()
	object.queue_free()
	cartridge_amount -= 1
