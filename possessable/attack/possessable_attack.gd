class_name PossessableAttack
extends Possessable

const LIGHT_ENERGY: float = 1
const TWEEN_IN_DURATION: float = 2
const TWEEN_OUT_DURATION: float = 0.5

var light_tween: Tween

@onready var range_collision_shape: CollisionShape3D = $AttackRange/CollisionShape3D
# flag for checking if player is in attack range
@onready var player_in_range: bool = false


func _ready() -> void:
	super()
	# detect when player is in range
	$AttackRange.body_entered.connect(_on_player_entered_range)
	$AttackRange.body_exited.connect(_on_player_exited_range)


func possess() -> void:
	if not is_possessable:
		return
	super()
	# enable player detection
	range_collision_shape.set_deferred("disabled", false)
	enable_effects()


func depossess(disable_effects: bool = true) -> void:
	super(disable_effects)
	# disable player detection
	range_collision_shape.set_deferred("disabled", true)
	player_in_range = false


func enable_effects() -> void:
	super()
	# make possessable glow
	if light_tween:
		light_tween.kill()
	light_tween = create_tween()
	light_tween.tween_property($OmniLight3D, "light_energy", LIGHT_ENERGY, TWEEN_IN_DURATION)


func disable_effects() -> void:
	super()
	# stop glow effect
	if light_tween:
		light_tween.kill()
	light_tween = create_tween()
	light_tween.tween_property($OmniLight3D, "light_energy", 0, TWEEN_OUT_DURATION)


func _on_player_entered_range(_player: Player) -> void:
	# technically can trigger when player is in DEAD state, but any ghost
	# will immediately move to ATTACKING if the player enters the room
	player_in_range = true


func _on_player_exited_range(_player: Player) -> void:
	player_in_range = false
