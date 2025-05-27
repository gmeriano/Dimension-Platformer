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
		
	#if Input.is_action_just_pressed("dimension_swap"):
		#players["1"].player.can_move = false
		#players["2"].player.can_move = false
		#TransitionScreen.transition()
		#await TransitionScreen.on_transition_finished
		#players["1"].player.can_move = true
		#players["2"].player.can_move = true
		
	# Assume you have references to your two Camera2D nodes:
	var cam1 = players["1"].camera
	var cam2 = players["2"].camera

	# Decide the X coordinate you want both cameras to have.
	# Example: average the players' X positions, or choose one player's X

	var target_x = (cam1.global_position.x + cam2.global_position.x) / 2

	# Update both cameras to have the same X, keep their Y independent
	cam1.global_position.x = target_x
	cam2.global_position.x = target_x
	
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
			remote_transform.name = "RemoteTransformP1"
			node.player = level_node.get_node("Player1")
		else:
			remote_transform.name = "RemoteTransformP2"
			node.player = level_node.get_node("Player2")
		node.player.add_child(remote_transform)
		node.player.setCamera()
