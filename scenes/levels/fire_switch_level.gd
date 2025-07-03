extends Node2D

@onready var level_manager: LevelManager = $LevelManager
@onready var shoot_timer_1: Timer = $Dimension1/ShootTimer1
@onready var shoot_timer_2: Timer = $Dimension2/ShootTimer2
@onready var double_timer: Timer = $DoubleTimer

@onready var spawners := get_tree().get_nodes_in_group("fireball_spawners")
var current_dim_shoot = 1

func _ready() -> void:
	level_manager.respawn_players.connect(Callable(self, "_on_level_reset"))
	shoot_timer_1.start()

func _on_level_reset() -> void:
	current_dim_shoot = 1
	shoot_timer_1.stop()
	shoot_timer_2.stop()
	double_timer.stop()
	shoot_timer_1.start()

func _on_shoot_timer_1_timeout() -> void:
	double_timer.start()
	shoot_timer_1.stop()
	shoot_timer_2.start()
	for spawner in spawners:
		var fireball_spawner = spawner as FireballSpawner
		if fireball_spawner.dimension == 1 or fireball_spawner.dimension == -1:
			fireball_spawner.shoot_fireball()


func _on_shoot_timer_2_timeout() -> void:
	double_timer.start()
	shoot_timer_2.stop()
	shoot_timer_1.start()
	for spawner in spawners:
		var fireball_spawner = spawner as FireballSpawner
		if fireball_spawner.dimension == 2 or fireball_spawner.dimension == -1:
			fireball_spawner.shoot_fireball()


func _on_double_timer_timeout() -> void:
	double_timer.stop()
	for spawner in spawners:
		var fireball_spawner = spawner as FireballSpawner
		if fireball_spawner.dimension == current_dim_shoot or fireball_spawner.dimension == -1:
			fireball_spawner.can_fire = true
			fireball_spawner.shoot_fireball()
	current_dim_shoot = 1 if current_dim_shoot == 2 else 2
