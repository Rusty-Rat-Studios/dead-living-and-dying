class_name ItemInventory
extends Node3D

# to be set by inheritors as a reference to their in-world partner version
const DELAY_DURATION: int = 1
var world_resource: Resource
var display_name: String
var input_event: String
var description: String
var texture: Texture2D

func drop() -> void:
	var world_item: ItemWorld = world_resource.instantiate()
	PlayerHandler.get_current_room().add_child(world_item)
	world_item.global_position = PlayerHandler.get_player().global_position + Vector3(0, -0.5, 0.01)
	world_item.disable_interactable(DELAY_DURATION)
	queue_free()
