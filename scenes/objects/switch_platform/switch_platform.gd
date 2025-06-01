extends Node2D
class_name SwitchPlatform

@export var current_dimension: int = 0
var player_on_platform = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_area_2d_body_entered(body: Node2D) -> void:
	if body is Player:
		var player = body as Player
		if !player.is_tweening:
			player_on_platform = true


func _on_area_2d_body_exited(body: Node2D) -> void:
	if player_on_platform:
		player_on_platform = false
		if current_dimension == 0:
			global_position.y += Global.DIMENSION_OFFSET
			current_dimension = 1
		else:
			global_position.y -= Global.DIMENSION_OFFSET
			current_dimension = 0
