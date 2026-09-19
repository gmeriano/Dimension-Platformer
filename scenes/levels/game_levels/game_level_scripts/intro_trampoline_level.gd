extends Node2D
@onready var button: GameButton = $Dimension2/Button
@onready var moving_platform_spawn: Marker2D = $Dimension1/MovingPlatformSpawn

const MovingPlatformScene = preload("res://scenes/objects/moving_platform_v2/MovingPlatformV2.tscn")

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
		moving_platform_instance.global_position = moving_platform_spawn.global_position
		moving_platform_instance.distance = 1500
		moving_platform_instance.time = 25
		moving_platform_instance.start_right = true
		add_child(moving_platform_instance)
		
