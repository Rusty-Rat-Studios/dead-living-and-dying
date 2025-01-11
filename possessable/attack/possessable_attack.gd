class_name PossessableAttack
extends Possessable

func _ready() -> void:
	super()
	# detect when player is in range
	$AttackRange.body_entered.connect(_on_player_entered_range)
	$AttackRange.body_exited.connect(_on_player_exited_range)


func possess() -> void:
	super()
	# enable player detection
	$AttackRange.collision_mask = CollisionBit.PLAYER
	is_possessed = true
	# check if player in range on initial possession
	if $AttackRange.overlaps_body(PlayerHandler.get_player()):
		player_in_range = true


func depossess() -> void:
	super()
	# disable player detection
	$AttackRange.collision_mask = 0
