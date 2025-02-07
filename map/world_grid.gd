class_name WorldGrid
extends Node3D

# This class is the authority on everything room related. It handles instantiation, 
# initialization, and storing the location of the rooms. Other classes call this
# class to ask about the state of the WorldGrid.

const GRID_SCALE: float = 20 # Size of each grid square in editor units

const BASIC_ROOM: RoomInformation = preload("res://map/rooms/basic_room/basic_room.tres")

var room_map: HashMap = HashMap.new()
var occupied_grid: Array[Vector2] = []
var door_grid: Array[DoorLocation] = []


func _ready() -> void:
	_add_room(BASIC_ROOM, Vector2(0,0)) # Hardcoded to a basic room for now
	_generate_grid()
	_init_all_rooms()
	_spawn_entities()


func _clear() -> void:
	occupied_grid = []
	door_grid = []
	for node: Node in get_children():
		if node is Room:
			node.queue_free()
	room_map.clear()


func _generate_grid() -> void:
	pass


func _add_room(room_info: RoomInformation, grid_location: Vector2) -> void:
	var room: Room = room_info.resource.instantiate() 
	room.grid_location = grid_location
	room.room_information = room_info
	# Adds each grid square that the room takes up to the HashMap & occupied_grid
	for room_portion: Vector2 in room_info.room_shape:
		var translated_room_portion: Vector2 = room_portion + grid_location
		room_map.add_with_hash(_hash_vector2(translated_room_portion), room)
		occupied_grid.append(translated_room_portion)
	add_child(room)


func _init_all_rooms() -> void:
	for node: Node in self.get_children():
		if node is Room:
			node.init()


func _spawn_entities() -> void:
	pass


# If grid_location exists in the HashMap return room, otherwise returns null
func get_room_at_location(grid_location: Vector2) -> Room:
	return room_map.retrieve_with_hash(_hash_vector2(grid_location))


func _hash_vector2(vector: Vector2) -> PackedByteArray:
	var hash_string: String = "Vector2|%s" % [str(vector)]
	return hash_string.sha256_buffer()
