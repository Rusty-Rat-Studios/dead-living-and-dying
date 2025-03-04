class_name WorldGrid
extends Node3D

# This class is the authority on everything room related. It handles instantiation, 
# initialization, and storing the location of the rooms. Other classes call this
# class to ask about the state of the WorldGrid.

const GRID_SCALE: float = 16 # Size of each grid square in editor units
const BASIC_ROOM: RoomInformation = preload("res://map/rooms/basic_room/basic_room.tres")

var room_map: HashMap = HashMap.new()

@onready var entity_table: EntityTable = load("res://entity/entity_tables/test_entity_table.tres")


func _ready() -> void:
	setup_grid()


func setup_grid() -> void:
	add_room(BASIC_ROOM, Vector2(0,0)) # Hardcoded to a basic room for now
	var room_occupied_and_door_grids: Dictionary[String, Array] = get_room_occupied_and_door_grids(
		BASIC_ROOM, Vector2(0,0))
	var generator: WorldGenerator = WorldGenerator.new(
		room_occupied_and_door_grids.get('occupied_grid'), 
		room_occupied_and_door_grids.get('door_grid')
	)
	
	generator.generate_grid(self)
	_init_all_rooms()
	_spawn_entities()


func clear() -> void:
	for node: Node in get_children():
		if node is Room:
			node.queue_free()
	room_map.clear()


# Returns the occupied_grid and door_grid of a room
static func get_room_occupied_and_door_grids(room_info: RoomInformation, 
	grid_location: Vector2) -> Dictionary[String, Array]:
	var room_occupied: Array[Vector2]
	room_occupied.assign(room_info.room_shape.map(
		func(value: Vector2) -> Vector2:
			return value + grid_location
	))
	
	var room_doors: Array[DoorLocation]
	room_doors.assign(room_info.possible_door_locations.map(
		func(value: DoorLocation) -> DoorLocation:
			return value.translate(grid_location)
	))
	
	return {
		'occupied_grid': room_occupied,
		'door_grid': room_doors
	}
	

func add_room(room_info: RoomInformation, grid_location: Vector2) -> void:
	var room: Room = room_info.resource.instantiate() 
	room.grid_location = grid_location
	room.room_information = room_info
	# Adds each grid square that the room takes up to the HashMap & occupied_grid
	for room_portion: Vector2 in room_info.room_shape:
		var translated_room_portion: Vector2 = room_portion + grid_location
		room_map.add_with_hash(_hash_vector2(translated_room_portion), room)
	add_child(room)


func _init_all_rooms() -> void:
	for node: Node in self.get_children():
		if node is Room:
			node.init()


func _spawn_entities() -> void:
	SpawnerManager.spawn(Spawner.SpawnerType.ENEMY, entity_table)


# If grid_location exists in the HashMap return room, otherwise returns null
func get_room_at_location(grid_location: Vector2) -> Room:
	return room_map.retrieve_with_hash(_hash_vector2(grid_location))


func _hash_vector2(vector: Vector2) -> PackedByteArray:
	var hash_string: String = "Vector2|%s" % [str(vector)]
	return hash_string.sha256_buffer()
