extends Camera2D

@export var normal_camera_zoom = 1.0
@export var dimension = 1  # 1 or 2
@export var edge_threshold: float = 0.0

var player1: Player = GameManager.get_player_1()
var player2: Player = GameManager.get_player_2()

var initial_position: Vector2

const CAMERA_LERP_SPEED := 120.0  # Pixels per second
var prev = 0.0

func _ready() -> void:
	global_position.x = get_viewport_rect().size.x + get_viewport_rect().size.x / 2.0
	zoom = Vector2(normal_camera_zoom, normal_camera_zoom)
	initial_position = position
	#position_smoothing_enabled = false  # Disable built-in smoothing
	
	#limit_left = 0
	if dimension == 1:
		limit_bottom = 0
	if dimension == 2:
		initial_position.y += Global.DIMENSION_OFFSET
		limit_bottom = Global.DIMENSION_OFFSET

func _physics_process(delta: float) -> void:
	_update_camera_logic(delta)
	#call_deferred("_update_camera_logic", delta)

func _update_camera_logic(delta: float) -> void:
	if edge_threshold == 0:
		edge_threshold = get_viewport_rect().size.x * 0.2

	if player1.state_machine.current_state.get_state_name() != PlayerDimensionSwapState.state_name \
	and player2.state_machine.current_state.get_state_name() != PlayerDimensionSwapState.state_name:
		set_x_position(delta)

func reset() -> void:
	position = initial_position

func set_x_position(delta: float) -> void:
	var viewport_width = get_viewport_rect().size.x / zoom.x
	var half_width = viewport_width * 0.5
	var camera_pos_x = position.x

	var left_edge = camera_pos_x - half_width + edge_threshold
	var right_edge = camera_pos_x + half_width - edge_threshold

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
		#print("P1: ", p1_outside, " P2: ", p2_outside)
		var target_x = p1_x if p1_outside else p2_x
		prev = position.x
		position.x = move_toward(position.x, target_x, CAMERA_LERP_SPEED * delta)
		position.x = round(position.x)  # <--- important
		#print("CAM: ", position.x)

		#print("CAM: ", position.x - prev)
		#var direction = sign(target_x - position.x)
		#var move_amount = CAMERA_LERP_SPEED * delta
		#var distance_to_target = abs(target_x - position.x)
#
		#if move_amount >= distance_to_target:
			#position.x = target_x
		#else:
			#position.x += direction * move_amount
		#var actual = position
		#var cam_subpixel_offset = actual.round() - actual
		#if true:
			#print("OFFSET: ", cam_subpixel_offset)
			#get_parent().get_parent().material.set_shader_parameter("cam_offset", cam_subpixel_offset)
	## Pixel-perfect final snap
	#position.x = round(position.x)

func get_active_player() -> Player:
	return player1 if player1.current_dimension == dimension else player2

func get_other_player() -> Player:
	return player1 if player1.current_dimension != dimension else player2
