extends CharacterBody2D


const SPEED = 100.0
const JUMP_VELOCITY = -200.0

@export var controls: Resource = null
@export var current_dimension: int = 0
@onready var player_shadow: Sprite2D = $PlayerShadow
@onready var collision_shape_2d: CollisionShape2D = $CollisionShape2D
@onready var tile_map_layer: TileMapLayer = $"../TileMapLayer"

var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
var frames_since_last_on_ground = 0
var coyote_time_frames = 5
var double_jump = true
var jump_velocity = -300
var speed = 100
var friction = 600
var air_resistance = 200
var can_move = true

var camera: Camera2D = null

func _ready():
	if (current_dimension == 0):
		player_shadow.offset.y += Global.DIMENSION_OFFSET
	elif (current_dimension == 1):
		player_shadow.offset.y -= Global.DIMENSION_OFFSET
	
func _physics_process(delta: float) -> void:
	if can_move:
		handle_gravity(delta)
		handle_jump()
		handle_wall_jump()
		var inputAxis = Input.get_axis(controls.move_left, controls.move_right)
		if inputAxis != 0:
			handle_acceleration(inputAxis, delta)
		apply_friction(inputAxis, delta)
		apply_air_resistance(inputAxis, delta)
		move_and_slide()

func swap_dimension():
	if current_dimension == 0:
		position.y += Global.DIMENSION_OFFSET
		player_shadow.offset.y = -Global.DIMENSION_OFFSET
		current_dimension = 1
		unstick_player_if_necessary()
	else:
		position.y -= Global.DIMENSION_OFFSET
		player_shadow.offset.y = Global.DIMENSION_OFFSET
		current_dimension = 0
		unstick_player_if_necessary()

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
		# final pass (for when you are perfectly aligned with tile)
		for dir in directions:
			var offset = dir.normalized() * (offset_distance + 3)
			var test_transform := global_transform.translated(offset)
			if not test_move(test_transform, Vector2.ZERO):
				global_position += offset
				return
		
		print("suffocate")

func handle_gravity(delta):
	if not is_on_floor():
		frames_since_last_on_ground += 1
		velocity.y += gravity * delta
	else:
		frames_since_last_on_ground = 0
		
func handle_wall_jump():
	if not is_on_wall_only():
		return
	var wall_normal = get_wall_normal()

	if Input.is_action_just_pressed(controls.move_left) and Input.is_action_pressed(controls.jump) and wall_normal == Vector2.LEFT:

		velocity.x = wall_normal.x * speed
		velocity.y = jump_velocity
	if Input.is_action_just_pressed(controls.move_right) and Input.is_action_pressed(controls.jump) and wall_normal == Vector2.RIGHT:

		velocity.x = wall_normal.x * speed
		velocity.y = jump_velocity
		
func handle_jump():
	if is_on_floor() or frames_since_last_on_ground < coyote_time_frames:
		double_jump = true
		if Input.is_action_just_pressed(controls.jump):
			velocity.y = jump_velocity
	else:
		if Input.is_action_just_released(controls.jump) and velocity.y < jump_velocity / 2:
			velocity.y = jump_velocity / 2
		if Input.is_action_just_pressed(controls.jump) and double_jump:
			velocity.y = jump_velocity * 0.8
			double_jump = false
			
func apply_friction(inputAxis, delta):
	if inputAxis == 0 and is_on_floor():
		velocity.x = move_toward(velocity.x, 0, friction * delta)
		
func apply_air_resistance(inputAxis, delta):
	if inputAxis == 0 and not is_on_floor():
		velocity.x = move_toward(velocity.x, 0, air_resistance * delta)
		
func handle_acceleration(inputAxis, delta):
	# can handle separate acceleration with if check for is_on_floor() in future
	if inputAxis != 0:
		var target_velocity_x = move_toward(velocity.x, speed * inputAxis, air_resistance * delta)
		var proposed_position_x = global_position.x + target_velocity_x * delta
		var half_width = collision_shape_2d.shape.get_rect().size.x / 2 
		
		if !is_within_camera_left(camera, proposed_position_x):
			# Left boundary hit, block movement left
			target_velocity_x = max(0, target_velocity_x) 
		elif !is_within_camera_right(camera, proposed_position_x):
			# Right boundary hit, block movement right
			target_velocity_x = min(0, target_velocity_x) 
		velocity.x = target_velocity_x

func set_camera(camera1: Camera2D):
	camera = camera1
	
func is_within_camera_right(camera: Camera2D, x_pos: float) -> bool:
	var player_half_size = collision_shape_2d.shape.get_rect().size.x / 2
	var viewport_size = camera.get_viewport_rect().size
	var half_width = (viewport_size.x / camera.zoom.x) / 2.0
	var camera_right_edge = camera.global_position.x + half_width

	return x_pos + player_half_size <= camera_right_edge
	
func is_within_camera_left(camera: Camera2D, x_pos: float) -> bool:
	var player_half_size = collision_shape_2d.shape.get_rect().size.x / 2
	var viewport_size = camera.get_viewport_rect().size
	var half_width = (viewport_size.x / camera.zoom.x) / 2.0
	var camera_left_edge = camera.global_position.x - half_width
	return x_pos - player_half_size >= camera_left_edge
