extends PlayerState

const SPEED_MODIFIER: float = 4
const DEAD_MODIFIER_NAME: String = "dead"
const ATTACKED_MODIFIER_NAME: String = "ghost attack"

# the amount of time before recalculating attacked effect from ghost contact
const ATTACKED_INCREMENT_DURATION: float = 0.1
# base amount that attack_modifier is incremented/decremented every timeout
const ATTACKED_MODIFIER_INCREMENT: float = 0.02
# the multiplicative magnitude increase for each ghost in contact
const ATTACKED_MAGNITUDE_MODIFIER: float = 1.1
# provide a better indicator by "jumpstarting" the effect on first contact
const ATTACKED_MODIFIER_START: float = 0.4
# amount that attack_modifier is multiplied by before applying to speed
const ATTACKED_MODIFIER_SPEED_SCALAR: float = 5

const RESPAWN_TIME: float = 2

# used to implement debuffs from ghosts contacting player
# incremented when in contact with ghosts, multiplied by magnitude * number of ghosts
var attacked_modifier: float = 0
# tracks all ghosts currently contacting/attacking player
var attacking_ghosts: Array[Ghost] = []

var dead_light_energy_default: float 

@onready var dead_light: DirectionalLight3D = get_tree().root.get_node("Game/DirectionalLight3D")
@onready var attacked_increment_timer: Timer = Timer.new()


func init(parent: CharacterBody3D, state_machine: StateMachine) -> void:
	super(parent, state_machine)
	add_child(attacked_increment_timer)
	attacked_increment_timer.wait_time = ATTACKED_INCREMENT_DURATION
	attacked_increment_timer.timeout.connect(_on_attacked_increment_timer_timeout)
	
	dead_light_energy_default = dead_light.light_energy


func enter() -> void:
	super()
	
	_parent.player_stats.remove_stat_modifiers()
	_parent.player_stats.stat_update_add(PlayerStats.Stats.SPEED, SPEED_MODIFIER, DEAD_MODIFIER_NAME)
	
	# modulate player color and opacity to appear ghostly
	_parent.modulate_color(Color(0.5, 0.5, 0.5, _parent.OPACITY_DEAD))
	
	# drop key item if player is carrying it
	var key_item: KeyItemInventory = _parent.get_key_item_or_null()
	if key_item:
		key_item.drop()
	
	await move_to_shrine()
	
	# activate corpse indicator particle emission
	_parent._corpse_indicator.emitting = true
	
	# change collision layers out of physical plane into spirit plane
	# temporarily disabled during move_to_shrine()
	_parent.collision_layer = CollisionBit.PLAYER + CollisionBit.SPIRIT
	_parent.collision_mask = CollisionBit.WORLD
	_parent.hurtbox.collision_mask = CollisionBit.SPIRIT
	
	SignalBus.player_hurt.connect(_on_player_hurt)
	SignalBus.player_escaped.connect(_on_player_escaped)
	SignalBus.player_revived.connect(_on_player_revived)
	SignalBus.player_exited_room.connect(_on_player_exited_room)
	
	# disable player light
	_parent.light_omni.visible = false
	_parent.light_spot.visible = false


func exit() -> void:
	# enable player light
	_parent.light_omni.visible = true
	_parent.light_spot.visible = true
	
	_parent.player_stats.remove_stat_modifiers()
	dead_light.light_energy = dead_light_energy_default
	attacked_modifier = 0
	if not attacked_increment_timer.is_stopped():
		attacked_increment_timer.stop()
  
	# restore player color and opacity
	_parent.modulate_color(Color(1, 1, 1, 1))
	
	# change collision layers out of spirit plane into physical plane
	_parent.collision_layer = CollisionBit.PLAYER + CollisionBit.PHYSICAL
	_parent.collision_mask = CollisionBit.WORLD
	_parent.hurtbox.collision_mask = CollisionBit.PHYSICAL
	
	# deactivate corpse indicator particle emission
	_parent._corpse_indicator.restart()
	_parent._corpse_indicator.emitting = false
	
	SignalBus.player_hurt.disconnect(_on_player_hurt)
	SignalBus.player_escaped.disconnect(_on_player_escaped)
	SignalBus.player_revived.disconnect(_on_player_revived)
	SignalBus.player_exited_room.disconnect(_on_player_exited_room)


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
	
	# move player corpse to death location
	_parent._corpse.global_position = _parent.global_position
	_parent._corpse.animate_fall()
	
	# add black screen fade effect
	var black_screen: TextureRect = get_tree().root.get_node("Game/UI/DeadScreenEffect")
	await black_screen.fade_in(RESPAWN_TIME)
	
	# move player to shrine
	_parent.global_position = target_shrine.respawn_point
	# execute single step of physics frame to trigger room visibility
	_parent._physics_process(get_physics_process_delta_time())
	# activate corpse light after fade-out to avoid "popping-in" if corpse visible on respawn
	_parent._corpse.activate()
	
	# fade visibility back in
	await black_screen.fade_out(RESPAWN_TIME / 2)
	
	# re-enable movement and camera lag 
	_parent.set_physics_process(true)
	_parent.camera.enable()


