class_name KeyItemInventory
extends ItemInventory


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	world_resource = preload("res://src/entity/items/key_item/key_item_world.tscn")
	
	display_name = "#1 Key Item"


func drop() -> void:
	SignalBus.key_item_dropped.emit()
	queue_free()
