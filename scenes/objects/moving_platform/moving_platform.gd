extends Node2D

@onready var platform: CharacterBody2D = $Platform
@export var speed: float = 30.0
@export var direction = -1  
@onready var game_manager: GameManager = $"../GameManager"
var platform_starting_position: Vector2
var starting_direction: float

func _ready() -> void:
	game_manager.connect("respawn_players", Callable(self, "_on_moving_platform_respawn"))
	platform_starting_position = platform.global_position
	starting_direction = direction

func _physics_process(delta: float) -> void:
	if not platform:
		return
	var velocity := Vector2(direction * speed, 0)
	var collision = platform.move_and_collide(velocity * delta)

	if collision:
		direction *= -1
		
func _on_moving_platform_respawn() -> void:
	platform.global_position = platform_starting_position
	direction = starting_direction
