extends Node


func delay(time: float) -> void:
	await get_tree().create_timer(time)


func find_closest(list: Array, global_pos: Vector3) -> Node:
	var closest: Node = list[0]
	var distance_sq: float
	for item: Node in list:
		distance_sq = item.global_position.distance_squared_to(global_pos)
		if distance_sq < global_pos.distance_squared_to(closest.global_position):
			closest = item
		
	return closest


func call_for_each(list: Array, function: Callable) -> void:
	for item: Node in list:
		function.call(item)
