extends CharacterBody2D
class_name Player

signal respawn

@export var controls: Resource = null
@export var current_dimension: int = 1
@onready var player_shadow: Sprite2D = $PlayerShadow
@onready var collision_shape_2d: CollisionShape2D = $CollisionShape2D
@onready var color_rect: ColorRect = $ColorRect
@onready var multiplayer_synchronizer: MultiplayerSynchronizer = $MultiplayerSynchronizer

@export var color: Color
var device_id: int = 0
var controller_id: int = 0
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
var frames_since_last_on_ground = 0
var coyote_time_frames = 10
var double_jump = true
var jump_velocity = -300

var speed = 125
var friction = 600
var air_resistance = 500
var can_move = true
var is_tweening = false
var use_controller = false
var previous_jump_pressed_for_controller = false
var respawn_point: Vector2

var original_dimension = 1
var tween: Tween = null

@export var wall_jump_push_off_x = 350.0 # Horizontal force away from the wall
@export var wall_jump_vertical_boost = -300.0 # Vertical force upwards
@export var wall_slide_gravity_multiplier = 0.5 # Slows down fall speed when sliding
@export var wall_jump_coyote_time_frames = 5 # Frames after leaving wall you can still wall jump
var frames_since_last_on_wall = 0
var wall_direction = 0 # -1 for left wall, 1 for right wall, 0 for no wall

const JUMP_BUTTON = 0		# JOY_BUTTON_0 (bottom button: Cross/A)
const MOVE_AXIS = 0			# JOY_AXIS_LEFT_X (left stick horizontal)

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
	shadow_color.a = 0.3
	player_shadow.modulate = shadow_color
	update_shadow_location()
	respawn_point = global_position

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
	if can_move:
		handle_gravity(delta)
		# --- NEW: Handle Wall Sliding before Jump ---
		handle_wall_slide(delta)
		handle_jump()
		var inputAxis = InputManager.get_input_axis(self)
		if inputAxis != 0:
			handle_acceleration(inputAxis, delta)
		# Apply friction/air resistance *after* accelerating
		apply_friction(inputAxis, delta)
		apply_air_resistance(inputAxis, delta)
		move_and_slide()
		clamp_x_by_camera()

# --- NEW FUNCTION: Wall Detection ---
func is_on_wall_right() -> bool:
	return is_on_wall_only() and get_last_slide_collision().get_normal().x < 0

func is_on_wall_left() -> bool:
	return is_on_wall_only() and get_last_slide_collision().get_normal().x > 0

# --- NEW FUNCTION: Handle Wall Slide ---
func handle_wall_slide(delta: float) -> void:
	if is_on_wall_left():
		wall_direction = -1
		frames_since_last_on_wall = 0
		if velocity.y > 0: # Only slow down if falling
			velocity.y = min(velocity.y, gravity * wall_slide_gravity_multiplier)
	elif is_on_wall_right():
		wall_direction = 1
		frames_since_last_on_wall = 0
		if velocity.y > 0: # Only slow down if falling
			velocity.y = min(velocity.y, gravity * wall_slide_gravity_multiplier)
	else:
		frames_since_last_on_wall += 1
		if frames_since_last_on_wall > wall_jump_coyote_time_frames:
			wall_direction = 0 # Reset wall direction if no longer on wall after coyote time

func clamp_x_by_camera():
	var new_x = global_position.x
	# Clamp to left camera bound
	if not is_within_camera_left(new_x):
		new_x = GameManager.get_camera_1().global_position.x - ((GameManager.get_camera_1().get_viewport_rect().size.x / GameManager.get_camera_1().zoom.x) / 2.0) + (collision_shape_2d.shape.get_rect().size.x / 2)
	# Clamp to right camera bound
	if not is_within_camera_right(new_x):
		new_x = GameManager.get_camera_1().global_position.x + ((GameManager.get_camera_1().get_viewport_rect().size.x / GameManager.get_camera_1().zoom.x) / 2.0) - (collision_shape_2d.shape.get_rect().size.x / 2)
	global_position.x = new_x

func swap_dimension():
	if current_dimension == 1:
		move_to(Vector2(global_position.x, global_position.y + Global.DIMENSION_OFFSET))
	else:
		move_to(Vector2(global_position.x, global_position.y - Global.DIMENSION_OFFSET))

