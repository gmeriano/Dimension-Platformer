class_name PlayerIdleState extends PlayerState

static var state_name = "PlayerIdleState"

func get_state_name() -> String:
	return state_name

func enter() -> void:
	player.double_jump = true
	player.last_wall_jump_direction = Vector2.ZERO
	player.wall_jump_coyote_timer = 0.0
	player.wall_jump_input_lockout_timer = 0.0

func physics_process(delta: float) -> void:
	player.apply_friction(delta)
	handle_transitions()

func handle_transitions() -> void:
	if player.jump_input:
		state_machine.transition(PlayerJumpState.state_name)
		return
	if player.velocity.y > 0 and player.frames_since_last_on_ground > player.coyote_time_frames:
		state_machine.transition(PlayerFallState.state_name)
		return
	if player.input_axis != 0.0:
		state_machine.transition(PlayerMovementState.state_name)
