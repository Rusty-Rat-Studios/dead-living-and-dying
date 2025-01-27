extends Node

@onready var player: Player = get_node("/root/Game/Player")


# globally access to Player node
func get_player() -> Player:
	return player


# globally access player state
func get_player_state() -> String:
	var sm: Node = player._state_machine
	match sm.current_state:
		sm.States.LIVING:
			return "Living"
		sm.States.DYING:
			return "Dying"
		sm.States.DEAD:
			return "Dead"
	
	push_error("Attempting to access invalid state: " + str(sm.current_state))
	return ""
