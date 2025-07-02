extends Node

const MAX_PLAYERS = 2
const JOY_DEADZONE = 0.2

@export var use_controller_for_p1 = true
@export var use_controller_for_p2 = true

const DEADZONE = 0.2

const JUMP_BUTTON = 0        # JOY_BUTTON_0 (bottom button: X/A)
const SWAP_BUTTON = 1        # JOY_BUTTON_1 (right button: Circle/B)
const INTERACT_BUTTON = 2    # JOY_BUTTON_2 (left button: Square/Y)
const MOVE_AXIS = 0          # JOY_AXIS_LEFT_X (left stick horizontal)

var connected_joypads = Input.get_connected_joypads()
	
func setup_player_inputs(player1: Player, player2: Player) -> void:
	if !Global.IS_ONLINE_MULTIPLAYER or player1.is_multiplayer_authority():
		if use_controller_for_p1 and connected_joypads.has(0):
			player1.device_id = connected_joypads[0]
			player1.controller_id = 1
			player1.use_controller = true
			assign_controller_to_player(connected_joypads[0], 1)
	
	if !Global.IS_ONLINE_MULTIPLAYER or player2.is_multiplayer_authority():
		if use_controller_for_p2 and !use_controller_for_p1 and connected_joypads.has(0):
			player2.device_id = connected_joypads[0]
			player2.controller_id = 2
			player2.use_controller = true
			assign_controller_to_player(connected_joypads[0], 2)
		elif use_controller_for_p2 and connected_joypads.has(1):
			player2.device_id = connected_joypads[1]
			player2.controller_id = 2
			player2.use_controller = true
			assign_controller_to_player(connected_joypads[1], 2)

func assign_controller_to_player(device_id: int, player_num: int) -> void:
	var actions = {
		"jump": JUMP_BUTTON,
		"interact": INTERACT_BUTTON,
		"dimension_swap": SWAP_BUTTON
	}
	# Clear previous jump input mapping for this player
	InputMap.action_erase_events("p%d_jump" % player_num)
	for action_name in actions.keys():
		var event := InputEventJoypadButton.new()
		event.device = device_id
		event.button_index = actions[action_name]

		var full_action_name = action_name if action_name == "dimension_swap" else "p%d_%s" % [player_num, action_name]
		InputMap.action_add_event(full_action_name, event)

func get_input_axis(player: Player) -> float:
	if !read_player_input(player):
		return false
	if player.use_controller:
		var axis_value = Input.get_joy_axis(player.device_id, MOVE_AXIS)
		if abs(axis_value) < DEADZONE:
			return 0.0
		return axis_value
	else:
		return Input.get_axis(player.controls.move_left, player.controls.move_right)	

func is_jump_just_pressed(player) -> bool:
	if !read_player_input(player):
		return false
	if player.use_controller:
		return Input.is_action_just_pressed("p%d_jump" % player.controller_id)
	else:
		return Input.is_action_just_pressed(player.controls.jump)

func is_jump_just_released(player) -> bool:
	if !read_player_input(player):
		return false
	if player.use_controller:
		return Input.is_action_just_released("p%d_jump" % player.controller_id)
	else:
		return Input.is_action_just_released(player.controls.jump)

func is_dimension_swap_pressed(player) -> bool:
	if !read_player_input(player):
		return false
	return Input.is_action_just_pressed("dimension_swap")
	return false

func is_interact_pressed(player) -> bool:
	if !read_player_input(player):
		return false
	if player.use_controller:
		return Input.is_action_just_pressed("p%d_interact" % player.controller_id)
	else:
		return Input.is_action_just_pressed(player.controls.interact)
		
func read_player_input(player: Player) -> bool:
	return !Global.IS_ONLINE_MULTIPLAYER or player.is_multiplayer_authority()
