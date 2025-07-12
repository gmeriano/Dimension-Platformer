extends Node2D

@export var dimension: int = 1

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if dimension == 1:
		global_position = GameManager.camera1.get_screen_center_position()
	elif dimension == 2:
		var pos = GameManager.camera1.get_screen_center_position()
		pos.y += Global.DIMENSION_OFFSET
		global_position = pos
