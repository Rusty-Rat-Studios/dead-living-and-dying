extends CooldownSlot


func _on_item_picked_up(item_inventory: ItemInventory, _current_consumable: bool = false) -> void:
	if item_inventory is ActiveItemInventory:
		_item_inventory = item_inventory
		# update UI image to match item
		texture_rect.texture = _item_inventory.texture
		
		# function implemented in cooldown_slot.gd
		_item_inventory.item_used.connect(_on_item_used)
