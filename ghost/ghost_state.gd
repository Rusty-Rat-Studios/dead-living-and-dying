class_name GhostState
extends Node

enum States {WAITING, POSSESSING, STUNNED, ATTACKING}

var _parent: Ghost
var _state_machine: Node

func init(parent: Ghost, state_machine: Node) -> void:
	_parent = parent
	_state_machine = state_machine


func exit() -> void:
	_parent.target_pos = _parent.global_position


func change_state(new_state: int) -> void:
	_state_machine.change_state(new_state)
