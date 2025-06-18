extends Node2D

@onready var switch_platform: SwitchPlatform = $SwitchPlatform
@onready var timer: Timer = $Timer
@export var current_dimension: int = 1
@export var timer_wait_time = 0.3

func _ready():
	timer.wait_time = timer_wait_time
	switch_platform.current_dimension = current_dimension
	switch_platform.original_dimension = current_dimension
	for button in get_tree().get_nodes_in_group("trigger_buttons"):
		button.connect("button_pressed", Callable(self, "on_any_button_pressed"))

func on_any_button_pressed() -> void:
	switch_platform.switch_dimension()
	timer.start()


func _on_timer_timeout() -> void:
	switch_platform.switch_dimension()
