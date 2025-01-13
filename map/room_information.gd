extends Resource
class_name RoomInformation

@export var resource: Resource
@export var room_shape: Array[Vector2]
@export var possible_door_locations: Array[DoorLocation]

func _init(_resource:Resource=null, _room_shape:Array[Vector2]=[], 
	_possible_door_locations:Array[DoorLocation]=[]) -> void:
	resource = _resource
	room_shape = _room_shape
	possible_door_locations = _possible_door_locations
