extends Area2D
class_name FireballShootArea
@export var spawner: FireballSpawner
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

func _on_body_entered(body):
	if body is Player:
		spawner.shoot_fireball()
