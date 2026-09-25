extends Node2D

@onready var area_2d: Area2D = $Area2D
@export var index: int = 0

var player: Player = null

func _ready():
	if GameManager.get_current_level_collectibles()[index] == true:
		queue_free()

func _physics_process(_delta: float) -> void:
	if player != null and player.is_state_interactable():
		GameManager.collect(index)
		queue_free()

func _on_area_2d_body_entered(body: Node2D) -> void:
	if body is Player:
		player = body as Player
		if player.is_state_interactable():
			GameManager.collect(index)
			queue_free()
		


func _on_area_2d_body_exited(body: Node2D) -> void:
	if body as Player == player:
		player = null
