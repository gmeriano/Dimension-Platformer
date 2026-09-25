extends Node2D
@onready var barrier_top: Sprite2D = $BarrierTop
@onready var barrier_bottom: Sprite2D = $BarrierBottom
@export var color: Color = Color(0.796, 0.431, 0.973, 1.0)

func _ready() -> void:
	barrier_top.global_position.x = GameManager.get_camera_1().global_position.x
	barrier_top.modulate = color
	barrier_bottom.global_position.x = GameManager.get_camera_2().global_position.x
	barrier_bottom.modulate = color

func _process(_delta: float) -> void:
	barrier_top.global_position.x = GameManager.get_camera_1().global_position.x
	barrier_bottom.global_position.x = GameManager.get_camera_1().global_position.x