func move_to(target_position: Vector2, duration: float = 1.0):
	multiplayer_synchronizer.replication_interval = 5.0
	can_move = false
	is_tweening = true
	color_rect.color.a = 0.2
	player_shadow.visible = false

	if tween and tween.is_valid():
		tween.kill()

	tween = create_tween()
	tween.set_parallel(true)
	tween.tween_property(self, "global_position", target_position, duration)\
		.set_trans(Tween.TRANS_SINE)\
		.set_ease(Tween.EASE_IN_OUT)
	tween.tween_property(self, "rotation", TAU, duration)\
		.set_trans(Tween.TRANS_LINEAR)\
		.set_ease(Tween.EASE_IN_OUT)
	tween.connect("finished", Callable(self, "_on_tween_finished"))

func _on_tween_finished():
	color_rect.color.a = 1
	color_rect.rotation = 0
	player_shadow.visible = true
	if current_dimension == 1:
		current_dimension = 2
	else:
		current_dimension = 1
	update_shadow_location()
	unstick_player_if_necessary()
	is_tweening = false
	can_move = true
	multiplayer_synchronizer.replication_interval = 0.0

# Try small diagonal and cardinal movements to escape the collision
func unstick_player_if_necessary():
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
				return
		# second pass (bigger step)
		for dir in directions:
			var offset = dir.normalized() * (offset_distance + 2)
			var test_transform := global_transform.translated(offset)
			if not test_move(test_transform, Vector2.ZERO):
				global_position += offset
				return
		# final pass (largest step)
		for dir in directions:
			var offset = dir.normalized() * (offset_distance + 3)
			var test_transform := global_transform.translated(offset)
			if not test_move(test_transform, Vector2.ZERO):
				global_position += offset
				return
		send_respawn_signal.rpc()

func handle_gravity(delta):
	if not is_on_floor():
		frames_since_last_on_ground += 1
		velocity.y += gravity * delta
	else:
		frames_since_last_on_ground = 0

func handle_jump():
	var jump_pressed = InputManager.is_jump_just_pressed(self)

	if is_on_floor() or frames_since_last_on_ground < coyote_time_frames:
		double_jump = true
		if jump_pressed:
			velocity.y = jump_velocity
			wall_direction = 0
			frames_since_last_on_wall = wall_jump_coyote_time_frames + 1 # Disable wall jump briefly
	elif double_jump and wall_direction != 0 and frames_since_last_on_wall < wall_jump_coyote_time_frames:
		if jump_pressed:
			velocity.y = wall_jump_vertical_boost
			velocity.x = -wall_direction * wall_jump_push_off_x
			wall_direction = 0
			frames_since_last_on_wall = wall_jump_coyote_time_frames + 1 # Disable wall jump briefly
	else:
		if jump_pressed and double_jump:
			velocity.y = jump_velocity * 0.8
			double_jump = false
	if InputManager.is_jump_just_released(self) and velocity.y < 0:
		print("released")
		velocity.y = velocity.y / 2

func apply_friction(inputAxis, delta):
	# Only apply friction if not accelerating and on floor, AND not actively wall sliding
	if inputAxis == 0 and is_on_floor():
		velocity.x = move_toward(velocity.x, 0, friction * delta)

func apply_air_resistance(inputAxis, delta):
	# Only apply air resistance if not accelerating and not on floor, AND not actively wall sliding
	if inputAxis == 0 and not is_on_floor() and wall_direction == 0:
		velocity.x = move_toward(velocity.x, 0, air_resistance * delta)

func handle_acceleration(inputAxis, delta):
	if inputAxis == 0:
		return
	
	var acceleration = air_resistance
	var direction_switch_boost = 15
	
	var current_direction = sign(velocity.x)
	var input_direction = sign(inputAxis)

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


	var target_speed = speed * inputAxis
	var acceleration_amount = acceleration * delta * boost_multiplier
	var new_velocity_x = move_toward(velocity.x, target_speed, acceleration_amount)

	# Prevent moving outside camera bounds
	var proposed_position_x = global_position.x + new_velocity_x * delta
	if !is_within_camera_left(proposed_position_x):
		new_velocity_x = max(0, new_velocity_x)
	elif !is_within_camera_right(proposed_position_x):
		new_velocity_x = min(0, new_velocity_x)

	velocity.x = new_velocity_x
	
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
	if tween and tween.is_valid():
		tween.kill()
		color_rect.color.a = 1
		rotation = 0
		is_tweening = false
		
	color_rect.visible = true
	global_position = respawn_position
	velocity = Vector2.ZERO
	current_dimension = original_dimension
	update_shadow_location()
	# Reset wall state on respawn
	wall_direction = 0
	frames_since_last_on_wall = wall_jump_coyote_time_frames + 1

func should_respawn() -> bool:
	if !can_move || is_tweening:
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
	print("on hit respawn")
	send_respawn_signal.rpc()
