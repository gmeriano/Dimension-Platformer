extends Area2D

@onready var marker_2d: Marker2D = $Marker2D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_body_entered(body: Node2D) -> void:
	if body is Player:
		print("ETNERED")
		var player = body as Player
		player.update_respawn = true
		player.possible_respawn_point = marker_2d.global_position
		if GameManager.get_player_1().update_respawn == true and GameManager.get_player_2().update_respawn == true:
			GameManager.update_player_respawn_points()


func _on_body_exited(body: Node2D) -> void:
	if body is Player:
		print("EXIT")
		var player = body as Player
		player.update_respawn = false
		player.possible_respawn_point = Vector2.ZERO
