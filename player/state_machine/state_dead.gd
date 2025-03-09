extends PlayerState

const SPEED_MODIFIER: float = 4
const NAME: String = "dead"

const RESPAWN_TIME: float = 2

func enter() -> void:
	super()
	
	_parent.player_stats.remove_stat_modifiers()
	_parent.player_stats.stat_update_add(PlayerStats.Stats.SPEED, SPEED_MODIFIER, NAME)
	
	# modulate player color and opacity to appear ghostly
	_parent.get_node("RotationOffset/AnimatedSprite3D").modulate = Color(0.5, 0.5, 0.5, 0.3)
	
	# drop key item if player is carrying it
	var key_item: KeyItemInventory = _parent.get_node_or_null("Inventory/KeyItemInventory")
	if key_item:
		key_item.drop()
	
	await move_to_shrine()
	
	# change collision layers out of physical plane into spirit plane
	# temporarily moved during move_to_shrine()
	_parent.collision_layer = CollisionBit.PLAYER + CollisionBit.SPIRIT
	_parent.collision_mask = CollisionBit.WORLD + CollisionBit.SPIRIT
	_parent.hurtbox.collision_mask = CollisionBit.SPIRIT
	
	SignalBus.player_hurt.connect(_on_player_hurt)
	SignalBus.player_revived.connect(_on_player_revived)
	
	# disable player light
	_parent.light_omni.visible = false
	_parent.light_spot.visible = false


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
	_parent._corpse_indicator.look_at(_parent._corpse.global_position, Vector3.UP)


func move_to_shrine() -> void:
	# temporarily deactivate player hurtbox to ensure they don't get hit again
	_parent.collision_layer = CollisionBit.PLAYER
	_parent.collision_mask = CollisionBit.WORLD
	
	# find closest active shrine
	var active_shrines: Array[Shrine] = ShrineManager.get_active_shrines()
	# failsafe if no shrines exist in WorldGrid (should not happen during prod)
	if active_shrines.size() == 0:
		push_error("No active shrine in game. There should always be a default shrine that is permanently active.")
		return
	var target_shrine: Shrine = Utility.find_closest(active_shrines, _parent.global_position)
	# consume shrine (note: does not consume default shrine)
	target_shrine.consume()
	
	# disable movement and camera lag for duration of motion
	_parent.camera.disable()
	_parent.set_physics_process(false)
	
	# add black screen fade effect
	var black_screen: TextureRect = get_tree().root.get_node("Game/UI/DeadScreenEffect")
	await black_screen.fade_in(RESPAWN_TIME / 2)
	
	# move player corpse to death location
	_parent._corpse.global_position = Vector3(_parent.global_position.x, 1, _parent.global_position.z)
	# move player to shrine
	_parent.global_position = target_shrine.global_position
	# execute single step of physics frame to trigger room visibility
	_parent._physics_process(get_physics_process_delta_time())
	
	# fade visibility back in
	await black_screen.fade_out(RESPAWN_TIME / 2)
	
	# re-enable movement and camera lag 
	_parent.set_physics_process(true)
	_parent.camera.enable()

	# activate corpse and indicator particle emission
	_parent._corpse.activate()
	_parent._corpse_indicator.emitting = true


func _on_player_hurt() -> void:
	SignalBus.game_over.emit()


func _on_player_revived(corpse_global_position: Vector3) -> void:
	_parent.global_position = corpse_global_position
	# provide i-frames on revive, no flashing
	_parent.take_damage(false)
	_state_machine.change_state(PlayerStateMachine.States.LIVING)
