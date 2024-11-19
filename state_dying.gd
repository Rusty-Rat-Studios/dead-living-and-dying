extends PlayerState


func enter() -> void:
	super()
	parent.speed = 4.0
	# DEBUG: modulate color according to state
	parent.get_node("RotationOffset/Sprite3D").modulate = Color(1, 0.5, 0.5)
	
	# adjust light strength
	parent.light_omni.omni_range = 6
	parent.light_omni.light_energy = 0.4


func process_input(event: InputEvent) -> State:
	# DEBUG: press tab to cycle state
	if Input.is_action_just_pressed("ui_focus_next"):
		return state_dead
	return null
