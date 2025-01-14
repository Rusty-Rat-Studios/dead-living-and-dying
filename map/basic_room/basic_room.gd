class_name BasicRoom
extends Room

const WALL_WITHOUT_DOOR: Resource = preload("res://map/basic_room/wall_without_door.tscn")
const WALL_WITH_DOOR: Resource = preload("res://map/basic_room/wall_with_door.tscn")

const WALL_OFFSET: float = 9.95
const NINETY_DEGREES: float = deg_to_rad(90)


func generate_walls_and_doors() -> void:
	for pdl: DoorLocation in room_information.possible_door_locations:
		var obj: Node3D
		if door_locations.any(_test_door_location(pdl)):
			obj = WALL_WITH_DOOR.instantiate()
		else:
			obj = WALL_WITHOUT_DOOR.instantiate()
		if pdl.direction == DoorLocation.Direction.NORTH:
			obj.translate_object_local(Vector3(pdl.location.x, 0, pdl.location.y - 1) * WALL_OFFSET)
		elif pdl.direction == DoorLocation.Direction.EAST:
			obj.translate_object_local(Vector3(pdl.location.x + 1, 0, pdl.location.y) * WALL_OFFSET)
			obj.rotate_y(NINETY_DEGREES)
		elif pdl.direction == DoorLocation.Direction.SOUTH:
			obj.translate_object_local(Vector3(pdl.location.x, 0, pdl.location.y + 1) * WALL_OFFSET)
		elif pdl.direction == DoorLocation.Direction.WEST:
			obj.translate_object_local(Vector3(pdl.location.x - 1, 0, pdl.location.y) * WALL_OFFSET)
			obj.rotate_y(NINETY_DEGREES)
		add_child(obj)


func _test_door_location(pdl: DoorLocation) -> Callable:
	return func (door_location: DoorLocation) -> bool:
		return pdl.equals(door_location)
