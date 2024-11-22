extends Node

@onready var player: Player = get_node("/root/Game/Player")


# globally access to Player node
func get_player() -> Player:
	return player


# globally access player state
func get_player_state() -> String:
	return get_node("/root/Game/StateMachine").current_state.name
