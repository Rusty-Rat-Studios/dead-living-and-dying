class_name GhostState
extends State

# gdlint wants const name to be all capitals, but this matches the enum name
# gdlint: ignore=constant-name
const States: Dictionary = GhostStateMachine.States

func init(parent: CharacterBody3D, state_machine: StateMachine) -> void:
	_parent = parent
	_state_machine = state_machine

# reset the ghost target position when changing states
func exit() -> void:
	_parent.target_pos = _parent.global_position
