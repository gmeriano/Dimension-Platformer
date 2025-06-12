extends Node2D

var complete = false

func _ready() -> void:
	self.z_index = 1

func _on_area_2d_body_entered(body: Node2D) -> void:
	if body is Player:
		#if body.can_move:
		complete = true

func _on_area_2d_body_exited(body: Node2D) -> void:
	if body is Player:
		complete = false
