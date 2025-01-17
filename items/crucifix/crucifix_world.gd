extends ItemWorld


func _ready() -> void:
	super()
	inventory_resource = preload("res://items/crucifix/crucifix_inventory.tscn")
