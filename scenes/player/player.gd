extends CharacterBody2D
class_name Player

@export var controls: Resource = null
@export var current_dimension: int = 1

@onready var player_shadow: Sprite2D = $PlayerShadow
@onready var collision_shape_2d: CollisionShape2D = $CollisionShape2D
#@onready var color_rect: ColorRect = $ColorRect
@onready var multiplayer_synchronizer: MultiplayerSynchronizer = $MultiplayerSynchronizer
@onready var state_machine: StateMachine = $StateMachine
@onready var player_sprite: Sprite2D = $PlayerSprite
@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D

#var color: Color
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
var original_dimension = 1
var tween: Tween = null
#var sprite_texture: Texture2D = preload("res://assets/sprites/player/cat.png")

# Respawn vars
var respawn_point: Vector2 = Vector2.ZERO
var possible_respawn_point: UpdateRespawnArea = null
var update_respawn: bool = false

# Jump vars
var frames_since_last_on_ground = 0
var coyote_time_frames = 5
var double_jump = true
var jump_velocity = -200
var was_on_wall = false
var last_wall_direction: Vector2 = Vector2.ZERO
var last_wall_jump_direction: Vector2 = Vector2.ZERO
var jump_buffer_time : float = 0.2
var jump_buffer_timer : float= 0.0
var jump_input_buffered : bool = false
@onready var right_ray_cast: RayCast2D = $RightRayCast
@onready var left_ray_cast: RayCast2D = $LeftRayCast


# Movement vars
var speed: float = Global.MOVESPEED
var friction: int = 2000
var air_resistance: int = 1000

# Input vars
var input_axis: float
var jump_input: bool
var jump_cut_input: bool

# Controller vars
var device_id: int = 0
var controller_id: int = 0
var use_controller: bool = false
const JUMP_BUTTON: int = 0		# JOY_BUTTON_0 (bottom button: Cross/A)
const MOVE_AXIS: int = 0			# JOY_AXIS_LEFT_X (left stick horizontal)

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
			GameManager.set_player_1(self)
		elif is_multiplayer_authority() and !multiplayer.is_server():
			GameManager.set_player_2(self)
			current_dimension = 2
			original_dimension = 2
			#sprite_texture = load("res://assets/sprites/background/white-cat-test.png")
			#player_sprite.texture = sprite_texture
		elif !is_multiplayer_authority() and !multiplayer.is_server():
			GameManager.set_player_1(self)
		else:
			GameManager.set_player_2(self)
			current_dimension = 2
			original_dimension = 2
			#sprite_texture = load("res://assets/sprites/background/white-cat-test.png")
			#player_sprite.texture = sprite_texture
		controls = load("res://assets/resources/player1_movement.tres")

func _ready():
	#animated_sprite_2d.play("default")
	#player_sprite.texture = sprite_texture
	update_shadow_location()
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
	if jump_input_buffered:
		jump_buffer_timer -= delta
		if jump_buffer_timer <= 0:
			jump_input_buffered = false
	if jump_input:
		jump_input_buffered = true
		jump_buffer_timer = jump_buffer_time

	jump_cut_input = InputManager.is_jump_just_released(self)

	# Movement input processing
	input_axis = InputManager.get_input_axis(self)

	# General physics processing
	if is_state_interactable():
		handle_gravity(delta)
		apply_air_resistance(delta)
		get_wall_direction()
		clamp_x_by_camera()

	# Debug: log extreme fall speeds for diagnosis
	if velocity.y > 1000:
		print("High fall speed:", velocity.y, "pos:", global_position)

	move_and_slide()
	position.x = round(position.x)

func get_wall_direction() -> Vector2:
	if right_ray_cast.is_colliding():
		last_wall_direction = Vector2.RIGHT
		return Vector2.RIGHT
	elif left_ray_cast.is_colliding():
		last_wall_direction = Vector2.LEFT
		return Vector2.LEFT
	else:
		last_wall_direction = Vector2.ZERO
		return Vector2.ZERO

# Try small diagonal and cardinal movements to escape the collision
func unstick_player_if_necessary() -> bool:
	var offset_distance: float = collision_shape_2d.shape.get_rect().size.x
	var directions : Array[Vector2] = [
		Vector2(0, -1), Vector2(1, 0), Vector2(0, 1), Vector2(-1, 0),
		Vector2(1, -1), Vector2(1, 1), Vector2(-1, 1), Vector2(-1, -1)
	]

	# Only try to unstick if we're colliding at the current position
	if test_move(global_transform, Vector2.ZERO):
		# first pass (small step)
		for dir in directions:
			var offset: Vector2 = dir.normalized() * offset_distance
			var test_transform: Transform2D = global_transform.translated(offset)
			if not test_move(test_transform, Vector2.ZERO):
				global_position += offset
				return false
		# second pass (bigger step)
		for dir in directions:
			var offset: Vector2 = dir.normalized() * (offset_distance + 2)
			var test_transform: Transform2D = global_transform.translated(offset)
			if not test_move(test_transform, Vector2.ZERO):
				global_position += offset
				return false
		# final pass (largest step)
		for dir in directions:
			var offset: Vector2 = dir.normalized() * (offset_distance + 3)
			var test_transform: Transform2D = global_transform.translated(offset)
			if not test_move(test_transform, Vector2.ZERO):
				global_position += offset
				return false
		send_respawn_signal.rpc()
		return true
	return false

