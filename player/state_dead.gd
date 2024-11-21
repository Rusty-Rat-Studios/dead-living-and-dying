extends PlayerState

func enter() -> void:
	super()
	parent.speed = 10.0
	
	SignalBus.emit_signal("player_state_changed", "Dead")
	
	# DEBUG: modulate color according to state
	parent.get_node("RotationOffset/Sprite3D").modulate = Color(0.5, 0.5, 0.5, 0.5)


func process_input(event: InputEvent) -> State:
	# DEBUG: press tab to cycle state
	if Input.is_action_just_pressed("ui_focus_next"):
		return state_living
	return null
