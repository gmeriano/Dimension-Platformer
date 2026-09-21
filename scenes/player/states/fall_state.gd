class_name PlayerFallState extends PlayerState

static var state_name = "PlayerFallState"

func get_state_name() -> String:
	return state_name

func physics_process(delta: float) -> void:
	player.handle_acceleration(delta)
	handle_transitions()

func handle_transitions() -> void:
	# Check if touching wall
	if player.is_on_any_wall():
		state_machine.transition(PlayerWallSlideState.state_name)
		return

	if player.jump_input and player.double_jump:
		state_machine.transition(PlayerDoubleJumpState.state_name)
		return

	if player.is_on_ground():
		if player.input_axis != 0.0:
			state_machine.transition(PlayerMovementState.state_name)
		else:
			state_machine.transition(PlayerIdleState.state_name)
