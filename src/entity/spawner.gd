class_name Spawner
extends Node

enum SpawnerType { ENEMY, ITEM, KEY_ITEM, BOSS }

@export var spawner_type: SpawnerType


func _ready() -> void:
	self.visible = false # Only visible in the editor for debug purposes
	$RayCast3D.enabled = false
	SpawnerManager.register_spawner(self)


# Spawns the given entity resource as a sibling at the spawners location
func spawn(entity: Resource) -> void:
	if entity != null:
		var node: Node = entity.instantiate()
		node.position = self.position
		node.rotation = self.rotation
		add_sibling(node)
		print(Time.get_time_string_from_system(), ": ", self.name, "(", get_parent().name, ") spawned ", node.name)
	else:
		print(Time.get_time_string_from_system(), ": ", self.name, "(", get_parent().name, ") didn't spawn ")
