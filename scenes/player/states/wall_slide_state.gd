class_name PlayerWallSlideState extends PlayerState

static var state_name = "PlayerWallSlideState"

const GRAVITY_MULTIPLIER = 0.05

func get_state_name() -> String:
	return state_name

func physics_process(delta: float) -> void:
	player.handle_wall_slide(delta, GRAVITY_MULTIPLIER)
	handle_transitions()

func handle_transitions() -> void:
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
		state_machine.transition(PlayerFallState.state_name)
		return
	
