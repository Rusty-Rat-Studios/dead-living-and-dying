extends InventorySlot


func _on_item_picked_up(item_inventory: ItemInventory) -> void:
	if item_inventory is ConsumableItemInventory:
		_item_inventory = item_inventory
		# update UI image to match item
		texture_rect.texture = _item_inventory.texture
		color_rect.visible = true
		
		# function implemented in cooldown_slot.gd
		_item_inventory.item_used.connect(_on_item_used)
		_item_inventory.item_consumed.connect(_on_item_consumed)


func _on_item_used() -> void:
	# TODO: update UI display for number of charges remaining
	pass


func _on_item_consumed() -> void:
	texture_rect.texture = null
	color_rect.visible = false
