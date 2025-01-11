class_name Projectile
extends RigidBody3D

const SPEED: float = 12

func _ready() -> void:
	body_entered.connect(_on_body_entered)
	# ensure projectile cannot collide with its parent
	add_collision_exception_with(get_parent())


func shoot(target: Vector3) -> void:
	# shoot projectile level with the floor towards the target
	linear_velocity = global_position.direction_to(Vector3(target.x, global_position.y, target.z)) * SPEED


func _on_body_entered(body: Node3D) -> void:
	if body == PlayerHandler.get_player():
		SignalBus.player_hurt.emit()
	# regardless of collision layer, delete projectile on contact
	queue_free()
