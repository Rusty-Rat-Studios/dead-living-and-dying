class_name BasicRoom
extends Room

const wall_without_door: Resource = preload("res://map/wall_without_door.tscn")
const wall_with_door: Resource = preload("res://map/wall_with_door.tscn")


func _ready() -> void:
	init(Vector2(0, -2))


func generate_walls_and_doors() -> void:
	var grid_locations: Dictionary = world_grid.get_grid_dict()
	var translated_possible_door_locations: Array[Vector2] = get_translated_possible_door_locations()
	print(grid_locations)
	for loc: Vector2 in translated_possible_door_locations:
		var is_door_location: bool = grid_locations.has(loc)
		var untranslated_location: Vector2 = loc - grid_location
		if untranslated_location.x == 0:
			generate_horizontal_wall_or_door(untranslated_location, is_door_location)
		elif untranslated_location.y == 0:
			generate_vertical_wall_or_door(untranslated_location, is_door_location)


func generate_horizontal_wall_or_door(loc: Vector2, is_door_location: bool) -> void:
	var obj: Node3D
	if is_door_location:
		obj = wall_with_door.instantiate()
	else:
		obj = wall_without_door.instantiate()
	obj.translate_object_local(Vector3(0, 0, loc.y) * 9.95)
	add_child(obj)


func generate_vertical_wall_or_door(loc: Vector2, is_door_location: bool) -> void:
	var obj: Node3D
	if is_door_location:
		obj = wall_with_door.instantiate()
	else:
		obj = wall_without_door.instantiate()
	obj.translate_object_local(Vector3(loc.x, 0, 0) * 9.95)
	obj.rotate_y(deg_to_rad(90))
	add_child(obj)
