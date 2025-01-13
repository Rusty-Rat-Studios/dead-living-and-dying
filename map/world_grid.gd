extends Node3D
class_name WorldGrid

const GRID_SCALE: float = 20 # Size of each grid square in editor units

var basic_room: RoomInformation = preload("res://map/basic_room/basic_room.tres")


func _ready() -> void:
	generate_grid()


func generate_grid() -> void:
	# Currently hardcoded to generate the default 5 rooms
	add_room(basic_room, Vector2(0, 0))
	add_room(basic_room, Vector2(0, -1))
	add_room(basic_room, Vector2(0, -2))
	add_room(basic_room, Vector2(-1, -1))
	add_room(basic_room, Vector2(1, -1))
	init_all_rooms()


func add_room(room_info: RoomInformation, grid_location: Vector2) -> void:
	var room: Room = room_info.resource.instantiate()
	room.grid_location = grid_location
	room.room_information = room_info
	add_child(room)


func init_all_rooms() -> void:
	for room: Room in self.get_children():
		room.init()


func is_door_connected(door_location: DoorLocation) -> bool:
	return false
