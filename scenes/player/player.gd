extends CharacterBody2D
class_name Player

signal respawn

@export var controls: Resource = null
@export var current_dimension: int = 1

@onready var player_shadow: Sprite2D = $PlayerShadow
@onready var collision_shape_2d: CollisionShape2D = $CollisionShape2D
@onready var color_rect: ColorRect = $ColorRect
@onready var multiplayer_synchronizer: MultiplayerSynchronizer = $MultiplayerSynchronizer
@onready var state_machine: StateMachine = $StateMachine

var color: Color
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
var original_dimension = 1
var tween: Tween = null
var respawn_point: Vector2

# Jump vars
var frames_since_last_on_ground = 0
var coyote_time_frames = 10
var double_jump = true
var jump_velocity = -300
var wall_coyote_time = 0.15  # 150 ms grace period
var wall_coyote_timer = 0.0
var was_on_wall = false
var last_wall_direction = 0  # -1 for left, 1 for right, 0 for none
var jump_buffer_time := 0.15
var jump_buffer_timer := 0.0
var jump_input_buffered := false
var wall_direction = 0 # -1 for left wall, 1 for right wall, 0 for no wall

# Movement vars
var speed = 125
var friction = 600
var air_resistance = 500

# Input vars
var input_axis: float
var jump_input: bool
var jump_cut_input: bool

# Controller vars
var device_id: int = 0
var controller_id: int = 0
var use_controller = false
const JUMP_BUTTON = 0		# JOY_BUTTON_0 (bottom button: Cross/A)
const MOVE_AXIS = 0			# JOY_AXIS_LEFT_X (left stick horizontal)

# State Machine vars
var prev_state: String
var jump_states: Array[String] = [
	PlayerJumpState.state_name,
	PlayerDoubleJumpState.state_name,
	PlayerWallJumpState.state_name,
]

func _enter_tree():
	if Global.IS_ONLINE_MULTIPLAYER:
		set_multiplayer_authority(int(str(name)))
		if is_multiplayer_authority() and multiplayer.is_server():
			color = Color.GREEN
			GameManager.set_player_1(self)
		elif is_multiplayer_authority() and !multiplayer.is_server():
			color = Color.RED
			GameManager.set_player_2(self)
			current_dimension = 2
			original_dimension = 2
		elif !is_multiplayer_authority() and !multiplayer.is_server():
			color = Color.GREEN
			GameManager.set_player_1(self)
		else:
			GameManager.set_player_2(self)
			current_dimension = 2
			original_dimension = 2
			color = Color.RED
		controls = load("res://assets/resources/player1_movement.tres")

func _ready():
	color_rect.color = color
	var shadow_color = color
	shadow_color.a = 0.6
	player_shadow.modulate = shadow_color
	update_shadow_location()
	respawn_point = global_position
	var states: Array[State] = [
		PlayerIdleState.new(self),
		PlayerMovementState.new(self),
		PlayerJumpState.new(self),
		PlayerDoubleJumpState.new(self),
		PlayerFallState.new(self),
		PlayerDimensionSwapState.new(self),
		PlayerWallSlideState.new(self),
		PlayerWallJumpState.new(self),
		PlayerRespawnState.new(self),
	]
	prev_state = states[0].get_state_name()
	state_machine.start_machine(states)

func is_on_ground() -> bool:
	return is_on_floor()

func update_shadow_location() -> void:
	player_shadow.offset = Vector2.ZERO
	if (current_dimension == 1):
		# times 2 bc we scaled sprite by 0.5, + 16 to match rect exactly
		player_shadow.offset.y = Global.DIMENSION_OFFSET * 2 - 16
	elif (current_dimension == 2):
		player_shadow.offset.y = -Global.DIMENSION_OFFSET * 2 - 16

func _physics_process(delta: float) -> void:
	if Global.IS_ONLINE_MULTIPLAYER && !is_multiplayer_authority():
		return
		
	# Jump input processing
	jump_input = InputManager.is_jump_just_pressed(self)
	if jump_input:
		jump_input_buffered = true
		jump_buffer_timer = jump_buffer_time
	if jump_input_buffered:
		jump_buffer_timer -= delta
		if jump_buffer_timer <= 0:
			jump_input_buffered = false
	jump_cut_input = InputManager.is_jump_just_released(self)
	
	# Movement input processing
	input_axis = InputManager.get_input_axis(self)
	
	# General physics processing
	if is_state_interactable():
		handle_gravity(delta)
		apply_air_resistance(input_axis, delta)
		update_wall_coyote_timer(delta)
	
	# Apply movement
	move_and_slide()
	clamp_x_by_camera()


# Jump helper functions
func update_wall_coyote_timer(delta: float) -> void:
	var touching_left := is_on_wall_left()
	var touching_right := is_on_wall_right()
	var touching_wall := touching_left or touching_right

	if touching_wall:
		last_wall_direction = -1 if touching_left else 1
		wall_coyote_timer = wall_coyote_time
	else:
		wall_coyote_timer = max(0.0, wall_coyote_timer - delta)

func is_on_wall_right() -> bool:
	return is_on_wall_only() and get_last_slide_collision().get_normal().x < 0

func is_on_wall_left() -> bool:
	return is_on_wall_only() and get_last_slide_collision().get_normal().x > 0

func handle_wall_slide(delta: float, gravity_multiplier: float) -> void:
	if is_on_wall_left():
		wall_direction = -1
		if velocity.y > 0:
			velocity.y = min(velocity.y, gravity * gravity_multiplier)
	elif is_on_wall_right():
		wall_direction = 1
		if velocity.y > 0:
			velocity.y = min(velocity.y, gravity * gravity_multiplier)
	else:
		wall_direction = 0

