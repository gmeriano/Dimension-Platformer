extends Camera2D

@export var normal_camera_zoom = 1.5
@export var dimension = 1  # 1 or 2
@export var edge_threshold: float = 0.0

var player1: Player = GameManager.get_player_1()
var player2: Player = GameManager.get_player_2()

var initial_position: Vector2

func _ready() -> void:
	zoom = Vector2(normal_camera_zoom, normal_camera_zoom)
	initial_position = global_position
	
	limit_left = 0
	if dimension == 1:
		limit_bottom = 0
	if dimension == 2:
		initial_position.y += Global.DIMENSION_OFFSET
		limit_bottom = Global.DIMENSION_OFFSET

func _physics_process(delta: float) -> void:
	call_deferred("_update_camera_logic", delta)

func _update_camera_logic(delta: float) -> void:
	var camera_pos = get_screen_center_position()

	if edge_threshold == 0:
		edge_threshold = get_viewport_rect().size.x * 0.33

	if player1.state_machine.current_state.get_state_name() != PlayerDimensionSwapState.state_name \
	and player2.state_machine.current_state.get_state_name() != PlayerDimensionSwapState.state_name:
		set_x_position(delta)

func reset() -> void:
	global_position = initial_position.round()

func set_x_position(delta: float) -> void:
	var viewport_width = get_viewport_rect().size.x / zoom.x
	var half_width = viewport_width * 0.5
	var camera_pos_x = global_position.x
	
	var left_edge = camera_pos_x - half_width + edge_threshold
	var right_edge = camera_pos_x + half_width - edge_threshold

	var p1_x = player1.global_position.x
	var p2_x = player2.global_position.x

	# Only move camera if necessary
	if p1_x < left_edge or p1_x > right_edge or p2_x < left_edge or p2_x > right_edge:
		var mid_x = (p1_x + p2_x) * 0.5

		global_position.x = lerp(global_position.x, mid_x, 1.0 * delta)

func get_active_player() -> Player:
	return player1 if player1.current_dimension == dimension else player2

func get_other_player() -> Player:
	return player1 if player1.current_dimension != dimension else player2
