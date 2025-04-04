extends CooldownSlot


func _ready() -> void:
	super()
	# set icon according to input map
	_input_event = "use_defense_item"
	$MarginIcon/IconLabel.init(_input_event)


func _on_item_picked_up(item_inventory: ItemInventory, _current_consumable: bool = false, _current_count: int = 0) -> void:
	if item_inventory is DefenseItemInventory:
		_item_inventory = item_inventory
		# update UI image to match item
		texture_rect.texture = _item_inventory.texture
		
		# function implemented in cooldown_slot.gd
		_item_inventory.item_used.connect(_on_item_used)
