class_name InventorySlot
extends PanelContainer

var _item_inventory: ItemInventory

@onready var texture_rect: TextureRect = $TextureRect

func _ready() -> void:
	# emitted by ItemWorld when player picks up an item
	SignalBus.item_picked_up.connect(_on_item_picked_up)


func _on_item_picked_up(item_inventory: ItemInventory) -> void:
	_item_inventory = item_inventory
	# update UI image to match item
	texture_rect.texture = _item_inventory.texture
