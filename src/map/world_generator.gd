class_name WorldGenerator
extends Object

const GENERATOR_ATTEMPTS: int = 10 # Number of consecutive failed attempts before error 

var room_table: EntityTable
var spread: float
var min_rooms: int
var occupied_grid: Array[Vector2] = []
var door_grid: Array[DoorLocation] = []


func _init(generator_settings: GeneratorSettings, initial_occupied_grid: Array[Vector2], 
	initial_door_grid: Array[DoorLocation]) -> void:
	room_table = generator_settings.room_table
	spread = generator_settings.spread
	min_rooms = generator_settings.min_rooms
	occupied_grid = initial_occupied_grid
	door_grid = initial_door_grid


# Generates a grid of rooms according to information in specified room_table.
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
	var fails: int = 0
	
	while(fails < GENERATOR_ATTEMPTS):
		if room_table.are_constraints_met() and grid.number_of_rooms >= min_rooms:
			print("All constraints met. Room generation complete")
			return
		
		if door_grid.size() == 0:
			push_error("ERROR: Room generation failed, ¯\\_(ツ)_/¯ Ran out of doors")
			return
		
		var required_doors_grid: Array[DoorLocation] = _get_required_doors_grid()
		
		var weighted_door_grid: Dictionary[Variant, float] = {}
		for door_location: DoorLocation in door_grid:
			var dist: float = door_location.invert().location.length() ** spread
			weighted_door_grid[door_location] = dist
		
		var target_door: DoorLocation = RNG.weighted_random(weighted_door_grid)
		var room_door_dir: DoorLocation.Direction = target_door.invert().direction # Direction of required connecting door
		
		print("Selected door %s, needing direction %s" % [target_door.string(), DoorLocation.Direction.keys()[room_door_dir]])
		
		var valid_room: Dictionary[String, Variant] = _get_valid_room(target_door, room_door_dir)
		
		if valid_room.has('invalid'):
			fails += 1
			continue
		
		var valid_room_placement: Dictionary[String, Variant] = valid_room.get("valid_room_placement")
		occupied_grid.append_array(valid_room_placement.get('occupied_grid'))
		WorldGrid.add_to_door_grid_removing_matches(door_grid, valid_room_placement.get('door_grid'))
		
		# Add room and reset 'fails'
		print("Adding room at position %s" % [valid_room_placement.get('room_pos')])
		grid.add_room(valid_room.get("room"), valid_room_placement.get('room_pos'))
		fails = 0
	
	push_error("ERROR: Generator exceeded GENERATOR_ATTEMPTS")
	return


func _get_required_doors_grid() -> Array[DoorLocation]:
	


# This function attempts to find a valid room and room placement at a given door location
# It will randomly pick rooms from the weighted_room_dict and if it fails in placing one,
# it will be removed from the weighted_room_dict (for this iteration). If all rooms are
# removed from the weighted_room_dict, then the function returns 'invalid'
func _get_valid_room(target_door: DoorLocation, room_door_dir: DoorLocation.Direction) -> Dictionary[String, Variant]:
	var weighted_room_dict: Dictionary[Variant, float] 
	weighted_room_dict.assign(room_table.get_choices_dictionary())
	
	while(weighted_room_dict.keys().size() > 0):
		var room_entry: EntityTableEntry = RNG.weighted_random(weighted_room_dict)
		var room: Room = room_entry.get_entity().instantiate()
		var valid_room_doors: Array[DoorLocation] = _get_door_locations_facing(room.room_information, room_door_dir)
		
		print("Selected room %s" % [room])
		
		# Fail if no doors of correct direction
		if valid_room_doors.size() == 0:
			print("No doors of that direction exist in room")
			weighted_room_dict.erase(room_entry)
			continue
		
		# Returns a dictionary of room_pos, occupied_grid, door_grid 
		var valid_room_placement: Dictionary[String, Variant] = _get_valid_room_placement_at_doors(
			room.room_information, target_door.invert().location, valid_room_doors)
		
		# Fail if no valid placements
		if valid_room_placement.has('invalid'):
			print("No valid placements for room")
			weighted_room_dict.erase(room_entry)
			continue
		
		room_entry.update_entity()
		
		return {
			"room": room,
			"valid_room_placement": valid_room_placement
		}
	
	return {"invalid": true}


# Checks if a random door in valid_room_doors will connect to the location at 
# room_location without overlapping other rooms. If so, returns the position to
# place the room at, the occupied_grid of the room, and the door_grid of the room.
# If no doors are valid, returns { 'invalid': true }
func _get_valid_room_placement_at_doors(room_information: RoomInformation, room_location: Vector2, 
	valid_room_doors: Array[DoorLocation]) -> Dictionary[String, Variant]:
	while valid_room_doors.size() > 0:
		var random_valid_room_door: DoorLocation = RNG.random_from_list(valid_room_doors)
		valid_room_doors.erase(random_valid_room_door)
		var room_pos: Vector2 = -random_valid_room_door.location + room_location
		var room_occupied_and_door_grids: Dictionary[String, Array] = WorldGrid.get_room_occupied_and_door_grids(
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


# Returns all the door locations of a room facing a specific direction
func _get_door_locations_facing(room_information: RoomInformation, dir: DoorLocation.Direction) -> Array[DoorLocation]:
	return room_information.possible_door_locations.filter(
		func(value: DoorLocation) -> bool: 
			return value.direction == dir
	)


# Returns true if room_occupied_grid overlaps any grid squares in occupied_grid
func _does_room_overlap_existing(room_occupied_grid: Array[Vector2]) -> bool:
	return room_occupied_grid.any(func(value: Vector2) -> bool: return value in occupied_grid)
