class_name ActiveItemInventory
extends ItemInventory

signal item_used(cooldown_timer: Timer)


func use() -> void:
	push_error("AbstractMethodError: ActiveItemInventory use() function called from base ActiveItemInventory class")
