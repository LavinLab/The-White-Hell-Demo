extends Sprite2D

const EXPANDED_POSITION := Vector2(0, 0)
const EXPANDED_SCALE := Vector2(0.65, 0.65)
const COLLAPSED_POSITION := Vector2(404, 264)
const COLLAPSED_SCALE := Vector2(0.246, 0.246)

var is_animating: bool = false

func _input(event: InputEvent) -> void:
	if not $"..".visible or is_animating or $"..".hint or $"..".repl:
		return
	
	if event.is_action_pressed("click") and get_rect().has_point(to_local(event.position)):
		animate_toggle()
		$"../../../HintTimer".stop()
		$"../../../HintTimer".start()

func animate_toggle() -> void:
	var target_position := EXPANDED_POSITION if position == COLLAPSED_POSITION else COLLAPSED_POSITION
	var target_scale := EXPANDED_SCALE if position == COLLAPSED_POSITION else COLLAPSED_SCALE
	
	is_animating = true
	
	var tween = create_tween()
	tween.tween_property(self, "position", target_position, 0.5).set_trans(Tween.TRANS_QUAD)
	tween.parallel().tween_property(self, "scale", target_scale, 0.5).set_trans(Tween.TRANS_QUAD)
	
	await tween.finished
	
	is_animating = false
