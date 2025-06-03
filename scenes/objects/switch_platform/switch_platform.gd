extends Node2D
class_name SwitchPlatform

@export var current_dimension: int = 0
@onready var game_manager: GameManager = $"../GameManager"
@onready var sprite_2d: Sprite2D = $Sprite2D

var player_on_platform = false
var respawn_x = 0
var respawn_y = 0
var original_dimension = 0

func _ready() -> void:
	game_manager.connect("respawn_players", Callable(self, "_on_respawn"))
	respawn_x = global_position.x
	respawn_y = global_position.y
	if current_dimension == 1:
		original_dimension = 1

func _process(delta: float) -> void:
	update_color()
	

func _on_area_2d_body_entered(body: Node2D) -> void:
	if body is Player:
		var player = body as Player
		if !player.is_tweening:
			player_on_platform = true


func _on_area_2d_body_exited(body: Node2D) -> void:
	if body is Player:
		var player: Player = body as Player
		if player_on_platform:
			player_on_platform = false
			if not player.is_tweening:
				if current_dimension == 0:
					global_position.y += Global.DIMENSION_OFFSET
					current_dimension = 1
				else:
					global_position.y -= Global.DIMENSION_OFFSET
					current_dimension = 0

func _on_respawn() -> void:
	global_position.x = respawn_x
	global_position.y = respawn_y
	current_dimension = original_dimension
	player_on_platform = false
	
func update_color() -> void:
	if player_on_platform:
		sprite_2d.modulate = Color(1, 0, 0)
	else:
		sprite_2d.modulate = Color(0, 0, 0)
