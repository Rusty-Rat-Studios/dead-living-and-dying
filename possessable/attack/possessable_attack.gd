class_name PossessableAttack
extends Possessable

const LIGHT_ENERGY: float = 0.2
const TWEEN_IN_DURATION: float = 2
const TWEEN_OUT_DURATION: float = 0.5

@onready var range_collision_shape: CollisionShape3D = $AttackRange/CollisionShape3D

var light_tween: Tween

func _ready() -> void:
	super()
	# detect when player is in range
	$AttackRange.body_entered.connect(_on_player_entered_range)
	$AttackRange.body_exited.connect(_on_player_exited_range)


func possess() -> void:
	super()
	# enable player detection
	range_collision_shape.set_deferred("disabled", false)
	is_possessed = true
	# check if player in range on initial possession
	if $AttackRange.overlaps_body(PlayerHandler.get_player()):
		player_in_range = true
	
	# make possessable glow
	light_tween = create_tween()
	light_tween.tween_property($OmniLight3D, "light_energy", LIGHT_ENERGY, TWEEN_IN_DURATION)


func depossess() -> void:
	super()
	# disable player detection
	range_collision_shape.set_deferred("disabled", true)
	
	# stop glow effect
	light_tween = create_tween()
	light_tween.tween_property($OmniLight3D, "light_energy", 0, TWEEN_OUT_DURATION)


func _on_player_entered_range(_player: Player) -> void:
	# technically can trigger when player is in DEAD state, but any ghost
	# will immediately move to ATTACKING if the player enters the room
	player_in_range = true


func _on_player_exited_range(_player: Player) -> void:
	player_in_range = false
