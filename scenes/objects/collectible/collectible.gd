extends Node2D

@onready var area_2d: Area2D = $Area2D
@export var index: int = 0

func _ready():
	if GameManager.get_current_level_collectibles()[index] == true:
		queue_free()

func _on_area_2d_body_entered(body: Node2D) -> void:
	if body is Player:
		var player = body as Player
		if player.is_state_interactable():
			GameManager.collect(index)
			queue_free()
		
