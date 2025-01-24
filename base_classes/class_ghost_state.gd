class_name GhostState
extends Node


@export var state_waiting: GhostState
@export var state_possessing: GhostState
@export var state_stunned: GhostState
@export var state_attacking: GhostState

var parent: Ghost
var state_machine: Node

func exit() -> void:
	parent.target_pos = parent.position
