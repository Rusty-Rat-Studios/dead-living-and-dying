extends Node3D
class_name WorldGrid

const GRID_SCALE: float = 20 # Size of each grid square in editor units

var basic_room: RoomInformation = preload("res://map/basic_room/basic_room.tres")


func _ready() -> void:
	generate_grid()


func generate_grid() -> void:
	# Currently hardcoded to generate the default 5 rooms
	add_room(basic_room, Vector2(0, 0), [
		DoorLocation.new(Vector2(0, 0), DoorLocation.Direction.NORTH)])
	add_room(basic_room, Vector2(0, -1), [
		DoorLocation.new(Vector2(0, 0), DoorLocation.Direction.NORTH),
		DoorLocation.new(Vector2(0, 0), DoorLocation.Direction.EAST),
		DoorLocation.new(Vector2(0, 0), DoorLocation.Direction.SOUTH),
		DoorLocation.new(Vector2(0, 0), DoorLocation.Direction.WEST)])
	add_room(basic_room, Vector2(0, -2), [
		DoorLocation.new(Vector2(0, 0), DoorLocation.Direction.SOUTH)])
	add_room(basic_room, Vector2(-1, -1), [
		DoorLocation.new(Vector2(0, 0), DoorLocation.Direction.EAST)])
	add_room(basic_room, Vector2(1, -1), [
		DoorLocation.new(Vector2(0, 0), DoorLocation.Direction.WEST)])
	init_all_rooms()


func add_room(room_info: RoomInformation, grid_location: Vector2, door_locations: Array[DoorLocation]) -> void:
	var room: Room = room_info.resource.instantiate()
	room.grid_location = grid_location
	room.room_information = room_info
	room.door_locations = door_locations
	add_child(room)


func init_all_rooms() -> void:
	for node: Node in self.get_children():
		if node is Room:
			node.init()
