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
		player.connect("dim_swap", Callable(self, "_dim_swap_all_players"))
	
func _physics_process(_delta: float) -> void:
	handle_inputs()
	check_level_complete()

func handle_inputs() -> void:
	if !swapping and (InputManager.is_dimension_swap_pressed(players[0]) or InputManager.is_dimension_swap_pressed(players[1])):
		swapping = true
		#teleport_players.rpc()
		print("pressed swap")
		request_dimension_swap.rpc()
		await reset_swapping_delay()

@rpc("any_peer", "call_local")
func request_dimension_swap() -> void:
	print("requesting swap")
	perform_tween()
	if multiplayer.is_server():
		handle_dimension_swap()

@rpc("any_peer", "call_local")
func teleport_all_players():
	for player in players:
		player._swap_dimension()

func perform_tween() -> void:
	var new_player1_position = Vector2.ZERO
	var new_player2_position = Vector2.ZERO
	if players[0].current_dimension == 0:
		players[0].move_to(Vector2(players[0].global_position.x, players[0].global_position.y + Global.DIMENSION_OFFSET))
		players[1].move_to(Vector2(players[1].global_position.x, players[1].global_position.y - Global.DIMENSION_OFFSET))
		#new_player1_position = players[0].global_position + Vector2(0, Global.DIMENSION_OFFSET)
		#new_player2_position = players[1].global_position - Vector2(0, Global.DIMENSION_OFFSET)
	else:
		players[0].move_to(Vector2(players[0].global_position.x, players[0].global_position.y - Global.DIMENSION_OFFSET))
		players[1].move_to(Vector2(players[1].global_position.x, players[1].global_position.y + Global.DIMENSION_OFFSET))
		#new_player1_position = players[0].global_position - Vector2(0, Global.DIMENSION_OFFSET)
		#new_player2_position = players[1].global_position + Vector2(0, Global.DIMENSION_OFFSET)
		
	#players[0].move_to(new_player1_position)
	#players[1].move_to(new_player2_position)

func handle_dimension_swap() -> void:
	if not multiplayer.is_server():
		return
	print("handling swap")
	#players[0]._swap_dimension()
	#players[1]._swap_dimension()
	var new_player1_position = Vector2.ZERO
	var new_player2_position = Vector2.ZERO
	if players[0].current_dimension == 0:
		new_player1_position = players[0].global_position + Vector2(0, Global.DIMENSION_OFFSET)
		new_player2_position = players[1].global_position - Vector2(0, Global.DIMENSION_OFFSET)
	else:
		new_player1_position = players[0].global_position - Vector2(0, Global.DIMENSION_OFFSET)
		new_player2_position = players[1].global_position + Vector2(0, Global.DIMENSION_OFFSET)

	players[0].update_player_position_rpc.rpc(new_player1_position)
	players[1].update_player_position_rpc.rpc(new_player2_position)
	#rpc("update_player_position_rpc", new_player1_position)
	#rpc("update_player_position_rpc", new_player2_position)

@rpc("any_peer")
func teleport_players():
	for player in players:
		player.rpc_id(player.get_multiplayer_authority(), "perform_teleport")

func _respawn_all_players():
	set_can_move(false)
	TransitionScreen.transition()
	TransitionScreen.connect("on_transition_finished", Callable(self, "_on_transition_finished_respawn"))

func _dim_swap_all_players():
	for player in players:
		if player.current_dimension == 0:
			player.global_position.y += 400
		else:
			player.global_position.y -= 400
			
func _on_transition_finished_respawn():
	TransitionScreen.disconnect("on_transition_finished", Callable(self, "_on_transition_finished_respawn"))
	for i in range(players.size()):
		var player = players[i]
		player.on_respawn(spawn_positions[i].global_position)
	reset_platforms()
	set_can_move(true)

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

func set_can_move(can_move: bool) -> void:
	players[0].can_move = can_move
	players[1].can_move = can_move
	
func check_level_complete() -> void:
	if level_complete_zone.complete == true and level_complete_zone_2.complete == true:
		GameManager.load_next_level()

func reset_swapping_delay() -> void:
	await get_tree().create_timer(1.0).timeout  # 1 second delay
	swapping = false
