extends Node3D


# Called when the node enters the scene tree for the first time.
func update_all() -> void:
	propagate_call("update")
