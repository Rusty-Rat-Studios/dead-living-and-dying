class_name ActiveItemInventory
extends ItemInventory


func use() -> void:
	push_error("AbstractMethodError: ActiveItemInventory use() function called from base ActiveItemInventory class")
