class_name PlayerState
extends Node

enum States {LIVING, DYING, DEAD}

var _parent: Player
var _state_machine: Node

func init(parent: Player, state_machine: Node) -> void:
	_parent = parent
	_state_machine = state_machine


func change_state(new_state: int) -> void:
	_state_machine.change_state(new_state)
