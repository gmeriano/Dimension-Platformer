extends Camera2D

var camera_zoom = 3

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	zoom.x = camera_zoom
	zoom.y = camera_zoom


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
