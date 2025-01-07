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
			get_tree().paused = true
		else:
			hide()
	if event.is_action_released("console"):
		if is_visible():
			# Grab focus after releasing 'console' as to not type 'console'
			$Panel/LineEdit.grab_focus()


func _on_focus_exited() -> void:
	hide()
	get_tree().paused = false


func _handle_command(text: String) -> void:
	append_text(">"+text)
	$Panel/LineEdit.clear()
	var response: String = CommandParser.handle_command(text)
	if not response.is_empty():
		append_text(response)


func append_text(text: String) -> void:
	$Panel/RichTextLabel.append_text(text)
	$Panel/RichTextLabel.newline()
