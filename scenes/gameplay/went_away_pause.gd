extends Sprite2D

var click_count = 0

@onready var hint_timer: Timer = $"../../../HintTimer"
var current_hint = 0
var hints = ["demo_went_away_pause_one", "demo_went_away_pause_two", "demo_went_away_pause_three"]
var hint = false

func _ready() -> void:
	$Request.text = Globals.text_vars["door_request"]

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("click") and get_parent().visible and not hint:
		if Globals.hints:
			hint_timer.stop()
			hint_timer.start()
		click_count += 1
		match click_count:
			1:
				$Request.size = Vector2(235, 160)
				$Request.position = Vector2(-2, -317)
				$Request.scale = Vector2(1.558, 1.558)
				texture = load("res://assets/textures/job/exit_from_job2.png")
			2:
				$Request.visible = false
				texture = load("res://assets/textures/job/exit_from_job3.png")
			3:
				get_parent().visible = false
				hint_timer.stop()
				DialogSystem.move_next()

func _on_hint_timer_timeout() -> void:
	if $"..".visible and current_hint < hints.size() and Globals.hints:
		hint = true
		DialogSystem.add_indialog_var("inattentive_demo", "1")
		$"../../../UI".show_hint(hints, current_hint)


func _on_ui_on_hint_clicked() -> void:
	if $"..".visible:
		hint = false
		current_hint += 1
		if current_hint < hints.size():
			hint_timer.start()
