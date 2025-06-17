extends Camera2D

var camera_zoom = 1.5
var player1: Player = GameManager.get_player_1()
var player2: Player = GameManager.get_player_2()
var dimension = 0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	zoom.x = camera_zoom
	zoom.y = camera_zoom

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	set_x_position()
	set_y_position()
	
func set_x_position() -> void:
	if not player1.is_tweening and not player2.is_tweening:
		var target_x = (player1.global_position.x + player2.global_position.x) / 2
		global_position.x = target_x

func set_y_position() -> void:
	var player = null
	if player1.current_dimension == dimension:
		player = player1
	else:
		player = player2

	if player.is_tweening:
		return

	var screen_half_height = get_viewport().get_visible_rect().size.y * 0.5
	var camera_half_height = screen_half_height * zoom.y

	# Define margin from center (40% of half screen height)
	var vertical_margin = camera_half_height * 0.2

	var camera_y = global_position.y
	var player_y = player.global_position.y

	var top_bound = camera_y - vertical_margin
	var bottom_bound = camera_y + vertical_margin

	if player_y < top_bound:
		global_position.y = player_y + vertical_margin
	elif player_y > bottom_bound:
		global_position.y = player_y - vertical_margin
