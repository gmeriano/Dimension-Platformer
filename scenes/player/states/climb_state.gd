class_name PlayerClimbState extends PlayerState

static var state_name = "PlayerClimbState"

const CLIMB_SPEED: float = 150.0

func get_state_name() -> String:
	return state_name

func physics_process(_delta: float) -> void:
	# Handle vertical climbing
	var vertical_input: float = InputManager.get_vertical_input_axis(player)
	
	player.velocity.y = vertical_input * CLIMB_SPEED
	
	handle_transitions()

func handle_transitions() -> void:
	# if InputManager.is_interact_pressed(player):
	# 	state_machine.transition(PlayerFallState.state_name)
	# 	player.is_on_ladder = false
	# 	return
	
	if player.jump_input:
		state_machine.transition(PlayerJumpState.state_name)
		return

