extends Node2D
class_name SwitchPlatform

@export var current_dimension: int = 1
@onready var platform: Node2D = $Platform

var player_on_platform = false

func switch_dimension() -> void:
	if current_dimension == 1:
		global_position.y += Global.DIMENSION_OFFSET
		current_dimension = 2
	else:
		global_position.y -= Global.DIMENSION_OFFSET
		current_dimension = 1
