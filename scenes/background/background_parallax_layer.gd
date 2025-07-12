extends Parallax2D

@export var layer: int

#func _ready() -> void:
	#print("PARA VACK")
	#repeat_size = get_parent().image_size
	#match layer:
		#0:
			#scroll_scale = Vector2(get_parent().background_speed, 1)
			#repeat_times = get_parent().background_repeat
		#1:
			#scroll_scale = Vector2(get_parent().secondary_background_speed, 1)
			#repeat_times = get_parent().secondary_background_repeat
		#2:
			#scroll_scale = Vector2(get_parent().foreground_speed, 1)
			#repeat_times = get_parent().foreground_repeat
