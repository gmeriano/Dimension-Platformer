extends CharacterBody2D


const SPEED = 100.0
const JUMP_VELOCITY = -200.0

@export var controls: Resource = null
@export var current_dimension: int = 0
@onready var player_shadow: Sprite2D = $PlayerShadow

var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

var frames_since_last_on_ground = 0
var coyote_time_frames = 5
var double_jump = true
var jump_velocity = -300
var speed = 100
var friction = 600
var air_resistance = 200
var can_move = true

func _ready():
	if (current_dimension == 0):
		player_shadow.offset.y += 400
	elif (current_dimension == 1):
		player_shadow.offset.y -= 400
	
func _physics_process(delta: float) -> void:
	print(player_shadow.offset.y)
	if can_move:
		handleGravity(delta)
		handleJump()
		handleWallJump()
		var inputAxis = Input.get_axis(controls.move_left, controls.move_right)
		if inputAxis != 0:
			handleAcceleration(inputAxis, delta)
		applyFriction(inputAxis, delta)
		applyAirResistance(inputAxis, delta)
		move_and_slide()
		
	if Input.is_action_just_pressed("dimension_swap"):
		can_move = false
		TransitionScreen.transition()
		await TransitionScreen.on_transition_finished
		can_move = true
		if current_dimension == 0:
			position.y += 400
			player_shadow.offset.y = -400
			current_dimension = 1
		else:
			position.y -= 400
			player_shadow.offset.y = 400
			current_dimension = 0
			
func handleGravity(delta):
	if not is_on_floor():
		frames_since_last_on_ground += 1
		velocity.y += gravity * delta
	else:
		frames_since_last_on_ground = 0
		
func handleWallJump():
	if not is_on_wall_only():
		return
	var wall_normal = get_wall_normal()

	if Input.is_action_just_pressed(controls.move_left) and Input.is_action_pressed(controls.jump) and wall_normal == Vector2.LEFT:

		velocity.x = wall_normal.x * speed
		velocity.y = jump_velocity
	if Input.is_action_just_pressed(controls.move_right) and Input.is_action_pressed(controls.jump) and wall_normal == Vector2.RIGHT:

		velocity.x = wall_normal.x * speed
		velocity.y = jump_velocity
		
func handleJump():
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
			
func applyFriction(inputAxis, delta):
	if inputAxis == 0 and is_on_floor():
		velocity.x = move_toward(velocity.x, 0, friction * delta)
		
func applyAirResistance(inputAxis, delta):
	if inputAxis == 0 and not is_on_floor():
		velocity.x = move_toward(velocity.x, 0, air_resistance * delta)
		
func handleAcceleration(inputAxis, delta):
	if inputAxis != 0:
		if is_on_floor():
			velocity.x = move_toward(velocity.x, speed * inputAxis, air_resistance * delta)
		else:
			velocity.x = move_toward(velocity.x, speed * inputAxis, air_resistance * delta)
