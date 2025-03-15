class_name UIDevice
extends Node


"""
have an array of all controller input

for every input detected, check if it maps to an controller input

if so, change the reference for the list of icons for a ui action
to the respective controller input

if switched to controller input, swap the detection to listen for
a keyboard/mouse input
"""

var icon_map_keyboard: Dictionary

var icon_map_controller: Dictionary

# pointer for which icon map to use
# changed according to last input device
var current_map: Dictionary = icon_map_keyboard

func _ready() -> void:
	icon_map_keyboard["ui_accept"] = "[img]res://ui/resources/control_icons/ENTER.png[/img]"
	icon_map_keyboard["interact"] = "[img]res://ui/resources/control_icons/E.png[/img]"
	#icon_map_keyboard["defense"] = "[img]res://ui/resources/control_icons/LMB.png[/img]"
	#icon_map_keyboard["active"] = "[img]res://ui/resources/control_icons/RMB.png[/img]"
	icon_map_keyboard["consumable"] = "[img]res://ui/resources/control_icons/Q.png[/img]"
	
	icon_map_controller["ui_accept"] = "[img]res://ui/resources/control_icons/button_xbox_digital_a_1.png[/img]"
	icon_map_controller["interact"] = "[img]res://ui/resources/control_icons/button_xbox_digital_x_1.png[/img]"
	icon_map_controller["defense"] = "[img]res://ui/resources/control_icons/button_xbox_analog_trigger_light_2.png[/img]" #right trigger
	icon_map_controller["active"] = "[img]res://ui/resources/control_icons/button_xbox_analog_trigger_light_1.png[/img]" # left trigger
	icon_map_controller["consumable"] = "[img]res://ui/resources/control_icons/button_xbox_digital_bumper_light_2.png[/img]" # right bumper


func _input(event: InputEvent) -> void:
	pass
	# search for event as hardcoded key-presses ("k" key, "x button", etc.) not their corresponing ui event
	# change current_map to point to keyboard or controller map based on the source device of the last input pressed


# input: event action (e.g. "ui_accept")
# output: BBCode for icon related to event action according 
# 	to last used device (keyboard or controller)
func retrieve_icon(input: String) -> void:
	pass
