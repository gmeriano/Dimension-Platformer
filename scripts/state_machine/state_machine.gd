class_name StateMachine extends Node

var current_state: State
var states: Dictionary = {}

func start_machine(init_states: Array[State]) -> void:
	for state in init_states:
		states[state.get_state_name()] = state
	current_state = init_states[0]
	current_state.enter()

func _process(delta: float) -> void:
	current_state.process(delta)

func _physics_process(delta: float) -> void:
	current_state.physics_process(delta)

func transition(new_state_name: String) -> void:
	var new_state: State = states.get(new_state_name)
	if new_state == null:
		push_error("Cannot transition to an empty state.")
	elif new_state_name != current_state.get_state_name():
		if new_state_name == PlayerWallJumpState.state_name:
			print("Transition: " + current_state.get_state_name() + " -> " + new_state_name)
		current_state.exit()
		current_state = new_state
		current_state.enter()
	else:
		push_warning("Attempt to transition to already enabled state.")
		
