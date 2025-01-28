extends PlayerState

func enter() -> void:
	_parent.speed = _parent.BASE_SPEED
	
	# DEBUG: modulate color according to state
	_parent.get_node("RotationOffset/AnimatedSprite3D").modulate = Color(0.5, 1, 0.5)
	
	SignalBus.player_hurt.connect(_on_player_hurt)
	SignalBus.player_state_changed.emit("Living")
	
	# adjust light strength
	_parent.light_omni.omni_range = 6
	_parent.light_omni.light_energy = 1
	_parent.light_spot.spot_range = 10
	_parent.light_spot.light_energy = 1


func exit() -> void:
	SignalBus.player_hurt.disconnect(_on_player_hurt)


func _on_player_hurt() -> void:
	_parent.take_damage()
	_state_machine.change_state(States.DYING)
