extends Node

"""
have an array of all controller input

for every input detected, check if it maps to an controller input

if so, change the reference for the list of icons for a ui action
to the respective controller input

if switched to controller input, swap the detection to listen for
a keyboard/mouse input
"""

# emitted when input detected on a different device than current one
# i.e. keyboard is the current map and controller input is detected
signal icon_map_changed

var icon_map_keyboard: Dictionary

var icon_map_controller: Dictionary

# pointer for which icon map to use
# changed according to last input device
var current_map: Dictionary = icon_map_keyboard

var no_icon_found: String = "[img={}]res://src/icon.png[/img]"

func _ready() -> void:
	icon_map_keyboard["ui_accept"] = "[img={}]res://ui/src/resources/control_icons/ENTER.png[/img]"
	icon_map_keyboard["interact"] = "[img={}]res://ui/src/resources/control_icons/E.png[/img]"
	#icon_map_keyboard["use_defense_item"] = "[img={}]res://ui/src/resources/control_icons/LMB.png[/img]"
	#icon_map_keyboard["use_active_item"] = "[img={}]res://ui/src/resources/control_icons/RMB.png[/img]"
	icon_map_keyboard["use_consumable_item"] = "[img={}]res://ui/src/resources/control_icons/Q.png[/img]"
	
	icon_map_controller["ui_accept"] = "[img={}]res://ui/src/resources/control_icons/button_xbox_digital_a_1.png[/img]"
	icon_map_controller["interact"] = "[img={}]res://ui/src/resources/control_icons/button_xbox_digital_x_1.png[/img]"
	icon_map_controller["use_defense_item"] = "[img={}]res://ui/src/resources/control_icons/button_xbox_analog_trigger_light_2.png[/img]" #right trigger
	icon_map_controller["use_active_item"] = "[img={}]res://ui/src/resources/control_icons/button_xbox_analog_trigger_light_1.png[/img]" # left trigger
	icon_map_controller["use_consumable_item"] = "[img={}]res://ui/src/resources/control_icons/button_xbox_digital_bumper_light_2.png[/img]" # right bumper


func _input(_event: InputEvent) -> void:
	pass
	# search for event as hardcoded key-presses ("k" key, "x button", etc.) not their corresponing ui event
	# change current_map to point to keyboard or controller map based on the source device of the last input pressed


# input: event action (e.g. "ui_accept")
# output: BBCode for icon related to event action according 
# 	to last used device (keyboard or controller)
func retrieve_icon(input: String) -> String:
	return current_map[input] if current_map.has(input) else no_icon_found


# performs same action as retrieve_icon() but inserts a size parameter to the [img] tag
# e.g. given size = 6, returns [img={6}]{image_path}[/img]
func retrieve_icon_sized(input: String, size: int) -> String:
	var img_sized: String
	if not current_map.has(input):
		return resize_bbcode(no_icon_found, size)
	else:
		return resize_bbcode(current_map[input], size)


func resize_bbcode(text: String, size: int) -> String:
	#return String("[img={" + String.num_int64(size) + "}]" + text.substr(5))
	print("resizing: ", text)
	print("to: ", String("[img={" + String.num_int64(size) + text.substr(text.find("]"))))
	return String("[img={" + String.num_int64(size) + text.substr(text.find("]")))
