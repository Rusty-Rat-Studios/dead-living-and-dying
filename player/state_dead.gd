extends PlayerState

func enter() -> void:
	super()
	parent.speed = 10.0
	
	SignalBus.emit_signal("player_state_changed", "Dead")
	
	# DEBUG: modulate color according to state
	parent.get_node("RotationOffset/Sprite3D").modulate = Color(0.5, 0.5, 0.5, 0.5)


func process_input(event: InputEvent) -> State:
	# DEBUG: press tab to cycle state
	if event is InputEventKey and event.pressed:
		if event.keycode == KEY_TAB:
			return state_living
	return null
