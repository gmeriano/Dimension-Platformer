extends Node2D
@onready var button: GameButton = $Dimension2/Button
@onready var moving_platform_spawn: Marker2D = $Dimension1/MovingPlatformSpawn
@onready var dimension_1: Node2D = $Dimension1

const MovingPlatformScene = preload("res://scenes/objects/moving_platform/moving_platform.tscn")

var has_button_been_pressed = false
var moving_platform_instance = null


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	button.button_pressed.connect(_on_button_pressed)

func _on_button_pressed() -> void:
	if has_button_been_pressed:
		moving_platform_instance.queue_free()
		has_button_been_pressed = false
	else:
		has_button_been_pressed = true
		moving_platform_instance = MovingPlatformScene.instantiate()
		dimension_1.add_child(moving_platform_instance)
		moving_platform_instance.global_position = moving_platform_spawn.global_position
		moving_platform_instance.speed = 180
		moving_platform_instance.direction = 1
		moving_platform_instance.can_move = true
