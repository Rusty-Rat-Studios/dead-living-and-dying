class_name InventorySlot
extends PanelContainer

var _item_inventory: ItemInventory
# set by inherited nodes to specify which input action they act on
# - needed for catching signal "icon_map_changed" to update icon
var _input_event: String

@onready var texture_rect: TextureRect = $MarginContainer/TextureRect

func _ready() -> void:
	# emitted by ItemWorld when player picks up an item
	SignalBus.item_picked_up.connect(_on_item_picked_up)
	UIDevice.icon_map_changed.connect(_on_icon_map_changed)


# implemented by final inheritors including type-checking for
# what kind of item was picked up - replace particular slots
func _on_item_picked_up(_item_inventory: ItemInventory, _current_consumable: bool = false,
						_current_count: int = 0) -> void:
	push_error("AbstractMethodError: function _on_item_picked_up called from base class")


func _on_icon_map_changed() -> void:
	if _input_event:
		$MarginIcon/IconLabel.update(_input_event)
