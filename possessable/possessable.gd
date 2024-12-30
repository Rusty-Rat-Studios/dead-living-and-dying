class_name Possessable
extends RigidBody3D

"""
COLLISION MASKING SCHEME:
	This object begins by having its AttackRange and Hurtbox collision areas disabled. 
	
	When it is possessed, it enables the AttackRange PHYSICAL collision mask to detect 
	player collision within the AttackRange. When the ghost decides to attack using this 
	item, it disables the AttackRange PLAYER collision mask and enables the Hurtbox 
	PHYSICAL collision layer so the player can detect it has taken damage on contact.
	
	Once the attack is finished, the Hurtbox collision layer is disabled. Similarly,
	once it is depossessed the AttackRange PHYSICAL collision mask is disabled.
"""

# signal connected when ghost discovers all possessables in the room
signal possessed

# impulse strength used to throw the object
const THROW_FORCE: float = 25.0
# speed threshold for enabling/disabling hurtbox
const DAMAGE_VELOCITY: float = 2.0

# RANGE object rises/falls while possessed
const FLOAT_RANGE: float = 0.2
# speed at which the object oscillates
const FLOAT_SPEED: float = 2
# scalar for speed that the object is lifted
const FLOAT_FORCE: float = 1.8
# target height for possessed objects to float to
const FLOAT_HEIGHT: float = 3
# for timing float effect oscillation
@onready var float_time_offset: float = 0.0

# store room for attaching self to "possessables_available" group that is 
# checked by ghosts in the same room for available possession targets
@onready var room: Room = get_parent()
# flag for ensuring object is not repossessed too soon after depossession
@onready var is_possessable: bool = true
# flag for ensuring object is "free" for possession
@onready var is_possessed: bool = false
# flag for checking if player is in attack range
@onready var player_in_range: bool = false
# store initial position to return to when calling reset()
@onready var starting_position: Vector3 = position

func _ready() -> void:
	# detect when player is in range
	$AttackRange.body_entered.connect(_on_player_entered_range)
	$AttackRange.body_exited.connect(_on_player_exited_range)
	
	# add self to possessables in room
	room.add_possessable(self)


func _integrate_forces(state: PhysicsDirectBodyState3D) -> void:
	# if object has been thrown, thus depossessed, it should not be possessable
	# again until object has slowed down enough
	if not is_possessable and linear_velocity.length() < DAMAGE_VELOCITY:
		# disable hurtbox when slow enough
		$Hurtbox.collision_layer = 0
		# set flag to allow possession again
		is_possessable = true
	
	# animate object to "float" in the air
	if is_possessed:
		# record time difference of how far the object should have floated
		# up-and-down (FLOAT_RANGE) at it's peak height (float_height)
		float_time_offset += state.step * FLOAT_SPEED
		
		# add default on-the-floor height to floating height and add an
		# oscillating sine component to float above/below target height
		var target_height: float = starting_position.y + FLOAT_HEIGHT + FLOAT_RANGE * sin(float_time_offset)
		var current_height: float = position.y
		var height_diff: float = target_height - current_height
		
		# ensure no "downward" velocity applies; let gravity do it
		if height_diff > 0:
			# increase velocity exponentially proportional to the target/current height difference
			# --- higher increase if far from target, smaller increase if close to target
			state.linear_velocity.y = lerp(state.linear_velocity.y, height_diff**2 * FLOAT_FORCE, state.step)


func reset() -> void:
	# return to starting position and depossess if necessary
	position = starting_position
	# is_possessed check required because a side effect of calling possess()/depossess()
	# adds or removes the possessable from the room's array of available possessables
	if is_possessed:
		depossess()


func possess() -> void:
	# remove self from room's available possessables
	# to disallow other ghosts to set it as a target
	room.remove_possessable(self)
	# signal to ghosts on the way to target it that it has been taken
	emit_signal("possessed")
	# enable player detection
	$AttackRange.collision_mask = CollisionBit.PLAYER
	is_possessed = true
	# check if player in range on initial possession
	if $AttackRange.overlaps_body(PlayerHandler.get_player()):
		player_in_range = true
	
	$GPUParticles3D.emitting = true
	
	#"bump" object to bring integrate_forces() out of sleep
	apply_central_impulse(Vector3.ZERO)


func depossess() -> void:
	# add self back to room's available possessables
	room.add_possessable(self)
	# disable player detection and reset flags
	$AttackRange.collision_mask = 0
	is_possessed = false
	player_in_range = false
	
	$GPUParticles3D.emitting = false


func attack(target: Node3D) -> void:
	if player_in_range and room.player_in_room:
		# disable player detection
		$AttackRange.collision_mask = 0
		# enable hurtbox
		$Hurtbox.collision_layer = CollisionBit.PHYSICAL
		# disallow re-possession during attack
		is_possessable = false
		# VIOLENTLY LAUNCH SELF TOWARDS PLAYER \m/
		apply_impulse(global_position.direction_to(target.global_position) * THROW_FORCE)


func _on_player_entered_range(body: Node3D) -> void:
	# should only detect player if in collision layer PHYSICAL (not DEAD state)
	if body == PlayerHandler.get_player():
		player_in_range = true


func _on_player_exited_range(body: Node3D) -> void:
	if body == PlayerHandler.get_player():
		player_in_range = false
