extends Camera2D

@export var normal_camera_zoom = 1.0
@export var dimension = 1  # 1 or 2

var player1: Player = GameManager.get_player_1()
var player2: Player = GameManager.get_player_2()

var initial_position: Vector2
var left_edge_threshold: float = 0.0
var right_edge_threshold: float = 0.0
var left_edge_threshold_percentage: float = 0.2
var right_edge_threshold_percentage: float = 0.4

var CAMERA_LERP_SPEED: float = Global.MOVESPEED  # Pixels per second

func _ready() -> void:
	print("GLOB POS: ", global_position)
	global_position.x = get_viewport_rect().size.x + get_viewport_rect().size.x / 2.0
	zoom = Vector2(normal_camera_zoom, normal_camera_zoom)
	initial_position = position
	left_edge_threshold = get_viewport_rect().size.x * left_edge_threshold_percentage
	right_edge_threshold = get_viewport_rect().size.x * right_edge_threshold_percentage

	# TODO mess around with this more
	position_smoothing_enabled = false  # Disable built-in smoothing
	#position_smoothing_speed = 100
    
	if dimension == 1:
		limit_bottom = 0
	if dimension == 2:
		initial_position.y += Global.DIMENSION_OFFSET
		limit_bottom = Global.DIMENSION_OFFSET

func _physics_process(delta: float) -> void:
	_update_camera_logic(delta)

func _update_camera_logic(delta: float) -> void:        
	if player1.state_machine.current_state.get_state_name() != PlayerDimensionSwapState.state_name \
	and player2.state_machine.current_state.get_state_name() != PlayerDimensionSwapState.state_name:
		set_x_position(delta)

func reset() -> void:
	position = initial_position

func set_x_position(delta: float) -> void:
	var viewport_width = get_viewport_rect().size.x / zoom.x
	var half_width = viewport_width * 0.5
	var camera_pos_x = position.x

	var left_edge = camera_pos_x - half_width + left_edge_threshold
	var right_edge = camera_pos_x + half_width - right_edge_threshold

	var p1_x = player1.global_position.x
	var p2_x = player2.global_position.x

	var p1_outside_left = p1_x < left_edge 
	var p1_outside_right = p1_x > right_edge
	var p2_outside_left = p2_x < left_edge 
	var p2_outside_right = p2_x > right_edge
	var p1_outside = p1_outside_left or p1_outside_right
	var p2_outside = p2_outside_left or p2_outside_right

	# Only move toward the one violating the boundary
	if p1_outside != p2_outside or (p1_outside_left and p2_outside_left) or (p1_outside_right and p2_outside_right):
		var midpoint_x = p1_x if p1_outside else p2_x
        
		var target_x = move_toward(position.x, midpoint_x, CAMERA_LERP_SPEED * delta)

		# Don't move camera behind x = 0 boundary
		if target_x < half_width:
			return
		position.x = target_x
		position.x = round(position.x * zoom.x) / zoom.x

func get_active_player() -> Player:
	return player1 if player1.current_dimension == dimension else player2

func get_other_player() -> Player:
	return player1 if player1.current_dimension != dimension else player2
