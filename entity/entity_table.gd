class_name EntityTable
extends Resource

@export var entities: Array[EntityTableEntry] = []


func get_random_entity() -> Resource:
	var entry: EntityTableEntry = RNG.weighted_random(_get_choices_dictionary_from_entities())
	return entry.get_entity()


func _get_choices_dictionary_from_entities() -> Dictionary:
	var choices: Dictionary = {}
	for entry: EntityTableEntry in entities:
		choices[entry] = entry.base_chance
	return choices
