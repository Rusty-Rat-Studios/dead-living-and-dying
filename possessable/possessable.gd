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
@onready var starting_transform: Transform3D = transform

func _ready() -> void:
	# add self to possessables in room
	room.add_possessable(self)


func reset() -> void:
	# return to starting position and depossess if necessary
	transform = starting_transform
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
	is_possessed = true
	
	$GPUParticles3D.emitting = true


func depossess() -> void:
	# add self back to room's available possessables
	room.add_possessable(self)
	# reset flags
	is_possessed = false
	player_in_range = false
	
	$GPUParticles3D.emitting = false


func attack(_target: Node3D) -> void:
	print(Time.get_time_string_from_system(), ": WARNING - attack() function called from base possessable ", self)
