extends Node

var _player: Player

# needed when loading the game scene
func register_player(player: Player) -> void:
	_player = player


# globally access to Player node
func get_player() -> Player:
	return _player


# globally access player state
func get_player_state() -> PlayerStateMachine.States:
	# gdscript gives a warning for implicitly casting an int to an enum
	return _player._state_machine.current_state as PlayerStateMachine.States
