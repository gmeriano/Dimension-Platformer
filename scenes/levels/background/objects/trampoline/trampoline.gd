extends Node2D
class_name Trampoline

@export var max_bounce_force = 800.0
@export var min_bounce_force = 300.0

func _on_area_2d_body_entered(body: Node2D) -> void:
	if body is Player:
		var velocity = body.velocity
		# Only react to downward movement
		if velocity.y > 0:
			var bounce_force = velocity.y
			bounce_force = clamp(bounce_force, min_bounce_force, max_bounce_force)
			
			body.velocity.y = -bounce_force  # Launch upwards
			print("TRAMPOILNE BOUNCE: ", bounce_force, " velocity: ", body.velocity)
			body.move_and_slide()  # Apply the velocity immediately
