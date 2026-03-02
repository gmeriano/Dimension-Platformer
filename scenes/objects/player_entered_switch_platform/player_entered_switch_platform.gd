extends Node2D
class_name PlayerEnteredSwitchPlatform

@onready var switch_platform: SwitchPlatform = $SwitchPlatform
@export var current_dimension: int = 1
var curr_player: Player = null

func _ready() -> void:
	add_to_group("player_entered_switch_platform")
	switch_platform.current_dimension = current_dimension

func _process(_delta: float) -> void:
	if curr_player:
		if curr_player.global_position.y < global_position.y:
			if curr_player != null and curr_player.state_machine.current_state.get_state_name() != PlayerRespawnState.state_name and curr_player.state_machine.current_state.get_state_name() != PlayerDimensionSwapState.state_name:
				switch_platform.player_on_platform = true
	update_color()

func _on_area_2d_body_entered(body: Node2D) -> void:
	if body is Player:
		var player = body as Player
		curr_player = player
		

func _on_area_2d_body_exited(body: Node2D) -> void:
	if body is Player:
		var player: Player = body as Player
		curr_player = null
		if switch_platform.player_on_platform:
			switch_platform.player_on_platform = false
			if player.state_machine.current_state.get_state_name() != PlayerRespawnState.state_name and player.state_machine.current_state.get_state_name() != PlayerDimensionSwapState.state_name:
				switch_platform.switch_dimension()
				
func update_color() -> void:
	if switch_platform.player_on_platform:
		switch_platform.platform.sprite_2d.modulate = Color(1, 0, 0)
	else:
		switch_platform.platform.sprite_2d.modulate = Color(0, 0, 0)
