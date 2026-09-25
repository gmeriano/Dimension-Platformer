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
const CAMERA_VIEWPORT_SIZE := Vector2(1920.0, 540.0)

func _ready() -> void:
	global_position.x = CAMERA_VIEWPORT_SIZE.x / 2.0
	zoom = Vector2(normal_camera_zoom, normal_camera_zoom)
	initial_position = position
	left_edge_threshold = CAMERA_VIEWPORT_SIZE.x * left_edge_threshold_percentage
	right_edge_threshold = CAMERA_VIEWPORT_SIZE.x * right_edge_threshold_percentage
	

	# set this to true to break the game :/
	position_smoothing_enabled = false  # Disable built-in smoothing
	
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
	var viewport_width = CAMERA_VIEWPORT_SIZE.x / zoom.x
	var half_width = viewport_width * 0.5
	var camera_pos_x = global_position.x

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
		var player_outside = player1 if p1_outside else player2
		if p1_outside_left and p2_outside_left:
			player_outside = player1 if player1.global_position.x < player2.global_position.x else player2
		elif p1_outside_right and p2_outside_right:
			player_outside = player1 if player1.global_position.x > player2.global_position.x else player2
		var midpoint_x = player_outside.global_position.x
		
		var speed = abs(player_outside.get_velocity_for_camera())
		if speed == 0:
			speed = Global.MOVESPEED
		var target_x = global_position.x + sign(midpoint_x - global_position.x) * speed * delta
		
		# Don't move camera behind x = 0 boundary
		if target_x < half_width:
			return
		global_position.x = target_x
		global_position.x = round(global_position.x * zoom.x) / zoom.x

func get_active_player() -> Player:
	return player1 if player1.current_dimension == dimension else player2

func get_other_player() -> Player:
	return player1 if player1.current_dimension != dimension else player2
