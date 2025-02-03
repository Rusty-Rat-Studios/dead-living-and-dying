class_name KeyItemInventory
extends ItemInventory

# TODO: update and apply to relevant value
# could be ghost aggression
# could be player light range
const DEBUFF_MODIFIER: float = 0.25


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	world_resource = preload("res://items/key_item/key_item_world.tscn")


func drop() -> void:
	# KeyItemWorld sets its starting position from the value saved in game.gd
	# when _ready is called -> i.e. after .instantiate()
	var world_item: ItemWorld = world_resource.instantiate()
	get_node("/root/Game").add_child(world_item)
	queue_free()
