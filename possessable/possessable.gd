extends RigidBody3D

"""
COLLISION MASKING SCHEME:
	This object begins by having its AttackRange and Hurtbox collision areas disabled. 
	
	When it is possessed, it enables the AttackRange PHYSICAL collision mask to detect 
	player collision within the AttackRange. When the ghost decides to attack using this 
	item, it disables the AttackRange PHYSICAL collision mask and enables the Hurtbox 
	PHYSICAL collision layer so the player can detect it has taken damage on contact.
	
	Once the attack is finished, the Hurtbox collision layer is disabled. Similarly,
	once it is depossessed the AttackRange PHYSICAL collision mask is disabled.
	
	It leaves the GhostDetector enabled at all times so if multiple ghosts simultaneously decide 
	to possess it the "late" ghosts can still detect it and perform the "is_possessed" check.
"""

# flag for ensuring object is "free" for possession
@onready var is_possessed: bool = false
# flag for checking if player is in attack range
@onready var player_in_range: bool = false

func _ready() -> void:
	# detect when player is in range
	$AttackRange.body_entered.connect(_on_player_entered_range)
	$AttackRange.body_exited.connect(_on_player_exited_range)
	
	# set is_possessed and update collision areas
	SignalBus.item_possessed.connect(_on_possession)
	SignalBus.item_depossessed.connect(_on_depossession)


func _on_player_entered_range(body: Node3D) -> void:
	# should only detect player if in collision layer PHYSICAL
	if body == PlayerHandler.get_player():
		player_in_range = true
		print("player in range of possessed item ", name)


func _on_player_exited_range(body: Node3D) -> void:
	if body == PlayerHandler.get_player():
		player_in_range = false
		print("player out of range of possessed item ", name)

func _on_possession(_item: RigidBody3D) -> void:
	$AttackRange.collision_mask = CollisionBit.PHYSICAL
	print(name, " possessed")


func _on_depossession(_item: RigidBody3D) -> void:
	$AttackRange.collision_mask = 0
	print(name, " depossessed")
