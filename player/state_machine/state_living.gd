extends PlayerState


func enter() -> void:
	super()
	# update player stats
	_parent.current_stats.speed = _parent.player_stats.BASE_SPEED
	_parent.current_stats.light_omni_range = _parent.player_stats.BASE_LIGHT_OMNI_RANGE
	_parent.current_stats.light_energy = _parent.player_stats.BASE_LIGHT_ENERGY
	_parent.current_stats.light_spot_range = _parent.player_stats.BASE_LIGHT_SPOT_RANGE
	# apply inventory buffs to modified stats
	_parent.inventory_update()
	
	# DEBUG: modulate color according to state
	_parent.get_node("RotationOffset/AnimatedSprite3D").modulate = Color(0.5, 1, 0.5)
	
	SignalBus.player_hurt.connect(_on_player_hurt)


func exit() -> void:
	SignalBus.player_hurt.disconnect(_on_player_hurt)


func _on_player_hurt() -> void:
	_parent.take_damage()
	_state_machine.change_state(PlayerStateMachine.States.DYING)
