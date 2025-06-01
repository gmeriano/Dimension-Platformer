extends SubViewport


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	set_size(Vector2i(DisplayServer.window_get_size().x, DisplayServer.window_get_size().y / 2))


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
