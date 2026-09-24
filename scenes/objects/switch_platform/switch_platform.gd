extends Node2D
class_name SwitchPlatform

@export var current_dimension: int = 1
@onready var platform: Node2D = $Platform

var player_on_platform = false

func switch_dimension() -> void:
	print("POS BEFORE: ", global_position.y)
	print(GameManager.get_player_1().global_position.y)
	if current_dimension == 1:
		global_position.y += Global.DIMENSION_OFFSET
		print("GL: ", Global.DIMENSION_OFFSET)
		print("NEW POS1: ", global_position.y)
		current_dimension = 2
	else:
		global_position.y -= Global.DIMENSION_OFFSET
		print("NEW POS2: ", global_position.y)
		current_dimension = 1
