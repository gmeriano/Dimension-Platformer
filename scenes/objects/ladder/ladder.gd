extends Node2D

@onready var area_2d: Area2D = $Area2D
@onready var collision_shape_2d: CollisionShape2D = $Area2D/CollisionShape2D
@onready var timer: Timer = $Timer

var player: Player = null
var can_get_off_ladder = false
var width: float = 10.0

func _ready() -> void:
	# Connect area signals to detect player
	area_2d.body_entered.connect(_on_body_entered)
	area_2d.body_exited.connect(_on_body_exited)
	timer.timeout.connect(_on_timer_timeout)
	width = collision_shape_2d.shape.extents.x * 2.0

func _physics_process(_delta: float) -> void:
	# Transition to climb state if on ground or already airborne
	if player != null and InputManager.is_interact_pressed(player) and player.state_machine.current_state.get_state_name() != PlayerClimbState.state_name:
		timer.start()
		player.velocity = Vector2.ZERO
		player.global_position.x = global_position.x + width / 2.0
		player.state_machine.transition(PlayerClimbState.state_name)
		print("HEREEE")
		
	if can_get_off_ladder and player != null and InputManager.is_interact_pressed(player) and player.state_machine.current_state.get_state_name() == PlayerClimbState.state_name:
		player.state_machine.transition(PlayerFallState.state_name)
		can_get_off_ladder = false
	
func _on_timer_timeout() -> void:
	timer.stop()
	can_get_off_ladder = true

func _on_body_entered(body: Node2D) -> void:
	if body is Player:
		player = body as Player
		can_get_off_ladder = false

func _on_body_exited(body: Node2D) -> void:
	if body is Player:
		player = null
		can_get_off_ladder = false
