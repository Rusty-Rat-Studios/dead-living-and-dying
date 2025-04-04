class_name RoomInformation
extends Resource

# Stores information about a room type. For example a seperate RoomInformation 
# would need to be crafted for every type of room (simple square, hallway, shrine, 
# etc). This is to be used both by the WorldGrid/LevelGenerator and the room itself.

@export var room_type: Room.RoomType = Room.RoomType.BASIC
@export var min_room_spawn_grid_distance: int = 0
@export var room_shape: Array[Vector2]
@export var possible_door_locations: Array[DoorLocation]
@export var minimap_component: Resource
@export var room_icon: Texture2D

func _init(_room_shape: Array[Vector2]=[], _possible_door_locations: Array[DoorLocation]=[], 
	_minimap_component: Resource = null, _room_icon: Texture2D = null) -> void:
	room_shape = _room_shape
	possible_door_locations = _possible_door_locations
	minimap_component = _minimap_component
	room_icon = _room_icon
