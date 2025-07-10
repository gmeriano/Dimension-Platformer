extends Area2D
class_name UpdateRespawnArea

@onready var marker_2d: Marker2D = $Marker2D
@onready var sprite_2d: Sprite2D = $Sprite2D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_body_entered(body: Node2D) -> void:
	if body is Player:
		sprite_2d.modulate = Color.RED
		var player = body as Player
		player.update_respawn = true
		player.possible_respawn_point = self
		if GameManager.get_player_1().update_respawn == true and GameManager.get_player_2().update_respawn == true:
			GameManager.update_player_respawn_points()


func _on_body_exited(body: Node2D) -> void:
	if body is Player:
		sprite_2d.modulate = Color.WHITE
		var player = body as Player
		player.update_respawn = false
		player.possible_respawn_point = null
