@tool
extends Node2D
class_name BackgroundNode

@export var background_settings: Array[BackgroundSettings]
@export var full_image_size: Vector2

var background_set = false

func _ready() -> void:
	if !background_set:
		background_set = true
		set_background_from_settings()

func _process(_delta: float) -> void:
	if Engine.is_editor_hint() and !background_set:
		print(background_set)
		background_set = true
		print("Setting background from settings in editor.")
		set_background_from_settings()

func set_background_from_settings() -> void:
	z_index = -1000  # Ensure the background is rendered behind everything else
	position = Vector2(full_image_size.x / 2.0, -full_image_size.y / 2.0)
	for i in range(background_settings.size()):
		var parallax_2d = Parallax2D.new()
		parallax_2d.scroll_scale.x = background_settings[i].speed
		parallax_2d.repeat_size = Vector2(background_settings[i].image_size.x, 0)
		parallax_2d.repeat_times = background_settings[i].repeat
		var texture_sprite = Sprite2D.new()
		texture_sprite.texture = background_settings[i].texture
		texture_sprite.scale = Vector2(background_settings[i].image_scale, background_settings[i].image_scale)
		parallax_2d.add_child(texture_sprite)
		add_child(parallax_2d)

