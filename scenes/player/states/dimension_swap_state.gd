class_name PlayerDimensionSwapState extends PlayerState

static var state_name = "PlayerDimensionSwapState"
var prev_state: String
var tween: Tween
var stored_velocity: Vector2

func get_state_name() -> String:
	return state_name

func enter() -> void:
	prev_state = player.prev_state
	stored_velocity = player.velocity  # Store current velocity
	if player.current_dimension == 1:
		move_to(Vector2(player.global_position.x, player.global_position.y + Global.DIMENSION_OFFSET))
	else:
		move_to(Vector2(player.global_position.x, player.global_position.y - Global.DIMENSION_OFFSET))

func move_to(target_position: Vector2, duration: float = 1.0):
	player.multiplayer_synchronizer.replication_interval = 5.0
	player.color_rect.color.a = 0.2
	player.player_shadow.visible = false
	
	if tween and tween.is_valid():
		tween.kill()
	tween = player.create_tween()
	tween.set_parallel(true)
	tween.tween_property(player, "global_position", target_position, duration)\
		.set_trans(Tween.TRANS_SINE)\
		.set_ease(Tween.EASE_IN_OUT)
	tween.tween_property(player, "rotation", TAU, duration)\
		.set_trans(Tween.TRANS_LINEAR)\
		.set_ease(Tween.EASE_IN_OUT)
	tween.connect("finished", Callable(self, "handle_transitions"))

func handle_transitions() -> void:
	tween.disconnect("finished", Callable(self, "handle_transitions"))
	player.color_rect.color.a = 1
	player.color_rect.rotation = 0
	player.player_shadow.visible = true
	if player.current_dimension == 1:
		player.current_dimension = 2
	else:
		player.current_dimension = 1
	player.update_shadow_location()
	player.multiplayer_synchronizer.replication_interval = 0.0
	if player.unstick_player_if_necessary():
		state_machine.transition(PlayerRespawnState.state_name)
	else:
		if prev_state in player.jump_states: # Don't reapply jump state, just go to FallState directly
			prev_state = PlayerFallState.state_name
		player.velocity = stored_velocity
		state_machine.transition(prev_state)
