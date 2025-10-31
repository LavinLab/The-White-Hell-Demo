extends Control

func fade_in_gopnik():
	if visible:
		var fade_in = create_tween()
		fade_in.tween_property($Gateway/Gopnik, "modulate:a", 1, 1.5)
		await fade_in.finished
		DialogSystem.move_next()
	
func fade_in_knife():
	if visible:
		var fade_in = create_tween()
		fade_in.tween_property($Gateway/KnifeInHand, "modulate:a", 1, 1.5)
		await fade_in.finished
		$BeforeKillTimer.start()

func fade_in_hands():
	if visible:
		var fade_in = create_tween()
		fade_in.tween_property($Gateway/Hands, "modulate:a", 1, 1.5)
		await fade_in.finished
		DialogSystem.move_next()



func _on_before_kill_timer_timeout() -> void:
	$"../../UI".play_music("res://assets/audio/music/suspense.ogg", false)
	DialogSystem.current_music = "res://assets/audio/music/suspense.ogg"
	$"../../UI".fade_in_solid(Color.RED, 0.5)
	$Gateway/Gopnik.visible = false
	$Gateway/KnifeInHand.visible = false
	$"../../UI".fade_out_solid(0.5)
	$Gateway/DyingGopnik.visible = true
	$"../../AnimationPlayer".play("gopnik_dying")
	await $"../../AnimationPlayer".animation_finished
	fade_in_hands()
	
