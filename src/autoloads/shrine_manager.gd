extends Node

@onready var shrines: Array[Shrine] = []


func register_shrine(shrine: Shrine) -> void:
	shrines.append(shrine)


func get_active_shrines() -> Array[Shrine]:
	var active_shrines: Array[Shrine]
	active_shrines.assign(shrines.filter(func(shrine: Shrine) -> bool: return shrine.activated))
	return active_shrines


func reset_shrines() -> void:
	for shrine: Shrine in shrines:
		shrine.reset()


func clear_shrines_list() -> void:
	shrines.clear()
