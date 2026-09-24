class_name PlayerDoubleJumpState extends PlayerState

static var state_name = "PlayerDoubleJumpState"
const DOUBLE_JUMP_VELOCITY: float = -150 * Global.ART_SCALAR * 0.8 # JUMP_VELOCTY * 0.8

func get_state_name() -> String:
	return state_name

func enter() -> void:
	if player.velocity.y < 0:
		player.velocity.y += DOUBLE_JUMP_VELOCITY / 3.0
	else:
		player.velocity.y = DOUBLE_JUMP_VELOCITY
	player.double_jump = false

func physics_process(delta: float) -> void:
	if player.jump_cut_input and player.velocity.y < 0:
		player.velocity.y /= 2
	player.handle_acceleration(delta)
	handle_transitions()

func handle_transitions() -> void:
	if player.velocity.y > 0:
		state_machine.transition(PlayerFallState.state_name)
		return
	if player.is_on_ground():
		if player.input_axis == 0:
			state_machine.transition(PlayerIdleState.state_name)
			return
		else:
			state_machine.transition(PlayerMovementState.state_name)
