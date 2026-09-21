extends Node2D
@onready var button: GameButton = $Dimension1/Button
@onready var moving_platform_spawn: Marker2D = $Dimension2/MovingPlatformSpawn
@onready var fire_wall_position: Marker2D = $Dimension1/FireWallPosition
@onready var fire_wall_timer: Timer = $FireWallTimer

@onready var spawners := get_tree().get_nodes_in_group("fireball_spawners")

const MovingPlatformScene = preload("res://scenes/objects/moving_platform/moving_platform.tscn")

var fire_wall_enabled = false
var curr_shoot_group = 2; # 2 is top level, 3 is bottom level

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	button.button_pressed.connect(_on_button_pressed)
	
func _process(_delta) -> void:
	if fire_wall_enabled == false and GameManager.get_player_1().global_position.x > fire_wall_position.global_position.x and GameManager.get_player_2().global_position.x > fire_wall_position.global_position.x:
		fire_wall_enabled = true
		fire_wall_timer.start()
	elif fire_wall_enabled == true and (GameManager.get_player_1().global_position.x < fire_wall_position.global_position.x or GameManager.get_player_2().global_position.x < fire_wall_position.global_position.x):
		fire_wall_enabled = false
		fire_wall_timer.stop()

func _on_button_pressed() -> void:
	var moving_platform = MovingPlatformScene.instantiate()
	moving_platform.global_position = moving_platform_spawn.global_position
	moving_platform.global_scale = Vector2(Global.ART_SCALAR,Global.ART_SCALAR)
	moving_platform.despawn = true
	moving_platform.speed = 180.0
	add_child(moving_platform)
	moving_platform.can_move = true


func _on_fire_wall_timer_timeout() -> void:
	for spawner in spawners:
		if spawner.shoot_as_group == curr_shoot_group or spawner.shoot_as_group == 4:
			spawner.shoot_fireball()
	if curr_shoot_group == 2:
		curr_shoot_group = 3
	elif curr_shoot_group == 3: 
		curr_shoot_group = 2
