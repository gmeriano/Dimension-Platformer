extends Node2D

@onready var cooldown_timer: Timer = $Timer
@onready var color_rect: ColorRect = $ColorRect
var player: Player = null

var can_be_pressed = true

signal button_pressed

func _process(delta: float) -> void:
	if player:
		if can_be_pressed and InputManager.is_interact_pressed(player):
			on_button_pressed.rpc()

@rpc("any_peer", "call_local")
func on_button_pressed() -> void:
	cooldown_timer.start()
	can_be_pressed = false
	emit_signal("button_pressed")
	var tween = create_tween()
	color_rect.modulate = Color(1, 1, 1, 0.5)
	tween.tween_property(color_rect, "modulate:a", 1.0, cooldown_timer.wait_time)

func _on_area_2d_body_entered(body: Node2D) -> void:
	if body is Player:
		player = body


func _on_area_2d_body_exited(body: Node2D) -> void:
	if body is Player:
		player = null

func _on_cooldown_timer_timeout() -> void:
	can_be_pressed = true
