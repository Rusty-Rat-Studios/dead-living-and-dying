extends PlayerState

const RESPAWN_TIME: float = 2

func enter() -> void:
	super()
	parent.stat_dict[0] = 10.0
	
	# DEBUG: modulate color according to state
	parent.get_node("RotationOffset/AnimatedSprite3D").modulate = Color(0.5, 0.5, 0.5, 0.5)
	
	# change collision layers out of physical plane into spirit plane
	parent.collision_layer = CollisionBit.PLAYER + CollisionBit.SPIRIT
	parent.collision_mask = CollisionBit.WORLD + CollisionBit.SPIRIT
	parent.hurtbox.collision_mask = CollisionBit.SPIRIT
	
	SignalBus.player_hurt.connect(_on_player_hurt)
	SignalBus.player_revived.connect(_on_player_revived)
	SignalBus.player_state_changed.emit("Dead")
	
	# drop key item if player is carrying it
	var key_item: Node3D = parent.get_node_or_null("Inventory/KeyItem")
	if key_item:
		key_item.drop()
	
	move_to_shrine()


func exit() -> void:
	super()
	# change collision layers out of spirit plane into physical plane
	parent.collision_layer = CollisionBit.PLAYER + CollisionBit.PHYSICAL
	parent.collision_mask = CollisionBit.WORLD
	parent.hurtbox.collision_mask = CollisionBit.PHYSICAL
	
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
	parent.hurtbox.collision_shape.set_deferred("disabled", true)
	parent.collision_shape.set_deferred("disabled", true)
	
	# spawn player corpse at death location
	parent.corpse.global_position = parent.global_position
	# corpse collision is ignored because player collision is temporarily disabled
	parent.corpse.activate()
	
	# find and move player to closest active shrine
	var active_shrines: Array[Shrine] = ShrineManager.get_active_shrines()
	# failsafe if no shrines exist in WorldGrid (should not happen during prod)
	if active_shrines.size() == 0:
		push_error("No active shrine in game. There should always be a default shrine that is permanently active.")
		SignalBus.game_over.emit()
		return
	var target_shrine: Shrine = Utility.find_closest(active_shrines, parent.global_position)
	
	# disable camera lagging for duration of motion
	parent.camera.disable()
	var tween: Tween = get_tree().create_tween()
	# move corpse towards shrine over RESPAWN_TIME duration
	tween.tween_property(parent, "global_position", target_shrine.global_position, 
		RESPAWN_TIME).set_trans(Tween.TRANS_CUBIC)
	
	# wait for tween to finish before reactivating collision layers and camera
	await Utility.delay(RESPAWN_TIME)
	
	# re-enable camera lagging
	parent.camera.enable()
	# consume shrine (note: does not consume default shrine)
	target_shrine.consume()
	
	# enable collision layers for spirit plane
	parent.hurtbox.collision_shape.set_deferred("disabled", false)
	parent.collision_shape.set_deferred("disabled", false)


func _on_player_hurt() -> void:
	SignalBus.game_over.emit()


func _on_player_revived(corpse_global_position: Vector3) -> void:
	parent.global_position = corpse_global_position
	# provide i-frames on revive, no flashing
	parent.take_damage(false)
	parent.state_machine.change_state(state_living)
