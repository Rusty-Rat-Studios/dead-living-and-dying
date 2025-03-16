extends HBoxContainer

@export var slot_resource: Resource = preload("res://src/ui/inventory/passive_slot.tscn")


func _ready() -> void:
	
	SignalBus.item_picked_up.connect(_on_item_picked_up)


func _on_item_picked_up(item_inventory: ItemInventory, _current_consumable: bool = false) -> void:
	if item_inventory is not PassiveItemInventory:
		return
	
	var passive_slot: PassiveSlot = slot_resource.instantiate()
	add_child(passive_slot)
	passive_slot._item_inventory = item_inventory
	passive_slot.texture_rect.texture = passive_slot._item_inventory.texture
