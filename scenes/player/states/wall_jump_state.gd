class_name PlayerWallJumpState extends PlayerState

static var state_name = "PlayerWallJumpState"

const HORIZONTAL_BOOST = 200.0
#const VERTICAL_BOOST = -100.0

func get_state_name() -> String:
	return state_name

func enter() -> void:
	player.jump_input_buffered = false
	if player.last_wall_direction == Vector2.RIGHT:
		print("WALL RIGHT")
	elif player.last_wall_direction == Vector2.LEFT:
		print("WALL LEFT")
	player.last_wall_jump_direction = player.last_wall_direction
	player.velocity.x = -player.last_wall_direction.x * HORIZONTAL_BOOST
	player.wall_jump_input_lockout_timer = player.wall_jump_input_lockout_time
	state_machine.transition(PlayerJumpState.state_name)
