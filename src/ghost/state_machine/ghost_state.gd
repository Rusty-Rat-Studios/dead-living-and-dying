class_name GhostState
extends State


# reset the ghost target position when changing states
func exit() -> void:
	_parent.target_pos = _parent.global_position
