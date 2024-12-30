class_name GhostState
extends State

@export var state_waiting: State
@export var state_possessing: State
@export var state_stunned: State
@export var state_attacking: State

# time to wait before attacking when player enters room
const ATTACK_DELAY: float = 0.3

var parent: Ghost

func exit() -> void:
	parent.target_pos = parent.position

func _on_player_entered_room(_room: Node3D) -> void:
	if (parent.player_in_room 
	and PlayerHandler.get_player_state() == "Dead"
	and parent.state_machine.current_state == self):
		# add delay to allow player breathing room if running from other ghosts
		await Utility.delay(ATTACK_DELAY)
		parent.state_machine.change_state(state_attacking)
