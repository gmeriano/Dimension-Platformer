extends Area2D
# Shoots all fireball spawner on enter
@onready var color_rect: ColorRect = $"ColorRect"

@onready var spawners := get_tree().get_nodes_in_group("fireball_spawners")
var original_modulate = Color(1,0,0,0)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	original_modulate = color_rect.modulate

func _on_body_entered(body):
	if body is Player:
		color_rect.modulate = Color(1,0,0,0.5)
		for spawner in spawners:
			if spawner.shoot_as_group == 0:
				spawner.shoot_fireball()




func _on_body_exited(body: Node2D) -> void:
	if body is Player:
		color_rect.modulate = original_modulate
