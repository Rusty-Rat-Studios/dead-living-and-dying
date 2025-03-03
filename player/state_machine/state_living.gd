extends PlayerState


func enter() -> void:
	super()
	# update player stats
	_parent.stat_update_remove(_parent.current_stats.stat_modifier_speed, "dead")

	# apply inventory buffs to modified stats
	_parent.inventory_update()
	_parent.stat_update()
	
	# DEBUG: modulate color according to state
	_parent.get_node("RotationOffset/AnimatedSprite3D").modulate = Color(0.5, 1, 0.5)
	
	SignalBus.player_hurt.connect(_on_player_hurt)


func exit() -> void:
	SignalBus.player_hurt.disconnect(_on_player_hurt)


func _on_player_hurt() -> void:
	_parent.take_damage()
	_state_machine.change_state(PlayerStateMachine.States.DYING)
