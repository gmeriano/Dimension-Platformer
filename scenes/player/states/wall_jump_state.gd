class_name PlayerWallJumpState extends PlayerState

static var state_name = "PlayerWallJumpState"

const HORIZONTAL_BOOST = 200.0
const VERTICAL_BOOST = -300.0
var frames_since_last_on_wall = 0
var wall_direction = 0

func get_state_name() -> String:
	return state_name

func enter() -> void:
	player.jump_input_buffered = false
	if player.is_on_wall_left():
		wall_direction = 1
	elif player.is_on_wall_right():
		wall_direction = -1
	player.velocity.x = wall_direction * HORIZONTAL_BOOST
	state_machine.transition(PlayerJumpState.state_name)
