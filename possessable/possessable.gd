class_name Possessable
extends Area3D

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

# maximum amount of time a possessable can have (is_possessable == false)
# after being depossessed. Needed because some inherited classes have
# specific logic for when to set is_possessable, such as throwables
const RESET_TIME: float = 5

@onready var parent: Node3D = get_parent()
# store room for attaching self to "possessables_available" group that is 
# checked by ghosts in the same room for available possession targets
@onready var room: Room = parent.get_parent()
# flag for ensuring object is not repossessed too soon after depossession
@onready var is_possessable: bool = true
# flag for ensuring object is "free" for possession
@onready var is_possessed: bool = false
@onready var reset_timer: Timer = Timer.new()
# store initial position to return to when calling reset()
@onready var starting_transform: Transform3D = transform


func _ready() -> void:
	# add self to possessables in room
	room.add_possessable(self)
	
	# move possession node forward relative to parent object to ensure the
	# ghost is always visible in front of the object - otherwise z-fighting
	# may occur if the item gets lifted and is closer to the camera
	position.z = 0.8
	
	add_child(reset_timer)
	reset_timer.wait_time = RESET_TIME
	reset_timer.one_shot = true
	reset_timer.timeout.connect(_on_reset_timer_timeout)
	


func reset() -> void:
	# return to starting position and depossess if necessary
	transform = starting_transform
	# is_possessed check required because a side effect of calling possess()/depossess()
	# adds or removes the possessable from the room's array of available possessables
	if is_possessed:
		depossess()


func possess() -> void:
	if not is_possessable:
		return
	# remove self from room's available possessables
	# to disallow other ghosts to set it as a target
	room.remove_possessable(self)
	# signal to ghosts on the way to target it that it has been taken
	possessed.emit()
	is_possessed = true
	is_possessable = false
	
	$GPUParticles3D.emitting = true


func depossess() -> void:
	if not is_possessed:
		return
	# reset flags
	is_possessed = false
	# reset is_possessable flag after RESET_TIME
	reset_timer.start()
	print(self.name, " possession cooldown started")
	
	$GPUParticles3D.emitting = false


func attack(_target: Node3D) -> void:
	print(Time.get_time_string_from_system(), ": WARNING - attack() function called from base possessable ", self)


func _on_reset_timer_timeout() -> void:
	print(self.name, " is possessable again")
	# add self back to room's available possessables
	room.add_possessable(self)
	is_possessable = true
