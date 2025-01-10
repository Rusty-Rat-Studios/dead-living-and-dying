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
	possessed.emit()
	# enable player detection
	$AttackRange.collision_mask = CollisionBit.PLAYER
	is_possessed = true
	# check if player in range on initial possession
	if $AttackRange.overlaps_body(PlayerHandler.get_player()):
		player_in_range = true
	
	$GPUParticles3D.emitting = true


func depossess() -> void:
	# add self back to room's available possessables
	room.add_possessable(self)
	# disable player detection and reset flags
	$AttackRange.collision_mask = 0
	is_possessed = false
	player_in_range = false
	
	$GPUParticles3D.emitting = false


func attack(_target: Node3D) -> void:
	print(Time.get_time_string_from_system(), ": WARNING - attack() function called from base possessable ", self)


func _on_player_entered_range(body: Node3D) -> void:
	# should only detect player if in collision layer PHYSICAL (not DEAD state)
	if body == PlayerHandler.get_player():
		player_in_range = true


func _on_player_exited_range(body: Node3D) -> void:
	if body == PlayerHandler.get_player():
		player_in_range = false
