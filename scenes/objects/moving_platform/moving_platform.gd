extends Node2D
class_name MovingPlatform

@onready var platform: CharacterBody2D = $Platform
@export var speed: float = 30.0
@export var direction = -1 
@onready var level_manager: LevelManager = $"../LevelManager"
var platform_starting_position: Vector2
var starting_direction: float

func _ready() -> void:
	add_to_group("moving_platform")
	platform_starting_position = platform.global_position
	starting_direction = direction

func _physics_process(delta: float) -> void:
	var velocity := Vector2(direction * speed, 0)
	var collision = platform.move_and_collide(velocity * delta)

	if collision:
		direction *= -1
		
func respawn() -> void:
	platform.global_position = platform_starting_position
	direction = starting_direction
