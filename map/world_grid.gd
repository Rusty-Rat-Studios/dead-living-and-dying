extends Node3D

# Size of each grid square in editor units
const GRID_SCALE: float = 20

@onready var grid: Dictionary = {}


func _ready() -> void:
	pass


func generate_grid() -> void:
	pass


func clear_grid() -> void:
	grid.clear()


func get_grid_dict() -> Dictionary:
	return grid
