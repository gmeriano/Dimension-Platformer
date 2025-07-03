extends Node2D
class_name MovingPlatform

@onready var platform: CharacterBody2D = $Platform
@export var speed: float = 30.0
@export var direction = -1 
var platform_starting_position: Vector2
var starting_direction: float
var can_move = false
var despawn: bool = false
var start_time = 0
var first_tick = false

func _ready() -> void:
	if despawn:
		add_to_group("despawn")
	add_to_group("moving_platform")
	platform_starting_position = platform.global_position
	starting_direction = direction
	TransitionScreen.connect("on_fade_to_normal_finished", Callable(self, "_on_fade_to_normal_finished_platform_can_move_true"))

func _physics_process(delta: float) -> void:
	if first_tick and can_move:
		first_tick = false
		var elapsed_msec = Time.get_ticks_msec() - start_time
		var elapsed_sec = float(elapsed_msec) / 1000.0
		var offset = Vector2(direction * speed * elapsed_sec, 0)
		platform.global_position = platform_starting_position + offset
		return 

	if can_move:
		var velocity := Vector2(direction * speed, 0)
		var collision = platform.move_and_collide(velocity * delta)
		if collision:
			direction *= -1
		
func respawn() -> void:
	platform.global_position = platform_starting_position
	direction = starting_direction
	can_move = false

func _on_fade_to_normal_finished_platform_can_move_true():
	if multiplayer.is_server():
		start_platform.rpc(Time.get_ticks_msec())

@rpc("call_local", "any_peer")
func start_platform(start_time_sent):
	can_move = true
	first_tick = false
	start_time = start_time_sent
