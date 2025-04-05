class_name ConsumableItemWorld
extends ItemWorld

# for keeping track of count on dropped items
var count: int = 3


func pick_up() -> void:
	if inventory_resource == null:
		#gdlint:ignore=max-line-length
		push_error("AbstractVariableError: ItemWorld base class function pick_up() called without initializing variable 'inventory_resource'")
		return
	
	# emits a signal caught by the player who then adds a child
	# of the inventory resource version to its $Inventory node
	var item_inventory: ItemInventory = inventory_resource.instantiate()
	var player: Node = PlayerHandler.get_player()
	var current_consumable: bool = false
	item_inventory.texture = $Sprite3D.texture
	for n: Node in player.get_node("Inventory").get_children():
		if n is ConsumableItemInventory and n.CONSUMABLE_ID == item_inventory.CONSUMABLE_ID:
			current_consumable = true
			if n.count + count >= n.MAX_COUNT:
				count = count - (n.MAX_COUNT - n.count)
				n.count = n.MAX_COUNT
				n.ui_update()
			else:
				n.count += count
				count = 0
			if count == 0:
				queue_free()
			return
		elif n is ConsumableItemInventory:
			n.drop()
	SignalBus.item_picked_up.emit(item_inventory, current_consumable, count)
	queue_free()
	return
