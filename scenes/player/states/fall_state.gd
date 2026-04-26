class_name PlayerFallState extends PlayerState

static var state_name = "PlayerFallState"

func get_state_name() -> String:
	return state_name

func physics_process(delta: float) -> void:
	player.handle_acceleration(delta)
	handle_transitions()

func handle_transitions() -> void:
	print("FALL STATE: is_on_any_wall=", player.is_on_any_wall(), " jump_input=", player.jump_input, " coyote_timer=", player.wall_jump_coyote_timer)
	
	# Check for wall jump coyote FIRST (high priority) before bouncing back to wall slide
	#if player.jump_input and player.should_wall_jump():
		#print("  -> Performing wall jump coyote")
		#state_machine.transition(PlayerWallJumpState.state_name)
		#return

	# Check if touching wall
	if player.is_on_any_wall():
		print("  -> Transitioning to wall_slide (touching wall)")
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
