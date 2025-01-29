class_name PlayerState
extends State

# gdlint wants const name to be all capitals, but this matches the enum name
# gdlint: ignore=constant-name
const States = PlayerStateMachine.States

func enter() -> void:
	SignalBus.player_state_changed.emit(_state_machine.current_state)
