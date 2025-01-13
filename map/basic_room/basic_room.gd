class_name BasicRoom
extends Room

const WALL_WITHOUT_DOOR: Resource = preload("res://map/basic_room/wall_without_door.tscn")
const WALL_WITH_DOOR: Resource = preload("res://map/basic_room/wall_with_door.tscn")


func generate_walls_and_doors() -> void:
	for door_location: DoorLocation in room_information.possible_door_locations:
		var obj: Node3D
		if world_grid.is_door_connected(door_location.translate(grid_location)):
			obj = WALL_WITH_DOOR.instantiate()
		else:
			obj = WALL_WITHOUT_DOOR.instantiate()
		if door_location.direction == DoorLocation.Direction.NORTH:
			obj.translate_object_local(Vector3(door_location.location.x, 0, door_location.location.y - 1) * 9.95)
		elif door_location.direction == DoorLocation.Direction.EAST:
			obj.translate_object_local(Vector3(door_location.location.x + 1, 0, door_location.location.y) * 9.95)
			obj.rotate_y(deg_to_rad(90))
		elif door_location.direction == DoorLocation.Direction.SOUTH:
			obj.translate_object_local(Vector3(door_location.location.x, 0, door_location.location.y + 1) * 9.95)
		elif door_location.direction == DoorLocation.Direction.WEST:
			obj.translate_object_local(Vector3(door_location.location.x - 1, 0, door_location.location.y) * 9.95)
			obj.rotate_y(deg_to_rad(90))
		add_child(obj)