func handle_gravity(delta):
	if not is_on_floor():
		frames_since_last_on_ground += 1
		if get_wall_direction() != Vector2.ZERO and velocity.y > 0:
			velocity.y += (gravity * 0.5) * delta
		else:
			velocity.y += gravity * delta
	else:
		frames_since_last_on_ground = 0

func apply_friction(_delta):
	# Only apply friction if not accelerating and on floor, AND not actively wall sliding
	if input_axis == 0 and is_on_floor():
		#velocity.x = move_toward(velocity.x, 0, friction * delta)
		velocity.x = 0

func apply_air_resistance(delta):
	if input_axis == 0 and not is_on_floor():
		velocity.x = move_toward(velocity.x, 0, air_resistance * delta)

var wall_jump_timer: float = 0.2

func handle_acceleration(_delta):
	if input_axis == 0:
		return
	#var acceleration: float = air_resistance
	#var direction_switch_boost: int = 10
	#var current_direction: int = sign(velocity.x)
	#var input_direction: int = sign(input_axis)
	#var boost_multiplier: float = 1.0
	#if current_direction != 0 and input_direction != 0 and input_direction != current_direction:
	#    boost_multiplier = direction_switch_boost

	# if is_on_floor():
	#     acceleration = air_resistance
	# else:
	#     acceleration = air_resistance * 2.0
	if wall_jump_timer > 0:
		wall_jump_timer -= _delta
		return

	var target_speed: float = speed * input_axis
	#var acceleration_amount: float = acceleration * boost_multiplier
	velocity.x = target_speed
	#velocity.x = move_toward(velocity.x, target_speed, acceleration_amount * delta)

func clamp_x_by_camera():
	var new_x: float = global_position.x
	if not is_within_camera_left(new_x):
		new_x = GameManager.get_camera_1().global_position.x - ((GameManager.get_camera_1().get_viewport_rect().size.x / GameManager.get_camera_1().zoom.x) / 2.0) + (collision_shape_2d.shape.get_rect().size.x / 2)
	if not is_within_camera_right(new_x):
		new_x = GameManager.get_camera_1().global_position.x + ((GameManager.get_camera_1().get_viewport_rect().size.x / GameManager.get_camera_1().zoom.x) / 2.0) - (collision_shape_2d.shape.get_rect().size.x / 2)
	global_position.x = new_x

func is_within_camera_right(x_pos: float) -> bool:
	if GameManager.get_camera_1() && GameManager.get_camera_2():
		var player_half_size: float = collision_shape_2d.shape.get_rect().size.x / 2.0
		return x_pos + player_half_size <= GameManager.get_camera_right_edge()
	return true

func is_within_camera_left(x_pos: float) -> bool:
	if GameManager.get_camera_1() && GameManager.get_camera_2():
		var player_half_size: float = collision_shape_2d.shape.get_rect().size.x / 2
		return x_pos - player_half_size >= GameManager.get_camera_left_edge()
	return true

@rpc("any_peer", "call_local")
func on_respawn(respawn_position: Vector2) -> void:
	global_position = respawn_position
	velocity = Vector2.ZERO
	current_dimension = original_dimension
	update_shadow_location()

func should_respawn() -> bool:
	if !is_state_interactable():
		return false
	if current_dimension == 1:
		var top_camera: Camera2D = GameManager.get_camera_1()
		var viewport_size: Vector2 = top_camera.get_viewport_rect().size
		var half_height: float = (viewport_size.y / top_camera.zoom.y) / 2.0
		var camera_bottom_y: float = top_camera.global_position.y + half_height + 32
		return global_position.y > camera_bottom_y
	else:
		var bottom_camera: Camera2D = GameManager.get_camera_2()
		var viewport_size: Vector2 = bottom_camera.get_viewport_rect().size
		var half_height: float = (viewport_size.y / bottom_camera.zoom.y) / 2.0
		var camera_bottom_y: float = bottom_camera.global_position.y + half_height + 32
		return global_position.y > camera_bottom_y

@rpc("any_peer", "call_local")
func send_respawn_signal() -> void:
	emit_signal("respawn")

func on_hit() -> void:
	send_respawn_signal.rpc()

func is_state_interactable() -> bool:
	return state_machine.current_state.get_state_name() != PlayerDimensionSwapState.state_name and state_machine.current_state.get_state_name() != PlayerRespawnState.state_name
