extends Node2D
class_name SwitchPlatform

@export var current_dimension: int = 0
@onready var level_manager: LevelManager
@onready var platform: Node2D = $Platform

var player_on_platform = false
var respawn_x = 0
var respawn_y = 0
var original_dimension = 0

func _ready() -> void:
	level_manager = get_level_manager()
	level_manager.connect("respawn_players", Callable(self, "_on_respawn"))
	respawn_x = global_position.x
	respawn_y = global_position.y
	if current_dimension == 1:
		original_dimension = 1

func get_level_manager() -> LevelManager:
	return get_tree().get_current_scene().find_child("LevelManager", true, false)

func _on_respawn() -> void:
	global_position.x = respawn_x
	global_position.y = respawn_y
	current_dimension = original_dimension
	player_on_platform = false

func switch_dimension() -> void:
	if current_dimension == 0:
		global_position.y += Global.DIMENSION_OFFSET
		current_dimension = 1
	else:
		global_position.y -= Global.DIMENSION_OFFSET
		current_dimension = 0
