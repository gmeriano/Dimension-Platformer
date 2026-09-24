extends Control

@onready var level_select: TextEdit = $VBoxContainer/HBoxContainer/LevelSelect
@onready var resume_button: Button = $VBoxContainer/ResumeButton

func _notification(what: int) -> void:
	match what:
		Node.NOTIFICATION_PAUSED:
			hide()
		Node.NOTIFICATION_UNPAUSED:
			show()
			resume_button.grab_focus.call_deferred()
			

func _on_resume_button_pressed() -> void:
	get_tree().paused = !get_tree().paused

func _on_reload_button_pressed() -> void:
	get_tree().paused = !get_tree().paused
	GameManager.reload_current_level()

func _on_exit_button_pressed() -> void:
	get_tree().quit()

func _on_load_level_button_pressed() -> void:
	if level_select.text.is_valid_int():
		var level = int(level_select.text) - 1
		if level >= 0 and level < len(GameManager.level_paths):
			get_tree().paused = !get_tree().paused
			GameManager.load_specific_level(level)
		
