class_name GhostState
extends Node

enum States {WAITING, POSSESSING, STUNNED, ATTACKING}

@export var state_waiting: GhostState
@export var state_possessing: GhostState
@export var state_stunned: GhostState
@export var state_attacking: GhostState

var parent: Ghost
var state_machine: Node

func init(parent: Ghost, state_machine: Node) -> void:
	self.parent = parent
	self.state_machine = state_machine


func exit() -> void:
	parent.target_pos = parent.position


func change_state(new_state: int) -> void:
	state_machine.change_state_enum(new_state)
