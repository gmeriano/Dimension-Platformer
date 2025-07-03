extends Node

var player1: Player
var player2: Player
var camera1: Camera2D
var camera2: Camera2D

func set_player_1(player: Player) -> void:
	player1 = player
	
func set_player_2(player: Player) -> void:
	player2 = player
	
func get_player_1() -> Player:
	return player1

func get_player_2() -> Player:
	return player2

func get_players() -> Array[Player]:
	return [player1, player2]

func is_player_1_set() -> bool:
	return player1 != null

func is_player_2_set() -> bool:
	return player2 != null

func set_camera_1(camera: Camera2D) -> void:
	camera1 = camera
	
func set_camera_2(camera: Camera2D) -> void:
	camera2 = camera
	
func get_camera_1() -> Camera2D:
	return camera1

func get_camera_2() -> Camera2D:
	return camera2

@rpc("any_peer", "call_local")
func load_next_level() -> void:
	# need this to move the player off the LevelComplete area to not trigger twice
	player1.global_position = Vector2(player1.global_position.x, player1.global_position.y + 100000)
	player2.global_position = Vector2(player2.global_position.x, player2.global_position.y + 100000)
	set_players_state_respawn()
	var game_node = get_tree().get_root().get_node("Game")
	game_node.load_next_level()

@rpc("any_peer", "call_local")
func reload_current_level() -> void:
	# need this to move the player off the LevelComplete area to not trigger twice
	player1.global_position = Vector2(player1.global_position.x, player1.global_position.y + 100000)
	player2.global_position = Vector2(player2.global_position.x, player2.global_position.y + 100000)
	set_players_state_respawn()
	var game_node = get_tree().get_root().get_node("Game")
	game_node.reload_current_level()

func _on_fade_to_normal_finished_can_move_true():
	GameManager.set_players_state_idle()

func set_players_state_respawn() -> void:
	if player1.tween:
		player1.tween.kill()
		print("tween 1")
	if player2.tween:
		player2.tween.kill()
		print("tween 2")
	player1.multiplayer_synchronizer.replication_interval = 10.0
	player2.multiplayer_synchronizer.replication_interval = 10.0
	player1.velocity = Vector2.ZERO
	player2.velocity = Vector2.ZERO
	player1.state_machine.transition(PlayerRespawnState.state_name)
	player2.state_machine.transition(PlayerRespawnState.state_name)

func set_players_state_idle() -> void:
	player1.multiplayer_synchronizer.replication_interval = 0.0
	player2.multiplayer_synchronizer.replication_interval = 0.0
	player1.state_machine.transition(PlayerIdleState.state_name)
	player2.state_machine.transition(PlayerIdleState.state_name)

func get_camera_right_edge() -> float:
	var viewport_size = camera1.get_viewport_rect().size
	var half_width = (viewport_size.x / camera1.zoom.x) / 2.0
	return camera1.global_position.x + half_width

func get_camera_left_edge() -> float:
	var viewport_size = camera1.get_viewport_rect().size
	var half_width = (viewport_size.x / camera1.zoom.x) / 2.0
	return camera1.global_position.x - half_width

func set_camera_zoom_default() -> void:
	camera1.zoom = Vector2(1.5, 1.5)
	camera2.zoom = Vector2(1.5, 1.5)

func set_camera_limit_default() -> void:
	camera1.limit_left = -400
	camera2.limit_left = -400
