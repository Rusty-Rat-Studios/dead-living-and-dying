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

const action_icons_keyboard: Array[String] = []
