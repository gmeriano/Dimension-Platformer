extends Node2D

@export var speed: float = 225.0
var direction: Vector2 = Vector2.LEFT
const BOUNCE_VELOCITY = -500  # Tweak this value


func _ready():
	add_to_group("fireballs")
	
func _physics_process(delta: float) -> void:
	position += direction * speed * delta
	if abs(position.x) > 4000:
		queue_free()

func _on_hitbox_body_entered(body: Node2D) -> void:
	if body is Player:
		register_hit(body)

func register_hit(player: Player) -> void:
	if Global.IS_ONLINE_MULTIPLAYER:
		if player.is_multiplayer_authority():
			player.on_hit()
	else:
		player.on_hit()

func _on_top_jumpbox_body_entered(body: Node2D) -> void:
	if body is Player:
		if body.velocity.y > 0:
			body.bounce = true
			#body.velocity.y = BOUNCE_VELOCITY  # Bounce effect
