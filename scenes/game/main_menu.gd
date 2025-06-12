extends Node

const PLAYER = preload("res://scenes/player/Player.tscn")
@onready var multiplayer_ui = $UI/Multiplayer
@onready var player_1_spawn: Marker2D = $Player1Spawn
@onready var player_2_spawn: Marker2D = $Player2Spawn
@onready var oid_lbl: Label = $UI/Multiplayer/VBoxContainer/OID
@onready var oid_input: LineEdit = $UI/Multiplayer/VBoxContainer/OIDInput

var peer
var controls1 = preload("res://assets/resources/player1_movement.tres")
var controls2 = preload("res://assets/resources/player2_movement.tres")

func _ready():
	set_oid()
	

func set_oid():
	await Multiplayer.noray_connected
	oid_lbl.text = Noray.oid

func _on_host_pressed():
	Global.IS_ONLINE_MULTIPLAYER = true
	Multiplayer.host()
	
	multiplayer.peer_connected.connect(
		func(pid):
			print("Peer " + str(pid) + " has joined the game!")
			add_player_online(pid)
	)
	
	add_player_online(multiplayer.get_unique_id())

func _on_join_pressed():
	Global.IS_ONLINE_MULTIPLAYER = true
	Multiplayer.join(oid_input.text)

func add_player_online(pid):
	var player = PLAYER.instantiate()
	player.name = str(pid)
	player.set_multiplayer_authority(int(str(pid)))
	
	add_child(player)
	
	set_player_positions_in_menu.rpc(player.name)

@rpc("any_peer", "call_local")
func set_player_positions_in_menu(player_name: String):
	var player = get_node(player_name)
	if player.is_multiplayer_authority():
		if multiplayer.is_server():
			player.global_position = player_1_spawn.global_position
		else:
			player.global_position = player_2_spawn.global_position
		

func _on_local_pressed() -> void:
	var player1 = PLAYER.instantiate()
	player1.controls = load("res://assets/resources/player1_movement.tres")
	var player2 = PLAYER.instantiate()
	player2.controls = load("res://assets/resources/player2_movement.tres")
	player1.color = Color.GREEN
	player2.color = Color.RED
	player1.global_position = player_1_spawn.global_position
	player2.global_position = player_2_spawn.global_position
	player2.current_dimension = 1
	player2.original_dimension = 1
	GameManager.set_player_1(player1)
	GameManager.set_player_2(player2)
	add_child(player1)
	add_child(player2)

func _on_start_pressed() -> void:
	start_game()


func start_game() -> void:
	if Global.IS_ONLINE_MULTIPLAYER:
		start_game_remote.rpc()
		return
	_start_game()

@rpc("any_peer", "call_local")
func start_game_remote() -> void:
	_start_game()

func _start_game() -> void:
	if GameManager.is_player_1_set() && GameManager.is_player_2_set():
		remove_child(GameManager.get_player_1())
		remove_child(GameManager.get_player_2())
		GameManager.set_can_move(false)
		TransitionScreen.transition()
		TransitionScreen.connect("on_transition_finished", Callable(self, "_on_transition_finished_start_game"))
		TransitionScreen.connect("on_fade_to_normal_finished", Callable(GameManager, "_on_fade_to_normal_finished_can_move_true"))

func _on_transition_finished_start_game():
	TransitionScreen.disconnect("on_transition_finished", Callable(self, "_on_transition_finished_start_game"))
	get_tree().change_scene_to_file("res://scenes/game/game.tscn")

func _on_copy_oid_pressed() -> void:
	DisplayServer.clipboard_set(Noray.oid)
