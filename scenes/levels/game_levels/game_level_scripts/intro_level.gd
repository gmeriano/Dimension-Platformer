extends Node2D
@onready var barrier_top: Sprite2D = $Dimension1/BarrierTop
@onready var barrier_bottom: Sprite2D = $Dimension2/BarrierBottom


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	GameManager.get_camera_1().zoom = Vector2(1.0, 1.0)
	GameManager.get_camera_2().zoom = Vector2(1.0, 1.0)
	barrier_top.global_position.x = GameManager.get_camera_1().global_position.x
	barrier_top.modulate = Color(1.0, 0.3, 0.3, 1.0)
	barrier_bottom.global_position.x = GameManager.get_camera_2().global_position.x
	barrier_bottom.modulate = Color(1.0, 0.3, 0.3, 1.0)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	barrier_top.global_position.x = GameManager.get_camera_1().global_position.x
	barrier_bottom.global_position.x = GameManager.get_camera_2().global_position.x
