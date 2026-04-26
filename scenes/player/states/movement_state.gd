class_name PlayerMovementState extends PlayerState

static var state_name = "PlayerMovementState"

func get_state_name() -> String:
	return state_name

func enter() -> void:
	player.double_jump = true
	player.last_wall_jump_direction = Vector2.ZERO
	player.wall_jump_coyote_timer = 0.0
	player.wall_jump_input_lockout_timer = 0.0

func physics_process(delta: float) -> void:
	player.handle_acceleration(delta)
	handle_transitions()

func handle_transitions() -> void:
	if player.jump_input:
		# Check for wall jump coyote before normal jump
		#if player.should_wall_jump():
			#state_machine.transition(PlayerWallJumpState.state_name)
			#return
		state_machine.transition(PlayerJumpState.state_name)
		return
	if player.velocity.y > 0 and player.frames_since_last_on_ground > player.coyote_time_frames:
		# Check if touching wall before transitioning to fall
		if player.is_on_any_wall():
			state_machine.transition(PlayerWallSlideState.state_name)
			return
		state_machine.transition(PlayerFallState.state_name)
		return
	if player.input_axis == 0.0:
		state_machine.transition(PlayerIdleState.state_name)
