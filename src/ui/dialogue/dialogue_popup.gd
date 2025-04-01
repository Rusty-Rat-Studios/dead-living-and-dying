class_name DialoguePopup
extends MarginContainer

signal next_stage(next_dialogue_stage: String)

var dialogue_container: VBoxContainer
var old_man_dialogue: Label
var player_responses: VBoxContainer


func _ready() -> void:
	
	dialogue_container = $MarginContainer/VBoxContainer/HBoxContainer/Dialogue
	old_man_dialogue = dialogue_container.get_node("OldManDialogue")
	player_responses = dialogue_container.get_node("Responses")
	hide()


func show_dialogue(dialogue: Dictionary) -> void:
	visible = true
	get_tree().paused = true
	
	old_man_dialogue.text = dialogue["prompt"]
	
	clear_dialogue_options()
	populate_dialogue_options(dialogue)

	
	# focus first dialogue option
	player_responses.get_child(0).grab_focus()


func hide_dialogue() -> void:
	visible = false
	get_tree().paused = false


func clear_dialogue_options() -> void:
	# destroy all old dialogue options
	for child: Button in player_responses.get_children():
		child.queue_free()


func populate_dialogue_options(dialogue: Dictionary) -> void:
	# populate dialogue options
	for response: String in dialogue["responses"]:
		var dialogue_option: DialogueOption = DialogueOption.new()
		
		# check if the response has a flag (text at end of string) for EXIT or NEXT
		# which indicate if the option closes or advances the dialogue, respectively
		# - if so, remove the signal and connect the response to the relevant functions
		if response.contains("EXIT"):
			response = response.replace("EXIT", "")
			dialogue_option.pressed.connect(_on_close_pressed, CONNECT_ONE_SHOT)
		if response.contains("NEXT"):
			response = response.replace("NEXT", "")
			dialogue_option.pressed.connect(_on_dialogue_next.bind(dialogue["next_stage"]), CONNECT_ONE_SHOT)
		dialogue_option.text = response
		player_responses.add_child(dialogue_option)


func _on_close_pressed() -> void:
	hide_dialogue()


func _on_dialogue_next(next_dialogue_stage: String) -> void:
	next_stage.emit(next_dialogue_stage)
