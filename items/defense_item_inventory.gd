class_name DefenseItemInventory
extends ItemInventory

signal item_used(cooldown_timer: Timer)


func use() -> void:
	push_error("AbstractMethodError: DefenseItemInventory use() function called from base DefenseItemInventory class")
