extends Control

func _ready() -> void:
	$VBoxContainer/Resume.pressed.connect(_on_resume_pressed)
	$VBoxContainer/Quit.pressed.connect(_on_quit_pressed)
	pause()


func _on_resume_pressed() -> void:
	resume()


func _on_quit_pressed() -> void:
	# close the application
	get_tree().quit()


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		if is_visible():
			resume()
		else:
			pause()


func resume() -> void:
	hide()
	get_tree().paused = false


func pause() -> void:
	show()
	get_tree().paused = true
	$VBoxContainer/Resume.grab_focus()
