extends Node2D

var current_level_node: Node2D = null
@onready var dimensions = {
	"1": {
		idx = 1,
		viewport = $VBoxContainer/SubViewportContainer/SubViewport,
		camera = $VBoxContainer/SubViewportContainer/SubViewport/Camera2D,
	},
	"2": {
		idx = 2,
		viewport = $VBoxContainer/SubViewportContainer2/SubViewport,
		camera = $VBoxContainer/SubViewportContainer2/SubViewport/Camera2D,
	}
}
var player1: Player = null
var player2: Player = null
var players = null
var connected_joypads = Input.get_connected_joypads()  # e.g. [0, 1]

var use_controller_for_p1 = true
var use_controller_for_p2 = true

var level_paths := [
	#"res://scenes/levels/test_levels/TestCameraLevel.tscn", # TEST (0)
	"res://scenes/levels/level1.tscn", # 0
	"res://scenes/levels/easy_platform_level.tscn", # 1
	"res://scenes/levels/level2.tscn", # 2
	"res://scenes/levels/level3.tscn", # 3
	"res://scenes/levels/button_platform_level.tscn", # 4
	"res://scenes/levels/fire_wall_level.tscn", # 5
	"res://scenes/levels/moving_platform_level.tscn", # 6
	"res://scenes/levels/pole_jump_level.tscn", # 7
]
var current_level_index = 2

func _ready() -> void:
	player1 = GameManager.get_player_1()
	player2 = GameManager.get_player_2()
	dimensions["1"].camera.dimension = 1
	dimensions["2"].camera.dimension = 2
	GameManager.set_camera_1(dimensions["1"].camera)
	GameManager.set_camera_2(dimensions["2"].camera)
	load_level(load(level_paths[current_level_index]))
	InputManager.setup_player_inputs(player1, player2)
	dimensions["2"].camera.global_position.y += Global.DIMENSION_OFFSET
	
	var joypads = Input.get_connected_joypads()
	print("Connected joypads: ", joypads)

func get_next_level_path() -> String:
	current_level_index = (current_level_index + 1) % level_paths.size()
	return level_paths[current_level_index]

func load_next_level() -> void:
	GameManager.set_can_move(false)
	TransitionScreen.transition()
	TransitionScreen.connect("on_transition_finished", Callable(self, "_on_transition_finished_load_next_level"))

func _on_transition_finished_load_next_level() -> void:
	current_level_index += 1
	if current_level_index >= level_paths.size():
		current_level_index = 0
	TransitionScreen.disconnect("on_transition_finished", Callable(self, "_on_transition_finished_load_next_level"))
	load_level(load(level_paths[current_level_index]))

func load_level(level: PackedScene) -> void:
	# Remove previous level if it exists
	if current_level_node and current_level_node.get_parent():
		current_level_node.remove_child(GameManager.get_player_1())
		current_level_node.remove_child(GameManager.get_player_2())
		current_level_node.get_parent().remove_child(current_level_node)
		current_level_node.queue_free()

	var level_node: Node2D = level.instantiate()
	dimensions["1"].viewport.add_child(level_node)
	dimensions["1"].viewport.move_child(level_node, 0)
	dimensions["2"].viewport.world_2d = dimensions["1"].viewport.world_2d

	current_level_node = level_node

	# Re-assign players
	player1.global_position = current_level_node.get_node("Dimension1").get_node("Player1Spawn").global_position
	player1.respawn_point = player1.global_position
	player1.current_dimension = 1
	player1.original_dimension = 1
	player1.update_shadow_location()
	current_level_node.add_child(player1)
	
	player2.global_position = current_level_node.get_node("Dimension2").get_node("Player2Spawn").global_position
	player2.respawn_point = player2.global_position
	player2.current_dimension = 2
	player2.original_dimension = 2
	player2.update_shadow_location()
	current_level_node.add_child(player2)

	players = [player1, player2]

	InputManager.setup_player_inputs(player1, player2)
