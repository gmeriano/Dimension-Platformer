extends Camera2D

@export var normal_camera_zoom = 1.5
@export var dimension = 1  # 1 or 2

var player1: Player = GameManager.get_player_1()
var player2: Player = GameManager.get_player_2()

var initial_position: Vector2

func _ready() -> void:
	zoom = Vector2(normal_camera_zoom, normal_camera_zoom)
	initial_position = global_position
	if dimension == 2:
		initial_position.y += Global.DIMENSION_OFFSET

func _process(delta: float) -> void:
	if !player1.is_tweening and !player2.is_tweening:
		set_x_position()

func reset() -> void:
	global_position = initial_position
	zoom = Vector2(normal_camera_zoom, normal_camera_zoom)

func set_x_position() -> void:
	if (player1.state_machine.current_state.get_state_name() != PlayerDimensionSwapState.state_name or player2.state_machine.current_state.get_state_name() != PlayerDimensionSwapState.state_name):
		global_position.x = (player1.global_position.x + player2.global_position.x) * 0.5

func get_active_player() -> Player:
	return player1 if player1.current_dimension == dimension else player2

func get_other_player() -> Player:
	return player1 if player1.current_dimension != dimension else player2
