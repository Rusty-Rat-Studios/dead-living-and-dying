extends Node

@onready var player: Player = get_node("/root/Game/Player")


# globally access to Player node
func get_player() -> Player:
	return player


# globally access player state
func get_player_state() -> String:
	var sm: Node = player._state_machine
	return sm._current_state_node.name
