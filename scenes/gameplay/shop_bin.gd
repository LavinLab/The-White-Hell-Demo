extends Sprite2D

var entered = false
var current_area: Area2D = null
var is_processing_drop = false  # To prevent multiple drops

func _input(_event: InputEvent) -> void:
	if $"..".visible and entered and Input.is_action_just_released("click") and not is_processing_drop:
		if current_area.get_parent().z_index == 100:
			is_processing_drop = true
			var target = current_area.get_parent()
			Globals.demo_vars["dropping"] = true
			
			var fall_tween = create_tween()
			
			# Random tilt angle (-30 to 30 degrees converted to radians)
			var tilt_angle = randf_range(-30.0, 30.0) * PI / 180.0
			
			# Falling animation
			fall_tween.tween_property(target, "position:y", target.position.y + 150, 0.3)\
				.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
			
			# Tilt animation (rotation)
			fall_tween.parallel().tween_property(target, "rotation", tilt_angle, 0.3)\
				.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
			
			# Fade out animation
			fall_tween.parallel().tween_property(target, "modulate:a", 0.0, 0.3)\
				.set_trans(Tween.TRANS_LINEAR)
			
			# Remove after animation completes
			fall_tween.tween_callback(target.queue_free)
			
			await fall_tween.finished
			Globals.demo_vars["dropping"] = false
			
			# Only decrement count by 1 for each drop
			match target.get_meta("tag"):
				"beer":
					$"..".beer_count -= 1
					$"..".product_count -= 1
				"bread":
					$"..".bread_count -= 1
					$"..".product_count -= 1
				"candies":
					$"..".candy_count -= 1
					$"..".product_count -= 1
				_:
					if not $"..".not_passed:
						$"..".not_passed = true
						$"..".restart_button.visible = true
					$"..".product_count -= 1
			
			is_processing_drop = false

func _on_area_2d_area_entered(area: Area2D) -> void:
	entered = true
	current_area = area

func _on_area_2d_area_exited(_area: Area2D) -> void:
	entered = false
	current_area = null
