class_name BasicRoom
extends Room

const WALL_WITHOUT_DOOR: Resource = preload("res://map/wall_without_door.tscn")
const WALL_WITH_DOOR: Resource = preload("res://map/wall_with_door.tscn")


func generate_walls_and_doors() -> void:
	var grid_locations: Dictionary = world_grid.get_grid_dict()
	var translated_possible_door_locations: Array[Vector2] = get_translated_possible_door_locations()
	for loc: Vector2 in translated_possible_door_locations:
		var is_door_location: bool = grid_locations.has(loc)
		var untranslated_location: Vector2 = loc - grid_location
		var obj: Node3D
		if is_door_location:
			obj = WALL_WITH_DOOR.instantiate()
		else:
			obj = WALL_WITHOUT_DOOR.instantiate()
		obj.translate_object_local(Vector3(untranslated_location.x, 0, 
			untranslated_location.y) * 9.95)
		if untranslated_location.y == 0:
			obj.rotate_y(deg_to_rad(90))
		add_child(obj)
