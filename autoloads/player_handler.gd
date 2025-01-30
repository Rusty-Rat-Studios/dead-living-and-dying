extends Node

@onready var player: Player = get_node("/root/Game/Player")


# globally access to Player node
func get_player() -> Player:
	return player


# globally access player state
func get_player_state() -> PlayerStateMachine.States:
	# gdscript gives a warning for implicitly casting an int to an enum
	return player._state_machine.current_state as PlayerStateMachine.States
