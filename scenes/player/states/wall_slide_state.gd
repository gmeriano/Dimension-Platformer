class_name PlayerWallSlideState extends PlayerState

static var state_name = "PlayerWallSlideState"

const GRAVITY_MULTIPLIER = 0.05

func get_state_name() -> String:
	return state_name

func enter() -> void:
	pass

func physics_process(delta: float) -> void:
	player.handle_wall_slide(delta, GRAVITY_MULTIPLIER)
	handle_transitions()
	
# NOTES:
# go from this to wall jump if conditions met
# can go to normal jump as well? Infinite loop between jump and this?
# make wall slide condition only met when holding a button to prevent this

func handle_transitions() -> void:
	if player.jump_input and (player.is_on_wall_left() or player.is_on_wall_right()):
		state_machine.transition(PlayerWallJumpState.state_name)
	if player.jump_input:
		state_machine.transition(PlayerJumpState.state_name)
		return
	if player.velocity.y > 0 and player.frames_since_last_on_ground > player.coyote_time_frames:
		state_machine.transition(PlayerFallState.state_name)
		return
	if player.input_axis != 0.0:
		state_machine.transition(PlayerMovementState.state_name)
