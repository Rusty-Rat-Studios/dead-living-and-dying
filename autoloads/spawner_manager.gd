extends Node

@onready var _spawners: Dictionary = {}


func register_spawner(spawner: Spawner) -> void:
	var spawnerType: Spawner.SpawnerType = spawner.spawnerType
	if not _spawners.has(spawnerType):
		_spawners[spawnerType] = []
	_spawners[spawnerType].append(spawner)


func get_spawners(type: Spawner.SpawnerType) -> Array:
	return _spawners.get(type, [])
