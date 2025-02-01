class_name BasicRoom
extends Room

# A very simple room script. This room extends Room and generate_walls_and_doors()
# is called by the super class.

const WALL_WITHOUT_DOOR: Resource = preload("res://map/basic_room/wall_without_door.tscn")
const WALL_WITH_DOOR: Resource = preload("res://map/basic_room/wall_with_door.tscn")

const WALL_OFFSET: float = 9.95
const NINETY_DEGREES: float = deg_to_rad(90)


# Uses the information stored in room_information and door_locations to initialize 
# doors at the correct locations in the room.
func init_doors() -> void:
	pass


func _test_door_location(pdl: DoorLocation) -> Callable:
	return func (door_location: DoorLocation) -> bool:
		return pdl.equals(door_location)
