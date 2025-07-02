extends Node2D
@onready var button: GameButton = $Dimension2/Button
@onready var moving_platform_spawn: Marker2D = $Dimension1/MovingPlatformSpawn

const MovingPlatformScene = preload("res://scenes/objects/moving_platform/moving_platform.tscn")


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	button.button_pressed.connect(_on_button_pressed)
	GameManager.camera1.zoom = Vector2(1.1, 1.1)
	GameManager.camera2.zoom = Vector2(1.1, 1.1)

func _on_button_pressed() -> void:
	var moving_platform = MovingPlatformScene.instantiate()
	moving_platform.global_position = moving_platform_spawn.global_position
	moving_platform.despawn = true
	moving_platform.speed = 100.0
	add_child(moving_platform)
	moving_platform.can_move = true
