extends Camera2D

var camera_zoom = 1.5
var player1: Player = null
var player2: Player = null

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	zoom.x = camera_zoom
	zoom.y = camera_zoom


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	set_x_position()
	
func set_x_position() -> void:
	if not player1.is_tweening and not player2.is_tweening:
		var target_x = (player1.global_position.x + player2.global_position.x) / 2
		global_position.x = target_x
		
func set_players(player_1: Player, player_2: Player) -> void:
	player1 = player_1
	player2 = player_2
