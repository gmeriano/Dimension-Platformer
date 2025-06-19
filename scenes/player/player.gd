extends CharacterBody2D
class_name Player

const SPEED = 100.0
const JUMP_VELOCITY = -200.0

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
var speed = 100
var friction = 600

var air_resistance = 200
var can_move = true
var is_tweening = false
var use_controller = false
var previous_jump_pressed_for_controller = false
var respawn_point: Vector2

var original_dimension = 1
var tween: Tween = null

const JUMP_BUTTON = 0        # JOY_BUTTON_0 (bottom button: Cross/A)
const MOVE_AXIS = 0          # JOY_AXIS_LEFT_X (left stick horizontal)

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
	return is_on_floor()  # If using Godot's KinematicBody2D method
	
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
		handle_jump()
		var inputAxis = InputManager.get_input_axis(self)
		if inputAxis != 0:
			handle_acceleration(inputAxis, delta)
		apply_friction(inputAxis, delta)
		apply_air_resistance(inputAxis, delta)
		move_and_slide()
		clamp_x_by_camera()

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
	if is_on_floor() or frames_since_last_on_ground < coyote_time_frames:
		double_jump = true
		if InputManager.is_jump_just_pressed(self):
			velocity.y = jump_velocity
	else:
		if InputManager.is_jump_just_released(self) and velocity.y < 0:
			velocity.y /= 2
		if InputManager.is_jump_just_pressed(self) and double_jump:
			velocity.y = jump_velocity * 0.8
			double_jump = false
	if use_controller:
		previous_jump_pressed_for_controller = Input.is_joy_button_pressed(device_id, JUMP_BUTTON)

func apply_friction(inputAxis, delta):
	if inputAxis == 0 and is_on_floor():
		velocity.x = move_toward(velocity.x, 0, friction * delta)
		
func apply_air_resistance(inputAxis, delta):
	if inputAxis == 0 and not is_on_floor():
		velocity.x = move_toward(velocity.x, 0, air_resistance * delta)
		
func handle_acceleration(inputAxis, delta):
	# can handle separate acceleration with if check for is_on_floor() in future
	if inputAxis != 0:
		var target_velocity_x: float
		if is_on_floor():
			target_velocity_x = move_toward(velocity.x, speed * inputAxis, air_resistance * delta)
		else:
			target_velocity_x = move_toward(velocity.x, speed * inputAxis, air_resistance * delta * 2)
		var proposed_position_x = global_position.x + target_velocity_x * delta
		
		if !is_within_camera_left(proposed_position_x):
			# Left boundary hit, block movement left
			target_velocity_x = max(0, target_velocity_x) 
		elif !is_within_camera_right(proposed_position_x):
			# Right boundary hit, block movement right
			target_velocity_x = min(0, target_velocity_x) 
		velocity.x = target_velocity_x
	
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
