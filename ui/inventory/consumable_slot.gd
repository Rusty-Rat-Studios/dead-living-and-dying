extends InventorySlot

var count: int

@onready var label: Label = $Label
@onready var color_rect: ColorRect = $ColorRect

func _on_item_picked_up(item_inventory: ItemInventory, current_consumable: bool = false) -> void:
	if item_inventory is ConsumableItemInventory and current_consumable == false:
		_item_inventory = item_inventory
		# update UI image to match item
		texture_rect.texture = _item_inventory.texture
		color_rect.visible = true
		count = item_inventory.count
		label.text = str(count)
		
		# function implemented in cooldown_slot.gd
		_item_inventory.item_used.connect(_on_item_used)
	elif item_inventory is ConsumableItemInventory and current_consumable == true:
		count += 1
		label.text = str(count)


func _on_item_used() -> void:
	count -= 1
	if (count == 0):
		color_rect.visible = false
		texture_rect.texture = null
		label.text = ""
	else:
		label.text = str(count)
