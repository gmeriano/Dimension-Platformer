extends Node2D
class_name LevelManager
@onready var level_complete_zone_1: Node2D = $"../Dimension1/LevelCompleteZone1"
@onready var level_complete_zone_2: Node2D = $"../Dimension2/LevelCompleteZone2"
@onready var player_1_spawn: Marker2D = $"../Dimension1/Player1Spawn"
@onready var player_2_spawn: Marker2D = $"../Dimension2/Player2Spawn"
@onready var dimension_1: Node2D = $"../Dimension1"
@onready var dimension_2: Node2D = $"../Dimension2"

var players: Array[Player] = []
var cameras: Array[Camera2D] = []
var spawn_positions: Array[Marker2D]
var swapping = false
var level_complete = false

signal respawn_players

func _ready():
	dimension_2.global_position.y = dimension_1.global_position.y + Global.DIMENSION_OFFSET
	spawn_positions = [player_1_spawn, player_2_spawn]
	players = [GameManager.get_player_1(), GameManager.get_player_2()]
	for player in players:
		player.connect("respawn", Callable(self, "respawn_all_players"))

func _physics_process(_delta: float) -> void:
	
	handle_inputs()
	check_respawn()
	if multiplayer.is_server() and !level_complete:
		check_level_complete()

func check_level_complete() -> void:
	if level_complete_zone_1.complete == true and level_complete_zone_2.complete == true:
		if players[0].is_state_interactable() and players[1].is_state_interactable():
			level_complete = true
			GameManager.load_next_level.rpc()

func check_respawn():
	for player in players:
		if player.is_multiplayer_authority():
			if player.should_respawn():
				respawn_all_players.rpc()
				break

func handle_inputs() -> void:
	if !swapping and (InputManager.is_dimension_swap_pressed(players[0]) or InputManager.is_dimension_swap_pressed(players[1])):
		swapping = true
		dimension_swap.rpc()
		await reset_swapping_delay()

@rpc("any_peer", "call_local")
func dimension_swap():
	for player in players:
		player.state_machine.transition(PlayerDimensionSwapState.state_name)

@rpc("any_peer", "call_local")
func respawn_all_players():
	GameManager.set_players_state_respawn()
	GameManager.reload_current_level()
	# TODO cleanup despawn_objects and code like this now that we fully reset the level on respawn
	#GameManager.set_players_state_respawn()
	#TransitionScreen.transition()
	#TransitionScreen.connect("on_transition_finished", Callable(self, "_on_transition_finished_respawn"))
	#TransitionScreen.connect("on_fade_to_normal_finished", Callable(GameManager, "_on_fade_to_normal_finished_can_move_true"))
	#despawn_objects()

func _on_transition_finished_respawn():
	TransitionScreen.disconnect("on_transition_finished", Callable(self, "_on_transition_finished_respawn"))
	for i in range(players.size()):
		var player = players[i]
		player.on_respawn.rpc(spawn_positions[i].global_position)
	GameManager.get_camera_1().reset()
	GameManager.get_camera_2().reset()
	reset_platforms()
	respawn_players.emit()

func reset_platforms() -> void:
	reset_player_entered_switch_platforms()
	reset_moving_platforms()

func despawn_objects() -> void:
	for fireball in get_tree().get_nodes_in_group("fireballs"):
		fireball.queue_free()
	for object in get_tree().get_nodes_in_group("despawn"):
		object.queue_free()
	
func reset_player_entered_switch_platforms() -> void:
	for node in get_tree().get_nodes_in_group("player_entered_switch_platform"):
		var player_entered_switch_platform = node as PlayerEnteredSwitchPlatform
		player_entered_switch_platform.switch_platform.respawn()

func reset_moving_platforms() -> void:
	for node in get_tree().get_nodes_in_group("moving_platform"):
		var moving_platform = node as MovingPlatform
		moving_platform.respawn() 

func reset_swapping_delay() -> void:
	await get_tree().create_timer(1.0).timeout  # 1 second delay
	swapping = false
