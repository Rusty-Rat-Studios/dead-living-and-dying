extends Node

var db_values: Dictionary[String, float]

func register_sound_group(group_name: String, value: float) -> void:
	if not db_values.has(group_name):
		db_values[group_name] = value


func set_db_value(group_name: String, value: float) -> void:
	db_values[group_name] = value


func get_db_value(group_name: String) -> float:
	return db_values[group_name]
