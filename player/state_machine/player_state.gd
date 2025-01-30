class_name PlayerState
extends State

func enter() -> void:
	SignalBus.player_state_changed.emit(_state_machine.current_state)
