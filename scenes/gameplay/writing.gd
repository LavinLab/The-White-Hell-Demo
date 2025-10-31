extends Control

var repl = true
var hint = false

@onready var hint_timer: Timer = $"../../HintTimer"
var current_hint = 0
var hints = ["demo_writing_pause_one", "demo_writing_pause_two", "demo_writing_pause_three"]

func _ready() -> void:
	$Writing.visible = false
	$WritingOnFloor/WritingText.text = Globals.text_vars["demo_writing_text"]
	$Writing/WritingText.text = Globals.text_vars["demo_writing_text"]


func _on_writing_zone_gui_input(event: InputEvent) -> void:
	if visible and event.is_action_pressed("click") and not repl and not hint:
		hint_timer.stop()
		repl = true
		$Writing.visible = true
		var tween = create_tween()
		tween.tween_property($Writing, "position:y", 308, 1).set_trans(Tween.TRANS_ELASTIC)
		await tween.finished
		DialogSystem.move_next()


func _on_hint_timer_timeout() -> void:
	if visible and current_hint < hints.size() and not repl and Globals.hints:
		hint = true
		DialogSystem.add_indialog_var("inattentive_demo", "1")
		$"../../UI".show_hint(hints, current_hint)


func _on_ui_on_hint_clicked() -> void:
	if visible:
		hint = false
		current_hint += 1
		if current_hint < hints.size():
			hint_timer.start()
