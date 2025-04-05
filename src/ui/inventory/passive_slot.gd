class_name PassiveSlot
extends InventorySlot


func _ready() -> void:
	# do not execute the parent signal bus connection for picking up items
	pass

func _on_item_picked_up(_item_inventory: ItemInventory, _current_consumable: bool = false,
						_current_count: int = 0) -> void:
	pass 
