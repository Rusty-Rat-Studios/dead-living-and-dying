extends Node

var _player: Player
var _current_room: Room

# needed when loading the game scene
func register_player(player: Player) -> void:
	_player = player


func register_current_room(current_room: Room) -> void:
	_current_room = current_room


# globally access to Player node
func get_player() -> Player:
	return _player


func get_current_room() -> Room:
	return _current_room


# globally access player state
func get_player_state() -> PlayerStateMachine.States:
	# gdscript gives a warning for implicitly casting an int to an enum
	return _player._state_machine.current_state as PlayerStateMachine.States
