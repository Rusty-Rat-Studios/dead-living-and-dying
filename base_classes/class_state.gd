class_name State
extends Node
"""
States each have a reference to the the state machine and parent node
they belong to. States are defined and accessed as enums by both their 
state machine and inheritors. 
"""

var _parent: CharacterBody3D
var _state_machine: StateMachine

func init(parent: CharacterBody3D, state_machine: StateMachine) -> void:
	_parent = parent
	_state_machine = state_machine


func change_state(new_state: int) -> void:
	_state_machine.change_state(new_state)
