extends InventorySlot

var count: int

@onready var label: Label = $MarginContainer/Label
@onready var color_rect: ColorRect = $MarginContainer/ColorRect


func _ready() -> void:
	super()
	# set icon according to input map
	_input_event = "use_consumable_item"
	$MarginIcon/IconLabel.init("use_consumable_item")


func _on_item_picked_up(item_inventory: ItemInventory, current_consumable: bool = false,
						_current_count: int = 0) -> void:
	if item_inventory is ConsumableItemInventory and current_consumable == false:
		_item_inventory = item_inventory
		# update UI image to match item
		texture_rect.texture = _item_inventory.texture
		color_rect.visible = true
		count = item_inventory.count
		label.text = str(count)
		
		# function implemented in cooldown_slot.gd
		_item_inventory.item_used.connect(_on_item_used)
		_item_inventory.count_update.connect(_on_count_update)
	elif item_inventory is ConsumableItemInventory and current_consumable == true:
		texture_rect.texture = _item_inventory.texture
		color_rect.visible = true
		count = item_inventory.MAX_COUNT
		label.text = str(count)


func _on_item_used() -> void:
	count -= 1
	if (count == 0):
		color_rect.visible = false
		texture_rect.texture = null
		label.text = ""
	else:
		label.text = str(count)


func _on_count_update(new_count: int) -> void:
	count = new_count
	label.text = str(count)
