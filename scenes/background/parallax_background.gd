extends Node2D
class_name GameBackgroundParallaxNode

@export var dimension: int = 1
@export var background_texture: Texture2D
@export var background_speed: float
@export var background_repeat: int
@export var secondary_background_texture: Texture2D
@export var secondary_background_speed: float
@export var secondary_background_repeat: int
@export var foreground_texture: Texture2D
@export var foreground_speed: float
@export var foreground_repeat: int
@export var image_size: Vector2

@onready var parallax_2d: Parallax2D = $Parallax2D
@onready var background: Sprite2D = $Parallax2D/background
@onready var parallax_2d_2: Parallax2D = $Parallax2D2
@onready var secondary_background: Sprite2D = $Parallax2D2/secondary_background
@onready var parallax_2d_3: Parallax2D = $Parallax2D3
@onready var foreground: Sprite2D = $Parallax2D3/foreground


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if dimension == 1:
		global_position = GameManager.camera1.get_screen_center_position()
	elif dimension == 2:
		var pos = GameManager.camera1.get_screen_center_position()
		pos.y += Global.DIMENSION_OFFSET
		global_position = pos
	print("POS: ", global_position)
	parallax_2d.scroll_scale.x = background_speed
	parallax_2d.repeat_size = image_size
	parallax_2d.repeat_times = background_repeat
	parallax_2d_2.scroll_scale.x = secondary_background_speed
	parallax_2d_2.repeat_size = image_size
	parallax_2d_2.repeat_times = secondary_background_repeat
	parallax_2d_3.scroll_scale.x = foreground_speed
	parallax_2d_3.repeat_size = image_size
	parallax_2d_3.repeat_times = foreground_repeat
	
	background.texture = background_texture
	secondary_background.texture = secondary_background_texture
	foreground.texture = foreground_texture
