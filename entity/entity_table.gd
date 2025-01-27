class_name EntityTable
extends Resource

@export var entities: Array[EntityTableEntry] = []


func get_random_entity() -> Resource:
	var entry: EntityTableEntry = RNG.weighted_random(_get_choices_dictionary_from_entities())
	return entry.get_entry()


func _get_choices_dictionary_from_entities() -> Dictionary:
	var choices: Dictionary = {}
	for entry: EntityTableEntry in entities:
		if entry.current < entry.max:
			choices[entry] = entry.base_chance
	return choices


func are_constraints_met() -> bool:
	return entities.filter(
		func(entry: EntityTableEntry) -> bool: 
			return entry.current < entry.min or entry.current > entry.max
	).size() == 0
