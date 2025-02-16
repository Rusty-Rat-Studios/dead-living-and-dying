extends CooldownSlot


func _on_item_picked_up(item_inventory: ItemInventory) -> void:
	super(item_inventory)
	
	if item_inventory is DefenseItemInventory:
		_item_inventory.item_used.connect(_on_item_used)
