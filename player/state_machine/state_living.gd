extends PlayerState


func enter() -> void:
	super()
	_parent.speed = _parent.BASE_SPEED
	
	# DEBUG: modulate color according to state
	_parent.get_node("RotationOffset/AnimatedSprite3D").modulate = Color(0.5, 1, 0.5)
	
	SignalBus.player_hurt.connect(_on_player_hurt)
	
	# set light strength to default
	_parent.light_omni.omni_range = _parent.LIGHT_OMNI_RANGE
	_parent.light_omni.light_energy = _parent.LIGHT_ENERGY
	_parent.light_spot.spot_range = _parent.LIGHT_SPOT_RANGE
	_parent.light_spot.light_energy = _parent.LIGHT_ENERGY


func exit() -> void:
	SignalBus.player_hurt.disconnect(_on_player_hurt)


func _on_player_hurt() -> void:
	_parent.take_damage()
	_state_machine.change_state(States.DYING)
