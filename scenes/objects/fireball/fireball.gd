extends Node2D

@export var speed: float = 225.0
var direction: Vector2 = Vector2.LEFT
@export var bounce_multiplier = 1.5  # Tune this to adjust how much force is applied
@export var max_bounce_force = 500.0
@export var min_bounce_force = 400.0
var player_bouncing = false
@onready var timer: Timer = $Timer


func _ready():
	add_to_group("fireballs")
	
func _physics_process(delta: float) -> void:
	position += direction * speed * delta
	if abs(position.x) > 4000:
		queue_free()

func _on_hitbox_body_entered(body: Node2D) -> void:
	if body is Player and !player_bouncing:
		register_hit(body)

func register_hit(player: Player) -> void:
	if Global.IS_ONLINE_MULTIPLAYER:
		if player.is_multiplayer_authority():
			player.on_hit()
	else:
		player.on_hit()

func _on_top_jumpbox_body_entered(body: Node2D) -> void:
	if body is Player:
		player_bouncing = true
		timer.start()
		var velocity = body.velocity
		# Only react to downward movement
		if velocity.y > 0:
			var bounce_force = velocity.y * bounce_multiplier
			bounce_force = clamp(bounce_force, min_bounce_force, max_bounce_force)
			
			body.velocity.y = -bounce_force  # Launch upwards
			body.move_and_slide()  # Apply the velocity immediately

func _on_timer_timeout() -> void:
	player_bouncing = false
