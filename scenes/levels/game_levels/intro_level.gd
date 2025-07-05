extends Node2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	GameManager.get_camera_1().zoom = Vector2(1.0, 1.0)
	GameManager.get_camera_2().zoom = Vector2(1.0, 1.0)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
