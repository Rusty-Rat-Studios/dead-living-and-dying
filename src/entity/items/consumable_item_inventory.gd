class_name ConsumableItemInventory
extends ItemInventory

signal item_used(cooldown_timer: Timer)
signal count_update(count: int)

var count: int

func use() -> void:
	#gdlint:ignore=max-line-length
	push_error("AbstractMethodError: ConsumableItemInventory use() function called from base ConsumableItemInventory class")


func drop() -> void:
	var world_item: ConsumableItemWorld = world_resource.instantiate()
	PlayerHandler.get_current_room().add_child(world_item)
	world_item.count = count
	world_item.global_position = PlayerHandler.get_player().global_position + Vector3(0, -0.5, 0.01)
	world_item.disable_interactable(DELAY_DURATION)
	queue_free()


func ui_update()-> void:
	count_update.emit(count)
