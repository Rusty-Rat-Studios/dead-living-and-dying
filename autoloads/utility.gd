extends Node


func delay(time: float) -> Signal:
	return get_tree().create_timer(time).timeout


func find_closest(list: Array, global_pos: Vector3) -> Node:
	var closest: Node = list[0]
	var distance_sq: float
	for item: Node in list:
		distance_sq = item.global_position.distance_squared_to(global_pos)
		if distance_sq < global_pos.distance_squared_to(closest.global_position):
			closest = item
		
	return closest


func call_for_each(list: Array, function: String) -> void:
	for item: Node in list:
		if item.has_method(function):
			item.call(function)
		else:
			print(Time.get_time_string_from_system(), ": ERROR: ", self.script.get_path(),
			" non-existant function ", function, " called for Node ", item)
