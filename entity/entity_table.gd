class_name EntityTable
extends Resource

@export var entities: Array[EntityTableEntry] = []


func get_random_entity() -> Resource:
	var entry: EntityTableEntry = RNG.weighted_random(_get_choices_dictionary_from_entities())
	return entry.get_entity()


func _get_choices_dictionary_from_entities() -> Dictionary:
	var choices: Dictionary = {}
	for entry: EntityTableEntry in entities:
		if entry.max_spawn == -1 or entry.current < entry.max_spawn:
			choices[entry] = entry.base_chance
	return choices


func are_constraints_met() -> bool:
	return entities.all(
		func(entry: EntityTableEntry) -> bool: 
			return entry.is_within_constraints()
	)
