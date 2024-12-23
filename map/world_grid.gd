extends Node3D

# Size of each grid square in editor units
const GRID_SCALE: float = 20

@onready var grid: Dictionary = {
	Vector2(0,0): get_node("/root/Game/WorldGrid/RoomBottom"),
	Vector2(0,-1): get_node("/root/Game/WorldGrid/RoomCenter"),
	Vector2(0,-2): get_node("/root/Game/WorldGrid/RoomTop"),
	Vector2(-1,-1): get_node("/root/Game/WorldGrid/RoomLeft"),
	Vector2(1,-1): get_node("/root/Game/WorldGrid/RoomRight"),
}


func _ready() -> void:
	(grid.get(Vector2(0, -2)) as Room).generate_walls_and_doors()


func generate_grid() -> void:
	pass


func clear_grid() -> void:
	grid.clear()


func get_grid_scale() -> float:
	return GRID_SCALE


func get_grid_dict() -> Dictionary:
	return grid
