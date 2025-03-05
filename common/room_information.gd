class_name RoomInformation
extends Resource

# Stores information about a room type. For example a seperate RoomInformation 
# would need to be crafted for every type of room (simple square, hallway, shrine, 
# etc). This is to be used both by the WorldGrid/LevelGenerator and the room itself.

@export var room_shape: Array[Vector2]
@export var possible_door_locations: Array[DoorLocation]

func _init(_room_shape:Array[Vector2]=[], _possible_door_locations:Array[DoorLocation]=[]) -> void:
	room_shape = _room_shape
	possible_door_locations = _possible_door_locations