# Try small diagonal and cardinal movements to escape the collision
func unstick_player_if_necessary() -> bool:
	var offset_distance = collision_shape_2d.shape.get_rect().size.x
	var directions = [
		Vector2(0, -1), Vector2(1, 0), Vector2(0, 1), Vector2(-1, 0),
		Vector2(1, -1), Vector2(1, 1), Vector2(-1, 1), Vector2(-1, -1)
	]

	# Only try to unstick if we're colliding at the current position
	if test_move(global_transform, Vector2.ZERO):
		# first pass (small step)
		for dir in directions:
			var offset = dir.normalized() * offset_distance
			var test_transform := global_transform.translated(offset)
			if not test_move(test_transform, Vector2.ZERO):
				global_position += offset
				return false
		# second pass (bigger step)
		for dir in directions:
			var offset = dir.normalized() * (offset_distance + 2)
			var test_transform := global_transform.translated(offset)
			if not test_move(test_transform, Vector2.ZERO):
				global_position += offset
				return false
		# final pass (largest step)
		for dir in directions:
			var offset = dir.normalized() * (offset_distance + 3)
			var test_transform := global_transform.translated(offset)
			if not test_move(test_transform, Vector2.ZERO):
				global_position += offset
				return false
		send_respawn_signal.rpc()
		return true
	return false

func handle_gravity(delta):
	if not is_on_floor():
		frames_since_last_on_ground += 1
		velocity.y += gravity * delta
	else:
		frames_since_last_on_ground = 0

func apply_friction(input_axis, delta):
	# Only apply friction if not accelerating and on floor, AND not actively wall sliding
	if input_axis == 0 and is_on_floor():
		velocity.x = move_toward(velocity.x, 0, friction * delta)

func apply_air_resistance(input_axis, delta):
	if input_axis == 0 and not is_on_floor():
		velocity.x = move_toward(velocity.x, 0, air_resistance * delta)

func handle_acceleration(input_axis, delta):
	if input_axis == 0:
		return
	var acceleration = air_resistance
	var direction_switch_boost = 10
	var current_direction = sign(velocity.x)
	var input_direction = sign(input_axis)
	var boost_multiplier = 1.0
	if current_direction != 0 and input_direction != 0 and input_direction != current_direction:
		boost_multiplier = direction_switch_boost

	if is_on_floor():
		acceleration = air_resistance
	else:
		if wall_direction != 0:
			acceleration = air_resistance * 0.5
		else:
			acceleration = air_resistance * 2.0

	var target_speed = speed * input_axis
	var acceleration_amount = acceleration * delta * boost_multiplier
	var new_velocity_x = move_toward(velocity.x, target_speed, acceleration_amount)

	var proposed_position_x = global_position.x + new_velocity_x * delta
	if !is_within_camera_left(proposed_position_x):
		new_velocity_x = max(0, new_velocity_x)
	elif !is_within_camera_right(proposed_position_x):
		new_velocity_x = min(0, new_velocity_x)
	velocity.x = new_velocity_x

func clamp_x_by_camera():
	var new_x = global_position.x
	if not is_within_camera_left(new_x):
		new_x = GameManager.get_camera_1().global_position.x - ((GameManager.get_camera_1().get_viewport_rect().size.x / GameManager.get_camera_1().zoom.x) / 2.0) + (collision_shape_2d.shape.get_rect().size.x / 2)
	if not is_within_camera_right(new_x):
		new_x = GameManager.get_camera_1().global_position.x + ((GameManager.get_camera_1().get_viewport_rect().size.x / GameManager.get_camera_1().zoom.x) / 2.0) - (collision_shape_2d.shape.get_rect().size.x / 2)
	global_position.x = new_x

func is_within_camera_right(x_pos: float) -> bool:
	if GameManager.get_camera_1() && GameManager.get_camera_2():
		var player_half_size = collision_shape_2d.shape.get_rect().size.x / 2
		return x_pos + player_half_size <= GameManager.get_camera_right_edge()
	return true

func is_within_camera_left(x_pos: float) -> bool:
	if GameManager.get_camera_1() && GameManager.get_camera_2():
		var player_half_size = collision_shape_2d.shape.get_rect().size.x / 2
		return x_pos - player_half_size >= GameManager.get_camera_left_edge()
	return true

@rpc("any_peer", "call_local")
func on_respawn(respawn_position: Vector2) -> void:
	global_position = respawn_position
	velocity = Vector2.ZERO
	current_dimension = original_dimension
	update_shadow_location()
	wall_direction = 0

func should_respawn() -> bool:
	if !is_state_interactable():
		return false
	if current_dimension == 1:
		var top_camera: Camera2D = GameManager.get_camera_1()
		var viewport_size := top_camera.get_viewport_rect().size
		var half_height := (viewport_size.y / top_camera.zoom.y) / 2.0
		var camera_bottom_y := top_camera.global_position.y + half_height + 32
		return global_position.y > camera_bottom_y
	else:
		var bottom_camera: Camera2D = GameManager.get_camera_2()
		var viewport_size := bottom_camera.get_viewport_rect().size
		var half_height := (viewport_size.y / bottom_camera.zoom.y) / 2.0
		var camera_bottom_y := bottom_camera.global_position.y + half_height + 32
		return global_position.y > camera_bottom_y

@rpc("any_peer", "call_local")
func send_respawn_signal() -> void:
	emit_signal("respawn")

func on_hit() -> void:
	send_respawn_signal.rpc()

func is_state_interactable() -> bool:
	return state_machine.current_state.get_state_name() != PlayerDimensionSwapState.state_name and state_machine.current_state.get_state_name() != PlayerRespawnState.state_name
