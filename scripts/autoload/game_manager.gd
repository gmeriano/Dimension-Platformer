extends Node

var player1: Player
var player2: Player

func set_player_1(player: Player) -> void:
	player1 = player
	
func set_player_2(player: Player) -> void:
	player2 = player
	
func get_player_1() -> Player:
	return player1

func get_player_2() -> Player:
	return player2

func is_player_1_set() -> bool:
	return player1 != null

func is_player_2_set() -> bool:
	return player2 != null

@rpc("any_peer", "call_local")
func load_next_level() -> void:
	player1.global_position = Vector2(player1.global_position.x, player1.global_position.y + 100)
	player2.global_position = Vector2(player2.global_position.x, player2.global_position.y + 100)
	var game_node = get_tree().get_root().get_node("Game")
	game_node.load_next_level()

func _on_fade_to_normal_finished_can_move_true():
	GameManager.set_can_move(true)

func set_can_move(can_move: bool) -> void:
	if can_move == false:
		player1.multiplayer_synchronizer.replication_interval = 10.0
		player2.multiplayer_synchronizer.replication_interval = 10.0
		player1.can_move = false
		player2.can_move = false
		player1.velocity = Vector2.ZERO
		player2.velocity = Vector2.ZERO
	else:
		player1.multiplayer_synchronizer.replication_interval = 0.0
		player2.multiplayer_synchronizer.replication_interval = 0.0
		player1.can_move = true
		player2.can_move = true
