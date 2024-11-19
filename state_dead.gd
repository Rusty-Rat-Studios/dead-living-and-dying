extends PlayerState

func enter() -> void:
	super()
	parent.speed = 10.0
	# DEBUG: modulate color according to state
	parent.get_node("RotationOffset/Sprite3D").modulate = Color(0.5, 0.5, 0.5, 0.5)
	parent.get_node("OmniLight3D").visible = false # disable player light
	get_parent().get_parent().get_node("DirectionalLight3D").visible = true # enable global light
	


func exit() -> void:
	parent.get_node("OmniLight3D").visible = true # enable player light
	get_parent().get_parent().get_node("DirectionalLight3D").visible = false # disable global light


func process_input(event: InputEvent) -> State:
	# DEBUG: press tab to cycle state
	if Input.is_action_just_pressed("ui_focus_next"):
		return state_living
	return null
