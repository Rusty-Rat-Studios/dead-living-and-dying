class_name ConsumableItemInventory
extends ItemInventory

signal item_used(cooldown_timer: Timer)

var count: int

func use() -> void:
	#gdlint:ignore=max-line-length
	push_error("AbstractMethodError: ConsumableItemInventory use() function called from base ConsumableItemInventory class")


func drop() -> void:
	var world_item: ConsumableItemWorld = world_resource.instantiate()
	get_node("/root/Game").add_child(world_item)
	world_item.count = count
	world_item.position = PlayerHandler.get_player().position + Vector3(0, -0.5, 0.01)
	world_item.disable_interactable(DELAY_DURATION)
	queue_free()
