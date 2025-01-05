extends Control


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$Panel/LineEdit.connect("focus_exited", _on_focus_exited)
	$Panel/LineEdit.connect("text_submitted", _handle_command)


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("console"):
		if not is_visible():
			$Panel/LineEdit.clear()
			show()
		else:
			hide()
	if event.is_action_released("console"):
		if is_visible():
			$Panel/LineEdit.grab_focus()


func _on_focus_exited() -> void:
	hide()


func _handle_command(text: String) -> void:
	print(text)
	$Panel/LineEdit.clear()
