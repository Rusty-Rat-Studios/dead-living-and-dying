extends PlayerState


func enter() -> void:
	super()
	parent.speed = 6.0
	
	# DEBUG: modulate color according to state
	parent.get_node("RotationOffset/Sprite3D").modulate = Color(0.5, 1, 0.5)
	
	SignalBus.player_hurt.connect(_on_player_hurt)
	SignalBus.emit_signal("player_state_changed", "Living")
	
	# adjust light strength
	parent.light_omni.omni_range = 6
	parent.light_omni.light_energy = 1
	parent.light_spot.spot_range = 10
	parent.light_spot.light_energy = 1


func exit() -> void:
	SignalBus.player_hurt.disconnect(_on_player_hurt)


func process_input(event: InputEvent) -> State:
	# DEBUG: press tab to cycle state
	if event is InputEventKey and event.pressed:
		if event.keycode == KEY_TAB:
			return state_dying
	return null


func _on_player_hurt() -> void:
	parent.take_damage()
	parent.state_machine.change_state(state_dying)
