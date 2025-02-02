class_name BasicRoom
extends Room

# A very simple room script. This room extends Room and generate_walls_and_doors()
# is called by the super class.

const WALL_WITHOUT_DOOR: Resource = preload("res://map/wall_without_door.tscn")
const WALL_WITH_DOOR: Resource = preload("res://map/wall_with_door.tscn")


# Uses the information stored in room_information and door_locations to initialize 
# doors at the correct locations in the room.
func init_doors() -> void:
	pass
