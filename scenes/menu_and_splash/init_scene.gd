extends Control

func _enter_tree() -> void:
	if Globals.SHOP_NAME == "play_market" and OS.get_name() == "Android":
		GodotPlayGameServices.initialize()

func _ready() -> void:
	if Globals.SHOP_NAME == "play_market" and OS.get_name() == "Android":
		$PlayGamesSignInClient.is_authenticated()
	else:
		# Use call_deferred to safely change scenes
		call_deferred("change_to_disclaimer")

func _on_play_games_sign_in_client_user_authenticated(is_authenticated: bool) -> void:
	Globals.authed = is_authenticated
	if is_authenticated:
		$PlayGamesSnapshotsClient.load_snapshots(true)
	else:
		# Use call_deferred to safely change scenes
		call_deferred("change_to_disclaimer")
	

# Helper method to safely change scenes
func change_to_disclaimer() -> void:
	get_tree().change_scene_to_file("res://scenes/menu_and_splash/disclaimer.tscn")


func _on_play_games_snapshots_client_snapshots_loaded(snapshots: Array[PlayGamesSnapshotMetadata]) -> void:
	if snapshots.is_empty():
		call_deferred("change_to_disclaimer")
	else:
		snapshots.sort_custom(func(a, b): return a.last_modified_timestamp > b.last_modified_timestamp)
		$PlayGamesSnapshotsClient.load_game(snapshots[0].unique_name)


func _on_play_games_snapshots_client_game_loaded(snapshot: PlayGamesSnapshot) -> void:
	SaveSystem.values = str_to_var(snapshot.content.get_string_from_utf8())
	SaveSystem.save_data()
	call_deferred("change_to_disclaimer")
