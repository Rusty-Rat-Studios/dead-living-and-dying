class_name EntityTableEntry
extends Resource

@export var entity: Resource
@export var base_chance: float
@export var chance_change: float
@export var min: int
@export var max: int
var current: int = 0


func get_entity() -> Resource:
	base_chance += chance_change
	current += 1
	return entity
