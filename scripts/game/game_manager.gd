extends Node2D
class_name GameManager
@onready var level_complete_zone: Node2D = $"../LevelCompleteZone"
@onready var level_complete_zone_2: Node2D = $"../LevelCompleteZone2"

@onready var player_1: Player = $"../Player1"
@onready var player_2: Player = $"../Player2"
var players = null

signal respawn_players

func _ready():
	players = [player_1, player_2]
	
func _process(delta: float) -> void:
	handle_inputs()
	check_level_complete()

func handle_inputs() -> void:
	if InputManager.is_dimension_swap_pressed(player_1) or InputManager.is_dimension_swap_pressed(player_2):
		for player in players:
			player.swap_dimension()
	if Input.is_action_just_pressed("switch_scene"):
		load_next_level()	

func respawn_all_players():
	set_can_move(false)
	TransitionScreen.transition()
	TransitionScreen.connect("on_transition_finished", Callable(self, "_on_transition_finished_respawn"))
	
func _on_transition_finished_respawn():
	TransitionScreen.disconnect("on_transition_finished", Callable(self, "_on_transition_finished_respawn"))
	emit_signal("respawn_players")
	set_can_move(true)
	
func set_can_move(can_move: bool) -> void:
	player_1.can_move = can_move
	player_2.can_move = can_move
	
func check_level_complete() -> void:
	if level_complete_zone.complete == true and level_complete_zone_2.complete == true:
		load_next_level()
	
func load_next_level() -> void:
	var game_node = get_tree().get_root().get_node("Game")
	game_node.load_next_level()
	
