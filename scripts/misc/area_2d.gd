extends Area2D
# Shoots all fireball spawner on enter

@onready var spawners := get_tree().get_nodes_in_group("fireball_spawners")

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

func _on_body_entered(body):
	if body is Player:
		print("hiiii")
		for spawner in spawners:
			print("hey")
			if spawner.shoot_as_group == 0:
				print("shoot")
				spawner.shoot_fireball()
			else:
				print("not shoot")
