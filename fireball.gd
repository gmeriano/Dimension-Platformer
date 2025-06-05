extends Node2D

@export var speed: float = 225.0
var direction: Vector2 = Vector2.LEFT
const BOUNCE_VELOCITY = -500  # Tweak this value


func _ready():
	add_to_group("fireballs")
	
func _physics_process(delta: float) -> void:
	position += direction * speed * delta

func _on_hitbox_body_entered(body: Node2D) -> void:
	if body is Player:
		body.on_hit()
		for fireball in get_tree().get_nodes_in_group("fireballs"):
			fireball.queue_free()


func _on_top_jumpbox_body_entered(body: Node2D) -> void:
	if body is Player:
		if body.velocity.y > 0:
			body.bounce = true
			#body.velocity.y = BOUNCE_VELOCITY  # Bounce effect
