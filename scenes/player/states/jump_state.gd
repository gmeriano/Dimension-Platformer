class_name PlayerJumpState extends PlayerState

static var state_name = "PlayerJumpState"
const JUMP_VELOCITY: float = -250
const MAX_SPEED: float = 350.0

func get_state_name() -> String:
	return state_name

func enter() -> void:
	player.velocity.y = JUMP_VELOCITY

func physics_process(delta: float) -> void:
	if player.jump_cut_input and player.velocity.y < 0:
		player.velocity.y /= 2
	player.handle_acceleration(delta)
	handle_transitions()

func handle_transitions() -> void:
	if player.jump_input_buffered or player.jump_input:
		if player.last_wall_direction != player.last_wall_jump_direction and player.last_wall_direction != Vector2.ZERO and player.input_axis != 0 and player.input_axis != player.last_wall_direction.x:
			state_machine.transition(PlayerWallJumpState.state_name)
			return

	if player.jump_input and player.double_jump:
		state_machine.transition(PlayerDoubleJumpState.state_name)
		return

	if player.velocity.y > 0:
		state_machine.transition(PlayerFallState.state_name)
		return

	if player.is_on_ground():
		if player.input_axis == 0:
			state_machine.transition(PlayerIdleState.state_name)
		else:
			state_machine.transition(PlayerMovementState.state_name)
