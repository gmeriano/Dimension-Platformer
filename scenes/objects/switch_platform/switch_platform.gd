extends Node2D
class_name SwitchPlatform

@export var current_dimension: int = 0
@onready var game_manager: GameManager
@onready var platform: Node2D = $Platform

var player_on_platform = false
var respawn_x = 0
var respawn_y = 0
var original_dimension = 0

func _ready() -> void:
	game_manager = get_game_manager()
	game_manager.connect("respawn_players", Callable(self, "_on_respawn"))
	respawn_x = global_position.x
	respawn_y = global_position.y
	if current_dimension == 1:
		original_dimension = 1

func get_game_manager() -> GameManager:
	return get_tree().get_current_scene().find_child("GameManager", true, false)


#func _process(delta: float) -> void:
	#update_color()
	#

#func _on_area_2d_body_entered(body: Node2D) -> void:
	#if body is Player:
		#var player = body as Player
		#if !player.is_tweening:
			#player_on_platform = true


#func _on_area_2d_body_exited(body: Node2D) -> void:
	#if body is Player:
		#var player: Player = body as Player
		#if player_on_platform:
			#player_on_platform = false
			#if not player.is_tweening:
				#switch_dimension()

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

#func update_color() -> void:
	#if player_on_platform:
		#platform.sprite_2d.modulate = Color(1, 0, 0)
	#else:
		#platform.sprite_2d.modulate = Color(0, 0, 0)
