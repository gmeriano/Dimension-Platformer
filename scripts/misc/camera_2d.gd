extends Camera2D

@export var camera_zoom = 1.5
@export var min_zoom = 0.5
@export var max_zoom = 3.0
@export var zoom_out_speed = 3.0
@export var zoom_in_speed = 5.0
@export var dimension = 1  # 1 or 2
@export var zoom_out_trigger_buffer = 0.25  # percentage of screen
@export var zoom_in_trigger_buffer = 0.35  # percentage of screen (greater than zoom out)

var player1: Player = GameManager.get_player_1()
var player2: Player = GameManager.get_player_2()
var previous_zoom = camera_zoom
var zoom_target = camera_zoom
var is_zooming_out = false
var initial_position: Vector2

func _ready() -> void:
	zoom = Vector2(camera_zoom, camera_zoom)
	previous_zoom = camera_zoom
	initial_position = global_position
	if dimension == 2:
		initial_position.y += Global.DIMENSION_OFFSET

func _process(delta: float) -> void:
	if !player1.is_tweening and !player2.is_tweening:
		set_x_position()
		update_camera_zoom(delta)

func reset() -> void:
	global_position = initial_position
	zoom = Vector2(camera_zoom, camera_zoom)

func set_x_position() -> void:
	var mid_x = (player1.global_position.x + player2.global_position.x) / 2
	global_position.x = mid_x

func get_active_player() -> Player:
	return player1 if player1.current_dimension == dimension else player2

func get_other_player() -> Player:
	return player1 if player1.current_dimension != dimension else player2

func update_camera_zoom(delta: float) -> void:
	var player = get_active_player()
	var other_player = get_other_player()

	var half_visible_height = (get_viewport_rect().size.y / zoom.y) / 2
	var top_edge_y = global_position.y - half_visible_height
	var quarter_visible_height = half_visible_height / 2

	var distance_to_top_player = player.global_position.y - top_edge_y
	var other_position_y = other_player.global_position.y - Global.DIMENSION_OFFSET if dimension == 1 else other_player.global_position.y + Global.DIMENSION_OFFSET
	var distance_to_top_other = other_position_y - top_edge_y

	var distance_to_top = min(distance_to_top_player, distance_to_top_other)

	var zoom_out_threshold = half_visible_height * zoom_out_trigger_buffer
	var zoom_in_threshold = half_visible_height * zoom_in_trigger_buffer

	if distance_to_top < zoom_out_threshold:
		is_zooming_out = true
		var zoom_ratio = clamp(distance_to_top / zoom_out_threshold, 0.2, 1.0)
		zoom_target = camera_zoom * zoom_ratio

	elif is_zooming_out and distance_to_top > zoom_in_threshold:
		is_zooming_out = false
		zoom_target = camera_zoom

	# If in between, do nothing (dead zone)
	elif not is_zooming_out:
		zoom_target = zoom_target

	zoom_target = clamp(zoom_target, min_zoom, camera_zoom)

	# Only update if zoom is meaningfully different
	if abs(zoom.y - zoom_target) > 0.01:
		var zoom_speed = zoom_out_speed if zoom_target < zoom.y else zoom_in_speed
		var new_zoom = lerp(zoom.y, zoom_target, ease_func(delta * zoom_speed))

		# Re-anchor to bottom-left to preserve screen position
		var viewport_size = get_viewport_rect().size
		var zoom_diff = new_zoom - previous_zoom
		if abs(zoom_diff) > 0.001:
			var anchor_offset = Vector2(viewport_size.x, viewport_size.y) * 0.5 * zoom_diff
			global_position += anchor_offset

		zoom = Vector2(new_zoom, new_zoom)
		previous_zoom = new_zoom

func ease_func(t: float) -> float:
	return t * t * (3.0 - 2.0 * t)  # Smoothstep easing
