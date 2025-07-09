extends Area2D

@onready var sprite_2d: Sprite2D = $CollisionShape2D/Sprite2D

@export var color: Color = Color.REBECCA_PURPLE
@export var open_buttons: Array[GameButton]
@export var press_window: float = 0.5  # seconds

var button_press_times := {}

func _ready() -> void:
	sprite_2d.modulate = color

	# Connect signals and init times
	for button in open_buttons:
		button_press_times[button] = -INF
		button.connect("button_pressed", Callable(self, "_on_button_pressed"))
		
func _on_button_pressed():
	var now := Time.get_ticks_msec() / 1000.0  # Seconds

	# Find which button was just pressed
	for button in open_buttons:
		if button.was_just_pressed():
			button_press_times[button] = now

	# Check if all buttons were pressed within press_window
	var all_recent := true
	for button in open_buttons:
		var last_time = button_press_times.get(button, -INF)
		if now - last_time > press_window:
			all_recent = false
			break

	if all_recent:
		open()
	
func open():
	queue_free()
