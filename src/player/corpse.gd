class_name Corpse
extends Area3D

const FALL_DURATION: float = 0.7
# y-offset from sprite center to its base
# needed for rotating about the base of the sprite rather than the center
const SPRITE_OFFSET: float = 1.4
const DEAD_COLOR: Color = Color(0.5, 0.125, 0.125)

var fall_tween: Tween

var current_room: Room

@onready var collision_shape: CollisionShape3D = $CollisionShape3D
# used to rotate sprite about its base to provide a "falling over" effect
@onready var sprite_base: Node3D = $SpriteBase
@onready var sprite: Sprite3D = $SpriteBase/Sprite3D


func _ready() -> void:
	body_entered.connect(_on_body_entered)
	SignalBus.player_entered_room.connect(_on_player_entered_room)
	deactivate()


func reset() -> void:
	deactivate()


func activate() -> void:
	visible = true
	$OmniLight3D.visible = true
	collision_shape.set_deferred("disabled", false)
	
	# stop updating current_room based on player's position
	SignalBus.player_entered_room.disconnect(_on_player_entered_room)
	current_room.visibility_changed.connect(_on_room_visibity_changed)


func deactivate() -> void:
	visible = false
	$OmniLight3D.visible = false
	# reset sprite rotaiton
	sprite_base.rotation.x = 0
	collision_shape.set_deferred("disabled", true)
	
	# restart updating current_room based on player's position
	if not SignalBus.player_entered_room.is_connected(_on_player_entered_room):
		SignalBus.player_entered_room.connect(_on_player_entered_room)
	if current_room and current_room.visibility_changed.is_connected(_on_room_visibity_changed):
		current_room.visibility_changed.disconnect(_on_room_visibity_changed)


func animate_fall() -> void:
	if not visible:
		visible = true
	# ensure corpse sprite is aligned to player sprite
	sprite_base.global_position = get_parent().sprite_torso.global_position
	sprite_base.position.y -= SPRITE_OFFSET
	sprite.flip_h = PlayerHandler.get_player().sprite_torso.flip_h
	
	# rotate along x-axis to show sprite as "falling" backwards
	fall_tween = create_tween().set_ease(Tween.EASE_IN).set_parallel()
	fall_tween.tween_property(sprite_base, "rotation:x", -PI/2, FALL_DURATION)
	fall_tween.tween_property(sprite, "modulate", DEAD_COLOR, FALL_DURATION)
	await fall_tween.finished


func animate_revive() -> void:
	# force player direction to match corpse direction
	PlayerHandler.get_player().sprite_torso.flip_h = sprite.flip_h
	
	# inverse of fall animation
	fall_tween = create_tween().set_ease(Tween.EASE_OUT).set_parallel()
	fall_tween.tween_property(sprite_base, "rotation:x", 0, FALL_DURATION)
	fall_tween.tween_property(sprite, "modulate", Color.WHITE, FALL_DURATION)
	await fall_tween.finished
	deactivate()


func _on_body_entered(body: Node3D) -> void:
	if body == PlayerHandler.get_player():
		SignalBus.player_revived.emit()


func _on_player_entered_room(room: Room) -> void:
	current_room = room


func _on_room_visibity_changed() -> void:
	visible = current_room.visible
