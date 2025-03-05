extends PlayerState

const SPEED_MODIFIER: float = 4

const RESPAWN_TIME: float = 2

func enter() -> void:
	super()
	
	_parent.player_stats.remove_stat_modifiers()
	_parent.player_stats.stat_update_add(PlayerStats.Stats.SPEED, SPEED_MODIFIER, "dead")
	
	# disable player light
	_parent.light_omni.visible = false
	_parent.light_spot.visible = false
	
	# modulate player color and opacity to appear ghostly
	_parent.get_node("RotationOffset/AnimatedSprite3D").modulate = Color(0.5, 0.5, 0.5, 0.3)
	
	# change collision layers out of physical plane into spirit plane
	_parent.collision_layer = CollisionBit.PLAYER + CollisionBit.SPIRIT
	_parent.collision_mask = CollisionBit.WORLD + CollisionBit.SPIRIT
	_parent.hurtbox.collision_mask = CollisionBit.SPIRIT
	
	SignalBus.player_hurt.connect(_on_player_hurt)
	SignalBus.player_revived.connect(_on_player_revived)
	
	# drop key item if player is carrying it
	var key_item: KeyItemInventory = _parent.get_node_or_null("Inventory/KeyItemInventory")
	if key_item:
		key_item.drop()
	
	await move_to_shrine()


func exit() -> void:
	# enable player light
	_parent.light_omni.visible = true
	_parent.light_spot.visible = true
	
	_parent.player_stats.remove_stat_modifiers()
  
	# restore player color and opacity
	_parent.get_node("RotationOffset/AnimatedSprite3D").modulate = Color(1, 1, 1, 1)
	
	# change collision layers out of spirit plane into physical plane
	_parent.collision_layer = CollisionBit.PLAYER + CollisionBit.PHYSICAL
	_parent.collision_mask = CollisionBit.WORLD
	_parent.hurtbox.collision_mask = CollisionBit.PHYSICAL
	
	# deactivate corpse indicator particle emission
	_parent._corpse_indicator.restart()
	_parent._corpse_indicator.emitting = false
	
	SignalBus.player_hurt.disconnect(_on_player_hurt)
	SignalBus.player_revived.disconnect(_on_player_revived)


func process_state() -> void:
	#_parent._corpse_indicator.rotation = _parent.global_position.direction_to(_parent._corpse.global_position)
	#_parent._corpse_indicator.process_material.direction = _parent.global_position.direction_to(_parent._corpse.global_position)
	_parent._corpse_indicator.look_at(_parent._corpse.global_position, Vector3.UP)


func move_to_shrine() -> void:
	# temporarily deactivate player collision and hurtbox to ensure they
	# don't interact with anything while tweening to shrine
	# --- reactivate after reaching shrine
	_parent.hurtbox.collision_shape.set_deferred("disabled", true)
	_parent.collision_shape.set_deferred("disabled", true)
	
	# spawn player corpse at death location
	_parent._corpse.global_position = _parent.global_position
	# corpse collision is ignored because player collision is temporarily disabled
	_parent._corpse.activate()
	
	# find and move player to closest active shrine
	var active_shrines: Array[Shrine] = ShrineManager.get_active_shrines()
	# failsafe if no shrines exist in WorldGrid (should not happen during prod)
	if active_shrines.size() == 0:
		push_error("No active shrine in game. There should always be a default shrine that is permanently active.")
		SignalBus.game_over.emit()
		return
	var target_shrine: Shrine = Utility.find_closest(active_shrines, _parent.global_position)
	
	# disable camera lagging for duration of motion
	_parent.camera.disable()
	var tween: Tween = get_tree().create_tween()
	# move corpse towards shrine over RESPAWN_TIME duration
	tween.tween_property(_parent, "global_position", target_shrine.global_position, 
		RESPAWN_TIME).set_trans(Tween.TRANS_CUBIC)
	
	# wait for tween to finish before reactivating collision layers and camera
	await Utility.delay(RESPAWN_TIME)
	
	# re-enable camera lagging
	_parent.camera.enable()
	# consume shrine (note: does not consume default shrine)
	target_shrine.consume()
	
	# activate corpse indicator particle emission
	_parent._corpse_indicator.emitting = true
	
	# enable collision layers for spirit plane
	_parent.hurtbox.collision_shape.set_deferred("disabled", false)
	_parent.collision_shape.set_deferred("disabled", false)


func _on_player_hurt() -> void:
	SignalBus.game_over.emit()


func _on_player_revived(corpse_global_position: Vector3) -> void:
	_parent.global_position = corpse_global_position
	# provide i-frames on revive, no flashing
	_parent.take_damage(false)
	_state_machine.change_state(PlayerStateMachine.States.LIVING)
