class_name InventorySlot
extends PanelContainer

var _item_inventory: ItemInventory

@onready var texture_rect: TextureRect = $TextureRect
@onready var color_rect: ColorRect = $ColorRect

func _ready() -> void:
	# emitted by ItemWorld when player picks up an item
	SignalBus.item_picked_up.connect(_on_item_picked_up)


# implemented by final inheritors including type-checking for
# what kind of item was picked up - replace particular slots
func _on_item_picked_up(_item_inventory: ItemInventory, _current_consumable: bool = false) -> void:
	push_error("AbstractMethodError: function _on_item_picked_up called from base class")