func _on_player_hurt(entity: Node3D) -> void:
	if entity is Ghost:
		attacking_ghosts.append(entity)
	if attacked_increment_timer.is_stopped():
		# start the effect partially complete to provide a clear indicator of damage
		attacked_modifier = ATTACKED_MODIFIER_START
		attacked_increment_timer.start()


func _on_player_escaped(entity: Node3D) -> void:
	if entity is Ghost:
		# handle case where player has entered another room and the
		#  attacking_ghosts array is cleared while still contacting player
		var ghost_position: int = attacking_ghosts.find(entity)
		if ghost_position != -1:
			attacking_ghosts.remove_at(ghost_position)


func _on_player_revived(corpse_global_position: Vector3) -> void:
	# provide i-frames on revive, no flashing
	_parent.take_damage(false)
	
	# disable movement and camera lag for revive duration
	_parent.camera.disable()
	_parent.set_physics_process(false)
	create_tween().tween_property(_parent, "global_position", _parent._corpse.global_position, 0.3)
	await _parent._corpse.animate_revive()
	_parent.camera.enable()
	_parent.set_physics_process(true)
	
	_state_machine.change_state(PlayerStateMachine.States.LIVING)


func _on_player_exited_room(_body: Node3D) -> void:
	# clear attacking ghosts to ensure effect does not apply when player enters
	# an adjacent room while ghosts are still in contact - they can still collide
	# with the player in the doorway as they are entering the next room even if
	# they are no longer explicitly attacking
	attacking_ghosts.clear()


func _on_attacked_increment_timer_timeout() -> void:
	# over short increments, apply an "attacked" effect of speed reduction
	# and ghost light dimming according to how long the player has been attacked
	# and by how many ghosts are currently attacking the player
	
	if not attacking_ghosts.is_empty():
		# CASE: ghost(s) attacking player
		var num_ghosts: int = attacking_ghosts.size()
		# increase increment magnitude according to number of ghosts attacking
		var attacked_modifier_magnitude: float = num_ghosts * ATTACKED_MAGNITUDE_MODIFIER 
		attacked_modifier += ATTACKED_MODIFIER_INCREMENT * attacked_modifier_magnitude
	else:
		# CASE: no ghosts attacking
		if attacked_modifier <= 0:
			# CASE: player has fully recovered from attack
			# remove effect entirely
			attacked_increment_timer.stop()
			attacked_modifier = 0
			_parent.player_stats.stat_update_remove(PlayerStats.Stats.SPEED, ATTACKED_MODIFIER_NAME)
			return
		
		# decrease effect over time
		attacked_modifier -= ATTACKED_MODIFIER_INCREMENT
	
	# apply attacked modifier to dead light and player speed
	dead_light.light_energy = dead_light_energy_default - attacked_modifier
	_parent.player_stats.stat_update_add(
		PlayerStats.Stats.SPEED, -attacked_modifier * ATTACKED_MODIFIER_SPEED_SCALAR, ATTACKED_MODIFIER_NAME)
	
	if dead_light.light_energy <= 0:
		# full effect has applied - game over
		SignalBus.game_over.emit()
		dead_light.light_energy = dead_light_energy_default
		attacked_increment_timer.stop()
