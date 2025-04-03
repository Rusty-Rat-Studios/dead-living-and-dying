extends Projectile

@export var replacement_scene: PackedScene


func perform_post_throw_action() -> void:
	var new_object: Node3D = replacement_scene.instantiate()
	add_sibling(new_object)
	new_object.global_position = global_position + Vector3(0, 0.5, 0)
	new_object.global_rotation = global_rotation
	
	queue_free() # Delete projectile version of object
