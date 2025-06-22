class_name PlayerMovementState extends PlayerState

static var state_name = "PlayerMovementState"
const ACCELERATION: float = 20.0
const MAX_SPEED: float = 350.0

func get_state_name() -> String:
	return state_name

func enter() -> void:
	player.double_jump = true

func physics_process(_delta: float) -> void:
	player.handle_acceleration(player.input_axis, _delta)
	handle_transitions()

func handle_transitions() -> void:
	if player.jump_input:
		state_machine.transition(PlayerJumpState.state_name)
		return
	if player.is_on_wall_left() or player.is_on_wall_right():
		state_machine.transition(PlayerWallSlideState.state_name)
		return
	if player.velocity.y > 0 and player.frames_since_last_on_ground > player.coyote_time_frames:
		state_machine.transition(PlayerFallState.state_name)
		return
	if player.input_axis == 0.0:
		state_machine.transition(PlayerIdleState.state_name)
