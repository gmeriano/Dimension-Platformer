extends SubViewport


func _ready() -> void:
	set_size(Vector2i(DisplayServer.window_get_size().x, DisplayServer.window_get_size().y / 2))

func _process(delta: float) -> void:
	pass
