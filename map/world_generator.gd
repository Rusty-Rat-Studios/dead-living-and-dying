class_name WorldGenerator
extends Object

const GENERATOR_ATTEMPTS: int = 10 # Number of consecutive failed attempts before error 

var occupied_grid: Array[Vector2] = []
var door_grid: Array[DoorLocation] = []


func _init(initial_occupied_grid: Array[Vector2], initial_door_grid: Array[DoorLocation]) -> void:
	occupied_grid = initial_occupied_grid
	door_grid = initial_door_grid


# Generates a grid of rooms according to information in specified room_table.
# TODO: Move generation code into its own class
# Function keeps track of failed placements and will fail generation if number of 
# consecutive failed placements exceeds GENERATOR_ATTEMPTS.
# Function returns when all constraints of room_table are met (unless it fails in
# which case it prints an error and then returns).
# Steps: pick a random door location on the grid, pick a random room entity, 
#        check if any of room entity's doors can connect to selected door location,
#        find a random door that connects and is a valid placement, add locations
#        room occupies to occupied_grid, add door locations from room to door_grid
#        (removing and pairs that connect), add room to grid, loop until complete
func generate_grid(grid: WorldGrid) -> void:
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
		
		print("Selected door %s, needing direction %s" % [target_door.string(), DoorLocation.Direction.keys()[room_door_dir]])
		
		var room_information: RoomInformation = room_table.get_random_entity()
		var valid_room_doors: Array[DoorLocation] = _get_door_locations_facing(room_information, room_door_dir)
		
		print("Selected room %s" % [room_information.resource])
		
		# Fail if no doors of correct direction
		if valid_room_doors.size() == 0:
			print("No doors of that direction exist in room")
			fails += 1
			continue
		
		# Returns a dictionary of room_pos, occupied_grid, door_grid 
		var valid_room_placement: Dictionary = _get_valid_room_placement_at_doors(room_information, 
			target_door.invert().location, valid_room_doors)
		
		# Fail if no valid placements
		if valid_room_placement.has('invalid'):
			print("No valid placements for room")
			fails += 1
			continue
		
		occupied_grid.append_array(valid_room_placement.get('occupied_grid'))
		_add_to_door_grid_removing_matches(valid_room_placement.get('door_grid'))
		
		# Add room and reset 'fails'
		print("Adding room at position %s" % [valid_room_placement.get('room_pos')])
		grid.add_room(room_information, valid_room_placement.get('room_pos'))
		fails = 0
	
	push_error("ERROR: Generator exceeded GENERATOR_ATTEMPTS")
	return


# Checks if a random door in valid_room_doors will connect to the location at 
# room_location without overlapping other rooms. If so, returns the position to
# place the room at, the occupied_grid of the room, and the door_grid of the room.
# If no doors are valid, returns { 'invalid': true }
func _get_valid_room_placement_at_doors(room_information: RoomInformation, room_location: Vector2, 
	valid_room_doors: Array[DoorLocation]) -> Dictionary:
	while valid_room_doors.size() > 0:
		var random_valid_room_door: DoorLocation = RNG.random_from_list(valid_room_doors)
		valid_room_doors.erase(random_valid_room_door)
		var room_pos: Vector2 = -random_valid_room_door.location + room_location
		var room_occupied_and_door_grids: Dictionary = WorldGrid.get_room_occupied_and_door_grids(
			room_information, room_pos)
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


# Takes each DoorLocation in room_door_grid and sees if there is a connecting door
# in door_grid. If there is, it is removed. If there is not, then the door location
# is added to the grid.
func _add_to_door_grid_removing_matches(room_door_grid: Array[DoorLocation]) -> void:
	for door_location: DoorLocation in room_door_grid:
		var matches: Array[DoorLocation] = door_grid.filter(
			func(value: DoorLocation) -> bool: 
				return value.equals(door_location.invert())
		)
		
		if matches.size() > 0:
			door_grid.erase(matches.front())
		else:
			door_grid.append(door_location)


# Returns all the door locations of a room facing a specific direction
func _get_door_locations_facing(room_information: RoomInformation, dir: DoorLocation.Direction) -> Array[DoorLocation]:
	return room_information.possible_door_locations.filter(
		func(value: DoorLocation) -> bool: 
			return value.direction == dir
	)


# Returns true if room_occupied_grid overlaps any grid squares in occupied_grid
func _does_room_overlap_existing(room_occupied_grid: Array[Vector2]) -> bool:
	return room_occupied_grid.any(func(value: Vector2) -> bool: return value in occupied_grid)
