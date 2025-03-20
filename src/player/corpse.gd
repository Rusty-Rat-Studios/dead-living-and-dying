class_name Corpse
extends Area3D

const FALL_DURATION: float = 0.7
# y-offset from sprite center to its base
# needed for rotating about the base of the sprite rather than the center
const SPRITE_OFFSET: float = 1.4

var fall_tween: Tween

@onready var collision_shape: CollisionShape3D = $CollisionShape3D
# used to rotate sprite about its base to provide a "falling over" effect
@onready var sprite_base: Node3D = $SpriteBase
@onready var sprite: Sprite3D = $SpriteBase/Sprite3D


func _ready() -> void:
	body_entered.connect(_on_body_entered)
	deactivate()


func reset() -> void:
	deactivate()


func activate() -> void:
	visible = true
	collision_shape.set_deferred("disabled", false)


func deactivate() -> void:
	visible = false
	# reset sprite rotaiton
	sprite_base.rotation.x = 0
	collision_shape.set_deferred("disabled", true)


func animate_fall() -> void:
	if not visible:
		visible = true
	# ensure corpse sprite is aligned to player sprite
	sprite_base.global_position = get_parent().sprite.global_position
	sprite_base.position.y -= SPRITE_OFFSET
	
	# rotate along x-axis to show sprite as "falling" backwards
	fall_tween = create_tween().set_ease(Tween.EASE_IN)
	fall_tween.tween_property(sprite_base, "rotation:x", -PI/2, FALL_DURATION)
	await Utility.delay(FALL_DURATION)


func _on_body_entered(body: Node3D) -> void:
	if body == PlayerHandler.get_player():
		deactivate()
		SignalBus.player_revived.emit(global_position)
