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
		var player = body as Player
		if player.respawn_point.x < marker_2d.global_position.x:
			player.respawn_point = marker_2d.global_position
