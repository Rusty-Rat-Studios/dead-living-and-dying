extends Node

"""
This script contains two dictionaries, one for KBM and one for controller,
containing the related BBCode image tag for displaying the icon related
to an input event according to the device.

It detects if the input device has changed and updates the current icon
map to point to the one for the last-used input device. Then it emits a
signal that is caught by all nodes that display an icon who then can
retrieve the related icon according to the updated map.
"""

# emitted when input detected on a different device than current one
# i.e. keyboard is the current map and controller input is detected
signal icon_map_changed

# if no size is provided for bbcode image, this default size is used
const DEFAULT_BBCODE_SIZE: int = 15

var icon_map_keyboard: Dictionary
var icon_map_controller: Dictionary

# pointer for which icon map to use
# changed according to last input device
var current_map: Dictionary = icon_map_keyboard

# for debugging -> displayed if no icon is found
var no_icon_found: String = "[img={}]res://src/icon.svg[/img]"

func _ready() -> void:
	#gdlint:disable=max-line-length
	icon_map_keyboard["ui_accept"] = "[img={}]res://src/ui/resources/control_icons/ENTER.png[/img]"
	icon_map_keyboard["interact"] = "[img={}]res://src/ui/resources/control_icons/E.png[/img]"
	icon_map_keyboard["use_defense_item"] = "[img={}]res://src/ui/resources/control_icons/LMB.png[/img]"
	icon_map_keyboard["use_active_item"] = "[img={}]res://src/ui/resources/control_icons/RMB.png[/img]"
	icon_map_keyboard["use_consumable_item"] = "[img={}]res://src/ui/resources/control_icons/Q.png[/img]"
	
	icon_map_controller["ui_accept"] = "[img={}]res://src/ui/resources/control_icons/button_xbox_digital_a_1.png[/img]"
	icon_map_controller["interact"] = "[img={}]res://src/ui/resources/control_icons/button_xbox_digital_x_1.png[/img]"
	icon_map_controller["use_defense_item"] = "[img={}]res://src/ui/resources/control_icons/button_xbox_analog_trigger_light_2.png[/img]"
	icon_map_controller["use_active_item"] = "[img={}]res://src/ui/resources/control_icons/button_xbox_analog_trigger_light_1.png[/img]"
	icon_map_controller["use_consumable_item"] = "[img={}]res://src/ui/resources/control_icons/button_xbox_digital_bumper_light_2.png[/img]"
	#gdlint:disable=max-line-length


func _input(event: InputEvent) -> void:
	# change current_map to point to keyboard or controller map 
	# based on the source device of the last input pressed
	if (current_map == icon_map_controller and 
		(event is InputEventKey or
		event is InputEventMouseButton)):
		current_map = icon_map_keyboard
		icon_map_changed.emit()
	elif (current_map == icon_map_keyboard and
		(event is InputEventJoypadButton or
		event is InputEventJoypadMotion)):
		current_map = icon_map_controller
		icon_map_changed.emit()


# input: event action (e.g. "ui_accept")
# output: BBCode for icon related to event action according 
# 	to last used device (keyboard or controller)
func retrieve_icon(input: String) -> String:
	return current_map[input] if current_map.has(input) else no_icon_found


# performs same action as retrieve_icon() but inserts a size parameter to the [img] tag
# e.g. given size = 6, returns [img={6}]{image_path}[/img]
func retrieve_icon_sized(input: String, size: int = DEFAULT_BBCODE_SIZE) -> String:
	if current_map.has(input):
		return resize_bbcode(current_map[input], size)
	return resize_bbcode(no_icon_found, size)


# takes a BBCode text string and inserts a size parameter to the [img] tag
func resize_bbcode(text: String, size: int = DEFAULT_BBCODE_SIZE) -> String:
	return String("[img={" + String.num_int64(size) + "}" + text.substr(text.find("]")))
