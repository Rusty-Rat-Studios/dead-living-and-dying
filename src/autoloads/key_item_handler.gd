extends Node

var _key_item: ItemWorld
var _display_name: String

# needed when loading the game scene
func register_key_item(key_item: ItemWorld) -> void:
	_key_item = key_item
	
	# initialize display name
	var dummy: KeyItemInventory = _key_item.inventory_resource.instantiate()
	dummy._ready()
	_display_name = dummy.display_name
	dummy.queue_free()


# globally access to Key Item node
func get_key_item() -> ItemWorld:
	return _key_item


func get_display_name() -> String:
	return _display_name
