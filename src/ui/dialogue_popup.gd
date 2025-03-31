class_name DialoguePopup
extends MarginContainer


var dialogue_container: VBoxContainer
var old_man_dialogue: Label
var responses: Array[Button]

func _ready() -> void:
	
	dialogue_container = $MarginContainer/VBoxContainer/HBoxContainer/Dialogue
	old_man_dialogue = dialogue_container.get_node("OldManDialogue")
	for response: Node in dialogue_container.get_node("Responses").get_children():
		responses.append(response)
	
	print("old man says: ", old_man_dialogue.text)
	print("responses are:")
	for response: Button in responses:
		print("\t", response.text)
	
	responses[-1].pressed.connect(_on_close_pressed)
	hide()


func show_dialogue() -> void:
	visible = true
	get_tree().paused = true
	responses[0].grab_focus()


func hide_dialogue() -> void:
	visible = false
	get_tree().paused = false


func _on_close_pressed() -> void:
	hide_dialogue()
