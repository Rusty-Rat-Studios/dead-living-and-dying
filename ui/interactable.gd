extends Node3D
'''
https://forum.godotengine.org/t/display-the-character-of-an-input-on-screen/4101
'''

# used to communicate input back to parent scene
signal input_detected(event: InputEvent)

# allow multiple input actions for a single node, parsed in _input()
# input types should be Input Map strings, e.g. "ui_accept" or "interact"
@export var inputs: Array = []

@onready var text_box: Label3D = $Label3D
# flag used to control global signal emission to be caught by parent only
# otherwise, signals are emitted and caught by all parents of same type
@onready var enabled: bool = false


func _input(event: InputEvent) -> void:
	if not inputs.is_empty() and enabled:
		# check if event matches any input we are listening for
		for input_name: String in inputs:
			if event.is_action_pressed(input_name):
				input_detected.emit(input_name)
				return


func display_message(message: String) -> void:
	if text_box:
		text_box.text = message
		text_box.visible = true


func hide_message() -> void:
	if text_box:
		text_box.text = ""
		text_box.visible = false
