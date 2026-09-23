extends SubViewport


func _ready() -> void:
	#set_size(Vector2i(DisplayServer.window_get_size().x, DisplayServer.window_get_size().y / 2.0))
	#set_size(Vector2i(DisplayServer.window_get_size().x, DisplayServer.window_get_size().y / 2.0))
	#set_size(Vector2i(640, 180))
	set_size(Vector2i(1920, 1080/2.0))
	print("SIZE: ", size)
	#snap_2d_transforms_to_pixel = true
	render_target_update_mode = SubViewport.UPDATE_ALWAYS
