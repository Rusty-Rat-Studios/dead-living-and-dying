extends PlayerState


func enter() -> void:
	super()
	parent.speed = 10.0
	
	SignalBus.player_hurt.connect(_on_player_hurt)
	SignalBus.player_entered_shrine.connect(_on_player_entered_shrine)
	SignalBus.emit_signal("player_state_changed", "Dead")
	
	# change collision layers out of physical plane into spirit plane
	parent.collision_layer = Collision.PLAYER + Collision.SPIRIT
	parent.collision_mask = Collision.WORLD + Collision.SPIRIT
	parent.get_node("DamageDetector").collision_mask = Collision.SPIRIT
	
	# DEBUG: modulate color according to state
	parent.get_node("RotationOffset/Sprite3D").modulate = Color(0.5, 0.5, 0.5, 0.5)


func exit() -> void:
	super()
	# change collision layers out of spirit plane into physical plane
	parent.collision_layer = Collision.PLAYER
	parent.collision_mask = Collision.WORLD + Collision.PHYSICAL
	parent.get_node("DamageDetector").collision_mask = Collision.PHYSICAL
	
	SignalBus.player_hurt.disconnect(_on_player_hurt)
	SignalBus.player_entered_shrine.disconnect(_on_player_entered_shrine)


func process_input(event: InputEvent) -> State:
	# DEBUG: press tab to cycle state
	if event is InputEventKey and event.pressed:
		if event.keycode == KEY_TAB:
			return state_living
	return null


func _on_player_hurt() -> void:
	# TODO: Implement game-over signal
	pass


func _on_player_entered_shrine() -> void:
	parent.state_machine.change_state(state_living)
