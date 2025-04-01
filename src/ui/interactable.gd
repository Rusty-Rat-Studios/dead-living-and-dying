class_name Interactable
extends Node3D
'''
https://forum.godotengine.org/t/display-the-character-of-an-input-on-screen/4101
'''

const ICON_E: Texture2D = preload("res://src/ui/resources/control_icons/E.png")
const ICON_X: Texture2D = preload("res://src/ui/resources/control_icons/button_xbox_digital_x_1.png")

# used to communicate input back to parent scene
signal input_detected(event: InputEvent)

# allow multiple input actions for a single node, parsed in _input()
# input types should be Input Map strings, e.g. "ui_accept" or "interact"
@export var inputs: Array = []

@onready var text_box: Label3D = $Label3D
@onready var sprite: Sprite3D = $Sprite3D
# flag used to control global signal emission to be caught by parent only
# otherwise, signals are emitted and caught by all parents of same type
@onready var enabled: bool = false


func _ready() -> void:
	# listen for device change and update sprite accordingly
	UIDevice.icon_map_changed.connect(_on_icon_map_changed)


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


func _on_icon_map_changed() -> void:
	# update texture and scale according to current device icon map
	# note we must adjust scale because the E texture is very small and the X texture is large
	if UIDevice.current_map == UIDevice.icon_map_keyboard:
		sprite.texture = ICON_E
		sprite.scale = Vector3(5, 5, 5)
	else:
		sprite.texture = ICON_X
		sprite.scale = Vector3(0.5, 0.5, 0.5)
