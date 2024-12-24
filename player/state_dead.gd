extends PlayerState

const RESPAWN_TIME: float = 2

func enter() -> void:
	super()
	parent.speed = 10.0
	
	# DEBUG: modulate color according to state
	parent.get_node("RotationOffset/Sprite3D").modulate = Color(0.5, 0.5, 0.5, 0.5)
	
	SignalBus.player_hurt.connect(_on_player_hurt)
	SignalBus.player_revived.connect(_on_player_revived)
	SignalBus.emit_signal("player_state_changed", "Dead")
	
	move_to_shrine()


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


func move_to_shrine() -> void:
	# temporarily deactivate player collision and hurtbox to ensure they
	# don't interact with anything while tweening to shrine
	# --- reactivate after reaching shrine
	parent.get_node("DamageDetector").collision_mask = 0
	parent.collision_layer = 0
	parent.collision_mask = 0
	
	# spawn player corpse at death location
	parent.corpse.global_position = parent.global_position
	# corpse collision is ignored because player collision is temporarily disabled
	parent.corpse.activate()
	
	# find and move player to closest active shrine
	var target_shrine: Shrine = parent.active_shrines[0]
	for shrine: Shrine in parent.active_shrines:
		# use squared distance because it computes fast
		var distance_sq: float = parent.global_position.distance_squared_to(shrine.global_position)
		if distance_sq < parent.global_position.distance_squared_to(target_shrine.global_position):
			target_shrine = shrine
	
	var tween: Tween = get_tree().create_tween()
	# move corpse towards shrine over RESPAWN_TIME duration
	tween.tween_property(parent, "global_position", target_shrine.global_position, 
						RESPAWN_TIME).set_trans(Tween.TRANS_CUBIC)
	# wait for tween to finish before reactivating collision layers
	await get_tree().create_timer(RESPAWN_TIME).timeout
	# consume shrine (note: does not consume default shrine)
	target_shrine.consume()
	
	# enable collision layers for spirit plane
	parent.get_node("DamageDetector").collision_mask = CollisionBit.SPIRIT
	parent.collision_layer = CollisionBit.PLAYER + CollisionBit.SPIRIT
	parent.collision_mask = CollisionBit.WORLD + CollisionBit.SPIRIT


func _on_player_hurt() -> void:
	SignalBus.emit_signal("game_over")


func _on_player_revived(corpse_global_position: Vector3) -> void:
	parent.global_position = corpse_global_position
	# provide i-frames on revive, no flashing
	parent.take_damage(false)
	parent.state_machine.change_state(state_living)
