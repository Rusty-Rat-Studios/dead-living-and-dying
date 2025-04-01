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


func hide_dialogue() -> void:
	visible = false
	get_tree().paused = false


func clear_dialogue_options() -> void:
	# destroy all old dialogue options
	for child: Button in player_responses.get_children():
		child.queue_free()


func populate_dialogue_options(dialogue: Dictionary) -> void:
	# populate dialogue options
	
	# track buttons as they are created to set focus neighbours for controller navigation
	var buttons: Array[DialogueOption]
	
	for response: String in dialogue["responses"]:
		var dialogue_option: DialogueOption = DialogueOption.new()
		# check if the response has a flag (text at end of string) for EXIT or NEXT
		# which indicate if the option closes or advances the dialogue, respectively
		# - if so, remove the flag and connect the response to the relevant functions
		if response.contains("EXIT"):
			response = response.replace("EXIT", "")
			dialogue_option.pressed.connect(_on_close_pressed, CONNECT_ONE_SHOT)
		if response.contains("NEXT"):
			response = response.replace("NEXT", "")
			dialogue_option.pressed.connect(_on_dialogue_next.bind(dialogue["next_stage"]), CONNECT_ONE_SHOT)
		dialogue_option.text = response
		player_responses.add_child(dialogue_option)
		
		# track buttons to iterate over later to set focus neighbours
		buttons.append(dialogue_option)
	
	# set focus neighbours for controller use
	if buttons.size() > 1:
		for i: int in range(buttons.size()):
			var current_button: DialogueOption = buttons[i]
			if i > 0:
				current_button.focus_neighbor_top = buttons[i - 1].get_path()
			if i < buttons.size() - 1:
				current_button.focus_neighbor_bottom = buttons[i + 1].get_path()
		
		# set first and last options to wrap focus
		buttons[0].focus_neighbor_top = buttons[buttons.size() - 1].get_path()
		buttons[buttons.size() - 1].focus_neighbor_bottom = buttons[0].get_path()
	
	# focus first dialogue option
	buttons[0].grab_focus()


func _on_close_pressed() -> void:
	hide_dialogue()


func _on_dialogue_next(next_dialogue_stage: String) -> void:
	next_stage.emit(next_dialogue_stage)
