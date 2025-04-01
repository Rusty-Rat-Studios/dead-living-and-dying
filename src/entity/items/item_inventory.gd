class_name ItemInventory
extends Node3D

# to be set by inheritors as a reference to their in-world partner version
var world_resource: Resource
var display_name: String
var input_event: String
var description: String
var texture: Texture2D

func drop() -> void:
	var world_item: ItemWorld = world_resource.instantiate()
	get_node("/root/Game").add_child(world_item)
	world_item.position = PlayerHandler.get_player().position + Vector3(0, -0.5, 0)
	world_item.disable_interactable(1)
	queue_free()
