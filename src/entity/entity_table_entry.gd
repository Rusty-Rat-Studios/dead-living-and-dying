class_name EntityTableEntry
extends Resource

@export var entity: Resource
@export var base_chance: float
@export var chance_change: float
@export var max_spawn: int = -1
@export var min_spawn: int = -1
var current: int = 0


# Returns the entity resource specified in 'entity'
func get_entity() -> Resource:
	return entity


# Updates 'base_chance' and increments 'current'
func update_entity() -> void:
	base_chance += chance_change
	current += 1


# Returns true if 'current' is within the specified constraints.
# This will be used by the world grid generator to place a specific set of rooms
func is_within_constraints() -> bool:
	return current >= min_spawn and (current <= max_spawn or max_spawn == -1)
