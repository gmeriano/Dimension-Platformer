class_name PlayerWallSlideState extends PlayerState

static var state_name = "PlayerWallSlideState"

const GRAVITY_MULTIPLIER = 0.05

func get_state_name() -> String:
	return state_name

func enter() -> void:
	player.double_jump = true

func physics_process(delta: float) -> void:
	player.handle_wall_slide(delta, GRAVITY_MULTIPLIER)
	handle_transitions()

func handle_transitions() -> void:
	# Check if we should wall jump
	#if player.jump_input:
		# Can only wall jump if we're on a different wall than last jump
		#if player.should_wall_jump():
			#state_machine.transition(PlayerWallJumpState.state_name)
			#return
	if player.jump_input and player.double_jump:
		state_machine.transition(PlayerDoubleJumpState.state_name)

	# Check if player has stopped touching the wall or is on the ground
	if player.is_on_ground():
		if player.input_axis == 0:
			state_machine.transition(PlayerIdleState.state_name)
		else:
			state_machine.transition(PlayerMovementState.state_name)
		return
	
	# Check if still touching a wall
	var touching_left_wall: bool = player.is_on_wall_left()
	var touching_right_wall: bool = player.is_on_wall_right()
	
	if not (touching_left_wall or touching_right_wall):
		# Not touching wall anymore, continue falling
		state_machine.transition(PlayerFallState.state_name)
		return
	
	# Still touching wall - check if actively moving away from it
	var moving_away_from_left_wall: bool = touching_left_wall and player.input_axis > 0.0
	var moving_away_from_right_wall: bool = touching_right_wall and player.input_axis < 0.0
	
	if moving_away_from_left_wall or moving_away_from_right_wall:
		# Moving away from wall, but start coyote timer so they can still wall jump
		player.wall_direction_coyote = player.last_wall_direction
		player.wall_jump_coyote_timer = player.wall_jump_coyote_time
		print("WALL_SLIDE: Setting coyote timer - wall_dir=", player.wall_direction_coyote, " timer=", player.wall_jump_coyote_timer)
		state_machine.transition(PlayerFallState.state_name)
		return
	
	# Stay in wall slide (either zero input or moving into wall)
