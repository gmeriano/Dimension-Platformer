extends Node2D

var current_level_node: Node2D = null

@onready var viewport1: SubViewport =  $VBoxContainer/SubViewportContainer/SubViewport
@onready var viewport2: SubViewport = $VBoxContainer/SubViewportContainer2/SubViewport
@onready var camera1: Camera2D = $VBoxContainer/SubViewportContainer/SubViewport/Camera2D
@onready var camera2: Camera2D = $VBoxContainer/SubViewportContainer2/SubViewport/Camera2D

var player1: Player = null
var player2: Player = null
var connected_joypads = Input.get_connected_joypads()  # e.g. [0, 1]

var use_controller_for_p1: bool = true
var use_controller_for_p2: bool = true

var level_paths: Array[String] = [
	#"res://scenes/levels/templates/TemplateLevel.tscn", # TEST (0)
	#"res://scenes/levels/test_levels/TestCameraLevel.tscn", # TEST (0)
	#"res://scenes/levels/test_levels/test_tile_level.tscn",
	"res://scenes/levels/game_levels/intro_level.tscn",
	"res://scenes/levels/game_levels/intro_swapping_level.tscn",
	"res://scenes/levels/game_levels/intro_trampoline_level.tscn",
	"res://scenes/levels/level1.tscn", # 0
	"res://scenes/levels/easy_platform_level.tscn", # 1
	"res://scenes/levels/pole_jump_level.tscn", # 2
	"res://scenes/levels/intro_level_1.tscn", # 3
	"res://scenes/levels/level2.tscn", # 4
	"res://scenes/levels/level3.tscn", # 5
	"res://scenes/levels/button_platform_level.tscn", # 6
	"res://scenes/levels/fire_switch_level.tscn", # 7
	"res://scenes/levels/fire_wall_level.tscn", # 8
	"res://scenes/levels/trampoline_level.tscn", # 9
	"res://scenes/levels/moving_platform_level.tscn", # 10
]
var current_level_index: int = 0

func _ready() -> void:
	Engine.max_fps = 60
	player1 = GameManager.get_player_1()
	player2 = GameManager.get_player_2()
	camera1.dimension = 1
	camera2.dimension = 2
	GameManager.set_camera_1(camera1)
	GameManager.set_camera_2(camera2)
	load_level(load(level_paths[current_level_index]))
	InputManager.setup_player_inputs(player1, player2)
	camera2.global_position.y += Global.DIMENSION_OFFSET
	
	var joypads: Array[int] = Input.get_connected_joypads()
	print("Connected joypads: ", joypads)

func get_next_level_path() -> String:
	current_level_index = (current_level_index + 1) % level_paths.size()
	return level_paths[current_level_index]

func load_next_level() -> void:
	TransitionScreen.transition()
	TransitionScreen.connect("on_transition_finished", Callable(self, "_on_transition_finished_load_next_level"))

func _on_transition_finished_load_next_level() -> void:
	current_level_index += 1
	if current_level_index >= level_paths.size():
		current_level_index = 0
	TransitionScreen.disconnect("on_transition_finished", Callable(self, "_on_transition_finished_load_next_level"))
	load_level(load(level_paths[current_level_index]))

func reload_current_level() -> void:
	TransitionScreen.transition()
	TransitionScreen.connect("on_transition_finished", Callable(self, "_on_transition_finished_reload_current_level"))

func _on_transition_finished_reload_current_level() -> void:
	TransitionScreen.disconnect("on_transition_finished", Callable(self, "_on_transition_finished_reload_current_level"))
	load_level(load(level_paths[current_level_index]))

func load_level(level: PackedScene) -> void:
	# Remove previous level if it exists
	if current_level_node and current_level_node.get_parent():
		current_level_node.remove_child(GameManager.get_player_1())
		current_level_node.remove_child(GameManager.get_player_2())
		current_level_node.get_parent().remove_child(current_level_node)
		current_level_node.queue_free()

	GameManager.set_camera_zoom_default()

	var level_node: Node2D = level.instantiate()
	viewport1.add_child(level_node)
	viewport1.move_child(level_node, 0)
	viewport2.world_2d = viewport1.world_2d

	current_level_node = level_node

	# Set respawn point to start of level if not already set
	if player1.respawn_point == Vector2.ZERO:	
		player1.respawn_point = current_level_node.get_node("Dimension1").get_node("Player1Spawn").global_position
	if player2.respawn_point == Vector2.ZERO:
		player2.respawn_point = current_level_node.get_node("Dimension2").get_node("Player2Spawn").global_position

	player1.global_position = player1.respawn_point.round()
	player2.global_position = player2.respawn_point.round()

	player1.current_dimension = 1 if player1.global_position.y < player2.global_position.y else 2
	player1.original_dimension = player1.current_dimension
	player1.update_shadow_location()
	current_level_node.add_child(player1)
	
	player2.current_dimension = 1 if player2.global_position.y < player1.global_position.y else 2
	player2.original_dimension = player2.current_dimension
	player2.update_shadow_location()
	current_level_node.add_child(player2)
	
	GameManager.focus_camera_on_start()

	InputManager.setup_player_inputs(player1, player2)
