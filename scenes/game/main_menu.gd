extends Node

const PLAYER = preload("res://scenes/player/Player.tscn")
@onready var multiplayer_ui = $UI/Multiplayer

var peer
var controls1 = preload("res://assets/resources/player1_movement.tres")
var controls2 = preload("res://assets/resources/player2_movement.tres")


func _on_host_pressed():
	peer = ENetMultiplayerPeer.new()
	Global.IS_ONLINE_MULTIPLAYER = true
	peer.create_server(25565)
	multiplayer.multiplayer_peer = peer
	
	multiplayer.peer_connected.connect(
		func(pid):
			print("Peer " + str(pid) + " has joined the game!")
			add_player_online(pid)
	)
	
	add_player_online(multiplayer.get_unique_id())
	#multiplayer_ui.hide()

func _on_join_pressed():
	peer = ENetMultiplayerPeer.new()
	Global.IS_ONLINE_MULTIPLAYER = true
	peer.create_client("localhost", 25565)
	multiplayer.multiplayer_peer = peer
	#multiplayer_ui.hide()

func add_player_local(pid, controls):
	var player = PLAYER.instantiate()
	player.controls = controls
	player.name = str(pid)
	#player.set_multiplayer_authority(multiplayer.get_unique_id())
	add_child(player)
	
func add_player_online(pid):
	var player = PLAYER.instantiate()
	player.name = str(pid)
	player.set_multiplayer_authority(int(str(pid)))
	add_child(player)



func _on_local_pressed() -> void:
	add_player_local(multiplayer.get_unique_id(), controls1)
	add_player_local(multiplayer.get_unique_id(), controls2)
	#multiplayer_ui.hide()


func _on_start_pressed() -> void:
	start_game.rpc()
		
@rpc("any_peer", "call_local")
func start_game() -> void:
	if GameManager.is_player_1_set() && GameManager.is_player_2_set():
		remove_child(GameManager.get_player_1())
		remove_child(GameManager.get_player_2())
		get_tree().change_scene_to_file("res://scenes/game/game.tscn")
