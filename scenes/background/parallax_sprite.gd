extends Sprite2D

@export var layer: int

#func _ready() -> void:
	#print("PARA SPRITE")
	#match layer:
		#0:
			#texture = get_parent().get_parent().background_texture
		#1:
			#texture = get_parent().get_parent().secondary_background_texture
		#2:
			#texture = get_parent().get_parent().foreground_texture
