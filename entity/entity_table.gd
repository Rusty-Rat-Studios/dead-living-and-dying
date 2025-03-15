class_name EntityTable
extends Resource

@export var entities: Array[EntityTableEntry] = []


# Returns a random weighted entity from the valid entries in table
func get_random_entity() -> Resource:
	var choices_dictionary: Dictionary[Variant, float]
	choices_dictionary.assign(_get_choices_dictionary_from_entities())
	var entry: EntityTableEntry = RNG.weighted_random(choices_dictionary)
	return entry.get_entity()


# Returns a choices dictionary, filtered to include only valid entities.
# Any entity that is at/above its max spawn limit will not be included.
func _get_choices_dictionary_from_entities() -> Dictionary[EntityTableEntry, float]:
	var choices: Dictionary[EntityTableEntry, float] = {}
	for entry: EntityTableEntry in entities:
		if entry.max_spawn == -1 or entry.current < entry.max_spawn:
			choices[entry] = entry.base_chance
	return choices


# Checks if all entries in the table have their constraints satisfied
func are_constraints_met() -> bool:
	return entities.all(
		func(entry: EntityTableEntry) -> bool: 
			return entry.is_within_constraints()
	)


func count_remaining_entities() -> int:
	return entities.reduce(
		func(accum: int, entity: EntityTableEntry) -> int:
			if entity.max_spawn == -1:
				return accum
			var remaining: int = entity.max_spawn - entity.current
			return accum + remaining
	, 0)


func count_max_entities() -> int:
	return entities.reduce(
		func(accum: int, entity: EntityTableEntry) -> int:
			if entity.max_spawn == -1:
				return accum
			return accum + entity.max_spawn
	, 0)
