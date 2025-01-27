class_name EntityTableEntry
extends Resource

@export var entity: Resource
@export var base_chance: float
@export var chance_change: float


func get_entity() -> Resource:
	base_chance += chance_change
	return entity
