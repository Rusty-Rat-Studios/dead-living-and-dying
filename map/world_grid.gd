class_name WorldGrid
extends Node3D

# This class is the authority on everything room related. It handles instantiation, 
# initialization, and storing the location of the rooms. Other classes call this
# class to ask about the state of the WorldGrid.

const GRID_SCALE: float = 20 # Size of each grid square in editor units
const GENERATOR_ATTEMPTS: int = 10 # Number of consecutive failed attempts before error 
const BASIC_ROOM: RoomInformation = preload("res://map/rooms/basic_room/basic_room.tres")

var room_map: HashMap = HashMap.new()
var occupied_grid: Array[Vector2] = []
var door_grid: Array[DoorLocation] = []

@onready var entity_table: EntityTable = load("res://entity/entity_tables/test_entity_table.tres")


func _ready() -> void:
	_add_room(BASIC_ROOM, Vector2(0,0)) # Hardcoded to a basic room for now
	var room_occupied_and_door_grids: Dictionary = _get_room_occupied_and_door_grids(BASIC_ROOM, Vector2(0,0))
	occupied_grid.assign(room_occupied_and_door_grids.get('occupied_grid'))
	door_grid.assign(room_occupied_and_door_grids.get('door_grid'))
	
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
	var room_table: EntityTable = load("res://entity/entity_tables/test_room_table.tres")
	var fails: int = 0
	
	while(fails < GENERATOR_ATTEMPTS):
		if room_table.are_constraints_met():
			print("All constraints met. Room generation complete")
			return
		
		if door_grid.size() == 0:
			push_error("ERROR: Room generation failed, ¯\\_(ツ)_/¯ Ran out of doors")
			return
		
		var target_door: DoorLocation = RNG.random_from_list(door_grid)
		var room_door_dir: DoorLocation.Direction = target_door.invert().direction # Diection of required connecting door
		
		print("Selected door %s, needing direction %s" % [target_door, DoorLocation.Direction.keys()[room_door_dir]])
		
		var room_information: RoomInformation = room_table.get_random_entity()
		var valid_room_doors: Array[DoorLocation] = _get_door_locations_facing(room_information, room_door_dir)
		
		# Fail if no doors of correct direction
		if valid_room_doors.size() == 0:
			fails += 1
			continue
		
		# Returns a dictionary of room_pos, occupied_grid, door_grid 
		var valid_room_placement: Dictionary = _get_valid_room_placement_at_doors(room_information, 
			target_door.invert().location, valid_room_doors)
		
		# Fail if no valid placements
		if valid_room_placement.has('invalid'):
			fails += 1
			continue
		
		occupied_grid.append_array(valid_room_placement.get('occupied_grid'))
		_add_to_door_grid_removing_matches(valid_room_placement.get('door_grid'))
		
		# Add room and reset 'fails'
		_add_room(room_information, valid_room_placement.get('room_pos'))
		fails = 0
	
	push_error("ERROR: Generator exceeded GENERATOR_ATTEMPTS")
	return


func _get_valid_room_placement_at_doors(room_information: RoomInformation, room_location: Vector2, 
	valid_room_doors: Array[DoorLocation]) -> Dictionary:
	while valid_room_doors.size() > 0:
		var random_valid_room_door: DoorLocation = RNG.random_from_list(valid_room_doors)
		valid_room_doors.erase(random_valid_room_door)
		var room_pos: Vector2 = -random_valid_room_door.location + room_location
		var room_occupied_and_door_grids: Dictionary = _get_room_occupied_and_door_grids(room_information, room_pos)
		var room_occupied_grid: Array[Vector2]
		room_occupied_grid.assign(room_occupied_and_door_grids.get('occupied_grid'))
		var room_door_grid: Array[DoorLocation]
		room_door_grid.assign(room_occupied_and_door_grids.get('door_grid'))
		if _does_room_overlap_existing(room_occupied_grid):
			continue
		return {
			'room_pos': room_pos,
			'occupied_grid': room_occupied_grid,
			'door_grid': room_door_grid
		}
	return { 'invalid': true }


func _add_to_door_grid_removing_matches(room_door_grid: Array[DoorLocation]) -> void:
	for door_location: DoorLocation in room_door_grid:
		var matched_door: DoorLocation = door_grid.filter(
			func(value: DoorLocation) -> bool: 
				return value.equals(door_location.invert())
		).front()
		
		if matched_door:
			door_grid.erase(matched_door)
		else:
			door_grid.append(door_location)


func _get_door_locations_facing(room_information: RoomInformation, dir: DoorLocation.Direction) -> Array[DoorLocation]:
	return room_information.possible_door_locations.filter(
		func(value: DoorLocation) -> bool: 
			return value.direction == dir
	)


func _get_room_occupied_and_door_grids(room_info: RoomInformation, grid_location: Vector2) -> Dictionary:
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


func _does_room_overlap_existing(room_occupied_grid: Array[Vector2]) -> bool:
	return room_occupied_grid.any(func(value: Vector2) -> bool: return value in occupied_grid)


func _add_room(room_info: RoomInformation, grid_location: Vector2) -> void:
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
