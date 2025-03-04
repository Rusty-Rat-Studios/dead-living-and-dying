extends PlayerState


func enter() -> void:
	super()

	# apply inventory buffs to modified stats
	_parent.inventory_update()
	
	SignalBus.player_hurt.connect(_on_player_hurt)


func exit() -> void:
	SignalBus.player_hurt.disconnect(_on_player_hurt)


func _on_player_hurt() -> void:
	_parent.take_damage()
	_state_machine.change_state(PlayerStateMachine.States.DYING)
