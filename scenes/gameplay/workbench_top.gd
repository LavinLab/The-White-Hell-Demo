extends Sprite2D

var current_ind = 0

func _ready() -> void:
	$Powder.text = Globals.text_vars["powder"]
	$Nails.text = Globals.text_vars["nails"]
	$Sleeves.text = Globals.text_vars["sleeves"]
	$Bolts.text = Globals.text_vars["bolts"]
	$Bullets.text = Globals.text_vars["bullets"]
	$Box/StampText.text = Globals.text_vars["stamp"]


func _on_box_gui_input(event: InputEvent) -> void:
	if event.is_action_pressed("click") and $"..".visible and visible:
		match current_ind:
			0:
				current_ind += 1
				$Box.texture = load("res://assets/textures/job/box_top_half_closed.png")
			1:
				current_ind += 1
				$Box.texture = load("res://assets/textures/job/box_top_closed.png")
			2:
				current_ind += 1
				$Box.texture = load("res://assets/textures/job/box_top_closed_with_tape.png")
			3:
				current_ind += 1
				$Box.texture = load("res://assets/textures/job/box_top_closed_with_stamp.png")
				$Box/StampText.visible = true
			4:
				DialogSystem.move_next()
