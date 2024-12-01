extends Control

func _ready() -> void:
	$VBoxContainer/Resume.pressed.connect(_on_resume_pressed)
	$VBoxContainer/Quit.pressed.connect(_on_quit_pressed)
	pause()


func _on_resume_pressed() -> void:
	print('resume')
	resume()


func _on_quit_pressed() -> void:
	print('quit')
	# close the application
	get_tree().quit()


func _input(event: InputEvent) -> void:
	print("processing input")
	if event.is_action_pressed("ui_cancel"):
		if is_visible():
			resume()
		else:
			pause()


func resume() -> void:
	print('call resume')
	hide()
	get_tree().paused = false


func pause() -> void:
	print('call pause')
	show()
	get_tree().paused = true
	$VBoxContainer/Resume.grab_focus()
