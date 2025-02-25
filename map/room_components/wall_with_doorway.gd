class_name WallWithDoorway
extends Wall

func _ready() -> void:
	super()
	wall_material = preload("res://map/room_components/wall_with_doorway_material.tres")
