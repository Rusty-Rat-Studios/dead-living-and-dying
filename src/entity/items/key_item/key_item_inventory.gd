class_name KeyItemInventory
extends ItemInventory


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass


func drop() -> void:
	var key_item: KeyItemWorld = KeyItemHandler.get_key_item()
	# add key item as child of the player's current room
	PlayerHandler.get_current_room().add_child(key_item)
	key_item.visible = true
	
	# update key item position to be directly matching the player position
	key_item.global_position = PlayerHandler.get_player().global_position
	key_item.global_position.y = 1
	
	# update key item movement path with world-grid find_shortest_path algorithm
	key_item.movement_path = PlayerHandler.get_current_room().get_parent().find_shortest_path(key_item.get_parent(), key_item.starting_room)
	SignalBus.key_item_dropped.emit()
	queue_free()
