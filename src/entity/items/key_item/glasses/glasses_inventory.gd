extends KeyItemInventory

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	world_resource = load("res://src/entity/items/key_item/glasses/glasses_world.tscn")
	display_name = "Glasses"
	description = ("Your grandfather's reading glasses he sent you to fetch.")
