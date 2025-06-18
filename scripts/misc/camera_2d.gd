extends Camera2D

@export var normal_camera_zoom = 1.5
@export var min_zoom = 0.5
@export var max_zoom = 3.0
@export var zoom_out_speed = 3.0
@export var zoom_in_speed = 5.0
@export var dimension = 1  # 1 or 2
@export var zoom_out_trigger_buffer = 0.25  # percentage of screen
@export var zoom_in_trigger_buffer = 0.375  # percentage of screen (greater than zoom out)
@export var lower_camera_bound_offset = 0.25 # percentage of screen

var player1: Player = GameManager.get_player_1()
var player2: Player = GameManager.get_player_2()

var previous_zoom = normal_camera_zoom
var zoom_target = normal_camera_zoom
var is_zooming_out = false
var initial_position: Vector2
var camera_y_target: float

func _ready() -> void:
	zoom = Vector2(normal_camera_zoom, normal_camera_zoom)
	previous_zoom = normal_camera_zoom
	initial_position = global_position
	camera_y_target = initial_position.y
	if dimension == 2:
		initial_position.y += Global.DIMENSION_OFFSET
		camera_y_target = initial_position.y

func _process(delta: float) -> void:
	if !player1.is_tweening and !player2.is_tweening:
		set_x_position()
		update_camera_zoom(delta)
		update_camera_y_target(delta)
		
		# Smoothly move camera Y towards target
		global_position.y = lerp(global_position.y, camera_y_target, delta * 3.0)

func reset() -> void:
	global_position = initial_position
	zoom = Vector2(normal_camera_zoom, normal_camera_zoom)
	camera_y_target = initial_position.y

func set_x_position() -> void:
	global_position.x = (player1.global_position.x + player2.global_position.x) * 0.5

func get_active_player() -> Player:
	return player1 if player1.current_dimension == dimension else player2

func get_other_player() -> Player:
	return player1 if player1.current_dimension != dimension else player2

func update_camera_zoom(delta: float) -> void:
	var player = get_active_player()
	var other_player = get_other_player()

	var half_visible_height = (get_viewport_rect().size.y / zoom.y) * 0.5
	var top_edge_y = global_position.y - half_visible_height

	var distance_to_top_player = player.global_position.y - top_edge_y
	var other_pos_y = other_player.global_position.y
	if dimension == 1:
		other_pos_y -= Global.DIMENSION_OFFSET
	else:
		other_pos_y += Global.DIMENSION_OFFSET
	var distance_to_top_other = other_pos_y - top_edge_y

	var distance_to_top = min(distance_to_top_player, distance_to_top_other)

	var zoom_out_threshold = half_visible_height * (zoom_out_trigger_buffer * 2)
	var zoom_in_threshold = half_visible_height * (zoom_in_trigger_buffer * 2)

	if distance_to_top < zoom_out_threshold:
		is_zooming_out = true
		var zoom_ratio = clamp(distance_to_top / zoom_out_threshold, 0.2, 1.0)
		zoom_target = normal_camera_zoom * zoom_ratio
	elif is_zooming_out and distance_to_top > zoom_in_threshold:
		is_zooming_out = false
		zoom_target = normal_camera_zoom
	# else keep zoom_target as is

	zoom_target = clamp(zoom_target, min_zoom, normal_camera_zoom)

	if abs(zoom.y - zoom_target) > 0.01:
		var zoom_speed = zoom_out_speed if zoom_target < zoom.y else zoom_in_speed
		var new_zoom = lerp(zoom.y, zoom_target, ease_func(delta * zoom_speed))

		# Re-anchor camera bottom-left to avoid showing below floor
		var viewport_size = get_viewport_rect().size
		var zoom_diff = new_zoom - previous_zoom
		if abs(zoom_diff) > 0.001:
			var anchor_offset = Vector2()
			anchor_offset.x = viewport_size.x * 0.5 * zoom_diff
			anchor_offset.y = viewport_size.y * zoom_diff  # full height for bottom alignment

			camera_y_target += anchor_offset.y
			global_position += anchor_offset  # immediately apply horizontal offset

		zoom = Vector2(new_zoom, new_zoom)
		previous_zoom = new_zoom

func update_camera_y_target(delta: float) -> void:
	var active_player = get_active_player()
	var other_player = get_other_player()

	var adjusted_other_y = other_player.global_position.y
	if dimension == 1:
		adjusted_other_y -= Global.DIMENSION_OFFSET
	else:
		adjusted_other_y += Global.DIMENSION_OFFSET

	var lowest_player_y = max(active_player.global_position.y, adjusted_other_y)

	var half_visible_height = (get_viewport_rect().size.y / zoom.y) * 0.5

	# Dynamic lower bound offset scales inversely with zoom ratio:
	var zoom_ratio = zoom.x / normal_camera_zoom
	var dynamic_offset = clamp(lower_camera_bound_offset / zoom_ratio, 0.0, 1.0)

	# Calculate where the bottom edge target should be
	var bottom_edge_y = camera_y_target + half_visible_height * dynamic_offset

	# Adjust camera_y_target to keep lowest player above bottom edge with dynamic offset
	camera_y_target = lowest_player_y - half_visible_height * dynamic_offset

	# Prevent camera from going below initial position (floor)
	camera_y_target = min(camera_y_target, initial_position.y)

func ease_func(t: float) -> float:
	return t * t * (3.0 - 2.0 * t)  # smoothstep easing
