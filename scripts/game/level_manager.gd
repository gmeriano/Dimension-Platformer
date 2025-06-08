extends Node2D
class_name LevelManager
@onready var level_complete_zone: Node2D = $"../LevelCompleteZone"
@onready var level_complete_zone_2: Node2D = $"../LevelCompleteZone2"
@onready var player_1_spawn: Marker2D = $"../Player1Spawn"
@onready var player_2_spawn: Marker2D = $"../Player2Spawn"


var players: Array[Player] = []
var spawn_positions: Array[Marker2D]
var swapping = false

signal respawn_players

func _ready():
	spawn_positions = [player_1_spawn, player_2_spawn]
	players = [GameManager.get_player_1(), GameManager.get_player_2()]
	for player in players:
		player.connect("respawn", Callable(self, "_respawn_all_players"))
	
func _process(delta: float) -> void:
	handle_inputs()
	check_level_complete()

func handle_inputs() -> void:
	var swap_pressed = false
	#if Global.IS_ONLINE_MULTIPLAYER:
		#swap_pressed = (InputManager.is_dimension_swap_pressed(players[0]) && players[0].is_multiplayer_authority()) || (InputManager.is_dimension_swap_pressed(players[1]) && players[1].is_multiplayer_authority())
	#else:
		#swap_pressed = InputManager.is_dimension_swap_pressed(players[0]) || InputManager.is_dimension_swap_pressed(players[1])
	if !swapping && (InputManager.is_dimension_swap_pressed(players[0]) || InputManager.is_dimension_swap_pressed(players[1])):
		swapping = true
		for player in players:
			player.swap_dimension.rpc()
		await reset_swapping_delay()
	if Input.is_action_just_pressed("switch_scene"):
		GameManager.load_next_level()

func _respawn_all_players():
	set_can_move(false)
	TransitionScreen.transition()
	TransitionScreen.connect("on_transition_finished", Callable(self, "_on_transition_finished_respawn"))
	
func _on_transition_finished_respawn():
	TransitionScreen.disconnect("on_transition_finished", Callable(self, "_on_transition_finished_respawn"))
	for i in range(players.size()):
		var player = players[i]
		#if player.is_multiplayer_authority():
		print("I: ", i)
		player.on_respawn.rpc(spawn_positions[i].global_position)
	set_can_move(true)
	
func set_can_move(can_move: bool) -> void:
	players[0].can_move = can_move
	players[1].can_move = can_move
	
func check_level_complete() -> void:
	if level_complete_zone.complete == true and level_complete_zone_2.complete == true:
		GameManager.load_next_level.rpc()

func reset_swapping_delay() -> void:
	await get_tree().create_timer(1.0).timeout  # 1 second delay
	swapping = false
	
