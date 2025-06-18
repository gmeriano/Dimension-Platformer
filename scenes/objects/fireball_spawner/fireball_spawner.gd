extends Node2D
class_name FireballSpawner

@export var fireball_scene: PackedScene
@export var fire_rate: float = 2.0
@onready var muzzle: Marker2D = $Muzzle
@onready var timer: Timer = $Timer
@export var direction: Vector2 = Vector2.LEFT
@export var shoot_as_group = true
@export var fireball_speed = 225.0

var can_fire: bool = true

func _ready():
	add_to_group("fireball_spawners")

func _process(delta: float):
	if Input.is_action_just_pressed("switch_scene"):
		shoot_fireball()
func shoot_fireball():
	if can_fire:
		can_fire = false
		timer.start()
		var fireball = fireball_scene.instantiate()
		fireball.speed = fireball_speed
		fireball.position = muzzle.position
		fireball.direction = direction
		add_child(fireball)

func _on_timer_timeout() -> void:
	can_fire = true
