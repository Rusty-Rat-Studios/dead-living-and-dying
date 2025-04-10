class_name WorldGrid
extends Node3D

signal finished_generation

# This class is the authority on everything room related. It handles instantiation, 
# initialization, and storing the location of the rooms. Other classes call this
# class to ask about the state of the WorldGrid.

const GRID_SCALE: float = 16 # Size of each grid square in editor units

@export var generator_settings: GeneratorSettings = null

var generator_settings_original: GeneratorSettings
var number_of_rooms: int = 0
var room_map: HashMap = HashMap.new()
# adjacency list of each room's connected rooms
# key == room node
# value == array of connected room nodes
var room_graph: Dictionary[Room, Array]

@onready var shrine_room_scene: PackedScene = preload("res://src/map/rooms/shrine_room.tscn")


func _ready() -> void:
	if generator_settings != null:
		generator_settings_original = generator_settings.deep_copy()
	else:
		generator_settings_original = null
	setup_grid()


func setup_grid() -> void:
	_autoplace_shrine_room(Vector2(0, -1))
	
	var occupied_and_door_grids: Dictionary[String, Array] = _load_grid_with_current_scene()
	
	if generator_settings != null and generator_settings.room_table != null:
		var generator: WorldGenerator = WorldGenerator.new(
			generator_settings,
			occupied_and_door_grids.get('occupied_grid'),
			occupied_and_door_grids.get('door_grid')
		)
		generator.generate_grid(self)
		print("Spawned a total of ", number_of_rooms, " rooms")
		generator.free()
	_init_all_rooms()
	_spawn_entities()
	build_room_graph()
	finished_generation.emit()


func add_room(room: Room, grid_location: Vector2, add_to_tree: bool = true) -> void:
	print(Time.get_time_string_from_system(), 
		": Added room at location ", grid_location)
	room.grid_location = grid_location
	# Adds each grid square that the room takes up to the HashMap & occupied_grid
	for room_portion: Vector2 in room.room_information.room_shape:
		var translated_room_portion: Vector2 = room_portion + grid_location
		room_map.add_with_hash(_hash_vector2(translated_room_portion), room)
	number_of_rooms += 1
	if add_to_tree:
		add_child(room)


# If grid_location exists in the HashMap return room, otherwise returns null
func get_room_at_location(grid_location: Vector2) -> Room:
	return room_map.retrieve_with_hash(_hash_vector2(grid_location))


func get_rooms_of_type(room_type: Room.RoomType) -> Array[Room]:
	var rooms_of_type: Array[Room]
	rooms_of_type.assign(room_map.values().filter(
		func(room: Room) -> bool:
			return room.room_information.room_type == room_type
	))
	return rooms_of_type


func reset() -> void:
	number_of_rooms = 0
	generator_settings = generator_settings_original.deep_copy()
	clear()


func clear() -> void:
	for node: Node in get_children():
		if node is Room:
			if not (node as Room).spawn_room:
				node.free()
	room_map.clear()


func _autoplace_shrine_room(shrine_room_grid_loc: Vector2) -> void:
	var shrine_room: Room = shrine_room_scene.instantiate()
	(shrine_room.get_node("Shrine") as Shrine).default = true
	add_child(shrine_room)
	shrine_room.global_position = Vector3(shrine_room_grid_loc.x * GRID_SCALE, 0, shrine_room_grid_loc.y * GRID_SCALE)


func _load_grid_with_current_scene() -> Dictionary[String, Array]:
	var occupied_grid: Array[Vector2] = []
	var door_grid: Array[DoorLocation] = []
	for room: Room in get_tree().get_nodes_in_group("rooms"):
		var grid_location: Vector2 = (
			Vector2(room.global_position.x, room.global_position.z)/GRID_SCALE
			).round()
		add_room(room, grid_location, false)
		var room_occupied_and_door_grids: Dictionary[String, Array] = get_room_occupied_and_door_grids(
			room.room_information, grid_location)
		occupied_grid.append_array(room_occupied_and_door_grids.get("occupied_grid"))
		add_to_door_grid_removing_matches(door_grid, room_occupied_and_door_grids.get("door_grid"))
	return {
		"occupied_grid": occupied_grid,
		"door_grid": door_grid
	}


func _init_all_rooms() -> void:
	for node: Node in self.get_children():
		if node is Room:
			node.init()
	
	for shrine: Shrine in ShrineManager.shrines:
		shrine.init()


func _spawn_entities() -> void:
	if generator_settings != null:
		if generator_settings.enemy_entity_table != null:
			SpawnerManager.spawn(Spawner.SpawnerType.ENEMY, generator_settings.enemy_entity_table)
		if generator_settings.item_entity_table != null:
			SpawnerManager.spawn(Spawner.SpawnerType.ITEM, generator_settings.item_entity_table)
		if generator_settings.key_item_entity_table != null:
			SpawnerManager.spawn(Spawner.SpawnerType.KEY_ITEM, generator_settings.key_item_entity_table)
		if generator_settings.boss_entity_table != null:
			SpawnerManager.spawn(Spawner.SpawnerType.BOSS, generator_settings.boss_entity_table)


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


# Takes each DoorLocation in room_door_grid and sees if there is a connecting door
# in door_grid. If there is, it is removed. If there is not, then the door location
# is added to the grid. The resulting grid is returned.
static func add_to_door_grid_removing_matches(door_grid: Array[DoorLocation], 
	room_door_grid: Array[DoorLocation]) -> void:
	for door_location: DoorLocation in room_door_grid:
		var matches: Array[DoorLocation] = door_grid.filter(
			func(value: DoorLocation) -> bool: 
				return value.equals(door_location.invert())
		)
		
		if matches.size() > 0:
			door_grid.erase(matches.front())
		else:
			door_grid.append(door_location)


func _hash_vector2(vector: Vector2) -> PackedByteArray:
	var hash_string: String = "Vector2|%s" % [str(vector)]
	return hash_string.sha256_buffer()


# constructs a graph (nodes == rooms, edges == connected rooms/doors) of the map
func build_room_graph() -> void:
	room_graph.clear()
	for room_id: PackedByteArray in room_map.keys():
		if not room_graph.has(room_map.retrieve_with_hash(room_id)):
			# add each room as a key in the map
			var room: Room = room_map.retrieve_with_hash(room_id)
			
			# define all rooms linked to this room
			var linked_rooms: Array[Room]
			# get each door
			for door_id: PackedByteArray in room.doors.keys():
				var door: Door = room.doors.retrieve_with_hash(door_id)
				# append each door's linked room to the list
				linked_rooms.append(door.linked_room)
			
			room_graph[room_map.retrieve_with_hash(room_id)] = linked_rooms


# Returns the shortest path as a set of rooms from the current room to the target room.
func find_shortest_path(start_room: Room, end_room: Room) -> Array:
	
	if not room_graph.has(start_room) or not room_graph.has(end_room):
		return []
	
	# array of array of rooms
	var queue: Array[Array] = [[start_room]]
	var visited: Dictionary[Room, bool] = {start_room: true}
	
	while not queue.is_empty():
		var current_path: Array = queue.pop_front()
		var current_room: Room = current_path[-1]
		
		if current_room == end_room:
			return current_path
		
		if room_graph.has(current_room):
			for neighbor: Room in room_graph[current_room]:
				if not visited.has(neighbor):
					visited[neighbor] = true
					var new_path: Array = current_path.duplicate()
					new_path.append(neighbor)
					queue.append(new_path)
	
	return [] # no path found
