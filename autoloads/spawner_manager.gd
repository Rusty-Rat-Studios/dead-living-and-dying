extends Node

@onready var _spawners: Dictionary = {}


# Called in a Spawners _ready function
func register_spawner(spawner: Spawner) -> void:
	var spawnerType: Spawner.SpawnerType = spawner.spawnerType
	if not _spawners.has(spawnerType):
		_spawners[spawnerType] = []
	_spawners[spawnerType].append(spawner)


# Returns an array of all the spawners registered of a given type
func get_spawners(type: Spawner.SpawnerType) -> Array:
	return _spawners.get(type, [])


# Spawn an entity from EntityTable at each spawner registered of a given type
func spawn(type: Spawner.SpawnerType, entity_table: EntityTable) -> void:
	for spawner: Spawner in get_spawners(type):
		spawner.spawn(entity_table.get_random_entity())
