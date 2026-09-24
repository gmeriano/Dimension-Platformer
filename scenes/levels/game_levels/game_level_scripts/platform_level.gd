extends Node2D

@onready var button: GameButton = $Dimension2/Button
@onready var button_2: GameButton = $Dimension2/Button2
@onready var platform_marker: Marker2D = $Dimension1/PlatformMarker
@onready var dimension_1: Node2D = $Dimension1
@onready var platform_timer: Timer = $PlatformTimer

@export var platform_scene: PackedScene

var platform = null

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	button.button_pressed.connect(_on_button_pressed)
	button_2.button_pressed.connect(_on_button_pressed)
	
func _on_button_pressed() -> void:
	print("HEYYY")
	platform = platform_scene.instantiate()
	platform.position = platform_marker.position
	dimension_1.add_child(platform)
	print(platform.global_position)
	platform_timer.start()

	


func _on_platform_timer_timeout() -> void:
	platform.queue_free()
