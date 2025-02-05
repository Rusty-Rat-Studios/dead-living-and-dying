extends PlayerState


func enter() -> void:
	super()
	parent.stat_dict[Player.Stats.SPEED] = 4.0
	
	# DEBUG: modulate color according to state
	parent.get_node("RotationOffset/AnimatedSprite3D").modulate = Color(1, 0.5, 0.5)
	
	SignalBus.player_hurt.connect(_on_player_hurt)
	SignalBus.player_state_changed.emit("Dying")
	
	# adjust light strength
	parent.light_omni.omni_range = 4
	parent.light_omni.light_energy = 0.4
	parent.light_spot.spot_range = 6
	parent.light_spot.light_energy = 0.4
	parent.inventory_update()


func exit() -> void:
	SignalBus.player_hurt.disconnect(_on_player_hurt)


func process_input(event: InputEvent) -> State:
	# DEBUG: press tab to cycle state
	if event is InputEventKey and event.pressed:
		if event.keycode == KEY_TAB:
			return state_dead
	return null


func _on_player_hurt() -> void:
	# activate i-frames without flash
	parent.take_damage(false)
	parent.state_machine.change_state(state_dead)
