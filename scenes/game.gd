extends Node2D

var current_level_node: Node2D = null
@onready var dimensions = {
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
	dimensions["2"].camera.global_position.y += Global.DIMENSION_OFFSET
		
func _process(delta: float) -> void:
	handle_input()
	
	if not dimensions["1"].player.is_tweening and not dimensions["2"].player.is_tweening:
		var target_x = (dimensions["1"].player.global_position.x + dimensions["2"].player.global_position.x) / 2
		dimensions["1"].camera.global_position.x = target_x
		dimensions["2"].camera.global_position.x = target_x
	
func handle_input() -> void:
	if Input.is_action_just_pressed("switch_scene"):
		load_level(preload("res://scenes/test_level2.tscn"))
		
	if Input.is_action_just_pressed("dimension_swap"):
		for node in dimensions.values():
			#node.player.can_move = false
			#TransitionScreen.transition()
			#await TransitionScreen.on_transition_finished
			#node.player.can_move = true
			node.player.swap_dimension()
	
func load_level(level: PackedScene) -> void:
	var level_node: Node2D = level.instantiate()
	dimensions["1"].viewport.remove_child(current_level_node)
	dimensions["1"].viewport.add_child(level_node)
	dimensions["1"].viewport.move_child(level_node, 0)
	dimensions["2"].viewport.world_2d = dimensions["1"].viewport.world_2d
	
	current_level_node = level_node

	for node in dimensions.values():
		if node.idx == 1:
			node.player = current_level_node.get_node("Player1")
			node.player.set_camera(dimensions["1"].camera)
		else:
			node.player = current_level_node.get_node("Player2")
			node.player.set_camera(dimensions["2"].camera)
