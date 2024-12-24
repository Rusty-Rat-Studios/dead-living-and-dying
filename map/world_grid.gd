extends Node3D

const GRID_SCALE: float = 20 # Size of each grid square in editor units
const BASIC_ROOM: Resource = preload("res://map/basic_room.tscn")

@onready var grid: Dictionary = {}


func _ready() -> void:
	generate_grid()


func generate_grid() -> void:
	# Currently hardcoded to generate the default 5 rooms
	add_room(BASIC_ROOM.instantiate(), Vector2(0, 0))
	add_room(BASIC_ROOM.instantiate(), Vector2(0, -1))
	add_room(BASIC_ROOM.instantiate(), Vector2(0, -2))
	add_room(BASIC_ROOM.instantiate(), Vector2(-1, -1))
	add_room(BASIC_ROOM.instantiate(), Vector2(1, -1))
	init_all_rooms()


func add_room(room: Room, grid_location: Vector2) -> void:
	add_child(room)
	grid[grid_location] = room # Todo: Doesn't work for rooms bigger than 1 sq


func init_all_rooms() -> void:
	for grid_location: Vector2 in grid.keys():
		var room: Room = grid.get(grid_location)
		room.init(grid_location, GRID_SCALE)


func clear_grid() -> void:
	grid.clear()


func get_grid_dict() -> Dictionary:
	return grid
