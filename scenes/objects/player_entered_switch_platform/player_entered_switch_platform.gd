extends Node2D

@onready var switch_platform: SwitchPlatform = $SwitchPlatform
@export var current_dimension: int = 0

func _ready() -> void:
	switch_platform.current_dimension = current_dimension
	switch_platform.original_dimension = current_dimension

func _process(delta: float) -> void:
	update_color()

func _on_area_2d_body_entered(body: Node2D) -> void:
	if body is Player:
		var player = body as Player
		if !player.is_tweening:
			switch_platform.player_on_platform = true

func _on_area_2d_body_exited(body: Node2D) -> void:
	if body is Player:
		var player: Player = body as Player
		if switch_platform.player_on_platform:
			switch_platform.player_on_platform = false
			if not player.is_tweening:
				switch_platform.switch_dimension()
				
func update_color() -> void:
	if switch_platform.player_on_platform:
		switch_platform.platform.sprite_2d.modulate = Color(1, 0, 0)
	else:
		switch_platform.platform.sprite_2d.modulate = Color(0, 0, 0)
