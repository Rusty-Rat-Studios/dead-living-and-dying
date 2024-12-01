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

# height object is lifted to when possessed
const FLOAT_HEIGHT: float = 2
# height object rises/falls to while possessed
const FLOAT_RANGE: float = 0.2
# speed at which the object oscillates
const FLOAT_SPEED: float = 2
# time over which the object initially lifts
const FLOAT_FORCE: float = 8
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


func _ready() -> void:
	# detect when player is in range
	$AttackRange.body_entered.connect(_on_player_entered_range)
	$AttackRange.body_exited.connect(_on_player_exited_range)
	
	# add self to possessables in room
	room.add_possessable(self)


func _physics_process(delta: float) -> void:
	if is_possessed:
		# animate object to "float" in the air
		float_time_offset += delta * FLOAT_SPEED
		
		var target_height: float = FLOAT_HEIGHT + FLOAT_RANGE * sin(float_time_offset)
		var current_height: float = global_transform.origin.y
		var height_diff: float = target_height - current_height
		
		# ensure no "downward" velocity applies; let gravity do it
		if height_diff > 0:
			linear_velocity.y = lerp(linear_velocity.y, height_diff * FLOAT_FORCE, delta)


func _integrate_forces(_state: PhysicsDirectBodyState3D) -> void:
	if not is_possessable and linear_velocity.length() < DAMAGE_VELOCITY:
		# once object has slowed down enough
		# enable player detection
		$AttackRange.collision_mask = CollisionBit.PLAYER
		#disable hurtbox
		$Hurtbox.collision_layer = 0
		# set flag to allow possession again
		is_possessable = true


func possess() -> void:
	# remove self from room's available possessables
	room.remove_possessable(self)
	# enable player detection
	$AttackRange.collision_mask = CollisionBit.PLAYER
	is_possessed = true
	# check if player in range on initial possession
	if $AttackRange.overlaps_body(PlayerHandler.get_player()):
		player_in_range = true


func depossess() -> void:
	# add self back to room's available possessables
	room.add_possessable(self)
	# disable player detection and reset flags
	$AttackRange.collision_mask = 0
	is_possessed = false
	player_in_range = false


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
