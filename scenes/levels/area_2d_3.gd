extends Area2D
class_name Area2d3
@onready var spawners := get_tree().get_nodes_in_group("fireball_spawners")
@export var spawner: FireballSpawner
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

func _on_body_entered(body):
	if body is Player:
		for spawner in spawners:
			spawner.shoot_fireball()
