class_name PlayerDoubleJumpState extends PlayerState

static var state_name = "PlayerDoubleJumpState"
const DOUBLE_JUMP_VELOCITY: float = -240.0 # JUMP_VELOCTY * 0.8

func get_state_name() -> String:
	return state_name

func enter() -> void:
	player.velocity.y = DOUBLE_JUMP_VELOCITY
	player.double_jump = false

func physics_process(_delta: float) -> void:
	player.handle_acceleration(player.input_axis, _delta)
	handle_transitions()

func handle_transitions() -> void:
	if player.jump_input_buffered and player.wall_coyote_timer > 0:
		if player.last_wall_direction == -1 and player.input_axis > 0:
			state_machine.transition(PlayerWallJumpState.state_name)
			return
		elif player.last_wall_direction == 1 and player.input_axis < 0:
			state_machine.transition(PlayerWallJumpState.state_name)
			return
	if player.velocity.y > 0:
		state_machine.transition(PlayerFallState.state_name)
		return
	#if player.is_on_wall_left() or player.is_on_wall_right():
	#	state_machine.transition(PlayerWallSlideState.state_name)
	#	return
	if player.is_on_ground():
		if player.input_axis == 0:
			state_machine.transition(PlayerIdleState.state_name)
			return
		else:
			state_machine.transition(PlayerMovementState.state_name)
