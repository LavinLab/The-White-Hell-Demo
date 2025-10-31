extends Control

func come_closer():
	var tween = create_tween()
	tween.tween_property($FactoryOutside, "scale", Vector2(0.581, 0.581), 10).set_trans(Tween.TRANS_SINE)
	tween.parallel().tween_property($FactoryOutside, "position:y", 44, 10).set_trans(Tween.TRANS_SINE)
	await tween.finished
	DialogSystem.move_next()
	
