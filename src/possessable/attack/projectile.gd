class_name Projectile
extends RigidBody3D

const SPEED: float = 12
# used to delay enabling collision in case ranged possessable is next to some 
# collision object (e.g. wall for wall-painting)
const COLLISION_DELAY: float = 0.1

@onready var collision_shape: CollisionShape3D = $CollisionShape3D

func _ready() -> void:
	body_entered.connect(_on_body_entered)
	# ensure projectile cannot collide with its parent
	add_collision_exception_with(get_parent())


func shoot(target: Vector3) -> void:
	# ensure projectile is at the same height as the player
	global_position.y = PlayerHandler.get_player().global_position.y
	# shoot projectile level with the floor towards the target
	linear_velocity = global_position.direction_to(Vector3(target.x, global_position.y, target.z)) * SPEED
	# delay to allow it to travel past nearby collidable objects, e.g. walls
	await Utility.delay(COLLISION_DELAY)
	collision_shape.disabled = false


func _on_body_entered(body: Node3D) -> void:
	if body == PlayerHandler.get_player():
		SignalBus.player_hurt.emit(self)
	# regardless of collision layer, delete projectile on contact
	queue_free()
