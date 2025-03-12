class_name ConsumableItemInventory
extends ItemInventory

signal item_used(cooldown_timer: Timer)
signal item_consumed()

var count: int

func use() -> void:
	#gdlint:ignore=max-line-length
	push_error("AbstractMethodError: ConsumableItemInventory use() function called from base ConsumableItemInventory class")
