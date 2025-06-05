extends Node2D

@export var fireball_scene: PackedScene
@export var fire_rate: float = 2.0
@onready var muzzle: Marker2D = $Muzzle
@onready var timer: Timer = $Timer

var can_fire: bool = true

func _on_body_entered(body: Node):
	if body is Player:
		if can_fire:
			can_fire = false
			shoot_fireball()
			timer.start()

func shoot_fireball():
	if not fireball_scene:
		push_error("Fireball scene not assigned!")
		return
	var fireball = fireball_scene.instantiate()
	fireball.position = muzzle.global_position
	fireball.direction = Vector2.RIGHT  # or .LEFT, .DOWN, etc.
	get_tree().current_scene.add_child(fireball)

func _on_timer_timeout() -> void:
	can_fire = true
