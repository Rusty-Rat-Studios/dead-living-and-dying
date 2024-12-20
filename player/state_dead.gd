extends PlayerState


func enter() -> void:
	super()
	parent.speed = 10.0
	
	SignalBus.player_hurt.connect(_on_player_hurt)
	SignalBus.player_revived.connect(_on_player_revived)
	SignalBus.emit_signal("player_state_changed", "Dead")
	
	# change collision layers out of physical plane into spirit plane
	parent.collision_layer = CollisionBit.PLAYER + CollisionBit.SPIRIT
	parent.collision_mask = CollisionBit.WORLD + CollisionBit.SPIRIT
	
	# DEBUG: modulate color according to state
	parent.get_node("RotationOffset/Sprite3D").modulate = Color(0.5, 0.5, 0.5, 0.5)
	
	# move player to active shrine
	var tween: Tween = get_tree().create_tween()
	tween.tween_property(parent, "global_position", parent.respawn_position, 2).set_trans(Tween.TRANS_CUBIC)
	# activate damage detector AFTER they reach the respawn position
	# to avoid accidental game over while tweening to respawn position
	await get_tree().create_timer(2).timeout
	parent.get_node("DamageDetector").collision_mask = CollisionBit.SPIRIT


func exit() -> void:
	super()
	# change collision layers out of spirit plane into physical plane
	parent.collision_layer = CollisionBit.PLAYER + CollisionBit.PHYSICAL
	parent.collision_mask = CollisionBit.WORLD
	parent.get_node("DamageDetector").collision_mask = CollisionBit.PHYSICAL
	
	SignalBus.player_hurt.disconnect(_on_player_hurt)
	SignalBus.player_revived.disconnect(_on_player_revived)


func process_input(event: InputEvent) -> State:
	# DEBUG: press tab to cycle state
	if event is InputEventKey and event.pressed:
		if event.keycode == KEY_TAB:
			return state_living
	return null


func _on_player_hurt() -> void:
	SignalBus.emit_signal("game_over")


func _on_player_revived(corpse_global_position: Vector3) -> void:
	parent.global_position = corpse_global_position
	# provide i-frames on revive, no flashing
	parent.take_damage(false)
	parent.state_machine.change_state(state_living)
