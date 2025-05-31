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

func _ready() -> void:
	load_level(load("res://scenes/test_level3.tscn"))
	dimensions["2"].camera.global_position.y += Global.DIMENSION_OFFSET
		
func _process(delta: float) -> void:
	handle_input()

func handle_input() -> void:
	if Input.is_action_just_pressed("switch_scene"):
		load_level(preload("res://scenes/test_level2.tscn"))
		
	if Input.is_action_just_pressed("dimension_swap"):
		for player in players:
			player.swap_dimension()
	
func load_level(level: PackedScene) -> void:
	var level_node: Node2D = level.instantiate()
	dimensions["1"].viewport.remove_child(current_level_node)
	dimensions["1"].viewport.add_child(level_node)
	dimensions["1"].viewport.move_child(level_node, 0)
	dimensions["2"].viewport.world_2d = dimensions["1"].viewport.world_2d
	
	current_level_node = level_node

	player1 = current_level_node.get_node("Player1")
	player1.set_camera(dimensions["1"].camera)
	player2 = current_level_node.get_node("Player2")
	player2.set_camera(dimensions["2"].camera)
	players = [player1, player2]
	
	dimensions["1"].camera.set_players(player1, player2)
	dimensions["2"].camera.set_players(player1, player2)
