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
	"res://scenes/levels/level1.tscn",
	"res://scenes/levels/easy_platform_level.tscn",
	"res://scenes/levels/level2.tscn",
	"res://scenes/levels/level3.tscn",
	#"res://scenes/levels/level4.tscn",
	"res://scenes/levels/button_platform_level.tscn"
]
var current_level_index = 1

func _ready() -> void:
	load_level(load("res://scenes/levels/level3.tscn"))
	InputManager.setup_player_inputs(player1, player2)
	dimensions["2"].camera.global_position.y += Global.DIMENSION_OFFSET
	
	var joypads = Input.get_connected_joypads()
	print("Connected joypads: ", joypads)

func get_next_level_path() -> String:
	current_level_index = (current_level_index + 1) % level_paths.size()
	return level_paths[current_level_index]

func load_next_level() -> void:
	TransitionScreen.transition()
	TransitionScreen.connect("on_transition_finished", Callable(self, "_on_transition_finished_load_next_level"))

func _on_transition_finished_load_next_level() -> void:
	TransitionScreen.disconnect("on_transition_finished", Callable(self, "_on_transition_finished_load_next_level"))
	load_level(load(level_paths[current_level_index]))
	current_level_index += 1
	if current_level_index >= level_paths.size():
		current_level_index = 0

func load_level(level: PackedScene) -> void:
	# Remove previous level if it exists
	if current_level_node and current_level_node.get_parent():
		current_level_node.get_parent().remove_child(current_level_node)
		current_level_node.queue_free()

	var level_node: Node2D = level.instantiate()
	dimensions["1"].viewport.add_child(level_node)
	dimensions["1"].viewport.move_child(level_node, 0)
	dimensions["2"].viewport.world_2d = dimensions["1"].viewport.world_2d

	current_level_node = level_node

	# Re-assign players
	if current_level_node.has_node("Player1") and current_level_node.has_node("Player2"):
		player1 = current_level_node.get_node("Player1")
		player1.set_camera(dimensions["1"].camera)

		player2 = current_level_node.get_node("Player2")
		player2.set_camera(dimensions["2"].camera)

		players = [player1, player2]

		dimensions["1"].camera.set_players(player1, player2)
		dimensions["2"].camera.set_players(player1, player2)
		InputManager.setup_player_inputs(player1, player2)
	else:
		print("Player nodes not found in loaded level!")
