class_name GhostState
extends State

@export var state_waiting: State
@export var state_possessing: State
@export var state_stunned: State
@export var state_attacking: State

var parent: Ghost

func exit() -> void:
	parent.target_pos = parent.position

func _on_player_entered_room(_room: Node3D) -> void:
	if (parent.player_in_room 
	and PlayerHandler.get_player_state() == "Dead"
	and parent.state_machine.current_state == self):
		print("ghost on_player_entered_room passed for: ", parent.name)
		# add delay to allow player breathing room if running from other ghosts
		await get_tree().create_timer(0.3).timeout
		parent.state_machine.change_state(state_attacking)
