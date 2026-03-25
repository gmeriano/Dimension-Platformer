extends Node2D

@export_group("Movement Settings")
@export var distance: float = 300.0
@export var time: float = 5.0
@export var start_right: bool = true

@onready var anim_player: AnimationPlayer = $AnimatableBody2D/AnimationPlayer


func _ready() -> void:
	_setup_dynamic_animation()
	#anim_player.current_animation = "ModularMove"
	#anim_player.play("ModularMove")
	pass
	
func _process(_delta: float):
	print(anim_player.is_playing())

func _setup_dynamic_animation() -> void:
	#var original_anim: Animation = anim_player.get_animation("ModularMove")
	#var anim = original_anim.duplicate()
	var unique_anim_name = "Move_" + str(get_instance_id())
	print("UNIQIE: ", unique_anim_name)
	var lib = anim_player.get_animation_library("")
	var anim: Animation = Animation.new()
	anim.add_track(Animation.TYPE_VALUE, 0)
	
	lib.add_animation(unique_anim_name, anim)
	var track_idx = 0
	anim.track_set_path(track_idx, ".:position")
	anim.loop_mode = Animation.LOOP_PINGPONG

	#var distance = 600
	#var time = 2.0
	#var start_right = true
	if (start_right):
		anim.length = time
		anim.track_insert_key(track_idx, 0.0, Vector2.ZERO)
		anim.track_insert_key(track_idx, time/2.0, Vector2(distance, 0))
		anim.track_insert_key(track_idx, time, Vector2.ZERO)
		anim.value_track_set_update_mode(track_idx, Animation.UPDATE_CONTINUOUS)
		anim.track_set_interpolation_type(track_idx, Animation.INTERPOLATION_LINEAR)
	else:
		anim.length = time
		anim.track_insert_key(track_idx, 0.0, Vector2.ZERO)
		anim.track_insert_key(track_idx, time/2.0, Vector2(-1.0*distance, 0))
		anim.track_insert_key(track_idx, time, Vector2.ZERO)
		anim.value_track_set_update_mode(track_idx, Animation.UPDATE_CONTINUOUS)
		anim.track_set_interpolation_type(track_idx, Animation.INTERPOLATION_LINEAR)
	anim_player.play(unique_anim_name)
