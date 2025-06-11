extends Node2D
class_name LevelManager
@onready var level_complete_zone: Node2D = $"../LevelCompleteZone"
@onready var level_complete_zone_2: Node2D = $"../LevelCompleteZone2"
@onready var player_1_spawn: Marker2D = $"../Player1Spawn"
@onready var player_2_spawn: Marker2D = $"../Player2Spawn"

var players: Array[Player] = []
var spawn_positions: Array[Marker2D]
var swapping = false
var level_complete = false

signal respawn_players

func _ready():
	spawn_positions = [player_1_spawn, player_2_spawn]
	players = [GameManager.get_player_1(), GameManager.get_player_2()]
	for player in players:
		player.connect("respawn", Callable(self, "respawn_all_players"))

func _physics_process(_delta: float) -> void:
	handle_inputs()
	if Global.IS_ONLINE_MULTIPLAYER:
		if multiplayer.is_server():
			check_level_complete_or_respawn()
	else:
		check_level_complete_or_respawn()

func check_level_complete_or_respawn():
	if !level_complete:
		check_level_complete()
		if level_complete:
			return
		for player in players:
			if player.can_move && player.should_respawn():
				print("respawning")
				respawn_all_players()
				break

func handle_inputs() -> void:
	if !swapping and (InputManager.is_dimension_swap_pressed(players[0]) or InputManager.is_dimension_swap_pressed(players[1])):
		swapping = true
		dimension_swap()
		await reset_swapping_delay()

func dimension_swap():
	if Global.IS_ONLINE_MULTIPLAYER:
		dimension_swap_remote.rpc()
	else:
		_dimension_swap()

@rpc("any_peer", "call_local")
func dimension_swap_remote() -> void:
	_dimension_swap()

func _dimension_swap():
	for player in players:
		player.swap_dimension()

func respawn_all_players():
	if Global.IS_ONLINE_MULTIPLAYER:
		respawn_all_players_remote.rpc()
	else:
		_respawn_all_players()

@rpc("any_peer", "call_local")
func respawn_all_players_remote():
	_respawn_all_players()

func _respawn_all_players():
	GameManager.set_can_move(false)
	TransitionScreen.transition()
	TransitionScreen.connect("on_transition_finished", Callable(self, "_on_transition_finished_respawn"))
	TransitionScreen.connect("on_fade_to_normal_finished", Callable(GameManager, "_on_fade_to_normal_finished_can_move_true"))
	despawn_objects()

func _on_transition_finished_respawn():
	TransitionScreen.disconnect("on_transition_finished", Callable(self, "_on_transition_finished_respawn"))
	for i in range(players.size()):
		var player = players[i]
		player.on_respawn(spawn_positions[i].global_position)
	reset_platforms()

func reset_platforms() -> void:
	reset_player_entered_switch_platforms()
	reset_moving_platforms()
	
func reset_player_entered_switch_platforms() -> void:
	for node in get_tree().get_nodes_in_group("player_entered_switch_platform"):
		var player_entered_switch_platform = node as PlayerEnteredSwitchPlatform
		player_entered_switch_platform.switch_platform.respawn()

func reset_moving_platforms() -> void:
	for node in get_tree().get_nodes_in_group("moving_platform"):
		var moving_platform = node as MovingPlatform
		moving_platform.respawn() 

func despawn_objects() -> void:
	for fireball in get_tree().get_nodes_in_group("fireballs"):
		fireball.queue_free()

func check_level_complete() -> void:
	if level_complete_zone.complete == true and level_complete_zone_2.complete == true:
		level_complete = true
		GameManager.load_next_level()

func reset_swapping_delay() -> void:
	await get_tree().create_timer(1.0).timeout  # 1 second delay
	swapping = false
