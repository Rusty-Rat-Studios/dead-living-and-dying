extends Node

@onready var _spawners: Dictionary[Spawner.SpawnerType, Array] = {}


# Called in a Spawners _ready function
func register_spawner(spawner: Spawner) -> void:
	var spawner_type: Spawner.SpawnerType = spawner.spawner_type
	if not _spawners.has(spawner_type):
		_spawners[spawner_type] = []
	_spawners[spawner_type].append(spawner)


# Returns an array of all the spawners registered of a given type
func get_spawners(type: Spawner.SpawnerType) -> Array:
	return _spawners.get(type, [])


# Spawn an entity from EntityTable at each spawner registered of a given type
func spawn(type: Spawner.SpawnerType, entity_table: EntityTable) -> void:
	for spawner: Spawner in get_spawners(type):
		spawner.spawn(entity_table.get_random_entity())


func reset() -> void:
	_spawners.clear()
