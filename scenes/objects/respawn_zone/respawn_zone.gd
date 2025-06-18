extends Node2D

@onready var collision_shape_2d: CollisionShape2D = $Area2D/CollisionShape2D
@onready var area_2d: Area2D = $Area2D

@export var width = 10000

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	collision_shape_2d.shape.size = Vector2(width,1)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_area_2d_body_entered(body: Node2D) -> void:
	if body is Player:
		var player = body as Player
		if player.is_tweening:
			return
		player.send_respawn_signal()
