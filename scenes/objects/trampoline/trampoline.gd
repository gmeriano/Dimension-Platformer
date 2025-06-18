extends Node2D
class_name Trampoline

@export var bounce_multiplier = 1.5  # Tune this to adjust how much force is applied
@export var max_bounce_force = 2000.0
@export var min_bounce_force = 400.0

func _on_area_2d_body_entered(body: Node2D) -> void:
	if body is Player:
		var velocity = body.velocity
		# Only react to downward movement
		if velocity.y > 0:
			var bounce_force = velocity.y * bounce_multiplier
			bounce_force = clamp(bounce_force, min_bounce_force, max_bounce_force)
			
			body.velocity.y = -bounce_force  # Launch upwards
			body.move_and_slide()  # Apply the velocity immediately
