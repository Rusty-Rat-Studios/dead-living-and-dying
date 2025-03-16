class_name ItemInventory
extends Node3D

# to be set by inheritors as a reference to their in-world partner version
var world_resource: Resource
var display_name: String
var description: String
var texture: Texture2D

func drop() -> void:
	pass
