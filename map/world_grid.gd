class_name WorldGrid
extends Node3D

# This class is the authority on everything room related. It handles instantiation, 
# initialization, and storing the location of the rooms. Other classes call this
# class to ask about the state of the WorldGrid.

const GRID_SCALE: float = 16 # Size of each grid square in editor units

var room_map: HashMap = HashMap.new()

@onready var basic_room: RoomInformation = preload("res://map/rooms/basic_room/basic_room.tres")
# For some reason preload will not work here
@onready var entity_table: EntityTable = load("res://entity/entity_tables/test_entity_table.tres")


func _ready() -> void:
	generate_grid()
	# TODO: Run for each type of spawner using a specific EntityTable
	SpawnerManager.spawn(Spawner.SpawnerType.ENEMY, entity_table)


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
	# Adds each grid square that the room takes up to the HashMap
	for room_portion: Vector2 in room_info.room_shape:
		var translated_room_portion: Vector2 = room_portion + grid_location
		room_map.add_with_hash(_hash_vector2(translated_room_portion), room)
	add_child(room)


# If grid_location exists in the HashMap return room, otherwise returns null
func get_room_at_location(grid_location: Vector2) -> Room:
	return room_map.retrieve_with_hash(_hash_vector2(grid_location))


func clear() -> void:
	for room: Node in get_children():
		room.queue_free()
	room_map.clear()


func init_all_rooms() -> void:
	for node: Node in self.get_children():
		if node is Room:
			node.init()


func _hash_vector2(vector: Vector2) -> PackedByteArray:
	var hash_string: String = "Vector2|%s" % [str(vector)]
	return hash_string.sha256_buffer()
