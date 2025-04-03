class_name KeyItemInventory
extends ItemInventory


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass


func drop() -> void:
	SignalBus.key_item_dropped.emit()
	queue_free()
