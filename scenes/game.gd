extends Node2D

var current_level_node: Node2D = null
@onready var players = {
	"1": {
		idx = 1,
		viewport = $VBoxContainer/SubViewportContainer/SubViewport,
		camera = $VBoxContainer/SubViewportContainer/SubViewport/Camera2D,
		player = null
	},
	"2": {
		idx = 2,
		viewport = $VBoxContainer/SubViewportContainer2/SubViewport,
		camera = $VBoxContainer/SubViewportContainer2/SubViewport/Camera2D,
		player = null
	}
}

func _ready() -> void:
	load_level(load("res://scenes/test_level.tscn"))
		
func _process(delta: float) -> void:
	if Input.is_action_just_pressed("switch_scene"):
		load_level(preload("res://scenes/test_level2.tscn"))
		
func load_level(level: PackedScene) -> void:
	var level_node: Node2D = level.instantiate()
	$VBoxContainer/SubViewportContainer/SubViewport.remove_child(current_level_node)
	$VBoxContainer/SubViewportContainer/SubViewport.add_child(level_node)
	$VBoxContainer/SubViewportContainer/SubViewport.move_child(level_node, 0)
	current_level_node = level_node
	players["2"].viewport.world_2d = players["1"].viewport.world_2d
	for node in players.values():
		var remote_transform = RemoteTransform2D.new()
		remote_transform.remote_path = node.camera.get_path()
		if node.idx == 1:
			node.player = level_node.get_node("Player1")
		else:
			node.player = level_node.get_node("Player2")
		node.player.add_child(remote_transform)
