extends Node

const MAX_PLAYERS = 2
const JOY_DEADZONE = 0.2

@export var use_controller_for_p1 = true
@export var use_controller_for_p2 = true

const DEADZONE = 0.2

const JUMP_BUTTON = 0        # JOY_BUTTON_0 (bottom button: Cross/A)
const SWAP_BUTTON = 1        # JOY_BUTTON_1 (right button: O/B)
const MOVE_AXIS = 0          # JOY_AXIS_LEFT_X (left stick horizontal)

var connected_joypads = Input.get_connected_joypads()
	
func setup_player_inputs(player1: Player, player2: Player) -> void:
	if use_controller_for_p1 and 0 in connected_joypads:
		player1.device_id = connected_joypads[0]
		player1.use_controller = true
	if use_controller_for_p2 and 1 in connected_joypads:
		player2.device_id = connected_joypads[1]
		player2.use_controller = true
	elif !player1.use_controller and 0 in connected_joypads:
		player2.device_id = connected_joypads[0]
		player2.use_controller = true

func get_input_axis(player: Player) -> float:
	if player.use_controller:
		var axis_value = Input.get_joy_axis(player.device_id, MOVE_AXIS)
		if abs(axis_value) < DEADZONE:
			return 0.0
		return axis_value
	else:
		return Input.get_axis(player.controls.move_left, player.controls.move_right)	

func is_jump_just_pressed(player) -> bool:
	if player.use_controller:
		var current = Input.is_joy_button_pressed(player.device_id, JUMP_BUTTON)
		var just_pressed = current and not player.previous_jump_pressed_for_controller
		#player.previous_jump_pressed_for_controller = current
		return just_pressed
	else:
		return Input.is_action_just_pressed(player.controls.jump)

func is_jump_just_released(player) -> bool:
	if player.use_controller:
		var current = not Input.is_joy_button_pressed(player.device_id, JUMP_BUTTON)
		var just_released = current and not player.previous_jump_pressed_for_controller
		#player.previous_jump_pressed_for_controller = current
		return just_released
	else:
		return Input.is_action_just_released(player.controls.jump)

func is_dimension_swap_pressed(player) -> bool:
	if not player.is_tweening:
		if player.use_controller:
			return Input.is_joy_button_pressed(player.device_id, SWAP_BUTTON)
		else:
			return Input.is_action_just_pressed("dimension_swap")
	return false

func is_interact_pressed(player) -> bool:
	if player.use_controller:
		return Input.is_joy_button_pressed(player.device_id, 2)
	else:
		return Input.is_action_just_pressed(player.controls.interact)
