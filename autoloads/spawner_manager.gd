extends Node

@onready var _spawners: Dictionary = {}
@onready var entity_table: EntityTable = preload("res://map/test_entity_table.tres")


func _ready() -> void:
	await Utility.delay(1)
	for spawner: Spawner in get_spawners(Spawner.SpawnerType.ENEMY):
		var res: Resource = entity_table.get_random_entity()
		spawner.spawn(res)


func register_spawner(spawner: Spawner) -> void:
	var spawnerType: Spawner.SpawnerType = spawner.spawnerType
	if not _spawners.has(spawnerType):
		_spawners[spawnerType] = []
	_spawners[spawnerType].append(spawner)


func get_spawners(type: Spawner.SpawnerType) -> Array:
	return _spawners.get(type, [])
