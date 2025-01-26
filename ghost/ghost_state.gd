class_name GhostState
extends Node

enum States {WAITING, POSSESSING, STUNNED, ATTACKING}

var parent: Ghost
var state_machine: Node

func init(parent: Ghost, state_machine: Node) -> void:
	self.parent = parent
	self.state_machine = state_machine


func exit() -> void:
	parent.target_pos = parent.global_position


func change_state(new_state: int) -> void:
	state_machine.change_state(new_state)
