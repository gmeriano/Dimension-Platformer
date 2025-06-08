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
	var game_node = get_tree().get_root().get_node("Game")
	game_node.load_next_level()
	
