class_name GhostState
extends State

@export var state_waiting: State
@export var state_possessing: State
@export var state_stunned: State
@export var state_attacking: State

var parent: Ghost

func _on_player_entered_room(_room: Node3D) -> void:
	if (parent.player_in_room 
	and PlayerHandler.get_player_state() == "Dead"
	and parent.state_machine.current_state == self):
		parent.state_machine.change_state(state_attacking)
